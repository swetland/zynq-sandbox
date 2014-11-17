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

// MEM2MEM causes ch0 reader to send to ch1 writer
//`define MEM2MEM

module top();

wire clk;

axi_ifc #(.IWIDTH(12),.AXI3(1)) axi_ctl();
axi_ifc #(.IWIDTH(6),.DWIDTH(64),.AXI3(1)) axi_dma0();
axi_ifc #(.IWIDTH(6),.DWIDTH(64),.AXI3(1)) axi_dma1();
axi_ifc #(.IWIDTH(6),.DWIDTH(64),.AXI3(1)) axi_dma2();
axi_ifc #(.IWIDTH(6),.DWIDTH(64),.AXI3(1)) axi_dma3();

reg_ifc #(.AWIDTH(3)) ri();

axi_registers regs0(
	.clk(clk),
	.s(axi_ctl),
	.rm(ri)
	);

zynq_ps7 zynq(
	.fclk0(clk),
	.s_axi_hp0_clk(clk),
	.s_axi_hp0(axi_dma0),
	.s_axi_hp1_clk(clk),
	.s_axi_hp1(axi_dma1),
	.s_axi_hp2_clk(clk),
	.s_axi_hp2(axi_dma2),
	.s_axi_hp3_clk(clk),
	.s_axi_hp3(axi_dma3),
	.m_axi_gp0_clk(clk),
	.m_axi_gp0(axi_ctl)
	);

wire [31:0]rcc0;
wire [31:0]rcc1;
wire [31:0]rcc2;
wire [31:0]rcc3;

`ifdef MEM2MEM
wxire [63:0]r0_data;
wire r0_valid;
wire r0_ready;
`endif

axi_hp_dma_reader #(.DWIDTH(64)) dma_r0(
	.clk(clk),
	.m(axi_dma0.reader),
	.txn_addr(32'h02000000),
	.txn_count(262144),
	.txn_start(ri.wr & ri.wdata[4]),
	.txn_busy(),
`ifdef MEM2MEM
	.data(r0_data),
	.valid(r0_valid),
	.ready(r0_ready),
`else
	.data(),
	.valid(),
	.ready(1),
`endif
	.cyc_count(rcc0)
	);

axi_hp_dma_reader #(.DWIDTH(64)) dma_r1(
	.clk(clk),
	.m(axi_dma1.reader),
	.txn_addr(32'h02100000),
	.txn_count(262144),
	.txn_start(ri.wr & ri.wdata[5]),
	.txn_busy(),
	.data(),
	.valid(),
	.ready(1),
	.cyc_count(rcc1)
	);

axi_hp_dma_reader #(.DWIDTH(64)) dma_r2(
	.clk(clk),
	.m(axi_dma2.reader),
	.txn_addr(32'h02200000),
	.txn_count(262144),
	.txn_start(ri.wr & ri.wdata[6]),
	.txn_busy(),
	.data(),
	.valid(),
	.ready(1),
	.cyc_count(rcc2)
	);

axi_hp_dma_reader #(.DWIDTH(64)) dma_r3(
	.clk(clk),
	.m(axi_dma3.reader),
	.txn_addr(32'h02300000),
	.txn_count(262144),
	.txn_start(ri.wr & ri.wdata[7]),
	.txn_busy(),
	.data(),
	.valid(),
	.ready(1),
	.cyc_count(rcc3)
	);

wire [31:0]cc0;
wire rdy0;
reg [31:0]count0 = 0;
always @(posedge clk)
	if (rdy0) count0 <= count0 + 1;

axi_hp_dma_writer #(.DWIDTH(64)) dma_w0(
	.clk(clk),
	.m(axi_dma0.writer),
	.txn_addr(32'h01000000),
	.txn_count(262144),
	.txn_start(ri.wr & ri.wdata[0]),
	.txn_busy(),
	.data({ 32'h00bbccdd, count0 }),
	.valid(1),
	.ready(rdy0),
	.cyc_count(cc0)
	);

wire [31:0]cc1;
wire rdy1;
reg [31:0]count1 = 0;
always @(posedge clk)
	if (rdy1) count1 <= count1 + 1;

axi_hp_dma_writer #(.DWIDTH(64)) dma_w1(
	.clk(clk),
	.m(axi_dma1.writer),
	.txn_addr(32'h01100000),
	.txn_count(262144),
	.txn_start(ri.wr & ri.wdata[1]),
	.txn_busy(),
`ifdef MEM2MEM
	.data(r0_data),
	.valid(r0_valid),
	.ready(r0_ready),
`else
	.data({ 32'h11bbccdd, count1 }),
	.valid(1),
	.ready(rdy1),
`endif
	.cyc_count(cc1)
	);

wire [31:0]cc2;
wire rdy2;
reg [31:0]count2 = 0;
always @(posedge clk)
	if (rdy2) count2 <= count2 + 1;

axi_hp_dma_writer #(.DWIDTH(64)) dma_w2(
	.clk(clk),
	.m(axi_dma2.writer),
	.txn_addr(32'h01200000),
	.txn_count(262144),
	.txn_start(ri.wr & ri.wdata[2]),
	.txn_busy(),
	.data({ 32'h22bbccdd, count2 }),
	.valid(1),
	.ready(rdy2),
	.cyc_count(cc2)
	);

wire [31:0]cc3;
wire rdy3;
reg [31:0]count3 = 0;
always @(posedge clk)
	if (rdy3) count3 <= count3 + 1;

axi_hp_dma_writer #(.DWIDTH(64)) dma_w3(
	.clk(clk),
	.m(axi_dma3.writer),
	.txn_addr(32'h01300000),
	.txn_count(262144),
	.txn_start(ri.wr & ri.wdata[3]),
	.txn_busy(),
	.data({ 32'h33bbccdd, count3 }),
	.valid(1),
	.ready(rdy3),
	.cyc_count(cc3)
	);

always @(posedge clk)
	if (ri.rd) case (ri.raddr)
	0: ri.rdata <= cc0;
	1: ri.rdata <= cc1;
	2: ri.rdata <= cc2;
	3: ri.rdata <= cc3;
	4: ri.rdata <= rcc0;
	5: ri.rdata <= rcc1;
	6: ri.rdata <= rcc2;
	7: ri.rdata <= rcc3;
	//default: ri.rdata <= 32'ha7a7a7a7;
	endcase

endmodule

