// Copyright 2014 Travis Geiselbrecht <geist@foobox.com>
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

module xadc(
	input clk,
	input rst,

	input vp,
	input vn,
	input [15:0] aux_channel_n,
	input [15:0] aux_channel_p,

	output [3:0] debug_out,

	axi_ifc.slave axi
);

parameter reg [15:0] CLKDIV = 8; // default ADCCLK divide from input clk
parameter reg [15:0] CHSEL1 = 16'b0000000100000000; // CHSEL1 - enable temperature
parameter reg [15:0] CHSEL2 = 16'b0000000011000000; // CHSEL2 - enable simultaneous channels 6/14, 7/15

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

XADC #(
	.INIT_40(16'b1000000000000000),// No averaging
	.INIT_41(16'b0100111011110000),// Simultaneous sampling mode, Disable unused ALMs, Enable calibration
	.INIT_42(16'b0000000000000000 | (CLKDIV << 8)),// DCLK divide
	.INIT_48(CHSEL1),
	.INIT_49(CHSEL2),
)
adc0(
	.DI(adc_din), // 16 bit in
	.DO(adc_dout), // 16 bit out
	.DADDR(adc_daddr), // 7 bit address
	.DEN(adc_den), // enable
	.DWE(adc_dwe), // write enable
	.DCLK(clk), // clock
	.DRDY(adc_drdy), // data ready out
	.RESET(rst), // reset
	.CONVST(0), // not used
	.CONVSTCLK(0), // not used

	.VN(vn),
	.VP(vp),
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

localparam ADC_REG_COUNT = 32;
localparam ADC_REG_COUNT_BITS = $clog2(ADC_REG_COUNT);
reg [15:0] adc_data [ADC_REG_COUNT];

typedef enum {
	WAIT_FOR_EOS,
	READ_REG,
	READ_REG_WAIT
} state_t;

state_t state = WAIT_FOR_EOS;
reg [ADC_REG_COUNT_BITS-1:0] reg_count;

/* wait for EOS then pull out readings from each ADC we care about */
always_ff @(posedge clk) begin
	adc_den = 0;
	adc_dwe = 0;
	adc_daddr = 0;
	adc_din = 0;

	if (rst) begin
		state = WAIT_FOR_EOS;
		for (int i = 0; i < ADC_REG_COUNT; i++)
			adc_data[i] = 0;
	end else begin
		case (state)
		WAIT_FOR_EOS: begin
			reg_count = 0;
			if (adc_eos) state = READ_REG;
		end
		READ_REG: begin
			if (!adc_drdy) begin
				adc_den = 1;
				adc_daddr = { 2'b0, reg_count };
				state = READ_REG_WAIT;
			end
		end
		READ_REG_WAIT: begin
			if (adc_drdy) begin
				adc_data[reg_count] <= adc_dout;
				if (reg_count == ADC_REG_COUNT[ADC_REG_COUNT_BITS-1:0] - 1) begin
					reg_count = 0;
					state = WAIT_FOR_EOS;
				end else begin
					reg_count = reg_count + 1;
					state = READ_REG;
				end
			end
		end
		endcase
	end
end

/* AXI stuffs */
wire [31:0]wdata;
reg [31:0]rdata;
wire [4:0]wreg;
wire [4:0]rreg;
wire wr;
wire rd;

axi_registers #(
	.R_ADDR_WIDTH(5)
)
regs(
	.clk(clk),
	.s(axi),
	.o_rreg(rreg),
	.o_wreg(wreg),
	.i_rdata(rdata),
	.o_wdata(wdata),
	.o_rd(rd),
	.o_wr(wr)
	);

always_comb begin
	rdata = { 16'h0, adc_data[rreg[ADC_REG_COUNT_BITS-1:0]] };
end

always_ff @(posedge clk) begin
	if (wr) begin
		case (wreg)
		default: ;
		endcase
	end
end

assign debug_out[0] = adc_eoc;
assign debug_out[1] = adc_eos;
assign debug_out[2] = adc_busy;
assign debug_out[3] = 0;

endmodule

// vim: set noexpandtab:
