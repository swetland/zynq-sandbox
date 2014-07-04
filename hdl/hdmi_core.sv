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

module hdmi_core (
	input pixclk,
	input pixclkx5,
	// TMDS33 outputs
	output [2:0]hdmi_d_p,
	output [2:0]hdmi_d_n,
	output hdmi_clk_p,
	output hdmi_clk_n,
	// RGB data input
	output rgb_ready,
	input [7:0]red,
	input [7:0]grn,
	input [7:0]blu,
	// core status
	output [10:0]xpixel,
	output [10:0]ypixel,
	output vblank
	);

parameter HWIDTH = 960;
parameter HSYNC0 = 1000;
parameter HSYNC1 = 1100;
parameter HMAX = 1199;
parameter VHEIGHT = 600;
parameter VSYNC0 = 613;
parameter VSYNC1 = 620;
parameter VMAX = 624;

reg [10:0] hcount, vcount;
reg hsync, vsync, active;

assign vblank = vsync;

always @(posedge pixclk) begin
	if (hcount == HMAX) begin
		hcount <= 0;
		if (vcount == VMAX) begin
			vcount <= 0;
		end else begin
			vcount <= vcount + 1;
		end
	end else begin
		hcount <= hcount + 1;
	end
	active <= (hcount < HWIDTH) && (vcount < VHEIGHT);
	hsync <= (hcount >= HSYNC0) && (hcount < HSYNC1);
	vsync <= (vcount >= VSYNC0) && (vcount < VSYNC1);
end

assign xpixel = hcount;
assign ypixel = vcount;
assign rgb_ready = active;

wire [9:0] ch0, ch1, ch2;

tmds_encoder enc2(
	.clk(pixclk),
	.data(red),
	.ctrl(0),
	.active(active),
	.out(ch2)
	);
tmds_encoder enc1(
	.clk(pixclk),
	.active(active),
	.data(grn),
	.ctrl(0),
	.out(ch1)
	);
tmds_encoder enc0(
	.clk(pixclk),
	.active(active),
	.data(blu),
	.ctrl({vsync,hsync}),
	.out(ch0)
	);

// does not reliably work on cold boot without reset/sync
reg [9:0]txrescnt = 0;
wire txres = (txrescnt[9:1] == 9'b100000000);
always @(posedge pixclk) begin
	if (txrescnt != 10'b1111111111) begin
		txrescnt <= txrescnt + 1;
	end
end

serdes_10to1_tx tx2(
	.clk(pixclk),
	.clkx5(pixclkx5),
	.reset(txres),
	.o_p(hdmi_d_p[2]),
	.o_n(hdmi_d_n[2]),
	.i_data(ch2)
	);

serdes_10to1_tx tx1(
	.clk(pixclk),
	.clkx5(pixclkx5),
	.reset(txres),
	.o_p(hdmi_d_p[1]),
	.o_n(hdmi_d_n[1]),
	.i_data(ch1)
	);

serdes_10to1_tx tx0(
	.clk(pixclk),
	.clkx5(pixclkx5),
	.reset(txres),
	.o_p(hdmi_d_p[0]),
	.o_n(hdmi_d_n[0]),
	.i_data(ch0)
	);

OBUFDS OBUFDS_clock(.I(pixclk), .O(hdmi_clk_p), .OB(hdmi_clk_n));

endmodule
