`timescale 1ps/1ps

// F(CLKIN) = 1 / CLKIN_PERIOD
// F(VCO) = F(CLKIN) * ( VCOMUL / VCODIV )
// F(CLKn) = F(VCO) / OUTnDIV

module mmcm_1in_3out(
	input i_clk,
	output o_clk0,
	output o_clk1,
	output o_clk2
	);

parameter CLKIN_PERIOD = 10.0;
parameter VCO_MUL = 10.000;
parameter VCO_DIV = 2;
parameter OUT0_DIV = 2.000;
parameter OUT1_DIV = 2;
parameter OUT2_DIV = 2;

wire clkfb, clkfb_i, clk0, clk1, clk2;

BUFG bufg_clkfb(.I(clkfb_i), .O(clkfb));
BUFG bufg_pixclk(.I(clk0), .O(o_clk0));
BUFG bufg_pixclkx5(.I(clk1), .O(o_clk1));
BUFG bufg_pixclkx10(.I(clk2), .O(o_clk2));

MMCME2_ADV #(
	.BANDWIDTH("OPTIMIZED"),
	.CLKOUT4_CASCADE("FALSE"),
	.COMPENSATION("ZHOLD"),
	.STARTUP_WAIT("FALSE"),
	.DIVCLK_DIVIDE(VCO_DIV),
	.CLKFBOUT_MULT_F(VCO_MUL),
	.CLKFBOUT_PHASE(0.000),
	.CLKFBOUT_USE_FINE_PS("FALSE"),
	.CLKOUT0_DIVIDE_F(OUT0_DIV),
	.CLKOUT0_PHASE(0.000),
	.CLKOUT0_DUTY_CYCLE(0.500),
	.CLKOUT0_USE_FINE_PS("FALSE"),
	.CLKOUT1_DIVIDE(OUT1_DIV),
	.CLKOUT1_PHASE(0.000),
	.CLKOUT1_DUTY_CYCLE(0.500),
	.CLKOUT1_USE_FINE_PS("FALSE"),
	.CLKOUT2_DIVIDE(OUT2_DIV),
	.CLKOUT2_PHASE(0.000),
	.CLKOUT2_DUTY_CYCLE(0.500),
	.CLKOUT2_USE_FINE_PS("FALSE"),
	.CLKIN1_PERIOD(8.0),
	.REF_JITTER1(0.010)
	) mmcm_adv_inst (
	.CLKFBOUT(clkfb_i),
	.CLKFBOUTB(),
	.CLKOUT0(clk0),
	.CLKOUT0B(),
	.CLKOUT1(clk1),
	.CLKOUT1B(),
	.CLKOUT2(clk2),
	.CLKOUT2B(),
	.CLKOUT3(),
	.CLKOUT3B(),
	.CLKOUT4(),
	.CLKOUT5(),
	.CLKOUT6(),

	.CLKFBIN(clkfb),
	.CLKIN1(i_clk),
	.CLKIN2(0),

	.CLKINSEL(1),

	.DADDR(0),
	.DCLK(0),
	.DEN(0),
	.DI(0),
	.DO(),
	.DRDY(),
	.DWE(0),

	.PSCLK(0),
	.PSEN(0),
	.PSINCDEC(0),
	.PSDONE(),

	.LOCKED(),
	.CLKINSTOPPED(),
	.CLKFBSTOPPED(),
	.PWRDWN(0),
	.RST(0)
	);

endmodule
