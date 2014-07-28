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

// CRS_DV -- multiplexed, CR on first di-bit, DV on second di-bit of each nibble
//
//           preamble | packet 
// crs_dv ... 1 1 1 1 1 CR DV CR DV CR DV CR ...
// rx0    ... 0 0 0 0 1 b0 b2 b4 b6 b0 b2 b4 ...
// rx1    ... 1 1 1 1 1 b1 b3 b5 b7 b1 b3 b5 ...
//
// CR can go low when carrier lost, while DV remains asserted through end of frame.

// valid is asserted on each clock where data contains a byte of the frame
// eop is asserted for one clock after the last byte of the frame has arrived
// and before the next frame's first byte arrives

module eth_rmii_rx(
	input clk50,

	input [1:0]rx,
	input crs_dv,

	output reg [7:0]data = 0,
	output reg valid = 0,
	output reg eop = 0,

	// transmit outputs which can drive
	// an eth_rmii_tx to create a repeater
	output reg [1:0]out_tx = 0,
	output reg out_txen = 0,

	// start of packet strobe (for timestamping, etc)
	output reg sop = 0
	);

typedef enum {
	IDLE, PRE1, PRE2, PRE3,
        DAT0, DAT1, DAT2, DAT3,
	ERR0, ERR1, EOP
} state_t;

state_t state = IDLE;
state_t next_state;

reg [7:0]next_data;
reg next_valid;
reg next_eop;

wire [7:0]rxshift = { rx, data[7:2] };

reg [1:0]delay_tx = 0;
reg delay_txen = 0;
reg next_txen;
reg next_sop;

always_comb begin
	next_state = state;
	next_data = data;
	next_valid = 0;
	next_eop = 0;
	next_sop = 0;
	next_txen = delay_txen;

	case (state)
	IDLE: if ((rx == 2'b01) && (crs_dv == 1)) begin
		// crs_dv may go high asynchronously
		// only move to preamble on crs_dv AND a preamble di-bit
		next_state = PRE1;
		next_txen = 1;
		next_sop = 1;
	end
	PRE1: if (rx == 2'b01) begin
		next_state = PRE2;
	end else begin
		next_state = ERR0;
	end
	PRE2: if (rx == 2'b01) begin
		next_state = PRE3;
	end else begin
		next_state = ERR0;
	end
	PRE3: if (rx == 2'b11) begin
		next_state = DAT0;
	end else if (rx == 2'b01) begin
		next_state = PRE3;
	end else begin
		next_state = ERR0;
	end
	DAT0: begin
		next_data = rxshift;
		next_state = DAT1;
	end
	DAT1: begin
		next_data = rxshift;
		if (crs_dv) begin
			next_state = DAT2;
		end else begin
			next_txen = 0;
			next_state = EOP;
		end
	end
	DAT2: begin
		next_data = rxshift;
		next_state = DAT3;
	end
	DAT3: begin
		next_data = rxshift;
		if (crs_dv) begin
			next_state = DAT0;
			next_valid = 1;
		end else begin
			next_txen = 0;
			next_state = EOP;
		end
	end
	EOP: begin
		next_state = IDLE;
		next_data = 0;
		next_eop = 1;
	end
	ERR0: begin
		next_txen = 0;
		if (crs_dv == 0) begin
			next_state = ERR1;
		end
	end
	ERR1: begin
		if (crs_dv == 0) begin
			next_state = IDLE;
		end else begin
			next_state = ERR0;
		end
	end
	endcase
end

always_ff @(posedge clk50) begin
	state <= next_state;
	valid <= next_valid;
	data <= next_data;
	eop <= next_eop;
	sop <= next_sop;
	delay_txen <= next_txen;
	delay_tx <= rx;
	out_txen <= next_txen ? delay_txen : 0;
	out_tx <= next_txen ? delay_tx : 0;
end

endmodule
