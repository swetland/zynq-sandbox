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

// connects a rmii_rx to an rmii_tx through a small fifo

module eth_rmii_bridge(
	input clk,

	input rxvalid,
	input [7:0]rxdata,
	input rxeop,

	output reg txpacket = 0,
	output [7:0]txdata,
	input txadvance,
	input txbusy
	);

wire fifo_valid;
wire [8:0]fifo_rdata;
reg fifo_rd;
reg fifo_err;

reg txpacket = 0;
reg next_txpacket;

assign txdata = fifo_rdata[7:0];

always_comb begin
	next_txpacket = txpacket;
	fifo_rd = 0;
	fifo_err = 0;
	if (fifo_valid) begin
		if (txpacket == 0) begin
			// not transmitting, new SOP
			if (txbusy == 0) begin
				next_txpacket = 1;
			end
		end else if (fifo_rdata[8]) begin
			// EOP terminates transmit
			next_txpacket = 0;
			fifo_rd = 1;
		end else if (txadvance) begin
			fifo_rd = 1;
		end
	end else begin
		fifo_rd = 1;
		if (txadvance) fifo_err = 1;
	end
end

always @(posedge clk) begin
	txpacket <= next_txpacket;
end


simple_fifo #(.WIDTH(9)) fifo0(
	.clk(clk),
	.wr(rxvalid | rxeop),
	.wdata({rxeop,rxdata}),
	.rd(fifo_rd),
	.rdata(fifo_rdata),
	.rvalid(fifo_valid),
	.not_empty(),
	.not_full()
	);

endmodule
