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

// on the clock where start=1
//   addr is the first address of the transfer
//   burstlen is the transfer wordcount minus 1
//   data is the first word of the transfer
// on the clock where advance=1
//   data advances to the next word of the transfer
// busy is asserted from the cycle after start until transfer complete

module axi_dma_writer(
	input clk,
	axi_ifc.master m,
	input start,
	input [31:0]addr,
	input [3:0]burstlen,
	input [31:0]data,
	output reg busy = 0,
	output advance
	);

localparam STATE_IDLE = 4'd0;
localparam STATE_WADDR = 4'd1;
localparam STATE_WDATA = 4'd2;
localparam STATE_ACK = 4'd3;

initial m.awvalid = 0;
initial m.wvalid = 0;

reg [31:0]waddr = 0;
reg [31:0]waddr_next;

reg [3:0]state = STATE_IDLE;
reg [3:0]state_next;

reg awvalid_next;
reg wvalid_next;
reg bready_next;
reg wlast_next;

reg [3:0]count = 15;
reg [3:0]count_next;

reg busy_next;

wire count_is_zero = (count == 4'h0);
wire count_is_one = (count == 4'h1);

assign advance = m.wvalid & m.wready & busy;

always_comb begin
	state_next = state;
	count_next = count;
	waddr_next = waddr;
	busy_next = busy;
	awvalid_next = 0;
	wvalid_next = 0;
	bready_next = 0;
	wlast_next = 0;

	case (state)
	STATE_IDLE: begin
		if (start) begin
			state_next = STATE_WADDR;
			count_next = burstlen;
			waddr_next = addr;
			busy_next = 1;
			awvalid_next = 1;
		end
	end
	STATE_WADDR: begin
		if (m.awready) begin
			state_next = STATE_WDATA;
			wvalid_next = 1;
			wlast_next = count_is_zero;
		end else begin
			awvalid_next = 1;
		end
	end
	STATE_WDATA: begin
		if (count_is_zero) begin
			if (m.wready) begin
				state_next = STATE_ACK;
				bready_next = 1;
			end else begin
				wvalid_next = 1;
				wlast_next = 1;
			end
		end else begin
			wvalid_next = 1;
			if (m.wready) begin
				if (count_is_one) begin
					wlast_next = 1;
				end
				count_next = count - 1;
			end
		end
	end
	STATE_ACK: begin
		if (m.bvalid) begin
			state_next = STATE_IDLE;
			busy_next = 0;
		end else begin
			bready_next = 1;
		end
	end
	default: state_next = STATE_IDLE;
	endcase
end

assign m.awid = 0;
assign m.awburst = 1;
assign m.awcache = 0;
assign m.awsize = 2;
assign m.awlen = count;
assign m.awlock = 0;

assign m.awaddr = waddr;
assign m.wdata = data;
assign m.wstrb = 4'b1111;

always_ff @(posedge clk) begin
	state <= state_next;
	count <= count_next;
	waddr <= waddr_next;
	busy <= busy_next;
	m.awvalid <= awvalid_next;
	m.wvalid <= wvalid_next;
	m.bready <= bready_next;
	m.wlast <= wlast_next;
end


assign m.arid = 0;
assign m.araddr = 0;
assign m.arvalid = 0;
assign m.arburst = 0;
assign m.arcache = 0;
assign m.arlen = 0;
assign m.arsize = 0;
assign m.arlock = 0;
assign m.rready = 0;

endmodule
