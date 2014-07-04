
include build/init.mk

all:

HDMI_SRCS := \
	hdl/hdmi_core.sv \
	hdl/mmcm_1in_3out.sv \
	hdl/serdes_10to1_tx.sv \
	hdl/tmds_encoder.sv

MODULE_NAME := zybo-hdmi-axi
MODULE_PART := xc7z010clg400-2
MODULE_SRCS := hdl/zybo_hdmi_axi.sv
MODULE_SRCS += hdl/axi_ifc.sv hdl/axi_registers.sv hdl/zynq_ps_1m.sv
MODULE_SRCS += $(HDMI_SRCS)
MODULE_SRCS += hdl/zybo_hdmi.xdc
include build/vivado-bitfile.mk

MODULE_NAME := zybo-hdmi
MODULE_PART := xc7z010clg400-2
MODULE_SRCS := hdl/zybo_hdmi.sv
MODULE_SRCS += $(HDMI_SRCS)
MODULE_SRCS += hdl/zybo_hdmi.xdc
include build/vivado-bitfile.mk

clean::
	rm -rf sim synth out
