// Copyright 2014 Brian Swetland <swetland@frotz.net>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

`timescale 1ns / 1ps

module eth_capture(
	// interface from eth_rmii_rx 
	input clk50,
	input rxsop,
	input rxeop,
	input [7:0]rxdata,
	input rxvalid,

	// interface to axi
	input clk,
	input reset,
	input enable,
	axi_ifc.master axi_dma
	);

parameter BASE_ADDR = 32'h10000000;

wire active;
sync_oneway sync_enable(
	.txclk(clk),
	.txdat(enable),
	.rxclk(clk50),
	.rxdat(active)
	);

wire [31:0]w_data;
wire w_valid;
wire w_eop;
wire [11:0]bytecount;

reg [63:0]clk50_count = 0;
reg [63:0]rxtimestamp = 0;
always @(posedge clk50) begin
	clk50_count <= clk50_count + 1;
	if (rxsop) begin
		rxtimestamp <= clk50_count;
	end
end

pkt_bytes_to_words cap0(
	.clk(clk50),
	.rxdata(rxdata),
	.rxvalid(rxvalid & active),
	.rxeop(rxeop & active),
	.data(w_data),
	.bytecount(bytecount),
	.eop(w_eop),
	.valid(w_valid)
	);

typedef enum { DATA, EOP0, EOP1, EOP2 } state_t;
state_t state = DATA;
state_t next_state;

reg [19:0]cfifo_in = 0;
reg [31:0]dfifo_in = 0;
reg [19:0]next_cfifo_in;
reg [31:0]next_dfifo_in;
reg cfifo_wr = 0;
reg dfifo_wr = 0;
reg next_cfifo_wr;
reg next_dfifo_wr;
reg [3:0]dcount = 15;
reg [3:0]next_dcount;

// ADDR: window(10) packet(10) chunk(6) off(6)
reg [9:0]dbase = 0;
reg [9:0]next_dbase;
reg [5:0]daddr = 1;
reg [5:0]next_daddr;

wire [3:0]dcount_plus_one = (dcount + 1);

always_comb begin
	next_state = state;
	next_dcount = dcount;
	next_daddr = daddr;
	next_dbase = dbase;
	next_cfifo_in = cfifo_in;
	next_dfifo_in = dfifo_in;
	next_cfifo_wr = 0;
	next_dfifo_wr = 0;
	case (state)
	DATA: begin
		if (w_valid) begin
			next_dcount = dcount_plus_one;
			next_dfifo_in = w_data;
			next_dfifo_wr = 1;
			if (dcount_plus_one == 15) begin
				next_cfifo_in = { 4'd15, dbase, daddr };
				next_cfifo_wr = 1;
				next_daddr = daddr + 1;
			end
		end else if (w_eop) begin
			next_state = EOP0;
			next_dfifo_in = { 20'h00000, bytecount };
			next_dfifo_wr = 1;
			if (dcount != 15) begin
				next_cfifo_in = { dcount, dbase, daddr };
				next_cfifo_wr = 1;
			end
		end
	end
	EOP0: begin
		next_state = EOP1;
		next_dfifo_in = rxtimestamp[31:0];
		next_dfifo_wr = 1;
	end
	EOP1: begin
		next_state = EOP2;
		next_dfifo_in = rxtimestamp[63:32];
		next_dfifo_wr = 1;
	end
	EOP2: begin
		next_state = DATA;
		next_dcount = 15;
		next_daddr = 1;
		next_dbase = dbase + 1;
		next_dfifo_in = 32'h00000001; // status
		next_dfifo_wr = 1;
		next_cfifo_in = { 4'd3, dbase, 6'd0 };
		next_cfifo_wr = 1;
	end
	endcase
end

always_ff @(posedge clk50) begin
	state <= next_state;
	dcount <= next_dcount;
	daddr <= next_daddr;
	dbase <= next_dbase;
	cfifo_in <= next_cfifo_in;
	dfifo_in <= next_dfifo_in;
	cfifo_wr <= next_cfifo_wr;
	dfifo_wr <= next_dfifo_wr;
end

reg fifo_reset = 0;

wire [31:0]dfifo_data;
wire dfifo_rd;
wire dfifo_empty;
wire dfifo_active;

wire [19:0]cfifo_data;
reg cfifo_rd = 0;
wire cfifo_empty;
wire cfifo_active;

// on reset request, assert fifo_reset until both fifos
// have started the sequence (fifo_active=0)
always @(posedge clk) begin
	if (dfifo_active & cfifo_active) begin
		if (reset) begin
			fifo_reset <= 1;
		end
	end else if (~dfifo_active & ~cfifo_active) begin
		fifo_reset <= 0;
	end
end

// CMD:   wrstatus wrdata count(12)
xilinx_async_fifo #(
	.WIDTH(32)
	) dfifo (
	.wrclk(clk50),
	.rdclk(clk),
	.reset(fifo_reset),
	.wr_data(dfifo_in),
	.wr_en(dfifo_wr),
	.rd_en(dfifo_rd),
	.rd_data(dfifo_data),
	.o_empty(dfifo_empty),
	.o_ready(),
	.o_active(dfifo_active)
	);

// CMD: burst(4) addr(16)  -- addr is A[21:6]

xilinx_async_fifo #(
	.WIDTH(20)
	) cfifo ( 
	.wrclk(clk50),
	.rdclk(clk),
	.reset(fifo_reset),
	.wr_data(cfifo_in),
	.wr_en(cfifo_wr),
	.rd_en(cfifo_rd),
	.rd_data(cfifo_data),
	.o_empty(cfifo_empty),
	.o_ready(),
	.o_active(cfifo_active)
	);

reg [31:0]dma_base = BASE_ADDR;

wire [31:0]dma_addr = { dma_base[31:22], cfifo_data[15:0], 6'd0 };
wire [3:0]dma_len = cfifo_data[19:16];
wire dma_start = (~cfifo_empty) & (~dma_busy);
wire dma_busy;

always @(posedge clk) begin
	if (cfifo_active & dfifo_active) begin
		if (dma_start) begin
			cfifo_rd <= 1;
		end else begin
			cfifo_rd <= 0;
		end
	end
end

axi_dma_writer dma0(
	.clk(clk),
	.m(axi_dma),
	.addr(dma_addr),
	.burstlen(dma_len),
	.start(dma_start),
	.busy(dma_busy),
	.data(dfifo_data),
	.advance(dfifo_rd)
	);

endmodule
