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
 *     o_rd is strobed, and i_rdata is captured on the next clock
 *
 *  - to write a register via JTAG:
 *    - shift in {1, addr, data}, UPDATE
 *
 *  - to read a register via JTAG:
 *    - shift in {0, addr, dontcare}, UPDATE
 *    - data will be returned on next read or write
 * 
 *  - data read back via JTAG will be {1, addr, data}
 *    - addr is the last address read or written
 *    - data is the data that was read or written
 *    - high bit is one
 */

module jtag_debug_port(
	output reg o_rd,
	output reg o_wr,
	output [RBITS-1:0]o_addr,
	output [31:0]o_wdata,
	input [31:0]i_rdata,
	input clk
	);

parameter RBITS = 3;

wire capture, sel, shift;
wire tck, tdi, update;

reg [RBITS+32:0]data_sr;      // JTAG shift register
reg [RBITS+32:0]data_to_jtag; // captured on CAPTURE by sr
reg [RBITS+32:0]data_to_port; // captured on UPDATE from sr
reg [RBITS+32:0]data_to_jtag_next;
reg [RBITS+32:0]data_to_port_next;
reg o_rd_next;
reg o_wr_next;

assign o_wdata = data_to_port[31:0];
assign o_addr = data_to_port[RBITS+31:32];

wire do_txn;

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
	.TDO(data_sr[0])
	);
`endif

localparam STATE_IDLE = 0;
localparam STATE_READ = 1;
localparam STATE_READ2 = 2;
localparam STATE_WRITE = 3;

reg [1:0]state = STATE_IDLE;
reg [1:0]state_next;

always @(*) begin
	state_next = state;
	data_to_port_next = data_to_port;
	data_to_jtag_next = data_to_jtag;
	o_rd_next = 0;
	o_wr_next = 0;

	case (state)
	STATE_IDLE: begin
		if (do_txn) begin
			data_to_port_next = data_sr;
			if (data_sr[RBITS+32]) begin
				state_next = STATE_WRITE;
				o_wr_next = 1;
			end else begin
				state_next = STATE_READ;
				o_rd_next = 1;
			end
		end
	end
	STATE_READ: begin
		state_next = STATE_READ2;
	end
	STATE_READ2: begin
		state_next = STATE_IDLE;
		data_to_jtag_next = { 1'b1, data_to_port[RBITS+31:32], i_rdata };
	end	
	STATE_WRITE: begin
		state_next = STATE_IDLE;
		data_to_jtag_next = { 1'b1, data_to_port[RBITS+31:0] };
	end
	endcase
end	

always @(posedge clk) begin
	state <= state_next;
	data_to_port <= data_to_port_next;
	data_to_jtag <= data_to_jtag_next;
	o_rd <= o_rd_next;
	o_wr <= o_wr_next;
end

wire do_capture = sel & capture;
wire do_update = sel & update;
wire do_shift = sel & shift;

always @(posedge tck)
	if (do_capture)
		data_sr <= data_to_jtag;
	else if (do_shift)
		data_sr <= { tdi, data_sr[RBITS+32:1] };

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
