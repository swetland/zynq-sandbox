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

module axi_dma_reader(
	input clk,
	axi_ifc.master m,
	output reg [31:0]o_data,
	output reg o_valid,
	input i_start,
	input i_ready,
	input [31:0]i_baseaddr,
	input [15:0]i_burst_count
	);

assign m.awvalid = 0;
assign m.wvalid = 0;
assign m.awid = 0;
assign m.awaddr = 0;
assign m.wdata = 0;
assign m.wstrb = 0;
assign m.bready = 0;
assign m.awburst = 0;
assign m.awlen = 0;
assign m.awsize = 0;
assign m.awlock = 0;
assign m.wlast = 0;
assign m.awcache = 0;

typedef enum { IDLE, ACTIVE, RADDR, RDATA } rstate_t;
rstate_t rstate = IDLE;
rstate_t next_rstate;

reg [31:0]txn_addr;
reg [31:0]next_txn_addr;
reg [15:0]txn_count;
reg [15:0]next_txn_count;

reg [31:0]next_o_data;
reg next_o_valid;
reg next_arvalid;
reg next_rready;

assign m.araddr = txn_addr;
assign m.arid = 0;
assign m.arburst = 1; // INCR
assign m.arsize = 2; // 4 bytes
assign m.arlen = 15;
assign m.arcache = 0;
assign m.arlock = 0;

always_comb begin
	next_rstate = rstate;
	next_txn_addr = txn_addr;
	next_txn_count = txn_count;
	next_o_data = o_data;
	next_o_valid = 0;
	next_arvalid = 0;
	next_rready = 1;

	case (rstate)
	IDLE: begin
		if (i_start) begin
			next_rstate = ACTIVE;
			next_txn_addr = { i_baseaddr[31:6], 6'b0 };
			next_txn_count = i_burst_count;
		end
	end
	ACTIVE: begin
		if (next_txn_count == 0) begin
			next_rstate = IDLE;
		end else if (i_ready) begin
			next_rstate = RADDR;
			next_arvalid = 1;
		end
	end
	RADDR: begin
		if (m.arready) begin 
			next_rstate = RDATA;
			next_rready = 1;
		end else begin
			next_arvalid = 1;
		end
	end
	RDATA: begin
		if (m.rvalid) begin
			next_o_data = m.rdata;
			next_o_valid = 1;
			if (m.rlast) begin
				next_rstate = ACTIVE;
				next_txn_count = txn_count - 1;
				next_txn_addr = txn_addr + 64;
			end else begin
				next_rready = 1;
			end
		end else begin
			next_rready = 1;
		end
	end
	endcase
end

reg arvalid = 0;
reg rready = 0;
assign m.arvalid = arvalid;
assign m.rready = rready;

always_ff @(posedge clk) begin
	rstate <= next_rstate;
	txn_addr <= next_txn_addr;
	txn_count <= next_txn_count;
	o_data <= next_o_data;
	o_valid <= next_o_valid;
	arvalid <= next_arvalid;
	rready <= next_rready;
end

endmodule

