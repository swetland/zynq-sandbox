/* Copyright 2014 Brian Swetland <swetland@frotz.net>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

`timescale 1ns / 1ps

/* Exposes a 36bit register on JTAG USER4:
 *
 * 35                                  0
 *  CAAADDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
 *  |  |                               |
 *  |  addr                         data
 *  commit 
 *
 * - on JTAG UPDATE
 *   - if commit bit is set:
 *     bits 34:32 are presented on o_addr, 
 *     31:0 are presented on o_wdata,
 *     and o_wr is strobed
 *   - otherwise bits 34:32 are presented on o_addr,
 *     o_rd is strobed, and i_rdata is captured
 *
 *  - to write a register via JTAG:
 *    - shift in {1, addr, data}, UPDATE
 *
 *  - to read a register via JTAG:
 *    - shift in {0, addr, dontcare}, UPDATE
 *    - data will be returned on next read or write
 * 
 */
module xilinx_jtag_debugport (
	output o_rd,
	output o_wr,
	output [2:0]o_addr,
	output [31:0]o_wdata,
	input [31:0]i_rdata,
	input clk
	);

wire capture, sel, shift;
wire tck, tdi, update;

(* KEEP = "TRUE" *) reg [31:0] io = 32'd0;
(* KEEP = "TRUE" *) reg [35:0] data = 36'd0;

wire do_txn;
reg do_rd, do_wr;

assign o_wdata = io;
assign o_wr = do_wr;

assign o_addr = data[34:32];
assign o_rd = do_txn & (~data[35]);

`ifndef verilator
BSCANE2 #(
	.JTAG_CHAIN(4)
	) bscan (
	.CAPTURE(capture),
	.DRCK(),
	.RESET(),
	.RUNTEST(),
	.SEL(sel),
	.SHIFT(shift),
	.TCK(tck),
	.TDI(tdi),
	.TMS(),
	.UPDATE(update),
	.TDO(data[0])
	);
`endif

reg [31:0]io_next;
reg do_wr_next;
reg do_rd_next;

always @(*) begin
	io_next = io;
	do_wr_next = 1'b0;
	do_rd_next = 1'b0;
	if (do_txn) begin
		io_next = data[31:0];
		if (data[35])
			do_wr_next = 1'b1;
		else
			do_rd_next = 1'b1;
	end else if(do_rd) begin
		io_next = i_rdata;
	end
end

always @(posedge clk) begin
	io <= io_next;
	do_wr <= do_wr_next;
	do_rd <= do_rd_next;
end

wire do_capture = sel & capture;
wire do_update = sel & update;
wire do_shift = sel & shift;

always @(posedge tck)
	if (do_capture)
		data <= { 4'h0, io };
	else if (do_shift)
		data <= { tdi, data[35:1] };

sync s0(
	.clk_in(tck),
	.in(do_update),
	.clk_out(clk),
	.out(do_txn)
	);

endmodule


module sync(
	input clk_in,
	input clk_out,
	input in,
	output out
	);
reg toggle = 1'b0;
reg [2:0] sync = 3'b0;
always @(posedge clk_in)
	if (in) toggle <= ~toggle;
always @(posedge clk_out)
	sync <= { sync[1:0], toggle };
assign out = (sync[2] ^ sync[1]);
endmodule
