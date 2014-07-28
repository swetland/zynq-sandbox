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

module top(
	input clk,
	output [3:0]led,

	output phy0_mdc,
	//output phy0_mdio,
	output phy0_clk,
	output phy0_txen,
	output [1:0]phy0_tx,
	input phy0_crs,
	input [1:0]phy0_rx
	);

assign led = 0;

wire clk50;

mmcm_1in_3out #(
	.CLKIN_PERIOD(8.0),
	.VCO_MUL(8.000),
	.VCO_DIV(1),
	.OUT0_DIV(20.000),
	.OUT1_DIV(10),
	.OUT2_DIV(10)
	) mmcm0 (
	.i_clk(clk),
	.o_clk0(clk50),
	.o_clk1(),
	.o_clk2()
	);

assign phy0_clk = clk50;
assign phy0_mdc = 1;

wire [7:0]rxdata;
wire rxvalid;
wire rxeop;
wire rxsop;

(* keep_hierarchy = "yes" *)
eth_rmii_rx phy0rx(
	.clk50(clk50),
	.rx(phy0_rx),
	.crs_dv(phy0_crs),
	.data(rxdata),
	.valid(rxvalid),
	.eop(rxeop),
	.sop(rxsop),
	.out_tx(),
	.out_txen()
	);

axi_ifc #(.IWIDTH(12),.AXI3(1)) axi_ctl();
axi_ifc #(.IWIDTH(6),.AXI3(1)) axi_dma0();

zynq_ps7 zynq(
	.fclk0(),
	.m_axi_gp0_clk(clk),
	.m_axi_gp0(axi_ctl),
	.s_axi_gp0_clk(clk),
	.s_axi_gp0(axi_dma0)
	);

reg cap_enable = 0;
reg cap_reset = 0;

eth_capture #(
	.BASE_ADDR(32'h10000000)
	) cap0 (
	.clk50(clk50),
	.rxsop(rxsop),
	.rxeop(rxeop),
	.rxdata(rxdata),
	.rxvalid(rxvalid),
	.clk(clk),
	.reset(cap_reset),
	.enable(cap_enable),
	.axi_dma(axi_dma0)
	);

wire wr;
wire [31:0]wdata;

wire rrd;
wire [1:0]rreg;
reg [31:0]rdata = 0;

always_ff @(posedge clk) begin
	if (rrd) case(rreg)
		0: rdata <= 32'haabbccdd;
		1: rdata <= 0;
		2: rdata <= 0;
		3: rdata <= 0;
	endcase
end

axi_registers regs(
	.clk(clk),
	.s(axi_ctl),
	.o_rreg(rreg),
	.o_wreg(),
	.i_rdata(rdata),
	.o_wdata(wdata),
	.o_rd(rrd),
	.o_wr(wr)
	);

always @(posedge clk) begin
	if (wr) begin
		cap_enable <= wdata[0];
		cap_reset <= wdata[1];
	end else begin
		cap_reset <= 0;
	end
end

endmodule
