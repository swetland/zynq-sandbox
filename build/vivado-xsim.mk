## Copyright 2014 Brian Swetland <swetland@frotz.net>
##
## Licensed under the Apache License, Version 2.0 
## http://www.apache.org/licenses/LICENSE-2.0

MODULE_NAME := $(strip $(MODULE_NAME))
ifeq ("$(MODULE_NAME)","")
$(error no module name)
endif

MODULE_V_SRCS := $(filter %.v,$(MODULE_SRCS))
MODULE_SV_SRCS := $(filter %.sv,$(MODULE_SRCS))
MODULE_HEX_SRCS := $(filter %.hex,$(MODULE_SRCS))

ifneq ("$(NS)","")
MODULE_TIME := $(NS)ns
else
MODULE_TIME := 5000ns
endif

MODULE_DIR := sim/$(MODULE_NAME)-xsim
MODULE_RUN := $(MODULE_NAME)-xsim
MODULE_XELAB := $(MODULE_DIR)/.xelab.done

MODULE_OPTS := --debug typical --relax
MODULE_OPTS += -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip 
MODULE_OPTS += --snapshot sim
MODULE_OPTS += --prj sim.prj
MODULE_OPTS += xil_defaultlib.testbench xil_defaultlib.glbl
MODULE_OPTS += -d SIMULATION
# blackbox verilog for xilinx fpga-specific macros
MODULE_VOPTS := -I$(VIVADOPATH)/data/verilog/src/xeclib -DSIMULATION

$(MODULE_XELAB): _DIR := $(MODULE_DIR)
$(MODULE_XELAB): _NAME := $(MODULE_NAME)
$(MODULE_XELAB): _V := $(MODULE_V_SRCS)
$(MODULE_XELAB): _SV := $(MODULE_SV_SRCS)
$(MODULE_XELAB): _OPTS := $(MODULE_OPTS)
$(MODULE_XELAB): _VOPTS := $(MODULE_VOPTS)

$(MODULE_XELAB): $(MODULE_V_SRCS) $(MODULE_SV_SRCS)
	@mkdir -p $(_DIR)
	@echo "LINT (verilator): $(_NAME)"
	@$(VERILATOR) --lint-only --top-module testbench $(_VOPTS) $(_V) $(_SV)
	@for src in $(_V) ; do echo "verilog xil_defaultlib \"../../$$src\"" ; done > $(_DIR)/sim.prj
	@for src in $(_SV) ; do echo "sv xil_defaultlib \"../../$$src\"" ; done >> $(_DIR)/sim.prj
	@echo 'verilog xil_defaultlib "$(VIVADOPATH)/data/verilog/src/glbl.v"' >> $(_DIR)/sim.prj
	@echo "COMPILE (xelab): $(_NAME)"
	@(cd $(_DIR) && $(XELAB) $(_OPTS))
	@touch $@

$(MODULE_RUN): _DIR := $(MODULE_DIR)
$(MODULE_RUN): _HEX := $(MODULE_HEX_SRCS)
$(MODULE_RUN): _TIME := $(MODULE_TIME)

$(MODULE_RUN): $(MODULE_XELAB)
	@for hex in $(_HEX) ; do cp $$hex $(_DIR) ; done
	@echo 'open_vcd' > $(_DIR)/run.tcl
	@echo 'log_vcd' >> $(_DIR)/run.tcl
	@echo 'run $(_TIME)' >> $(_DIR)/run.tcl
	@echo 'close_vcd' >> $(_DIR)/run.tcl
	@echo 'exit' >> $(_DIR)/run.tcl
	@echo 'SIMULATE (xsim): $(_NAME)'
	@(cd $(_DIR) && $(XSIM) -nolog -t run.tcl sim)

ALL_TARGETS += $(MODULE_RUN)
TARGET_$(MODULE_RUN)_DESC := "run vivado xsim"

MODULE_NAME :=
MODULE_SRCS :=
