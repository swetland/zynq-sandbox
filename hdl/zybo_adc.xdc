##Clock signal
##IO_L11P_T1_SRCC_35	
set_property PACKAGE_PIN L16 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports clk]

##Switches
##IO_L19N_T3_VREF_35
set_property PACKAGE_PIN G15 [get_ports {sw[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[0]}]

##IO_L24P_T3_34
set_property PACKAGE_PIN P15 [get_ports {sw[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[1]}]

##IO_L4N_T0_34
set_property PACKAGE_PIN W13 [get_ports {sw[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[2]}]

##IO_L9P_T1_DQS_34
set_property PACKAGE_PIN T16 [get_ports {sw[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[3]}]

##Buttons
##IO_L20N_T3_34
set_property PACKAGE_PIN R18 [get_ports {btn[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn[0]}]

##IO_L24N_T3_34
set_property PACKAGE_PIN P16 [get_ports {btn[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn[1]}]

##IO_L18P_T2_34
set_property PACKAGE_PIN V16 [get_ports {btn[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn[2]}]

##IO_L7P_T1_34
set_property PACKAGE_PIN Y16 [get_ports {btn[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn[3]}]

##LEDs
##IO_L23P_T3_35
set_property PACKAGE_PIN M14 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]

##IO_L23N_T3_35
set_property PACKAGE_PIN M15 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]

##IO_0_35
set_property PACKAGE_PIN G14 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]

##IO_L3N_T0_DQS_AD1N_35
set_property PACKAGE_PIN D18 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]

#Pmod Header JA (XADC)
#IO_L21N_T3_DQS_AD14N_35
set_property PACKAGE_PIN N16 [get_ports {ja_n[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ja_n[0]}]

##IO_L21P_T3_DQS_AD14P_35
set_property PACKAGE_PIN N15 [get_ports {ja_p[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ja_p[0]}]

#IO_L22N_T3_AD7N_35
set_property PACKAGE_PIN L15 [get_ports {ja_n[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ja_n[1]}]

#IO_L22P_T3_AD7P_35
set_property PACKAGE_PIN L14 [get_ports {ja_p[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ja_p[1]}]

#IO_L24N_T3_AD15N_35
set_property PACKAGE_PIN J16 [get_ports {ja_n[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ja_n[2]}]

#IO_L24P_T3_AD15P_35
set_property PACKAGE_PIN K16 [get_ports {ja_p[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ja_p[2]}]

#IO_L20N_T3_AD6N_35
set_property PACKAGE_PIN J14 [get_ports {ja_n[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ja_n[3]}]

#IO_L20P_T3_AD6P_35
set_property PACKAGE_PIN K14 [get_ports {ja_p[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ja_p[3]}]

#Pmod Header JB
#IO_L15N_T2_DQS_34
set_property PACKAGE_PIN U20 [get_ports {jb_n[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {jb_n[0]}]

#IO_L15P_T2_DQS_34
set_property PACKAGE_PIN T20 [get_ports {jb_p[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {jb_p[0]}]

#IO_L16N_T2_34
set_property PACKAGE_PIN W20 [get_ports {jb_n[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {jb_n[1]}]

#IO_L16P_T2_34
set_property PACKAGE_PIN V20 [get_ports {jb_p[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {jb_p[1]}]

#IO_L17N_T2_34
set_property PACKAGE_PIN Y19 [get_ports {jb_n[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {jb_n[2]}]

#IO_L17P_T2_34
set_property PACKAGE_PIN Y18 [get_ports {jb_p[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {jb_p[2]}]

#IO_L22N_T3_34
set_property PACKAGE_PIN W19 [get_ports {jb_n[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {jb_n[3]}]

#IO_L22P_T3_34
set_property PACKAGE_PIN W18 [get_ports {jb_p[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {jb_p[3]}]

