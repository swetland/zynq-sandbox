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

module axi4_write_test(
	input clk,
	input start,
	output reg done = 0,
	output reg error = 0,
	axi4_ifc.master m
	);

localparam STATE_IDLE = 4'd0;
localparam STATE_WADDR = 4'd1;
localparam STATE_WDATA = 4'd2;
localparam STATE_ACK = 4'd3;

initial m.awvalid = 0;
initial m.wvalid = 0;

reg [31:0]waddr = 32'h00000000;
reg [31:0]wdata = 32'h12345678;
reg [31:0]wdata_next;

reg [3:0]state = STATE_IDLE;
reg [3:0]state_next;

reg awvalid_next;
reg wvalid_next;
reg bready_next;
//reg wlast_next;

reg [3:0]count = 4'hF;
reg [3:0]count_next;

reg done_next;

wire count_is_zero;
assign count_is_zero = (count == 4'h0);

always_comb begin
	state_next = state;
	count_next = count;
	done_next = done;
	wdata_next = wdata;
	awvalid_next = 1'b0;
	wvalid_next = 1'b0;
	bready_next = 1'b0;
	//wlast_next = 1'b0;

	case (state)
	STATE_IDLE: begin
		if (start) begin
			state_next = STATE_WADDR;
			awvalid_next = 1'b1;
		end
	end
	STATE_WADDR: begin
		if (m.awready) begin
			state_next = STATE_WDATA;
			wvalid_next = 1'b1;
		end else begin
			wvalid_next = 1'b1;
		end
	end
	STATE_WDATA: begin
		if (count_is_zero) begin
			if (m.wready) begin
				state_next = STATE_ACK;
				bready_next = 1'b1;
			end else begin
				wvalid_next = 1;
			end
		end else begin
			wvalid_next = 1'b1;
			if (m.wready) begin
				count_next = count - 4'h1;
				wdata_next = { wdata[3:0], wdata[31:4] };
			end
		end
	end
	STATE_ACK: begin
		if (m.bvalid) begin
			state_next = STATE_IDLE;
			count_next = 4'hF;
			wdata_next = 32'h12345678;
			done_next = 1;
		end else begin
			bready_next = 1'b1;
		end
	end
	default: state_next = STATE_IDLE;
	endcase
end

assign m.awburst = 2'b01;
assign m.awcache = 4'b0000;
assign m.awprot = 3'b000;
assign m.awsize = 3'h2;
assign m.awlen = 8'h0F;
assign m.awlock = 1'b0;

assign m.awaddr = waddr;
assign m.wdata = wdata;
assign m.wstrb = 4'b1111;
assign m.wlast = count_is_zero;

always_ff @(posedge clk) begin
	state <= state_next;
	count <= count_next;
	done <= done_next;
	wdata <= wdata_next;
	m.awvalid <= awvalid_next;
	m.wvalid <= wvalid_next;
	m.bready <= bready_next;
	//m.wlast <= wlast_next;
end

endmodule
