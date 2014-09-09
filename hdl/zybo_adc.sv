// Copyright 2014 Travis Geiselbrecht <geist@foobox.com>
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
	input [3:0]ja_p,
	input [3:0]ja_n,
	output [3:0]jb_p,
	output [3:0]jb_n,
	output reg [3:0]led
	);

axi_ifc #(.IWIDTH(12),.AXI3(1)) axi_ctl();

wire fclk;
wire axiclk = clk; // 125Mhz clock from external ethernet phy

zynq_ps7 zynq(
	.fclk0(fclk),
	.m_axi_gp0_clk(axiclk),
	.m_axi_gp0(axi_ctl)
	);

wire vn = 0;
wire vp = 0;
wire [15:0] aux_channel_n;
wire [15:0] aux_channel_p;

assign aux_channel_n[14] = ja_n[0];
assign aux_channel_p[14] = ja_p[0];
assign aux_channel_n[7] = ja_n[1];
assign aux_channel_p[7] = ja_p[1];
assign aux_channel_n[15] = ja_n[2];
assign aux_channel_p[15] = ja_p[2];
assign aux_channel_n[6] = ja_n[3];
assign aux_channel_p[6] = ja_p[3];

wire [3:0] adc_debug_out;

xadc #(
	.CLKDIV(5)
)
adc(
	.clk(axiclk),
	.rst(btn[0]),

	.vn(vn),
	.vp(vp),
	.aux_channel_n(aux_channel_n),
	.aux_channel_p(aux_channel_p),

	.debug_out(adc_debug_out),

	.axi(axi_ctl)
);

assign jb_p = adc_debug_out;

/*
// debugging
assign led[0] = adc_eoc;
assign led[1] = adc_eos;
assign led[2] = adc_busy;

assign jb_p[0] = adc_eoc;
assign jb_p[1] = adc_eos;
assign jb_p[2] = rd;
*/

endmodule

// vim: set noexpandtab:
