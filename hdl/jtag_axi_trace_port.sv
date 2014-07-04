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

module jtag_axi_trace_port(
	axi_ifc.debug axi
	);

wire clk = axi.aclk;

wire dbg_rd;
wire dbg_wr;
wire [2:0]dbg_addr;
wire [31:0]dbg_wdata;
reg [31:0]dbg_rdata = 0;

jtag_debug_port port0(
	.clk(clk),
	.o_rd(dbg_rd),
	.o_wr(dbg_wr),
	.o_addr(dbg_addr),
	.o_wdata(dbg_wdata),
	.i_rdata(dbg_rdata)
	);

wire [63:0]capture_wr = {
	axi.awaddr, // 63-32
	axi.awcache, axi.awlen, // 31-24
	axi.awburst, axi.awsize, axi.awlock, 2'b01, // 23-16
	axi.awqos, axi.awid // 15-0
};

wire [63:0]capture_rd = {
	axi.araddr, // 63-32
	axi.arcache, axi.arlen, // 31-24
	axi.arburst, axi.arsize, axi.arlock, 2'b00, // 23-16
	axi.arqos, axi.arid // 15-0
};

reg [63:0]trace[0:511];
reg [8:0]t_wptr = 0;
reg [8:0]t_rptr = 0;

always_ff @(posedge clk) begin
	if (axi.awvalid & axi.awready) begin
		trace[t_wptr] <= capture_wr;
		if (t_wptr != 511)
			t_wptr <= t_wptr + 1;
	end else if (axi.arvalid & axi.arready) begin
		trace[t_wptr] <= capture_rd;
		if (t_wptr != 511)
			t_wptr <= t_wptr + 1;
	end else if (dbg_wr) begin
		t_wptr <= 0;
		t_rptr <= 0;
	end
	if (dbg_rd) begin
		case (dbg_addr)
		0: begin
			dbg_rdata <= 32'hAABBCCDD;
		end
		1: begin
			dbg_rdata <= trace[t_rptr][31:0];
		end
		2: begin	
			dbg_rdata <= trace[t_rptr][63:32];
			t_rptr <= t_rptr + 1;
		end
		3: begin
			dbg_rdata <= { 23'd0, t_wptr };
		end
		4: begin
			dbg_rdata <= 0;
			t_rptr <= 0;
		end
		default: begin
			dbg_rdata <= 0;
		end
		endcase
	end
end

endmodule
