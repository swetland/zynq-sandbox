
create_clock -name clk_fpga_0 -period "10.00" [get_pins "zynq/ps7_i/FCLKCLK[0]"]
set_input_jitter clk_fpga_0 0.3

