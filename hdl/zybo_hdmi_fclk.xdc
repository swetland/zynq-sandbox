
create_clock -name clk_fpga_0 -period "10.00" [get_pins "zynq/ps7_i/FCLKCLK[0]"]
set_input_jitter clk_fpga_0 0.3

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks sys_clk_pin] -group clk_fpga_0

