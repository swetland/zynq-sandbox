/* Copyright 2014 Brian Swetland <swetland@frotz.net>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

`timescale 1ns/1ps

module axi4lite_jtag_debug_ip #(
	parameter integer C_M00_AXI_ADDR_WIDTH	= 32,
	parameter integer C_M00_AXI_DATA_WIDTH	= 32
	) (
	input wire  m00_axi_aclk,
	output wire [C_M00_AXI_ADDR_WIDTH-1 : 0] m00_axi_awaddr,
	output wire  m00_axi_awlock,
	output wire [3 : 0] m00_axi_awcache,
	output wire [2 : 0] m00_axi_awprot,
	output reg m00_axi_awvalid,
	input wire  m00_axi_awready,
	output wire [C_M00_AXI_DATA_WIDTH-1 : 0] m00_axi_wdata,
	output wire [C_M00_AXI_DATA_WIDTH/8-1 : 0] m00_axi_wstrb,
	output reg m00_axi_wvalid,
	input wire  m00_axi_wready,
	input wire [1 : 0] m00_axi_bresp,
	input wire  m00_axi_bvalid,
	output reg m00_axi_bready,
	output wire [C_M00_AXI_ADDR_WIDTH-1 : 0] m00_axi_araddr,
	output wire  m00_axi_arlock,
	output wire [3 : 0] m00_axi_arcache,
	output wire [2 : 0] m00_axi_arprot,
	output reg m00_axi_arvalid,
	input wire  m00_axi_arready,
	input wire [C_M00_AXI_DATA_WIDTH-1 : 0] m00_axi_rdata,
	input wire [1 : 0] m00_axi_rresp,
	input wire  m00_axi_rvalid,
	output reg m00_axi_rready
	);

wire clk;
assign clk = m00_axi_aclk;

assign m00_axi_awlock = 0;
assign m00_axi_awcache = 0;
assign m00_axi_awprot = 0;
assign m00_axi_arlock = 0;
assign m00_axi_arcache = 0;
assign m00_axi_arprot = 0;
assign m00_axi_wstrb = 4'b1111;

reg [31:0]txn_addr;
reg [31:0]txn_addr_next;

reg [31:0]txn_data;
reg [31:0]txn_data_next;

localparam STATE_IDLE   = 3'd0;
localparam STATE_WADDR  = 3'd1;
localparam STATE_WDATA  = 3'd2;
localparam STATE_WACK   = 3'd3;
localparam STATE_RADDR  = 3'd4;
localparam STATE_RDATA  = 3'd5;

localparam DBG_IDCODE		= 32'h4158494d;

localparam DBG_R_IDCODE                 = 3'd0;
localparam DBG_R_GETDATA                = 3'd1;
localparam DBG_R_GETADDR                = 3'd2;
localparam DBG_R_STATUS                 = 3'd7;

localparam DBG_W_SETADDR_READ           = 3'd1;
localparam DBG_W_SETADDR                = 3'd2;
localparam DBG_W_SETDATA_WRITE          = 3'd3;
localparam DBG_W_SETDATA_INCADDR_WRITE  = 3'd4;

reg [2:0]state = STATE_IDLE;
reg [2:0]state_next;

reg txn_done = 0;
reg txn_done_next;

reg awvalid_next;
reg wvalid_next;
reg bready_next;
reg arvalid_next;
reg rready_next;

assign m00_axi_awaddr = txn_addr;
assign m00_axi_araddr = txn_addr;
assign m00_axi_wdata = txn_data;

wire dbg_rd, dbg_wr;
wire [2:0]dbg_addr;
wire [31:0]dbg_wdata;
reg [31:0]dbg_rdata;

always @(posedge clk) begin
	state <= state_next;
	txn_addr <= txn_addr_next;
	txn_data <= txn_data_next;
	txn_done <= txn_done_next;
	m00_axi_awvalid = awvalid_next;
	m00_axi_wvalid = wvalid_next;
	m00_axi_bready = bready_next;
	m00_axi_arvalid = arvalid_next;
	m00_axi_rready = rready_next;
end

always @(*) begin
	state_next = state;
	txn_addr_next = txn_addr;
	txn_data_next = txn_data;
	txn_done_next = 0;
	awvalid_next = 0;
	wvalid_next = 0;
	bready_next = 0;
	arvalid_next = 0;
	rready_next = 0;
	case (state)
	STATE_IDLE: begin
		if (dbg_wr) begin
			case (dbg_addr)
			DBG_W_SETADDR: begin
				txn_addr_next = dbg_wdata;
			end
			DBG_W_SETADDR_READ: begin
				state_next = STATE_RADDR;
				txn_addr_next = dbg_wdata;
				arvalid_next = 1;
			end
			DBG_W_SETDATA_WRITE: begin
				state_next = STATE_WADDR;
				txn_data_next = dbg_wdata;
				awvalid_next = 1;
			end
			DBG_W_SETDATA_INCADDR_WRITE: begin
				state_next = STATE_WADDR;
				txn_data_next = dbg_wdata;
				txn_addr_next = txn_addr + 4;
				awvalid_next = 1;
			end
			default: ;
			endcase
		end else begin
			txn_done_next = 1;
		end
	end
	STATE_WADDR: begin
		if (m00_axi_awready) begin
			state_next = STATE_WDATA;
			wvalid_next = 1;
		end else begin
			awvalid_next = 1;
		end
	end
	STATE_WDATA: begin
		if (m00_axi_wready) begin
			state_next = STATE_WACK;
			bready_next = 1;
		end else begin
			wvalid_next = 1;
		end
	end
	STATE_WACK: begin
		if (m00_axi_bvalid) begin
			state_next = STATE_IDLE;
			txn_done_next = 1;
		end else begin
			bready_next = 1;
		end
	end
	STATE_RADDR: begin
		if (m00_axi_arready) begin
			state_next = STATE_RDATA;
			rready_next = 1;
		end else begin
			arvalid_next = 1;
		end
	end
	STATE_RDATA: begin
		if (m00_axi_rvalid) begin
			state_next = STATE_IDLE;
			txn_done_next = 1;
			txn_data_next = m00_axi_rdata;
		end else begin
			rready_next = 1;
		end
	end
	default: begin
		state_next = STATE_IDLE;
	end
	endcase
end

always @(*) begin
	case (dbg_addr)
	DBG_R_IDCODE:    dbg_rdata = DBG_IDCODE;
	DBG_R_GETDATA:   dbg_rdata = txn_data;
	DBG_R_GETADDR:   dbg_rdata = txn_addr;
	DBG_R_STATUS:    dbg_rdata = { 31'd0, txn_done };
	default:         dbg_rdata = 32'hFFFFFFFF;
	endcase
end

xilinx_jtag_debugport jtag(
	.o_rd(dbg_rd),
	.o_wr(dbg_wr),
	.o_addr(dbg_addr),
	.o_wdata(dbg_wdata),
	.i_rdata(dbg_rdata),
	.clk(clk)
	);

endmodule
