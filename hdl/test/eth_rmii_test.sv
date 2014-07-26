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

`timescale 1ns / 1ps

module testbench(input clk);

// RMII transport between tx and rx
wire [1:0]eth_data;
wire eth_en;


wire [7:0]txdata;
reg txpacket = 0;
wire txbusy;
wire txadvance;

eth_rmii_tx tx(
	.clk50(clk),
	.tx(eth_data),
	.txen(eth_en),
	.data(txdata),
	.packet(txpacket),
	.busy(txbusy),
	.advance(txadvance)
	);

wire [7:0]rxdata;
wire rxvalid;
wire rxeop;

eth_rmii_rx rx(
	.clk50(clk),
	.rx(eth_data),
	.crs_dv(eth_en),
	.data(rxdata),
	.valid(rxvalid),
	.eop(rxeop),
	.out_tx(),
	.out_txen()
	);

reg txgo = 0;
reg wait_eop = 0;

reg [7:0]pdata[0:15];
reg [3:0]pindex = 0;

assign txdata = pdata[pindex];

reg [7:0]start = 8'b10000000;

always_ff @(posedge clk) begin
	txgo <= start[0];
	start <= { 1'b0, start[7:1] };
end


always_ff @(posedge clk) begin
	if (txgo) begin
		txpacket <= 1;
	end
	if (txpacket) begin
		if (txadvance) begin
			if (pindex == 15) begin
				txpacket <= 0;
				wait_eop <= 1;
			end
			pindex <= pindex + 1;
		end
	end
	if (wait_eop & ~txbusy) begin
		$finish;
	end
end

initial begin
	pdata[0] = 8'hFF;
	pdata[1] = 8'h01;
	pdata[2] = 8'h77;
	pdata[3] = 8'hAA;
	pdata[4] = 8'h00;
	pdata[5] = 8'h10;
	pdata[6] = 8'h20;
	pdata[7] = 8'h30;
	pdata[8] = 8'h40;
	pdata[9] = 8'h50;
	pdata[10] = 8'h60;
	pdata[11] = 8'h70;
	pdata[12] = 8'h80;
	pdata[13] = 8'h90;
	pdata[14] = 8'hAA;
	pdata[15] = 8'h55;
end
	
endmodule
