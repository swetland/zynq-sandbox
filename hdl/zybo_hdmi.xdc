##Clock signal
##IO_L11P_T1_SRCC_35	
set_property PACKAGE_PIN L16 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports clk]

##HDMI Signals
##IO_L13N_T2_MRCC_35
set_property PACKAGE_PIN H17 [get_ports hdmi_clk_n]
set_property IOSTANDARD TMDS_33 [get_ports hdmi_clk_n]

##IO_L13P_T2_MRCC_35
set_property PACKAGE_PIN H16 [get_ports hdmi_clk_p]
set_property IOSTANDARD TMDS_33 [get_ports hdmi_clk_p]

##IO_L4N_T0_35
set_property PACKAGE_PIN D20 [get_ports {hdmi_d_n[0]}]
set_property IOSTANDARD TMDS_33 [get_ports {hdmi_d_n[0]}]

##IO_L4P_T0_35
set_property PACKAGE_PIN D19 [get_ports {hdmi_d_p[0]}]
set_property IOSTANDARD TMDS_33 [get_ports {hdmi_d_p[0]}]

##IO_L1N_T0_AD0N_35
set_property PACKAGE_PIN B20 [get_ports {hdmi_d_n[1]}]
set_property IOSTANDARD TMDS_33 [get_ports {hdmi_d_n[1]}]

##IO_L1P_T0_AD0P_35
set_property PACKAGE_PIN C20 [get_ports {hdmi_d_p[1]}]
set_property IOSTANDARD TMDS_33 [get_ports {hdmi_d_p[1]}]

##IO_L2N_T0_AD8N_35
set_property PACKAGE_PIN A20 [get_ports {hdmi_d_n[2]}]
set_property IOSTANDARD TMDS_33 [get_ports {hdmi_d_n[2]}]

##IO_L2P_T0_AD8P_35
set_property PACKAGE_PIN B19 [get_ports {hdmi_d_p[2]}]
set_property IOSTANDARD TMDS_33 [get_ports {hdmi_d_p[2]}]


