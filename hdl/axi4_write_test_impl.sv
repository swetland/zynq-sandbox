
`timescale 1ns/1ps

module axi4_write_test_impl #(
	parameter integer C_M_AXI_ID_WIDTH	= 1,
	parameter integer C_M_AXI_ADDR_WIDTH	= 32,
	parameter integer C_M_AXI_DATA_WIDTH	= 32
	)
	(
	input wire  start,
	output wire  done,
	output reg  error,
	input wire  M_AXI_ACLK,
	input wire  M_AXI_ARESETN,
	output wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_AWID,
	output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_AWADDR,
	output wire [7 : 0] M_AXI_AWLEN,
	output wire [2 : 0] M_AXI_AWSIZE,
	output wire [1 : 0] M_AXI_AWBURST,
	output wire  M_AXI_AWLOCK,
	output wire [3 : 0] M_AXI_AWCACHE,
	output wire [2 : 0] M_AXI_AWPROT,
	output wire [3 : 0] M_AXI_AWQOS,
	output wire  M_AXI_AWVALID,
	input wire  M_AXI_AWREADY,
	output wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_WDATA,
	output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB,
	output wire  M_AXI_WLAST,
	output wire  M_AXI_WVALID,
	input wire  M_AXI_WREADY,
	input wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_BID,
	input wire [1 : 0] M_AXI_BRESP,
	input wire  M_AXI_BVALID,
	output wire  M_AXI_BREADY,
	output wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_ARID,
	output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_ARADDR,
	output wire [7 : 0] M_AXI_ARLEN,
	output wire [2 : 0] M_AXI_ARSIZE,
	output wire [1 : 0] M_AXI_ARBURST,
	output wire  M_AXI_ARLOCK,
	output wire [3 : 0] M_AXI_ARCACHE,
	output wire [2 : 0] M_AXI_ARPROT,
	output wire [3 : 0] M_AXI_ARQOS,
	output wire  M_AXI_ARVALID,
	input wire  M_AXI_ARREADY,
	input wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_RID,
	input wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_RDATA,
	input wire [1 : 0] M_AXI_RRESP,
	input wire  M_AXI_RLAST,
	input wire  M_AXI_RVALID,
	output wire  M_AXI_RREADY
	);

axi4_ifc axi0();

assign M_AXI_AWID = 0;
assign M_AXI_AWADDR = axi0.awaddr;
assign M_AXI_AWLEN = axi0.awlen;
assign M_AXI_AWSIZE = axi0.awsize;
assign M_AXI_AWBURST = axi0.awburst;
assign M_AXI_AWLOCK = axi0.awlock;
assign M_AXI_AWCACHE = axi0.awcache;
assign M_AXI_AWPROT = 0;
assign M_AXI_AWQOS = 0;
assign M_AXI_AWVALID = axi0.awvalid;
assign axi0.awready = M_AXI_AWREADY;
assign M_AXI_WDATA = axi0.wdata;
assign M_AXI_WSTRB = axi0.wstrb;
assign M_AXI_WLAST = axi0.wlast;
assign M_AXI_WVALID = axi0.wvalid;
assign axi0.wready = M_AXI_WREADY;
assign axi0.bresp = M_AXI_BRESP;
assign axi0.bvalid = M_AXI_BVALID;
assign M_AXI_BREADY = axi0.bready;
assign M_AXI_ARID = 0;
assign M_AXI_ARADDR = axi0.araddr;
assign M_AXI_ARLEN = axi0.arlen;
assign M_AXI_ARSIZE = axi0.arsize;
assign M_AXI_ARBURST = axi0.arburst;
assign M_AXI_ARLOCK = axi0.arlock;
assign M_AXI_ARCACHE = axi0.arcache;
assign M_AXI_ARPROT = 0;
assign M_AXI_ARQOS = 0;
assign M_AXI_ARVALID = axi0.arvalid;
assign axi0.arready = M_AXI_ARREADY;
assign axi0.rdata = M_AXI_RDATA;
assign axi0.rresp = M_AXI_RRESP;
assign axi0.rlast = M_AXI_RLAST;
assign axi0.rvalid = M_AXI_RVALID;
assign M_AXI_RREADY = axi0.rready;

axi4_write_test test0(
	.clk(M_AXI_ACLK),
	.start(start),
	.done(done),
	.error(error),
	.m(axi0)
	);

endmodule
