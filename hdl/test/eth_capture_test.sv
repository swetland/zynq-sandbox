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

`ifdef verilator
module testbench(input clk);
`else
module testbench();
reg clk = 0;
always #5 clk = ~clk;
`endif

reg clk50 = 0;
always @(posedge clk)
	clk50 = ~clk50;

wire [1:0]eth_dat;
wire eth_pkt;
wire done;

reg pkt_gen_start = 0;

eth_packet_gen #(
	.PACKET_COUNT(5),
	.PACKET_LENGTH(277)
	) pgen0 (
	.clk50(clk50),
	.data(eth_dat),
	.packet(eth_pkt),
	.start(pkt_gen_start),
	.done(done)
	);

wire [7:0]rxdata;
wire rxvalid;
wire rxeop;
wire rxsop;

eth_rmii_rx rx0(
	.clk50(clk50),
	.rx(eth_dat),
	.crs_dv(eth_pkt),
	.data(rxdata),
	.valid(rxvalid),
	.eop(rxeop),
	.sop(rxsop),
	.out_tx(),
	.out_txen()
	);

axi_ifc #(.AXI3(1)) axi_dma();

reg cap_reset = 0;

eth_capture cap0(
	.clk50(clk50),
	.rxsop(rxsop),
	.rxeop(rxeop),
	.rxdata(rxdata),
	.rxvalid(rxvalid),
	.clk(clk),
	.reset(cap_reset),
	.axi_dma(axi_dma)
	);

axi_sram sram0(
	.clk(clk),
	.s(axi_dma)
	);

`ifdef XX
always @(posedge clk50)
	if (done)
		$finish;
`endif

reg [31:0]evt_cnt = 0;
always @(posedge clk) begin
	evt_cnt <= evt_cnt + 1;
	if (evt_cnt == 150) cap_reset <= 1;
	if (evt_cnt == 151) cap_reset <= 0;
	if (evt_cnt == 200) pkt_gen_start <= 1;
	if (evt_cnt == 100000) $finish;
end

endmodule
