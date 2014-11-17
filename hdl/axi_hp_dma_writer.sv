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

module axi_hp_dma_writer(
	input clk,
	axi_ifc.writer m,

// control interface
	input [31:0]txn_addr, // bits 6:0 ignored
	input [31:0]txn_count, // bits 6:0 ignored
	input txn_start,
	output reg txn_busy = 0,
	output reg [31:0]cyc_count = 0,

// data interface
	input [DWIDTH-1:0]data,
	input valid,
	output ready
	);

// TODO: make 32bit work
parameter DWIDTH = 64;

assign m.awid = 0;
assign m.awlen = 15;
assign m.awsize = 2'b11; // dword
assign m.awburst = 2'b01; // incr
assign m.awlock = 0;
assign m.awcache = 0;
assign m.wstrb = 8'b11111111;
assign m.bready = 1;

logic [31:0]cyc_count_next;

logic txn_busy_next;

logic [31:0]awaddr = 0;
logic [31:0]awaddr_next;

logic [15:0]awcount = 0;
logic [15:0]awcount_next;

logic [15:0]bcount = 0;
logic [15:0]bcount_next;

logic [19:0]wcount = 0;
logic [19:0]wcount_next;

wire awcount_is_zero = (awcount == 0);
wire wcount_is_zero = (wcount == 0);
wire bcount_is_zero = (bcount == 0);

assign m.awaddr = awaddr;
assign m.awvalid = (~awcount_is_zero);

assign m.wvalid = (~wcount_is_zero) & valid;
assign m.wlast = (wcount[3:0] == 4'd1);
assign m.wdata = data;

assign ready = (~wcount_is_zero) & m.wready;

always_comb begin
	cyc_count_next = cyc_count;
	awaddr_next = awaddr;
	awcount_next = awcount;
	bcount_next = bcount;
	wcount_next = wcount;
	txn_busy_next = txn_busy;

	if ( m.wready & m.wvalid ) begin
		wcount_next = wcount - 1;
	end

	if ( m.bvalid ) begin
		bcount_next = bcount - 1;
	end

	if ( m.awvalid & m.awready) begin
		awcount_next = awcount - 1;
		awaddr_next = awaddr + 128;
	end

	if (txn_busy) begin
		cyc_count_next = cyc_count + 1;
		if (wcount_is_zero & awcount_is_zero & bcount_is_zero) begin
			txn_busy_next = 0;
		end
	end else begin
		if (txn_start) begin
			cyc_count_next = 0;
			awaddr_next = { txn_addr[31:7], 7'd0 };
			awcount_next = txn_count[22:7];
			bcount_next = txn_count[22:7];
			wcount_next = { txn_count[22:7], 4'd0 };
			txn_busy_next = 1;
		end
	end
end

always_ff @(posedge clk) begin
	awaddr <= awaddr_next;
	awcount <= awcount_next;
	bcount <= bcount_next;
	wcount <= wcount_next;
	txn_busy <= txn_busy_next;
	cyc_count <= cyc_count_next;
end

endmodule
