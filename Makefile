
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

test2.xpr: build/create_test2.tcl build/create_test2_design1.tcl
	$(TOOLPATH)/vivado -nolog -nojournal -mode batch -source build/create_test2.tcl

MODULE_NAME := axi4_sram_test
MODULE_SRCS := hdl/axi4_sram_testbench.sv
MODULE_SRCS += hdl/axi4_ifc.sv hdl/axi4_sram.sv hdl/axi4_write_test.sv
include build/verilated-exe.mk

ip:: $(IP_ALL)

verilated:: $(VERILATOR_ALL)

clean::
	rm -rf obj bin ip
