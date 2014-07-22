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

module eth_mdio(
	input clk,

	input do_read,
	input do_write,
	input [31:0]txdata,
	output [15:0]rxdata,
	output reg busy = 0,

	input i_mdio,
	output o_mdio,
	output t_mdio,
	output reg mdc = 0
	);

parameter CLKDIV = 16;

//       ST OP PHYAD REGAD TA DATA             IDLE
// PRE   11 11 11111 11111 11 1111111111111111 Z
// READ  01 10 AAAAA RRRRR Z0 DDDDDDDDDDDDDDDD Z    // 6
// WRITE 01 01 AAAAA RRRRR 10 DDDDDDDDDDDDDDDD Z    // 5

//                on phase entry:
//                -------------------------
//   .-----.      A mdc=0 shift (new data on o_mdio)
//   |     |      B mdc=1 capture=i_mdio
// --'     '--    C mdc=1
// A  B  C  D     D mdc=0 
//
// always: o_mdio=shift[31]

typedef enum { IDLE, PHA, PHB, PHC, PHD } state_t;
state_t state = IDLE;
state_t next_state;

reg next_busy;
reg next_mdc;

reg [31:0]shift = 0;
reg [31:0]next_shift;
reg [4:0]count = 0;
reg [4:0]next_count;
reg [7:0]clkcnt = 0;
reg [7:0]next_clkcnt;
reg capture0 = 0;
reg next_capture0;
reg capture1 = 0;
reg next_capture1;
reg tristate = 1;
reg next_tristate;
reg op_read = 0;
reg next_op_read;

reg step;

assign o_mdio = shift[31];
assign t_mdio = tristate;
assign rxdata = shift[15:0];

always_comb begin
	next_tristate = tristate;
	next_capture0 = capture0;
	next_capture1 = capture1;
	next_clkcnt = clkcnt;
	next_count = count;
	next_op_read = op_read;
	next_state = state;
	next_shift = shift;
	next_busy = busy;
	next_mdc = mdc;
	step = 0;

	// while txn active, count clocks and advance
	// phases every CLKDIV clocks
	if (busy) begin
		if (clkcnt == CLKDIV) begin
			next_clkcnt = 0;
			step = 1;
		end else begin
			next_clkcnt = clkcnt + 1;
			step = 0;
		end
		// debounce input
		next_capture0 = i_mdio;
	end

	case (state)
	IDLE: if (do_read | do_write) begin
		next_state = PHA;
		next_mdc = 0;
		next_busy = 1;
		next_tristate = 0;
		next_count = 31;
		next_shift = txdata;
		next_op_read = do_read;
	end
	PHA: if (step) begin
		next_state = PHB;
		next_mdc = 1;
		// acquire debounced input
		next_capture1 = capture0;
	end
	PHB: if (step) begin
		next_state = PHC;
		next_mdc = 1;
	end
	PHC: if (step) begin
		next_state = PHD;
		next_mdc = 0;
	end
	PHD: if (step) begin
		next_shift = { shift[30:0], capture1 };
		if (op_read & (count == 18)) begin
			next_tristate = 1;
		end
		if (count == 0) begin
			next_state = IDLE;
			next_tristate = 1;
			next_busy = 0;
		end else begin
			next_state = PHA;
			next_count = count - 1;
		end
	end
	default: next_state = IDLE;
	endcase
end

always_ff @(posedge clk) begin
	tristate <= next_tristate;
	capture0 <= next_capture0;
	capture1 <= next_capture1;
	op_read <= next_op_read;
	clkcnt <= next_clkcnt;
	state <= next_state;
	shift <= next_shift;
	count <= next_count;
	busy <= next_busy;
	mdc <= next_mdc;
end

endmodule

