
##Clock signal
##IO_L11P_T1_SRCC_35	
set_property PACKAGE_PIN L16 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports clk]

# 30 MHz JTAG TCK
create_clock -period 33.333 -name jtag_tck [get_pins log0/port0/bscan/TCK]

# human readable generated clock name
create_generated_clock -name clk50 [get_pins mmcm0/mmcm_adv_inst/CLKOUT0]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks sys_clk_pin] -group jtag_tck

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

##Pmod Header JB
##IO_L15N_T2_DQS_34
set_property PACKAGE_PIN U20 [get_ports {phy0_rx[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {phy0_rx[1]}]

##IO_L15P_T2_DQS_34
set_property PACKAGE_PIN T20 [get_ports {phy0_tx[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {phy0_tx[0]}]
set_property SLEW FAST [get_ports {phy0_tx[0]}]

##IO_L16N_T2_34
set_property PACKAGE_PIN W20 [get_ports {phy0_mdc}]
set_property IOSTANDARD LVCMOS33 [get_ports {phy0_mdc}]

##IO_L16P_T2_34
set_property PACKAGE_PIN V20 [get_ports {phy0_crs}]
set_property IOSTANDARD LVCMOS33 [get_ports {phy0_crs}]

##IO_L17N_T2_34
set_property PACKAGE_PIN Y19 [get_ports {phy0_rx[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {phy0_rx[0]}]

##IO_L17P_T2_34
set_property PACKAGE_PIN Y18 [get_ports {phy0_txen}]
set_property IOSTANDARD LVCMOS33 [get_ports {phy0_txen}]
set_property SLEW FAST [get_ports {phy0_txen}]

##IO_L22N_T3_34
set_property PACKAGE_PIN W19 [get_ports {phy0_tx[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {phy0_tx[1]}]
set_property SLEW FAST [get_ports {phy0_tx[1]}]

##IO_L22P_T3_34
set_property PACKAGE_PIN W18 [get_ports {phy0_clk}]
set_property IOSTANDARD LVCMOS33 [get_ports {phy0_clk}]
set_property SLEW FAST [get_ports {phy0_clk}]
set_property DRIVE 8 [get_ports {phy0_clk}]

##Pmod Header JD
##IO_L5N_T0_34
#set_property PACKAGE_PIN T15 [get_ports {phy1_rx1}]
#set_property IOSTANDARD LVCMOS33 [get_ports {phy1_rx1}]

##IO_L5P_T0_34
#set_property PACKAGE_PIN T14 [get_ports {phy1_tx0}]
#set_property IOSTANDARD LVCMOS33 [get_ports {phy1_tx0}]

##IO_L6N_T0_VREF_34
#set_property PACKAGE_PIN R14 [get_ports {phy1_mdc}]
#set_property IOSTANDARD LVCMOS33 [get_ports {phy1_mdc}]

##IO_L6P_T0_34
#set_property PACKAGE_PIN P14 [get_ports {phy1_crs}]
#set_property IOSTANDARD LVCMOS33 [get_ports {phy1_crs}]

##IO_L11N_T1_SRCC_34
#set_property PACKAGE_PIN U15 [get_ports {phy1_rx0}]
#set_property IOSTANDARD LVCMOS33 [get_ports {phy1_rx0}]

##IO_L11P_T1_SRCC_34
#set_property PACKAGE_PIN U14 [get_ports {phy1_txen}]
#set_property IOSTANDARD LVCMOS33 [get_ports {phy1_txen}]

##IO_L21N_T3_DQS_34
#set_property PACKAGE_PIN V18 [get_ports {phy1_mdio}]
#set_property IOSTANDARD LVCMOS33 [get_ports {phy1_mdio}]

##IO_L21P_T3_DQS_34
#set_property PACKAGE_PIN V17 [get_ports {phy1_clk}]
#set_property IOSTANDARD LVCMOS33 [get_ports {phy1_clk}]

