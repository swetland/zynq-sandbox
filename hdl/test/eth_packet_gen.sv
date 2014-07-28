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



module eth_packet_gen(
	input clk50,
	output [1:0]data,
	output packet,
	input start,
	output reg done = 0
	);

parameter PACKET_COUNT = 5;
parameter PACKET_LENGTH = 145;

reg [8:0]pcount = PACKET_COUNT;
reg [11:0]plength = PACKET_LENGTH;
reg [11:0]bcount = 0;
reg active = 0;

reg txpacket = 0;
wire txbusy;
wire txadvance;

eth_rmii_tx tx0(
	.clk50(clk50),
	.tx(data),
	.txen(packet),
	.data(bcount[7:0]),
	.packet(txpacket),
	.busy(txbusy),
	.advance(txadvance)
	);

always @(posedge clk50) begin
	if (start) begin
		active <= 1;
	end
	if (txpacket) begin
		if (txadvance) begin
			if (bcount == (PACKET_LENGTH - 1)) begin
				txpacket <= 0;
				bcount <= 0;
			end else begin
				bcount <= bcount + 1;
			end
		end
	end else begin
		if (active && ~txbusy) begin
			if (pcount == 0) begin
				done <= 1;
			end else begin
				pcount <= pcount - 1;
				txpacket <= 1;
			end
		end
	end
end

endmodule
