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

module top(
	input clk,
	input [3:0]sw,
	input [3:0]btn,
	output reg [3:0]led = 0
	);

axi_ifc #(.IWIDTH(12),.AXI3(1)) axi_ctl();

wire fclk;
wire axiclk = clk;

zynq_ps7 zynq(
	.fclk0(fclk),
	.m_axi_gp0_clk(axiclk),
	.m_axi_gp0(axi_ctl)
	);

reg [31:0]dbg_reg = 32'haabbccdd;

wire [31:0]wdata;
reg [31:0]rdata;
wire [1:0]wreg;
wire [1:0]rreg;
wire wr;
wire rd;

axi_registers regs(
	.clk(axiclk),
	.s(axi_ctl),
	.o_rreg(rreg),
	.o_wreg(wreg),
	.i_rdata(rdata),
	.o_wdata(wdata),
	.o_rd(rd),
	.o_wr(wr)
	);

always_comb begin
	case (rreg)
	0: rdata = { 28'b0, sw };
	1: rdata = { 28'b0, btn };
	2: rdata = dbg_reg;
	3: rdata = 32'h12345678;
	endcase
end

always_ff @(posedge axiclk) begin
	if (wr) begin
		case (wreg)
		0: led <= wdata[3:0];
		1: ;
		2: dbg_reg <= wdata;
		3: ;
		endcase
	end
end

endmodule
