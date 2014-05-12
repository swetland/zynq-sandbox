
include build/init.mk

# opportunity to override VERILATOR, VIVADO, XSIM, etc
-include local.mk

all:

MODULE_NAME := axi4_write_test
MODULE_SRCS := axi4_write_test_ip.v axi4_write_test_impl.sv
MODULE_SRCS += axi4_ifc.sv axi4_write_test.sv
include build/package-ip.mk

MODULE_NAME := axi4_trace
MODULE_SRCS := axi4_trace_ip.v xilinx_jtag_debugport.v
include build/package-ip.mk

MODULE_NAME := axi4lite_jtag_debug
MODULE_SRCS := axi4lite_jtag_debug_ip.v xilinx_jtag_debugport.v
include build/package-ip.mk

MODULE_NAME := axi4_sram
MODULE_SRCS := axi4_sram_ip.v axi4_sram_impl.sv
MODULE_SRCS += axi4_sram.sv axi4_ifc.sv
include build/package-ip.mk

MODULE_NAME := axi4-sram-test
MODULE_SRCS := hdl/axi4_sram_testbench.sv
MODULE_SRCS += hdl/axi4_ifc.sv hdl/axi4_sram.sv hdl/axi4_write_test.sv
include build/verilator-sim.mk

MODULE_NAME := axi4-sram-test
MODULE_SRCS := hdl/axi4_sram_xsim.sv
MODULE_SRCS += hdl/axi4_ifc.sv hdl/axi4_sram.sv hdl/axi4_write_test.sv
include build/vivado-xsim.mk

ip:: $(IP_ALL)

clean::
	rm -rf obj bin ip sim
