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

module top(
	input clk,
	output [15:0]led,
	output phy0_mdc,
	inout phy0_mdio,
	output phy0_rstn,
	input phy0_crs,
	input phy0_rxerr,
	input [1:0]phy0_rx,
	output phy0_txen,
	output [1:0]phy0_tx,
	output phy0_clk,
	input phy0_intn,
	output [3:0]JD
	);

wire clk50;
wire clk50b;

assign phy0_clk = clk50;
//assign phy0_mdc = 1;
//assign phy0_mdio = 1;
assign phy0_rstn = 1;


//assign JD[0] = phy0_clk;
//assign JD[1] = phy0_txen;
//assign JD[2] = phy0_tx[0];
//assign JD[3] = phy0_tx[1];
//assign JD[0] = phy0_clk;
//assign JD[1] = phy0_crs;
//assign JD[2] = phy0_rx[0];
//assign JD[3] = phy0_rx[1];

//assign phy0_txen = 0;
//assign phy0_tx = 0;

mmcm_1in_3out #(
	.CLKIN_PERIOD(10.0),
	.VCO_MUL(10.000),
	.VCO_DIV(1),
	.OUT0_DIV(20.000), // 50MHz
	.OUT1_DIV(20), // 50MHz
	.OUT2_DIV(4)  // 250MHz
	) mmcm0 (
	.i_clk(clk),
	.o_clk0(clk50),
	.o_clk1(clk50b),
	.o_clk2()
	);

wire [7:0]rxdata;
wire rxvalid;
wire rxeop;

(* keep_hierarchy = "yes" *)
eth_rmii_rx phy0rx(
	.clk50(clk50),
	.rx(phy0_rx),
	.crs_dv(phy0_crs),
	.data(rxdata),
	.valid(rxvalid),
	.eop(rxeop),
	.out_tx(),
	.out_txen(),
	.sop()
	);

wire go;

reg [7:0]txptr = 0;
reg [7:0]pdata[0:128];
initial $readmemh("testpacket.hex", pdata);

wire txbusy;
wire txadvance;
wire [7:0]txdata = pdata[txptr];
reg txpacket = 0;

always @(posedge clk50b) begin
	if (txpacket) begin
		if (txadvance) begin
			txptr <= txptr + 1;
			if (txptr == 101) begin
				txpacket <= 0;
				txptr <= 0;
			end
		end
	end else if (go) begin
		txpacket <= 1;
	end
end

eth_rmii_tx phy0tx(
	.clk50(clk50b),
	.tx(phy0_tx),
	.txen(phy0_txen),
	.data(txdata),
	.packet(txpacket),
	.busy(txbusy),
	.advance(txadvance)
	);

wire i_mdio;
wire o_mdio;
wire t_mdio;
IOBUF buf_mdio(
	.O(i_mdio),
	.I(o_mdio),
	.T(t_mdio),
	.IO(phy0_mdio)
	);

assign JD[0] = phy0_mdc;
assign JD[1] = i_mdio;

wire mi_read;
wire mi_write;
wire [31:0]mi_txdata;
wire [15:0]mi_rxdata;
wire mi_busy;

(* keep_hierarchy = "yes" *)
eth_mdio mdio0(
	.clk(clk50),
	.do_read(mi_read),
	.do_write(mi_write),
	.txdata(mi_txdata),
	.rxdata(mi_rxdata),
	.busy(mi_busy),
	.i_mdio(i_mdio),
	.o_mdio(o_mdio),
	.t_mdio(t_mdio),
	.mdc(phy0_mdc)
	);

(* keep_hierarchy = "yes" *)
packetlogger log0(
	.clk50(clk50),
	.rxdata(rxdata),
	.rxvalid(rxvalid),
	.rxeop(rxeop),
	.go(go),
	.mi_read(mi_read),
	.mi_write(mi_write),
	.mi_txdata(mi_txdata),
	.mi_rxdata(mi_rxdata),
	.mi_busy(mi_busy)
	);

endmodule

module packetlogger(
	input clk50,
	input [7:0]rxdata,
	input rxvalid,
	input rxeop,
	output reg go = 0,
	output reg mi_read = 0,
	output reg mi_write = 0,
	output [31:0]mi_txdata,
	input [15:0]mi_rxdata,
	input mi_busy
	);

reg [11:0]rdptr = 0;
reg [11:0]rxptr = 0;
reg [11:0]next_rdptr;
reg [11:0]next_rxptr;

wire [8:0]rdata;
reg bufrd = 0;

ram rxbuffer(
	.clk(clk50),
	.wen(rxvalid | rxeop),
	.waddr(rxptr),
	.wdata( { rxeop, rxdata } ),
	.ren(bufrd),
	.raddr(rdptr),
	.rdata(rdata)
	);

wire [31:0]dbg_wdata;
reg [31:0]dbg_rdata;
wire [2:0]dbg_addr;
wire dbg_rd;
wire dbg_wr;

assign mi_txdata = dbg_wdata;

always_comb begin
	next_rxptr = rxptr;
	next_rdptr = rdptr;
	bufrd = 0;
	if (rxvalid | rxeop) begin
		if (rxptr != 12'b111111111111)
			next_rxptr = rxptr + 1;
	end
	if (dbg_rd) begin
		if (dbg_addr == 1) begin
			next_rdptr = rdptr + 1;
			bufrd = 1;
		end
	end
	case (dbg_addr)
	0: dbg_rdata = 32'h12345678;
	1: dbg_rdata = { 23'd0, rdata };
	2: dbg_rdata = { 20'd0, rxptr };
	3: dbg_rdata = { 15'd0, mi_busy, mi_rxdata };
	default: dbg_rdata = 0;
	endcase
end

always_ff @(posedge clk50) begin
	rxptr <= next_rxptr;
	rdptr <= next_rdptr;
	if (dbg_wr) begin
		if (dbg_addr == 0) go <= 1;
		if (dbg_addr == 3) begin
			mi_read <= (dbg_wdata[29:28] == 2'b10);
			mi_write <= 1;
		end
	end else begin
		go <= 0;
		mi_read <= 0;
		mi_write <= 0;
	end
end

(* keep_hierarchy = "yes" *)
jtag_debug_port port0(
	.clk(clk50),
	.o_wdata(dbg_wdata),
	.i_rdata(dbg_rdata),
	.o_addr(dbg_addr),
	.o_rd(dbg_rd),
	.o_wr(dbg_wr)
	);

endmodule

module ram(
	input clk,
	input ren,
	input [11:0]raddr,
	output reg [8:0]rdata,
	input wen,
	input [11:0]waddr,
	input [8:0]wdata
	);

reg [8:0]memory[0:4095];

always_ff @(posedge clk) begin
	if (ren)
		rdata <= memory[raddr];
	if (wen)
		memory[waddr] <= wdata;
end

endmodule







