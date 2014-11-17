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

module axi_hp_dma_reader(
	input clk,
	axi_ifc.reader m,

// control interface
	input [31:0]txn_addr, // bits 6:0 ignored
	input [31:0]txn_count, // bits 6:0 ignored
	input txn_start,
	output reg txn_busy = 0,
	output reg [31:0]cyc_count = 0,

// data interface
	output [DWIDTH-1:0]data,
	output valid,
	input ready
	);

// TODO: make 32bit work
parameter DWIDTH = 64;

assign m.arid = 0;
assign m.arlen = 15;
assign m.arsize = 2'b11; // dword
assign m.arburst = 2'b01; // incr
assign m.arlock = 0;
assign m.arcache = 0;

logic [31:0]cyc_count_next;

logic txn_busy_next;

logic [31:0]araddr = 0;
logic [31:0]araddr_next;

logic [15:0]arcount = 0;
logic [15:0]arcount_next;

logic [19:0]rcount = 0;
logic [19:0]rcount_next;

wire arcount_is_zero = (arcount == 0);
wire rcount_is_zero = (rcount == 0);

assign m.araddr = araddr;
assign m.arvalid = (~arcount_is_zero);

assign m.rready = (~rcount_is_zero) & ready;
assign data = m.rdata;

assign valid = (~rcount_is_zero) & m.rvalid;

always_comb begin
	cyc_count_next = cyc_count;
	araddr_next = araddr;
	arcount_next = arcount;
	rcount_next = rcount;
	txn_busy_next = txn_busy;

	if ( m.rready & m.rvalid ) begin
		rcount_next = rcount - 1;
	end

	if ( m.arvalid & m.arready) begin
		arcount_next = arcount - 1;
		araddr_next = araddr + 128;
	end

	if (txn_busy) begin
		cyc_count_next = cyc_count + 1;
		if (rcount_is_zero & arcount_is_zero) begin
			txn_busy_next = 0;
		end
	end else begin
		if (txn_start) begin
			cyc_count_next = 0;
			araddr_next = { txn_addr[31:7], 7'd0 };
			arcount_next = txn_count[22:7];
			rcount_next = { txn_count[22:7], 4'd0 };
			txn_busy_next = 1;
		end
	end
end

always_ff @(posedge clk) begin
	araddr <= araddr_next;
	arcount <= arcount_next;
	rcount <= rcount_next;
	txn_busy <= txn_busy_next;
	cyc_count <= cyc_count_next;
end

endmodule
