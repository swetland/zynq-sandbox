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

`ifdef verilator
module testbench(input clk);
`else
module testbench();
reg clk = 0;
always #5 clk = ~clk;
`endif

axi_ifc axi0();

`ifdef SIMPLE_REGS
wire [1:0]rreg;
wire [1:0]wreg;
reg [31:0]rdata = 32'hdeadbeef;
wire [31:0]wdata;
wire rrd;
wire rwr;

axi_registers regs(
	.clk(clk),
	.s(axi0),
	.o_rreg(rreg),
	.o_wreg(wreg),
	.i_rdata(rdata),
	.o_wdata(wdata),
	.o_rd(rrd),
	.o_wr(rwr)
	);
reg [31:0]tmp = 32'heeeeeeee;

always_ff @(posedge clk) begin
	if (rrd) case(rreg)
		0: rdata <= 32'h10101010;
		1: rdata <= 32'h20202020;
		2: rdata <= 32'h30303030;
		3: rdata <= tmp;
	endcase
	if (rwr & (wreg == 3))
		tmp <= wdata;
end

`else
reg_ifc ri0();
reg_ifc ri1();
reg_ifc ri2();
reg_ifc ri3();
reg_ifc ri4();
reg_ifc ri5();
reg_ifc ri6();
reg_ifc ri7();

axi_to_reg_x8 bridge0(
	.clk(clk),
	.axi(axi0),
	.bank0(ri0),
	.bank1(ri1),
	.bank2(ri2),
	.bank3(ri3),
	.bank4(ri4),
	.bank5(ri5),
	.bank6(ri6),
	.bank7(ri7)
	);

reg [31:0]tmp = 32'heeeeeeee;

always_ff @(posedge clk) begin
	if (ri1.rd) case(ri1.raddr)
		0: ri1.rdata <= 32'h10101010;
		1: ri1.rdata <= 32'h20202020;
		2: ri1.rdata <= 32'h30303030;
		3: ri1.rdata <= tmp;
	endcase
	if (ri1.wr & (ri1.waddr == 3))
		tmp <= ri1.wdata;
end

assign ri3.rdata = 32'h33303330;

`endif


integer tick = 0;
reg [31:0]addr = 32'hffffffff;
reg [31:0]next_addr;
reg [31:0]data = 32'hffffffff;
reg [31:0]next_data;
reg do_rd = 0;
reg next_do_rd;
reg do_wr = 0;
reg next_do_wr;

axi_rw_engine engine0(
	.clk(clk),
	.m(axi0),
	.rd(do_rd),
	.wr(do_wr),
	.addr(addr),
	.data(data)
	);

integer BASE = 32'h00100000;

always_comb begin
	next_do_rd = 0;
	next_do_wr = 0;
	next_addr = 32'hffffffff;
	next_data = 32'hffffffff;
	if (tick == 10) begin
		next_do_rd = 1;
		next_addr = BASE + 4;
	end else if (tick == 20) begin
		next_do_rd = 1;
		next_addr = 32'h00300000; //BASE + 0;
	end else if (tick == 30) begin
		next_do_wr = 1;
		next_data = 32'haabbccdd;
		next_addr = BASE + 12;
	end else if (tick == 40) begin
		next_do_rd = 1;
		next_addr = BASE + 4;
	end else if (tick == 50) begin
		next_do_rd = 1;
		next_addr = BASE + 12;
	end else if (tick == 60) begin
		$finish;
	end
end

always_ff @(posedge clk) begin
	do_rd <= next_do_rd;
	do_wr <= next_do_wr;
	addr <= next_addr;
	data <= next_data;
	tick <= tick + 1;
end

endmodule


module axi_rw_engine(
	input clk,
	axi_ifc.master m,
	input rd,
	input wr,
	input [31:0]addr,
	input [31:0]data
	);

typedef enum { IDLE, RADDR, RDATA, WADDR, WDATA, WRESP } state_t;
state_t state = IDLE;
state_t next_state;

reg [31:0]awaddr = 0;
reg [31:0]next_awaddr;
reg [31:0]wdata = 0;
reg [31:0]next_wdata;
reg [31:0]araddr = 0;
reg [31:0]next_araddr;
reg arvalid = 0;
reg next_arvalid;
reg rready = 0;
reg next_rready;
reg awvalid = 0;
reg next_awvalid;
reg wvalid = 0;
reg next_wvalid;
reg bready = 0;
reg next_bready;

always_comb begin
	next_state = state;
	next_araddr = araddr;
	next_awaddr = awaddr;
	next_wdata = wdata;
	next_awvalid = 0;
	next_wvalid = 0;
	next_bready = 0;
	next_arvalid = 0;
	next_rready = 0;
	case (state)
	IDLE: begin
		if (rd) begin
			next_state = RADDR;
			next_araddr = addr;
			next_arvalid = 1;
		end else if (wr) begin
			next_state = WADDR;
			next_awaddr = addr;
			next_wdata = data;
			next_awvalid = 1;
		end
	end
	WADDR: begin
		if (m.awready) begin
			next_state = WDATA;
			next_wvalid = 1;
		end else begin
			next_awvalid = 1;
		end
	end
	WDATA: begin
		if (m.wready) begin
			next_state = WRESP;
			next_bready = 1;
		end else begin
			next_wvalid = 1;
		end
	end
	WRESP: begin
		if (m.bvalid) begin
			next_state = IDLE;
			$display("wr %x -> %x (status %x)", wdata, awaddr, m.bresp);
		end else begin
			next_bready = 1;
		end
	end
	RADDR: begin
		if (m.arready) begin
			next_state = RDATA;
			next_rready = 1;
		end else begin
			next_arvalid = 1;
		end
	end
	RDATA: begin
		if (m.rvalid) begin
			next_state = IDLE;
			$display("rd %x <- %x (status %x)", m.rdata, m.araddr, m.rresp);
		end else begin
			next_rready = 1;
		end
	end
	endcase
end

always_ff @(posedge clk) begin
	state <= next_state;
	araddr <= next_araddr;
	awaddr <= next_awaddr;
	arvalid <= next_arvalid;
	awvalid <= next_awvalid;
	rready <= next_rready;
	wvalid <= next_wvalid;
	bready <= next_bready;
	wdata <= next_wdata;
end

assign m.awid = 0;
assign m.awaddr = awaddr;
assign m.awvalid = awvalid;
assign m.wdata = wdata;
assign m.wstrb = 4'b1111;
assign m.wvalid = wvalid;
assign m.bready = bready;
assign m.awburst = 1; // INCR
assign m.awcache = 0;
assign m.awlen = 0;
assign m.awsize = 2; // 4 bytes
assign m.awlock = 0;
assign m.wlast = 1;

assign m.arid = 0;
assign m.araddr = araddr;
assign m.arvalid = arvalid;
assign m.rready = rready;
assign m.arburst = 1; // INCR
assign m.arcache = 0;
assign m.arlen = 0;
assign m.arsize = 2; // 4 bytes
assign m.arlock = 0;

endmodule


