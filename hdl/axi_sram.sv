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

`timescale 1ns/1ps

module axi_sram(
	input clk,
	axi_ifc.slave s
	);

// inherit configuration from AXI interface
// sadly this does not work with localparam (at least in verilator)
`define IWIDTH $bits(s.awid)
`define AWIDTH $bits(s.awaddr)
`define DWIDTH $bits(s.wdata)
`define LWIDTH $bits(s.awlen)

// LIMITATIONS / TODO
// - only supports INCR bursts (and treats all bursts as INCR type)
// - investigate raising BVALID earlier to possibly save a cycle at EOB

typedef enum reg[1:0] { W_IDLE, W_DATA, W_ACK } wstate_t;
wstate_t wstate = W_IDLE;
wstate_t next_wstate;

wire do_mem_wr;

reg [`IWIDTH-1:0]next_bid;
reg next_awready;
reg next_wready;
reg next_bvalid;

reg [`AWIDTH-1:0]waddr = 0;
reg [`AWIDTH-1:0]next_waddr;

wire [`AWIDTH-1:0]waddr_plus_four;
assign waddr_plus_four = waddr + 32'h4;

assign do_mem_wr = s.wvalid & s.wready;

always_comb begin
	next_wstate = wstate;
	next_waddr = waddr;
	next_bid = s.bid;
	next_awready = 0;
	next_wready = 0;
	next_bvalid = 0;
	case (wstate)
	W_IDLE: begin
		if (s.awvalid & s.awready) begin
			next_waddr = s.awaddr;
			next_bid = s.awid;
			next_wstate = W_DATA;
			next_wready = 1;
		end else begin
			next_awready = 1;
		end
	end
	W_DATA: begin
		if (s.wvalid) begin
			next_waddr = waddr_plus_four;
			if (s.wlast) begin
				next_wstate = W_ACK;
				next_bvalid = 1;
			end else begin
				next_wready = 1;
			end
		end else begin
			next_wready = 1;
		end
	end
	W_ACK: begin
		if (s.bready) begin
			next_wstate = W_IDLE;
			next_waddr = s.awaddr;
			next_awready = 1;
		end else begin
			next_bvalid = 1;
		end
	end
	default: next_wstate = W_IDLE;
	endcase
end

typedef enum reg[0:0] { R_IDLE, R_DATA } rstate_t;
rstate_t rstate = R_IDLE;
rstate_t next_rstate;

reg [`IWIDTH-1:0]next_rid;
reg next_arready;
reg next_rvalid;
reg next_rlast;

reg [`LWIDTH-1:0]rcount = 0;
reg [`LWIDTH-1:0]next_rcount;
reg [`AWIDTH-1:0]raddr = 0;
reg [`AWIDTH-1:0]next_raddr;

wire [`AWIDTH-1:0]raddr_plus_four;
assign raddr_plus_four = raddr + 32'h4;

wire rcount_is_zero;
assign rcount_is_zero = (rcount == 0);

wire rcount_is_one;
assign rcount_is_one = (rcount == 1);

always_comb begin
	next_rstate = rstate;
	next_raddr = raddr;
	next_rid = s.rid;
	next_rcount = rcount;
	next_arready = 0;
	next_rvalid = 0;
	next_rlast = 0;
	case (rstate)
	R_IDLE: begin
		if (s.arready & s.arvalid) begin
			next_rstate = R_DATA;
			next_raddr = s.araddr;
			next_rid = s.arid;
			next_rcount = s.arlen;
			next_rvalid = 1;

			// special case for 1-beat bursts
			if (s.arlen == 0)
				next_rlast = 1;
		end else begin
			next_arready = 1;
		end
	end
	R_DATA: begin
		if (s.rready & s.rvalid) begin
			next_raddr = raddr_plus_four;
			next_rcount = rcount - 1;
			if (rcount_is_zero) begin
				next_rstate = R_IDLE;
				next_arready = 1;
			end else begin
				if (rcount_is_one)
					next_rlast = 1;
				next_rvalid = 1;
			end
		end else begin
			if (rcount_is_zero)
				next_rlast = 1;
			next_rvalid = 1;
		end
	end
	endcase
end

assign s.bresp = 0; // always OK
assign s.rresp = 0; // always OK

always_ff @(posedge clk) begin
	wstate <= next_wstate;
	waddr <= next_waddr;
	s.awready <= next_awready;
	s.wready <= next_wready;
	s.bvalid <= next_bvalid;
	s.bid <= next_bid;

	rstate <= next_rstate;
	raddr <= next_raddr;
	rcount <= next_rcount;
	s.arready <= next_arready;
	s.rvalid <= next_rvalid;
	s.rlast <= next_rlast;
	s.rid <= next_rid;
end

// --- sram ----

reg [`DWIDTH-1:0]memory[0:4095];

always @(posedge clk) begin
	if (do_mem_wr) begin
		$display("mem[%x] = %x", waddr, s.wdata);
		memory[waddr[13:2]] <= s.wdata;
	end
	//TODO: only when needed:
	s.rdata <= memory[next_raddr[13:2]];
end

endmodule
