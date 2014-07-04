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
	output [2:0]hdmi_d_p,
	output [2:0]hdmi_d_n,
	output hdmi_clk_p,
	output hdmi_clk_n
	);

wire pixclk, pixclkx5, pixclkx10;
wire [10:0] xpixel, ypixel;
reg [7:0] red, grn, blu;

mmcm_1in_3out #(
	.CLKIN_PERIOD(8.0),
	.VCO_MUL(36.000), 
	.VCO_DIV(5),
	.OUT0_DIV(20), // 45MHz
	.OUT1_DIV(4),  // 225MHz
	.OUT2_DIV(2)   // 450MHz
	) mmcm0 (
	.i_clk(clk),
	.o_clk0(pixclk),
	.o_clk1(pixclkx5),
	.o_clk2(pixclkx10)
	);

hdmi_core #(
	// 640x480 @60 25MHz
	//.HWIDTH(640), .HSYNC0(656), .HSYNC1(752), .HMAX(799),
	//.VHEIGHT(480), .VSYNC0(490), .VSYNC1(492), .VMAX(524)
	// 1280x720 @60 75MHz
	//.HWIDTH(1280), .HSYNC0(1320), .HSYNC1(1376). HMAX(1649),
	//.VHEIGHT(720), .VSYNC0(722), .VSYNC1(728), .VMAX(750)
	// 960x600 @60 45MHz
	.HWIDTH(960), .HSYNC0(1000), .HSYNC1(1100), .HMAX(1199),
	.VHEIGHT(600), .VSYNC0(613), .VSYNC1(620), .VMAX(624)
	) hdmi0 (
	.pixclk(pixclk),
	.pixclkx5(pixclkx5),
	.hdmi_d_p(hdmi_d_p),
	.hdmi_d_n(hdmi_d_n),
	.hdmi_clk_p(hdmi_clk_p),
	.hdmi_clk_n(hdmi_clk_n),
	.rgb_ready(),
	.red(red),
	.grn(grn),
	.blu(blu),
	.xpixel(xpixel),
	.ypixel(ypixel)
	);

// test pattern
always @(posedge pixclk) begin
	red <= xpixel[3] ? 8'hFF : 8'h00;
	grn <= ypixel[3] ? 8'hFF : 8'h00;
end

wire axiclk;

axi_ifc #(.IWIDTH(12),.AXI3(1)) axi_ctl();

zynq_ps7 zynq(
	.fclk0(axiclk),
	.m_axi_gp0_clk(axiclk),
	.m_axi_gp0(axi_ctl)
	);

wire [31:0]wdata;
wire [1:0]wreg;
wire wr;

axi_registers regs(
	.clk(axiclk),
	.s(axi_ctl),
	.o_rreg(),
	.o_wreg(wreg),
	.i_rdata(32'h12345678),
	.o_wdata(wdata),
	.o_rd(),
	.o_wr(wr)
	);

always @(posedge axiclk)
	if (wr)
		blu <= wdata[7:0];

endmodule
