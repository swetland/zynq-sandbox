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

module axi_to_reg_x8(
	input clk,
	axi_ifc.slave axi,
	reg_ifc.master bank0,
	reg_ifc.master bank1,
	reg_ifc.master bank2,
	reg_ifc.master bank3,
	reg_ifc.master bank4,
	reg_ifc.master bank5,
	reg_ifc.master bank6,
	reg_ifc.master bank7
	);

localparam COUNT = 8;
localparam WIDTH = 20;

wire [WIDTH-1:0]rreg;
wire [WIDTH-1:0]wreg;
wire [31:0]rdata[0:COUNT-1];
wire [31:0]wdata;
wire rd[0:COUNT-1];
wire wr[0:COUNT-1];

axi_to_reg_impl #(
	.R_ADDR_WIDTH(20),
	.COUNT(8)
	) bridge_impl (
	.clk(clk),
	.s(axi),
	.o_rreg(rreg),
	.o_wreg(wreg),
	.o_rd(rd),
	.o_wr(wr),
	.i_rdata(rdata),
	.o_wdata(wdata)
	);

assign bank0.rd = rd[0];
assign bank0.wr = wr[0];
assign bank0.raddr = rreg[$bits(bank0.raddr)-1:0];
assign bank0.waddr = wreg[$bits(bank0.waddr)-1:0];
assign bank0.wdata = wdata[$bits(bank0.wdata)-1:0];
assign rdata[0] = { {32-$bits(bank0.rdata){1'b0}}, bank0.rdata };

assign bank1.rd = rd[1];
assign bank1.wr = wr[1];
assign bank1.raddr = rreg[$bits(bank1.raddr)-1:0];
assign bank1.waddr = wreg[$bits(bank1.waddr)-1:0];
assign bank1.wdata = wdata[$bits(bank1.wdata)-1:0];
assign rdata[1] = { {32-$bits(bank1.rdata){1'b0}}, bank1.rdata };

assign bank2.rd = rd[2];
assign bank2.wr = wr[2];
assign bank2.raddr = rreg[$bits(bank2.raddr)-1:0];
assign bank2.waddr = wreg[$bits(bank2.waddr)-1:0];
assign bank2.wdata = wdata[$bits(bank2.wdata)-1:0];
assign rdata[2] = { {32-$bits(bank2.rdata){1'b0}}, bank2.rdata };

assign bank3.rd = rd[3];
assign bank3.wr = wr[3];
assign bank3.raddr = rreg[$bits(bank3.raddr)-1:0];
assign bank3.waddr = wreg[$bits(bank3.waddr)-1:0];
assign bank3.wdata = wdata[$bits(bank3.wdata)-1:0];
assign rdata[3] = { {32-$bits(bank3.rdata){1'b0}}, bank3.rdata };

assign bank4.rd = rd[4];
assign bank4.wr = wr[4];
assign bank4.raddr = rreg[$bits(bank4.raddr)-1:0];
assign bank4.waddr = wreg[$bits(bank4.waddr)-1:0];
assign bank4.wdata = wdata[$bits(bank4.wdata)-1:0];
assign rdata[4] = { {32-$bits(bank4.rdata){1'b0}}, bank4.rdata };

assign bank5.rd = rd[5];
assign bank5.wr = wr[5];
assign bank5.raddr = rreg[$bits(bank5.raddr)-1:0];
assign bank5.waddr = wreg[$bits(bank5.waddr)-1:0];
assign bank5.wdata = wdata[$bits(bank5.wdata)-1:0];
assign rdata[5] = { {32-$bits(bank5.rdata){1'b0}}, bank5.rdata };

assign bank6.rd = rd[6];
assign bank6.wr = wr[6];
assign bank6.raddr = rreg[$bits(bank6.raddr)-1:0];
assign bank6.waddr = wreg[$bits(bank6.waddr)-1:0];
assign bank6.wdata = wdata[$bits(bank6.wdata)-1:0];
assign rdata[6] = { {32-$bits(bank6.rdata){1'b0}}, bank6.rdata };

assign bank7.rd = rd[7];
assign bank7.wr = wr[7];
assign bank7.raddr = rreg[$bits(bank7.raddr)-1:0];
assign bank7.waddr = wreg[$bits(bank7.waddr)-1:0];
assign bank7.wdata = wdata[$bits(bank7.wdata)-1:0];
assign rdata[7] = { {32-$bits(bank7.rdata){1'b0}}, bank7.rdata };

endmodule
