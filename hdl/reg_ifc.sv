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

`timescale 1ns/1ps

// write:
//   slave samples wr, waddr, wdata on posedge clk
//   if wr==1, wdata written to waddr
// read:
//   slave samples rd, raddr on posedge clk
//   if rd==1, read is requested
//   master samples rdata on next posedge clk 

interface reg_ifc;

parameter AWIDTH = 2;
parameter DWIDTH = 32;

logic [AWIDTH-1:0]raddr;
logic [AWIDTH-1:0]waddr;
logic rd;
logic wr;
logic [DWIDTH-1:0]rdata;
logic [DWIDTH-1:0]wdata;

modport master (
	output raddr, waddr, rd, wr, wdata,
	input rdata
	);

modport slave (
	input raddr, waddr, rd, wr, wdata,
	output rdata
	);

endinterface
