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

module testbench(input clk);

axi4_ifc #(.IWIDTH(5)) axi0();

reg [31:0]count = 0;

initial axi0.arvalid = 0;
initial axi0.rready = 0;
initial axi0.arburst = 1;
initial axi0.arsize = 2;
initial axi0.arcache = 0;
initial axi0.arprot = 0;

always @(posedge clk) begin
	count <= count + 1;
	if (count == 32'd50) begin
		axi0.araddr <= 0;
		axi0.arlen <= 7;
		axi0.arvalid <= 1;
	end
	if (axi0.arvalid & axi0.arready) begin
		axi0.arvalid <= 0;
		axi0.rready <= 1;
	end
	if (axi0.rready & axi0.rvalid & axi0.rlast) begin
		axi0.rready <= 0;
	end
	if (count == 32'd100) $finish;
end

reg [7:0]starts = 8'b00000001;
always @(posedge clk)
	starts <= { starts[6:0], 1'b0 };

wire done;

axi4_write_test writer(
	.clk(clk),
	.done(done),
	.error(),
	.start(starts[7]),
	.m(axi0)
	);

axi4_sram sram(
	.clk(clk),
	.s(axi0)
	);

endmodule
