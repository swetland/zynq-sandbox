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

module top(
	input clk,
	input [3:0]sw,
	input [3:0]btn,
	input [3:0]ja_p,
	input [3:0]ja_n,
	output [3:0]jb_p,
	output [3:0]jb_n,
	output reg [3:0]led
	);

axi_ifc #(.IWIDTH(12),.AXI3(1)) axi_ctl();

wire fclk;
wire axiclk = clk; // 125Mhz clock from external ethernet phy

zynq_ps7 zynq(
	.fclk0(fclk),
	.m_axi_gp0_clk(axiclk),
	.m_axi_gp0(axi_ctl)
	);

wire [15:0] aux_channel_n;
wire [15:0] aux_channel_p;

assign aux_channel_n[14] = ja_n[0];
assign aux_channel_p[14] = ja_p[0];
assign aux_channel_n[7] = ja_n[1];
assign aux_channel_p[7] = ja_p[1];
assign aux_channel_n[15] = ja_n[2];
assign aux_channel_p[15] = ja_p[2];
assign aux_channel_n[6] = ja_n[3];
assign aux_channel_p[6] = ja_p[3];

reg adc_den;
reg adc_dwe;
reg [15:0] adc_din;
wire [15:0] adc_dout;
reg [6:0] adc_daddr;
wire adc_drdy;

wire [4:0] adc_channel;
wire adc_eoc;
wire adc_eos;
wire adc_busy;

(* DONT_TOUCH = "true" *)
XADC #(
	.INIT_40(16'h9000),// averaging of 16 selected for external channels
	.INIT_41(16'h2ef0),// Continuous Seq Mode, Disable unused ALMs, Enable calibration
	.INIT_42(16'h0500),// DCLK divide 125Mhz / 5
	.INIT_48(16'b0000011100000001),// CHSEL1 - enable Temp, VCCINT, VCCAUX, and calibration
	.INIT_49(16'b1100000011000000),// CHSEL2 - enable aux channels 15, 14, 7, 6
)
adc0(
	.DI(adc_din), // 16 bit in
	.DO(adc_dout), // 16 bit out
	.DADDR(adc_daddr), // 7 bit address
	.DEN(adc_den), // enable
	.DWE(adc_dwe), // write enable
	.DCLK(axiclk), // clock
	.DRDY(adc_drdy), // data ready out
	.RESET(0), // reset
	.CONVST(0), // not used
	.CONVSTCLK(0), // not used

	.VP(0),
	.VN(0),
	.VAUXN(aux_channel_n[15:0]),
	.VAUXP(aux_channel_p[15:0]),

	.ALM(), // alarm outputs
	.OT(), // over temp alarm output

	.MUXADDR(),// not used
	.CHANNEL(adc_channel), // channel output

	.EOC(adc_eoc), // end of conversion
	.EOS(adc_eos), // end of sequence
	.BUSY(adc_busy), // busy during adc conversion

	.JTAGBUSY(),// not used
	.JTAGLOCKED(),// not used
	.JTAGMODIFIED()// not used
);

parameter integer ADC_REG_COUNT = 8;
reg [15:0] adc_data [ADC_REG_COUNT];

typedef enum {
	WAIT_FOR_EOS,
	READ_REG,
	READ_REG_WAIT
} state_t;

state_t state = WAIT_FOR_EOS;
int reg_count;
reg [6:0] reg_num;

/* mapping of current register count to XADC register */
always_comb begin
	case (reg_count)
	0: reg_num = 7'h0; // temperature
	1: reg_num = 7'h1; // VCCINT
	2: reg_num = 7'h2; // VCCAUX
	3: reg_num = 7'h5; // VCCREFN
	4: reg_num = 7'h10 + 7'd14; // AD14
	5: reg_num = 7'h10 + 7'd6;  // AD6
	6: reg_num = 7'h10 + 7'd15; // AD15
	7: reg_num = 7'h10 + 7'd7;  // AD7
	default: reg_num = 0;
	endcase
end

/* wait for EOS then pull out readings from each ADC we care about */
always_ff @(posedge axiclk) begin
	adc_den = 0;
	adc_dwe = 0;
	adc_daddr = 0;
	adc_din = 0;
	case (state)
	WAIT_FOR_EOS: begin
		reg_count = 0;
		if (adc_eos == 1) state = READ_REG;
	end
	READ_REG: begin
		if (adc_drdy == 0) begin
			adc_den = 1;
			adc_daddr = reg_num[6:0];
			state = READ_REG_WAIT;
		end
	end
	READ_REG_WAIT: begin
		if (adc_drdy) begin
			adc_data[reg_count] <= adc_dout;
			reg_count = reg_count + 1;
			if (reg_count == ADC_REG_COUNT) begin
				state = WAIT_FOR_EOS;
			end else begin
				state = READ_REG;
			end
		end
	end
	endcase
end

/* AXI stuffs */
wire [31:0]wdata;
reg [31:0]rdata;
wire [2:0]wreg;
wire [2:0]rreg;
wire wr;
wire rd;

axi_registers #(
	.R_ADDR_WIDTH(3)
)
regs(
	.clk(axiclk),
	.s(axi_ctl),
	.o_rreg(rreg),
	.o_wreg(wreg),
	.i_rdata(rdata),
	.o_wdata(wdata),
	.o_rd(rd),
	.o_wr(wr)
	);

always_comb begin
	rdata = { 16'h0, adc_data[rreg[2:0]] };
end

always_ff @(posedge axiclk) begin
	if (wr) begin
		case (wreg)
		0: ;
		1: ;
		2: ;
		3: ;
		endcase
	end
end

// debugging
assign led[0] = adc_eoc;
assign led[1] = adc_eos;
assign led[2] = adc_busy;

assign jb_p[0] = adc_eoc;
assign jb_p[1] = adc_eos;
assign jb_p[2] = adc_busy;

endmodule

// vim: set noexpandtab:
