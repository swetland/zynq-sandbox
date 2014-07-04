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

`timescale 1ns/1ps

// reset in synchronous with wrclk
// on reset=1, active will go low on the next clock
// active will return high once the reset is complete
// reset will take a bit longer than 12 wrclk or rdclk
// (whichever is slower)

(* keep_hierarchy = "yes" *)
module xilinx_async_fifo(
	input wrclk,
	input rdclk,
	input reset,

	input [WIDTH-1:0]wr_data,
	input wr_en,

	input rd_en,
	output [WIDTH-1:0]rd_data,

	output o_empty,
	output o_ready, // can absorb >= 16 writes
	output o_active
	);

parameter WIDTH = 16;

wire fifo_res, fifo_act;

fifo_reset fifo_reset_0(
	.clk1(wrclk),
	.i_res(reset),
	.clk2(rdclk),
	.o_res(fifo_res),
	.o_act(fifo_act)
	);

wire [31:0]do_data, di_data;
wire almostfull;
assign o_ready = ~almostfull;

assign o_active = fifo_act;
assign rd_data = do_data[WIDTH-1:0];
assign di_data[WIDTH-1:0] = wr_data;

FIFO18E1 #(
	.ALMOST_EMPTY_OFFSET(13'h80),
	.ALMOST_FULL_OFFSET(13'h80), // TODO
	.DATA_WIDTH(36),
	.DO_REG(1),
	.EN_SYN("FALSE"),
	.FIFO_MODE("FIFO18_36"),
	.FIRST_WORD_FALL_THROUGH("TRUE"),
	.INIT(32'h0),
	.SIM_DEVICE("7SERIES"),
	.SRVAL(36'h0)
	) fifo (
	.DO(do_data),
	.DOP(),
	.ALMOSTEMPTY(),
	.ALMOSTFULL(almostfull),
	.EMPTY(o_empty),
	.FULL(),
	.RDCOUNT(),
	.RDERR(),
	.WRCOUNT(),
	.WRERR(),
	.RDCLK(rdclk),
	.RDEN(fifo_act & rd_en),
	.RST(fifo_res),
	.WRCLK(wrclk),
	.WREN(fifo_act & wr_en),
	.DI(di_data),
	.DIP(),
	.REGCE(),
	.RSTREG()
	);

endmodule


// on i_res (sync w/ clk1):
//   1. o_res will go high, i_act will go low
//   2. after at least 6 cycles of clk1 and clk2, o_res will go high
//   2. after at least 6 more cycles of clk1 and clk2, o_act will go high

(* keep_hierarchy = "yes" *)
module fifo_reset(
	input clk1,
	input clk2,
	input i_res,
	output reg o_res = 0,
	output reg o_act = 1
	);

typedef enum { IDLE, RESET0, RESET1, WAIT } state_t;
state_t state1 = IDLE;
state_t next_state1;
reg [5:0]shift1 = 0;
reg [5:0]next_shift1;

// signal from clk1 domain to clk2
reg dat = 0;
reg next_dat;

reg next_res;
reg next_act;

// return from clk2 domain (after 6bit sr)
reg ack;

always_comb begin
	next_state1 = state1;
	next_shift1 = shift1;
	next_dat = dat;
	next_res = o_res;
	next_act = o_act;
	case (state1)
	IDLE: begin
		if (i_res) begin
			next_act = 0;
			next_state1 = RESET0;
		end
	end
	RESET0: begin
		next_res = 1;
		next_state1 = RESET1;
		next_shift1 = 6'b111111;
		next_dat = 1;
	end
	RESET1: begin
		next_shift1 = { 1'b0, shift1[5:1] };
		if ((shift1[0] == 0) && (ack==1)) begin
			next_res = 0;
			next_state1 = WAIT;
			next_dat = 0;
			next_shift1 = 6'b111111;
		end
	end
	WAIT: begin
		next_shift1 = { 1'b0, shift1[5:1] };
		if ((shift1[0] == 0) && (ack==0)) begin
			next_act = 1;
			next_state1 = IDLE;
		end
	end
	endcase
end

always_ff @(posedge clk1) begin
	state1 <= next_state1;
	shift1 <= next_shift1;
	dat <= next_dat;
	o_res <= next_res;
	o_act <= next_act;
end

wire shift2_in;
reg [5:0]shift2 = 0;

always @(posedge clk2)
	shift2 <= { shift2_in, shift2[5:1] };

sync_oneway sync0(
	.txclk(clk1),
	.txdat(dat),
	.rxclk(clk2),
	.rxdat(shift2_in)
	);

sync_oneway sync1(
	.txclk(clk2),
	.txdat(shift2[0]),
	.rxclk(clk1),
	.rxdat(ack)
	);

endmodule
