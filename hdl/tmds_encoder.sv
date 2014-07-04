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

/* verilator lint_off WIDTH */
module tmds_encoder(
	input clk,
	input [7:0]data,
	input [1:0]ctrl,
	input active,
	output reg [9:0]out
	);

reg [3:0]acc = 0;

wire [8:0]xo;
wire [8:0]xn;

assign xn[0] = data[0];
assign xn[1] = data[1] ~^ xn[0];
assign xn[2] = data[2] ~^ xn[1];
assign xn[3] = data[3] ~^ xn[2];
assign xn[4] = data[4] ~^ xn[3];
assign xn[5] = data[5] ~^ xn[4];
assign xn[6] = data[6] ~^ xn[5];
assign xn[7] = data[7] ~^ xn[6];
assign xn[8] = 0;

assign xo[0] = data[0];
assign xo[1] = data[1] ^ xo[0];
assign xo[2] = data[2] ^ xo[1];
assign xo[3] = data[3] ^ xo[2];
assign xo[4] = data[4] ^ xo[3];
assign xo[5] = data[5] ^ xo[4];
assign xo[6] = data[6] ^ xo[5];
assign xo[7] = data[7] ^ xo[6];
assign xo[8] = 1;

wire [3:0]ones = data[0] + data[1] + data[2] + data[3] + data[4] + data[5] + data[6] + data[7];

wire use_xn = ((ones > 4) | ((ones == 4) & (data[0] == 0)));

wire [8:0]tmp = use_xn ? xn : xo;
wire [3:0]tmp_ones = tmp[0]+tmp[1]+tmp[2]+tmp[3]+tmp[4]+tmp[5]+tmp[6]+tmp[7];

wire no_bias = (acc == 0) | (tmp_ones == 4);

wire same_sign = (acc[3] == tmp_ones[3]);

wire inv = no_bias ? (~tmp[8]) : same_sign;

wire [9:0]enc = { inv, tmp[8], inv ? ~tmp[7:0] : tmp[7:0] };
 
always @(posedge clk) begin
	if (active) begin
		out <= enc;
		acc = acc - 5 + enc[0]+enc[1]+enc[2]+enc[3]+enc[4]+enc[5]+enc[6]+enc[7]+enc[8]+enc[9];
	end else begin
		case (ctrl)
		2'b00: out <= 10'b1101010100;
		2'b01: out <= 10'b0010101011;
		2'b10: out <= 10'b0101010100;
		2'b11: out <= 10'b1010101011;
		endcase
		acc <= 0;
	end
end

endmodule
