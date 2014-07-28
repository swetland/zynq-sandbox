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


// converts packet bytestream to wordstream
//
// input: rxdata accepted when rxvalid=1
//        rxeop terminates stream
//        rxeop may not happen on same clock as rxvalid
// output: data and bytecount presented with valid=1
//         eop=1 indicates end of stream
//         eop and valid will not happen on the same clock

module pkt_bytes_to_words(
	input clk,
	input [7:0]rxdata,
	input rxvalid,
	input rxeop,

	output [31:0]data,
	output [11:0]bytecount,
	output reg valid = 0,
	output reg eop = 0
	);

typedef enum { IDLE, BYTE0, BYTE1, BYTE2, BYTE3, EOP } state_t;
state_t state = IDLE;
state_t next_state;

reg [11:0]count = 0;
wire [11:0]count_plus_one = (count + 1);
reg [11:0]next_count;
reg [7:0]byte0 = 0;
reg [7:0]next_byte0;
reg [7:0]byte1 = 0;
reg [7:0]next_byte1;
reg [7:0]byte2 = 0;
reg [7:0]next_byte2;
reg [7:0]byte3 = 0;
reg [7:0]next_byte3;

reg next_valid;
reg next_eop;

assign data = { byte3, byte2, byte1, byte0 };
assign bytecount = count;

always_comb begin
	next_state = state;
	next_count = count;
	next_byte0 = byte0;
	next_byte1 = byte1;
	next_byte2 = byte2;
	next_byte3 = byte3;
	next_valid = 0;
	next_eop = 0;

	case (state)
	IDLE: begin
		if (rxvalid) begin
			next_state = BYTE0;
			next_byte0 = rxdata;
			next_byte1 = 0;
			next_byte2 = 0;
			next_byte3 = 0;
			next_count = 1;
		end
	end
	BYTE0: begin
		if (rxvalid) begin
			next_state = BYTE1;
			next_byte1 = rxdata;
			next_count = count_plus_one;
		end else if (rxeop) begin
			next_state = EOP;
			next_valid = 1;
		end
	end
	BYTE1: begin
		if (rxvalid) begin
			next_state = BYTE2;
			next_byte2 = rxdata;
			next_count = count_plus_one;
		end else if (rxeop) begin
			next_state = EOP;
			next_valid = 1;
		end
	end
	BYTE2: begin
		if (rxvalid) begin
			next_state = BYTE3;
			next_byte3 = rxdata;
			next_count = count_plus_one;
			next_valid = 1;
		end else if (rxeop) begin
			next_state = EOP;
			next_valid = 1;
		end
	end
	BYTE3: begin
		if (rxvalid) begin
			next_state = BYTE0;
			next_byte0 = rxdata;
			next_byte1 = 0;
			next_byte2 = 0;
			next_byte3 = 0;
			next_count = count_plus_one;
		end else if (rxeop) begin
			next_state = EOP;
		end
	end
	EOP: begin
		next_state = IDLE;
		next_eop = 1;
	end
	endcase
end

always_ff @(posedge clk) begin
	state <= next_state;
	count <= next_count;
	byte0 <= next_byte0;
	byte1 <= next_byte1;
	byte2 <= next_byte2;
	byte3 <= next_byte3;
	valid <= next_valid;
	eop <= next_eop;
end

endmodule
