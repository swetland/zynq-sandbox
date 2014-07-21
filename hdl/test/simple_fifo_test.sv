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

module testbench(input clk);

parameter WIDTH = 8;
parameter DEPTH = 4;

reg wr = 0;
reg rd = 0;
wire rvalid;
wire not_empty;
wire not_full;

wire [WIDTH-1:0]rdata;
reg  [WIDTH-1:0]wdata = 0;

simple_fifo #(
	.WIDTH(WIDTH),
	.DEPTH(DEPTH)
	) fifo (
	.clk(clk),
	.rd(rd),
	.wr(wr),
	.rdata(rdata),
	.wdata(wdata),
	.rvalid(rvalid),
	.not_empty(not_empty),
	.not_full(not_full)
	);

integer count = 0;

reg next_wr;
reg next_rd;
reg [WIDTH-1:0]next_wdata;

always_comb begin
	next_wr = 0;
	next_rd = 0;
	next_wdata = wdata;

	if (count == 10) begin
		next_wr = 1;
		next_wdata = 8'haa;
	end
	if (count == 11) begin
		next_wr = 1;
		next_wdata = 8'hbb;
	end
	if (count == 12) begin
		next_wr = 1;
		next_wdata = 8'hcc;
	end
	if (count == 20) begin
		next_wr = 1;
		next_wdata = 8'h42;
	end
	if (count > 30) begin
		next_wr = 1;
		next_wdata = 8'hee;
	end

	if ((count > 15) && (count < 25)) next_rd = 1;
	if (count == 50) next_rd = 1;
	if (count == 100) $finish;
end

always_ff @(posedge clk) begin
	count <= count + 1;
	rd <= next_rd;
	wr <= next_wr;
	wdata <= next_wdata;
end

endmodule
