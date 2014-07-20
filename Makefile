
include build/init.mk

all: list-all-targets

MODULE_NAME := zybo-simple-io
MODULE_PART := xc7z010clg400-1
MODULE_SRCS := hdl/zybo_simple_io.sv
MODULE_SRCS += hdl/axi_ifc.sv hdl/axi_registers.sv
MODULE_SRCS += hdl/zynq_ps_1m.sv
MODULE_SRCS += hdl/zybo_simple_io.xdc
include build/vivado-bitfile.mk

HDMI_SRCS := \
	hdl/hdmi_core.sv \
	hdl/mmcm_1in_3out.sv \
	hdl/serdes_10to1_tx.sv \
	hdl/tmds_encoder.sv

MODULE_NAME := zybo-hdmi-axi
MODULE_PART := xc7z010clg400-1
MODULE_SRCS := hdl/zybo_hdmi_axi.sv
MODULE_SRCS += hdl/axi_ifc.sv hdl/axi_registers.sv
MODULE_SRCS += hdl/zynq_ps_1m_1s.sv
MODULE_SRCS += hdl/xilinx_async_fifo.sv hdl/sync_oneway.sv
MODULE_SRCS += hdl/axi_dma_reader.sv
MODULE_SRCS += $(HDMI_SRCS)
MODULE_SRCS += hdl/chardata8x8.hex
MODULE_SRCS += hdl/textdisplay.sv
MODULE_SRCS += hdl/zybo_hdmi.xdc
MODULE_SRCS += hdl/zybo_hdmi_fclk.xdc
include build/vivado-bitfile.mk

MODULE_NAME := zybo-hdmi
MODULE_PART := xc7z010clg400-1
MODULE_SRCS := hdl/zybo_hdmi.sv
MODULE_SRCS += $(HDMI_SRCS)
MODULE_SRCS += hdl/zybo_hdmi.xdc
include build/vivado-bitfile.mk

MODULE_NAME := axi-write-to-sram
MODULE_SRCS := hdl/test/axi_write_to_sram.sv
MODULE_SRCS += hdl/axi_ifc.sv
MODULE_SRCS += hdl/axi_sram.sv
MODULE_SRCS += hdl/axi_pattern_writer.sv
include build/verilator-sim.mk

MODULE_NAME := eth-crc32-test
MODULE_SRCS := hdl/test/eth_crc32_test.sv
MODULE_SRCS += hdl/eth_crc32.sv
include build/verilator-sim.mk

MODULE_NAME := eth-rmii-test
MODULE_SRCS := hdl/test/eth_rmii_test.sv
MODULE_SRCS += hdl/eth_rmii_tx.sv
MODULE_SRCS += hdl/eth_rmii_rx.sv
include build/verilator-sim.mk

MODULE_NAME := zybo-eth
MODULE_PART := xc7z010clg400-1
MODULE_SRCS := hdl/zybo_eth.sv
MODULE_SRCS += hdl/eth_rmii_rx.sv
MODULE_SRCS += hdl/mmcm_1in_3out.sv
MODULE_SRCS += hdl/jtag_debug_port.sv
MODULE_SRCS += hdl/zybo_eth.xdc
include build/vivado-bitfile.mk

clean::
	rm -rf sim synth out

list-all-targets::
	@echo buildable targets:
	@for x in $(ALL_TARGETS) ; do echo $$x ; done
