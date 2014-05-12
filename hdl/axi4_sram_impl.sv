
`timescale 1ns/1ps

module axi4_sram_impl #(
	parameter integer IWIDTH = 1,
	parameter integer DWIDTH = 32,
	parameter integer AWIDTH = 32
	) (
	input wire  s00_axi_aclk,
	input wire  s00_axi_aresetn,
	input wire [IWIDTH-1 : 0] s00_axi_awid,
	input wire [DWIDTH-1 : 0] s00_axi_awaddr,
	input wire [7 : 0] s00_axi_awlen,
	input wire [2 : 0] s00_axi_awsize,
	input wire [1 : 0] s00_axi_awburst,
	input wire  s00_axi_awlock,
	input wire [3 : 0] s00_axi_awcache,
	input wire [2 : 0] s00_axi_awprot,
	input wire [3 : 0] s00_axi_awqos,
	input wire [3 : 0] s00_axi_awregion,
	input wire  s00_axi_awvalid,
	output wire  s00_axi_awready,
	input wire [DWIDTH-1 : 0] s00_axi_wdata,
	input wire [(DWIDTH/8)-1 : 0] s00_axi_wstrb,
	input wire  s00_axi_wlast,
	input wire  s00_axi_wvalid,
	output wire  s00_axi_wready,
	output wire [IWIDTH-1 : 0] s00_axi_bid,
	output wire [1 : 0] s00_axi_bresp,
	output wire  s00_axi_bvalid,
	input wire  s00_axi_bready,
	input wire [IWIDTH-1 : 0] s00_axi_arid,
	input wire [AWIDTH-1 : 0] s00_axi_araddr,
	input wire [7 : 0] s00_axi_arlen,
	input wire [2 : 0] s00_axi_arsize,
	input wire [1 : 0] s00_axi_arburst,
	input wire  s00_axi_arlock,
	input wire [3 : 0] s00_axi_arcache,
	input wire [2 : 0] s00_axi_arprot,
	input wire [3 : 0] s00_axi_arqos,
	input wire [3 : 0] s00_axi_arregion,
	input wire  s00_axi_arvalid,
	output wire  s00_axi_arready,
	output wire [IWIDTH-1 : 0] s00_axi_rid,
	output wire [DWIDTH-1 : 0] s00_axi_rdata,
	output wire [1 : 0] s00_axi_rresp,
	output wire  s00_axi_rlast,
	output wire  s00_axi_rvalid,
	input wire  s00_axi_rready
	);

axi4_ifc #(
	.AWIDTH(AWIDTH),
	.DWIDTH(DWIDTH),
	.IWIDTH(IWIDTH)
	)axi0();

assign axi0.awid = s00_axi_awid;
assign axi0.awaddr = s00_axi_awaddr;
assign axi0.awlen = s00_axi_awlen;
assign axi0.awsize = s00_axi_awsize;
assign axi0.awburst = s00_axi_awburst;
assign axi0.awlock = s00_axi_awlock;
assign axi0.awcache = s00_axi_awcache;
assign axi0.awprot = s00_axi_awprot;
assign axi0.awvalid = s00_axi_awvalid;
assign s00_axi_awready = axi0.awready;
assign axi0.wdata = s00_axi_wdata;
assign axi0.wstrb = s00_axi_wstrb;
assign axi0.wlast = s00_axi_wlast;
assign axi0.wvalid = s00_axi_wvalid;
assign s00_axi_wready = axi0.wready;
assign s00_axi_bid = axi0.bid;
assign s00_axi_bresp = axi0.bresp;
assign s00_axi_bvalid = axi0.bvalid;
assign axi0.bready = s00_axi_bready;
assign axi0.arid = s00_axi_arid;
assign axi0.araddr = s00_axi_araddr;
assign axi0.arlen = s00_axi_arlen;
assign axi0.arsize = s00_axi_arsize;
assign axi0.arburst = s00_axi_arburst;
assign axi0.arlock = s00_axi_arlock;
assign axi0.arcache = s00_axi_arcache;
assign axi0.arprot = s00_axi_arprot;
assign axi0.arvalid = s00_axi_arvalid;
assign s00_axi_arready = axi0.arready;
assign s00_axi_rid = axi0.rid;
assign s00_axi_rdata = axi0.rdata;
assign s00_axi_rresp = axi0.rresp;
assign s00_axi_rlast = axi0.rlast;
assign s00_axi_rvalid = axi0.rvalid;
assign axi0.rready = s00_axi_rready;

axi4_sram sram0(
	.clk(s00_axi_aclk),
	.s(axi0)
	);

endmodule
