`timescale 1ns / 1ps

module serdes_10to1_tx(
	input clk,
	input clkx5,
	input reset,
	output o_p,
	output o_n,
	input [9:0]i_data
	);

wire out, shift1, shift2;

OBUFDS bufds(.I(out), .O(o_p), .OB(o_n));

OSERDESE2 #(
	.DATA_RATE_OQ("DDR"),
	.DATA_RATE_TQ("SDR"),
	.DATA_WIDTH(10),
	.TRISTATE_WIDTH(1),
	.SERDES_MODE("MASTER"),
	)serdes_lo(
	.CLK(clkx5),
	.CLKDIV(clk),
	.D1(i_data[0]),
	.D2(i_data[1]),
	.D3(i_data[2]),
	.D4(i_data[3]),
	.D5(i_data[4]),
	.D6(i_data[5]),
	.D7(i_data[6]),
	.D8(i_data[7]),
	.OCE(1),
	.OFB(),
	.OQ(out),
	.RST(reset),
	.SHIFTIN1(shift1),
	.SHIFTIN2(shift2),
	.SHIFTOUT1(),
	.SHIFTOUT2(),
	.TBYTEIN(0),
	.TBYTEOUT(),
	.TCE(0),
	.TFB(),
	.TQ(),
	.T1(0),
	.T2(0),
	.T3(0),
	.T4(0)
	);

OSERDESE2 #(
	.DATA_RATE_OQ("DDR"),
	.DATA_RATE_TQ("SDR"),
	.DATA_WIDTH(10),
	.TRISTATE_WIDTH(1),
	.SERDES_MODE("SLAVE"),
	)serdes_hi(
	.CLK(clkx5),
	.CLKDIV(clk),
	.D1(0),
	.D2(0),
	.D3(i_data[8]),
	.D4(i_data[9]),
	.D5(0),
	.D6(0),
	.D7(0),
	.D8(0),
	.OCE(1),
	.OFB(),
	.OQ(),
	.RST(reset),
	.SHIFTIN1(0),
	.SHIFTIN2(0),
	.SHIFTOUT1(shift1),
	.SHIFTOUT2(shift2),
	.TBYTEIN(0),
	.TBYTEOUT(),
	.TCE(0),
	.TFB(),
	.TQ(),
	.T1(0),
	.T2(0),
	.T3(0),
	.T4(0)
	);

endmodule
