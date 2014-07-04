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
module testbench(inout clk);
`else
module testbench();
reg clk = 0;
always #5 clk = ~clk;
`endif

reg go = 0;

axi_ifc axi0();

axi_pattern_writer writer0(
	.clk(clk),
	.trigger(go),
	.m(axi0)
	);

axi_sram sram0(
	.clk(clk),
	.s(axi0)
	);

integer count = 0;

always_ff @(posedge clk) begin
	count <= count + 1;
	case (count)
	5: go <= 1;
	6: go <= 0;
	30: go <= 1;
	31: go <= 0;
	100: $finish();
	endcase
end

endmodule

