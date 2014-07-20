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

// 1. Asserting packet starts tx cycle.
// 2. Deasserting packet will cause tx cycle to complete after current byte
//    has completed transmission.
// 3. busy is asserted while a packet is in flight (and will remain asserted after
//    packet deasserts, until after inter-packet-gap (IPG) has completed).
// 4. advance is asserted when txdata is consumed

module eth_rmii_tx(
	input clk50,

	output tx0,
	output tx1,
	output reg txen = 0,

	input [7:0]data,
	input packet,
	output reg busy = 0,
	output reg advance = 0
	);

typedef enum {
	IDLE, PRE, DAT0, DAT1, DAT2, DAT3, EOP
} state_t;

state_t state = IDLE;
state_t next_state;

reg [7:0] txdata = 0;
reg [7:0] next_txdata;

wire [7:0]txshift = { 2'b0, txdata[7:2] };

reg [1:0]txd = 0;
reg [1:0]next_txd;

assign { tx1, tx0 } = txd;

reg [5:0] count = 0;
reg [5:0] next_count;

wire count_is_zero = (count == 0);

wire [5:0]count_minus_one = (count - 1);

reg next_txen;
reg next_advance;
reg next_busy;

always_comb begin
	next_state = state;
	next_count = count;
	next_txdata = txdata;
	next_busy = busy;
	next_txd = txd;
	next_txen = 1;
	next_advance = 0;

	case (state)
	IDLE: begin
		next_txen = 0;
		next_txd = 0;
		if (packet) begin
			next_state = PRE;
			next_count = 31;
			next_busy = 1;
		end
	end
	PRE: begin
		if (count_is_zero) begin
			next_state = DAT0;
			next_txdata = data;
			next_advance = 1;
			next_txd = 2'b11;
		end else begin
			next_txd = 2'b01;
			next_count = count_minus_one;
		end
	end
	DAT0: begin
		next_state = DAT1;
		next_txdata = txshift;
		next_txd = txdata[1:0];
	end
	DAT1: begin
		next_state = DAT2;
		next_txdata = txshift;
		next_txd = txdata[1:0];
	end
	DAT2: begin
		next_state = DAT3;
		next_txdata = txshift;
		next_txd = txdata[1:0];
	end
	DAT3: begin
		next_txd = txdata[1:0];
		if (~packet) begin
			// no more data, wrap it up
			next_state = EOP;
			next_count = 48;
		end else begin
			next_state = DAT0;
			next_txdata = data;
			next_advance = 1;
		end
	end
	EOP: begin
		next_txd = 0;
		next_txen = 0;
		if (count_is_zero) begin
			next_state = IDLE;
			next_busy = 0;
		end else begin
			next_count = count_minus_one;
		end
	end
	endcase
end

always_ff @(posedge clk50) begin
	state <= next_state;
	count <= next_count;
	txdata <= next_txdata;
	txen <= next_txen;
	txd <= next_txd;
	advance <= next_advance;
	busy <= next_busy;
end

endmodule
