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

// rvalid: indicates rd was successful and rdata contains the read data
// not_full: indicates that wr will be successful if attempted
// not_empty: indicates that rd will be successful if attempted

module simple_fifo(
	input clk,

	input wr,
	input [WIDTH-1:0]wdata,

	input rd,
	output [WIDTH-1:0]rdata,
	output reg rvalid = 0,

	output not_empty,
	output not_full
	);

parameter WIDTH = 8; // bit width of fifo entries
parameter DEPTH = 8; // fifo contains 2^DEPTH entries

reg memrd = 0;
reg memwr = 0;

reg [DEPTH:0]rdptr = 0;
reg [DEPTH:0]wrptr = 0;

reg [DEPTH:0]next_rdptr;
reg [DEPTH:0]next_wrptr;
reg next_rvalid;

wire [DEPTH:0]count = (wrptr - rdptr);
wire full = count[DEPTH];
wire empty = (count == 0);

wire [DEPTH-1:0]memraddr;
wire [WIDTH-1:0]memrdata;
wire [DEPTH-1:0]memwaddr;

assign not_full = ~full;
assign not_empty = ~empty;

wire do_rd = rd & not_empty;
wire do_wr = wr & not_full;

always_comb begin
	next_rdptr = rdptr;
	next_wrptr = wrptr;
	next_rvalid = rvalid;
	if (do_rd)
		next_rdptr = rdptr + 1;
	if (rd)
		next_rvalid = not_empty;
	if (do_wr)
		next_wrptr = wrptr + 1;
end
	
always_ff @(posedge clk) begin
	rdptr <= next_rdptr;
	wrptr <= next_wrptr;
	rvalid <= next_rvalid;
end

fifo_memory #(
	.WIDTH(WIDTH),
	.DEPTH(DEPTH)
	) memory(
	.clk(clk),
	.rd(do_rd),
	.raddr(rdptr[DEPTH-1:0]),
	.rdata(rdata),
	.wr(do_wr),
	.waddr(wrptr[DEPTH-1:0]),
	.wdata(wdata)
	);

endmodule

module fifo_memory(
	input clk,
	input rd,
	input [DEPTH-1:0]raddr,
	output reg [WIDTH-1:0]rdata,
	input wr,
	input [DEPTH-1:0]waddr,
	input [WIDTH-1:0]wdata
	);

parameter WIDTH = 8;
parameter DEPTH = 8;

reg [WIDTH-1:0]memory[0:(1<<DEPTH)-1];

always_ff @(posedge clk) begin
	if (rd)
		rdata <= memory[raddr];
	if (wr)
		memory[waddr] <= wdata;
end

endmodule 
