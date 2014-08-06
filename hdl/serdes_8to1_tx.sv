`timescale 1ns / 1ps

module serdes_8to1_tx(
	input clk,
	input clkx4,
	input reset,
	output o_p,
	output o_n,
	input [7:0]i_data
	);

wire out;

OBUFDS bufds(.I(out), .O(o_p), .OB(o_n));

OSERDESE2 #(
	.DATA_RATE_OQ("DDR"),
	.DATA_RATE_TQ("SDR"),
	.DATA_WIDTH(8),
	.TRISTATE_WIDTH(1),
	.SERDES_MODE("MASTER"),
	)serdes_lo(
	.CLK(clkx4),
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
	.SHIFTIN1(),
	.SHIFTIN2(),
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

endmodule
