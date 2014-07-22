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

reg do_read = 0;
reg do_write = 0;
reg [31:0]txdata = 32'h80AA0123;
wire [15:0]rxdata;
wire busy;
wire o_dat;
wire t_dat;
wire o_clk;
reg i_raw = 0;
wire i_dat = t_dat ? i_raw : o_dat;

eth_mdio mdio0(
	.clk(clk),
	.do_read(do_read),
	.do_write(do_write),
	.txdata(txdata),
	.rxdata(rxdata),
	.busy(busy),
	.i_mdio(i_dat),
	.o_mdio(o_dat),
	.t_mdio(t_dat),
	.mdc(o_clk)
	);

integer count = 0;
reg next_rd;
reg next_wr;

always_comb begin
	next_rd = 0;
	next_wr = 0;
	if (count == 32768) $finish;
	if (count == 32) next_rd = 1;
end

always @(posedge clk) begin
	count <= count + 1;
	do_read <= next_rd;
	do_write <= next_wr;
end

endmodule
