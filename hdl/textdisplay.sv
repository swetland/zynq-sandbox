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

module textdisplay(
	input pixclk,
	input [10:0]xpixel,
	input [10:0]ypixel,
	output reg pixel,

	input bufclk,
	input [11:0]bufaddr,
	input [7:0]bufdata,
	input bufwe
	);

wire [7:0]cdata;
wire [9:0]caddr;

wire [7:0]bdata;
wire [11:0]baddr;

assign baddr = { ypixel[9:4], xpixel[9:4] };
assign caddr = { bdata[6:0], ypixel[3:1] };

always_comb begin
	case (xpixel[3:1])
	0: pixel = cdata[7];
	1: pixel = cdata[6];
	2: pixel = cdata[5];
	3: pixel = cdata[4];
	4: pixel = cdata[3];
	5: pixel = cdata[2];
	6: pixel = cdata[1];
	7: pixel = cdata[0];
	endcase
end

// text ram
reg [7:0]buffer[0:4095];
always @(posedge bufclk)
	if (bufwe)
		buffer[bufaddr] <= bufdata;
assign bdata = buffer[baddr];

// character pattern rom
reg [7:0]chardata[0:1023];
initial $readmemh("chardata8x8.hex", chardata);
assign cdata = chardata[caddr];

endmodule
