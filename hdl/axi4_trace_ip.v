
`timescale 1 ps / 1 ps

module axi4_trace_ip # (
	parameter integer C_S00_AXI_ID_WIDTH	= 1,
	parameter integer C_S00_AXI_DATA_WIDTH	= 32,
	parameter integer C_S00_AXI_ADDR_WIDTH	= 32,

	parameter integer C_M00_AXI_BURST_LEN	= 16,
	parameter integer C_M00_AXI_ID_WIDTH	= 1,
	parameter integer C_M00_AXI_ADDR_WIDTH	= 32,
	parameter integer C_M00_AXI_DATA_WIDTH	= 32
	)
	(
	output wire [31:0]trace_data,
	output wire trigger_out,

	input wire  s00_axi_aclk,
	input wire [C_S00_AXI_ID_WIDTH-1 : 0] s00_axi_awid,
	input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
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
	input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
	input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
	input wire  s00_axi_wlast,
	input wire  s00_axi_wvalid,
	output wire  s00_axi_wready,
	output wire [C_S00_AXI_ID_WIDTH-1 : 0] s00_axi_bid,
	output wire [1 : 0] s00_axi_bresp,
	output wire  s00_axi_bvalid,
	input wire  s00_axi_bready,
	input wire [C_S00_AXI_ID_WIDTH-1 : 0] s00_axi_arid,
	input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
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
	output wire [C_S00_AXI_ID_WIDTH-1 : 0] s00_axi_rid,
	output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
	output wire [1 : 0] s00_axi_rresp,
	output wire  s00_axi_rlast,
	output wire  s00_axi_rvalid,
	input wire  s00_axi_rready,

	input wire  m00_axi_aclk,
	output wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_awid,
	output wire [C_M00_AXI_ADDR_WIDTH-1 : 0] m00_axi_awaddr,
	output wire [7 : 0] m00_axi_awlen,
	output wire [2 : 0] m00_axi_awsize,
	output wire [1 : 0] m00_axi_awburst,
	output wire  m00_axi_awlock,
	output wire [3 : 0] m00_axi_awcache,
	output wire [2 : 0] m00_axi_awprot,
	output wire [3 : 0] m00_axi_awqos,
	output wire  m00_axi_awvalid,
	input wire  m00_axi_awready,
	output wire [C_M00_AXI_DATA_WIDTH-1 : 0] m00_axi_wdata,
	output wire [C_M00_AXI_DATA_WIDTH/8-1 : 0] m00_axi_wstrb,
	output wire  m00_axi_wlast,
	output wire  m00_axi_wvalid,
	input wire  m00_axi_wready,
	input wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_bid,
	input wire [1 : 0] m00_axi_bresp,
	input wire  m00_axi_bvalid,
	output wire  m00_axi_bready,
	output wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_arid,
	output wire [C_M00_AXI_ADDR_WIDTH-1 : 0] m00_axi_araddr,
	output wire [7 : 0] m00_axi_arlen,
	output wire [2 : 0] m00_axi_arsize,
	output wire [1 : 0] m00_axi_arburst,
	output wire  m00_axi_arlock,
	output wire [3 : 0] m00_axi_arcache,
	output wire [2 : 0] m00_axi_arprot,
	output wire [3 : 0] m00_axi_arqos,
	output wire  m00_axi_arvalid,
	input wire  m00_axi_arready,
	input wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_rid,
	input wire [C_M00_AXI_DATA_WIDTH-1 : 0] m00_axi_rdata,
	input wire [1 : 0] m00_axi_rresp,
	input wire  m00_axi_rlast,
	input wire  m00_axi_rvalid,
	output wire  m00_axi_rready
	);

`ifdef TRACE_WRITES
assign trace_data = {
//                   AA
//                   WW        WWW  BBBB
// LLLL LLLL  -SSS BBVR  TTTT -LVR  RRVR XXXX
	s00_axi_awlen, 
	1'b0, s00_axi_awsize, s00_axi_awburst, s00_axi_awvalid, m00_axi_awready,
	s00_axi_wstrb, 1'b0, s00_axi_wlast, s00_axi_wvalid, m00_axi_wready,
  	m00_axi_bresp, m00_axi_bvalid, s00_axi_bready, 4'b0000
};
`else
assign trace_data = {
//                   AA
//                   WW        WWW  BBBB
// LLLL LLLL  -SSS BBVR  TTTT -LVR  RRVR XXXX
	s00_axi_arlen, 
	1'b0, s00_axi_arsize, s00_axi_arburst, s00_axi_arvalid, m00_axi_arready,
	4'b0000, 1'b0, m00_axi_rlast, m00_axi_rvalid, s00_axi_rready,
  	s00_axi_rresp, 1'b0, 1'b0, 4'b0000
};
`endif

wire CLK;
assign CLK = s00_axi_aclk;

localparam DEPTH = 255;

reg [31:0]tracectrl[0:DEPTH];
reg [31:0]traceaddr[0:DEPTH];
reg [31:0]tracedata[0:DEPTH];

reg tracego = 0;

wire dbg_rd, dbg_wr;
wire [2:0]dbg_addr;
wire [31:0]dbg_wdata;
reg [31:0]dbg_rdata;

reg [7:0]tracewptr = 0;
reg [7:0]tracerptr = 0;

wire tracefull;
assign tracefull = (tracewptr == DEPTH);

wire trigger;
assign trigger = tracego | s00_axi_awvalid | s00_axi_arvalid;

always @(*) begin
	case (dbg_addr)
	3'd0:    dbg_rdata = 32'h4158494d; // AXIT
	3'd1:    dbg_rdata = tracectrl[tracerptr];
	3'd2:    dbg_rdata = traceaddr[tracerptr];
	3'd3:    dbg_rdata = tracedata[tracerptr];
	3'd6:    dbg_rdata = { 24'd0, tracewptr };
	default: dbg_rdata = 32'hFFFFFFFF;
	endcase
end

reg do_reset;
reg do_incr;

assign trigger_out = do_reset;

always @(*) begin
	do_reset = 0;
	do_incr = 0;
	if (dbg_wr) begin
		case (dbg_addr)
		1: do_incr = 1;
		7: do_reset = 1;
		endcase
	end
end

always @(posedge CLK) begin
	if (do_reset) begin
		tracego <= 0;
		tracewptr <= 0;
		tracerptr <= 0;
	end else begin
		if (trigger) begin
			tracego <= 1;
			if (~tracefull) begin
				tracectrl[tracewptr] <= trace_data;
`ifdef TRACE_WRITES
				traceaddr[tracewptr] <= s00_axi_awaddr;
				tracedata[tracewptr] <= s00_axi_wdata;
`else
				traceaddr[tracewptr] <= s00_axi_araddr;
				tracedata[tracewptr] <= s00_axi_rdata;
`endif
				tracewptr <= tracewptr + 1;
			end
		end
		if (do_incr) begin
			tracerptr <= tracerptr + 1;
		end
	end
end

xilinx_jtag_debugport jtag(
	.o_rd(dbg_rd),
	.o_wr(dbg_wr),
	.o_addr(dbg_addr),
	.o_wdata(dbg_wdata),
	.i_rdata(dbg_rdata),
	.clk(CLK)
	);


assign m00_axi_awid = s00_axi_awid;
assign m00_axi_awaddr = s00_axi_awaddr;
assign m00_axi_awlen = s00_axi_awlen;
assign m00_axi_awsize = s00_axi_awsize;
assign m00_axi_awburst = s00_axi_awburst;
assign m00_axi_awlock = s00_axi_awlock;
assign m00_axi_awcache = s00_axi_awcache;
assign m00_axi_awprot = s00_axi_awprot;
assign m00_axi_awqos = s00_axi_awqos;
assign m00_axi_awvalid = s00_axi_awvalid;
assign s00_axi_awready = m00_axi_awready;
assign m00_axi_wdata = s00_axi_wdata;
assign m00_axi_wstrb = s00_axi_wstrb;
assign m00_axi_wlast = s00_axi_wlast;
assign m00_axi_wvalid = s00_axi_wvalid;
assign s00_axi_wready = m00_axi_wready;
assign s00_axi_bid = m00_axi_bid;
assign s00_axi_bresp = m00_axi_bresp;
assign s00_axi_bvalid = m00_axi_bvalid;
assign m00_axi_bready = s00_axi_bready;
assign m00_axi_arid = s00_axi_arid;
assign m00_axi_araddr = s00_axi_araddr;
assign m00_axi_arlen = s00_axi_arlen;
assign m00_axi_arsize = s00_axi_arsize;
assign m00_axi_arburst = s00_axi_arburst;
assign m00_axi_arlock = s00_axi_arlock;
assign m00_axi_arcache = s00_axi_arcache;
assign m00_axi_arprot = s00_axi_arprot;
assign m00_axi_arqos = s00_axi_arqos;
assign m00_axi_arvalid = s00_axi_arvalid;
assign s00_axi_arready = m00_axi_arready;
assign s00_axi_rid = m00_axi_rid;
assign s00_axi_rdata = m00_axi_rdata;
assign s00_axi_rresp = m00_axi_rresp;
assign s00_axi_rlast = m00_axi_rlast;
assign s00_axi_rvalid = m00_axi_rvalid;
assign m00_axi_rready = s00_axi_rready;

endmodule
