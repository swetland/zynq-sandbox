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

// AXI Register Bridge
//
// Reads and Writes may happen simultaneously

// TODO: deal with non-length-1 bursts

module axi_registers (
	input clk,

	// AXI Interface
	axi_ifc.slave s,

	// Register File Interface
	reg_ifc.master rm
	);

reg [$bits(rm.raddr)-1:0]rreg = 0;
reg [$bits(rm.waddr)-1:0]wreg = 0;
reg rd = 0;

assign rm.rd = rd;
assign rm.raddr = rreg;
assign rm.waddr = wreg;

typedef enum { W_ADDR, W_DATA, W_RESP } wstate_t;

assign s.bresp = 0;
assign s.rresp = 0;

//reg [31:0]wdata = 0;
//reg [31:0]wdata_next;

wstate_t wstate = W_ADDR;
wstate_t wstate_next;

reg awready_next;
reg wready_next;
reg bvalid_next;

reg [$bits(rm.waddr)-1:0]wreg_next;
reg [$bits(rm.raddr)-1:0]rreg_next;

assign rm.wdata = s.wdata;
assign rm.wr = (s.wvalid & s.wready);

reg [$bits(s.awid)-1:0]twid = 0;
reg [$bits(s.awid)-1:0]twid_next;

assign s.bid = twid;

always_comb begin
	wstate_next = wstate;
	//wdata_next = wdata;
	wreg_next = wreg;
	twid_next = twid;
	awready_next = 0;
	wready_next = 0;
	bvalid_next = 0;
	case (wstate)
	W_ADDR: if (s.awvalid) begin
			wstate_next = W_DATA;
			wready_next = 1;
			twid_next = s.awid;
			wreg_next = s.awaddr[$bits(rm.waddr)+1:2];
		end else begin
			awready_next = 1;
		end
	W_DATA: if (s.wvalid) begin
			wstate_next = W_RESP;
			bvalid_next = 1;
		end else begin
			wready_next = 1;
		end
	W_RESP: if (s.bready) begin
			wstate_next = W_ADDR;
			awready_next = 1;
		end else begin
			bvalid_next = 1;
		end
	endcase
end

typedef enum { R_ADDR, R_CAPTURE, R_CAPTURE2, R_DATA } rstate_t;

rstate_t rstate = R_ADDR;
rstate_t rstate_next;

reg arready_next;
reg rvalid_next;
reg rlast_next;

reg [31:0]rdata = 0;
reg [31:0]rdata_next;
assign s.rdata = rdata;

reg rd_next;

reg [$bits(s.arid)-1:0]trid = 0;
reg [$bits(s.arid)-1:0]trid_next;
assign s.rid = trid;

always_comb begin 
	rstate_next = rstate;
	rdata_next = rdata;
	rreg_next = rreg;
	trid_next = trid;
	arready_next = 0;
	rvalid_next = 0;
	rlast_next = 0;
	rd_next = 0;
	case (rstate)
	R_ADDR: if (s.arvalid) begin
			// accept address from AXI
			rstate_next = R_CAPTURE;
			trid_next = s.arid;
			rreg_next = s.araddr[$bits(rm.raddr)+1:2];
			rd_next = 1;
		end else begin
			arready_next = 1;
		end
	R_CAPTURE: begin
			// present address and rd to register file
			rstate_next = R_CAPTURE2;
		end
	R_CAPTURE2: begin
			// capture register file output
			rstate_next = R_DATA;
			rvalid_next = 1;
			rlast_next = 1;
			rdata_next = rm.rdata;
		end
	R_DATA: if (s.rready) begin
			// present register data to AXI
			rstate_next = R_ADDR;
			arready_next = 1;
		end else begin
			rvalid_next = 1;
			rlast_next = 1;
		end
	endcase
end

always_ff @(posedge clk) begin
	wstate <= wstate_next;
	//wdata <= wdata_next;
	twid <= twid_next;
	s.awready <= awready_next;
	s.wready <= wready_next;
	s.bvalid <= bvalid_next;
	wreg <= wreg_next;

	rstate <= rstate_next;
	rdata <= rdata_next;
	trid <= trid_next;
	s.arready <= arready_next;
	s.rvalid <= rvalid_next;
	s.rlast <= rlast_next;
	rreg <= rreg_next;
	rd <= rd_next;
end

endmodule
