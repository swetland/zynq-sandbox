## Copyright 2014 Brian Swetland <swetland@frotz.net>
##
## Licensed under the Apache License, Version 2.0 
## http://www.apache.org/licenses/LICENSE-2.0

MODULE_NAME := $(strip $(MODULE_NAME))
ifeq ("$(MODULE_NAME)","")
$(error no module name)
endif

MODULE_OBJDIR := synth/$(MODULE_NAME)
MODULE_BIT := out/$(MODULE_NAME).bit
MODULE_CFG := $(MODULE_OBJDIR)/config.tcl

MODULE_HEX_SRCS := $(filter %.hex,$(MODULE_SRCS))
MODULE_XDC_SRCS := $(filter %.xdc,$(MODULE_SRCS))
MODULE_V_SRCS := $(filter %.v,$(MODULE_SRCS))
MODULE_SV_SRCS := $(filter %.sv,$(MODULE_SRCS))

$(MODULE_CFG): _V := $(MODULE_V_SRCS)
$(MODULE_CFG): _SV := $(MODULE_SV_SRCS)
$(MODULE_CFG): _XDC := $(MODULE_XDC_SRCS)
$(MODULE_CFG): _DIR := $(MODULE_OBJDIR)
$(MODULE_CFG): _PART := $(MODULE_PART)
$(MODULE_CFG): _NAME := $(MODULE_NAME)
$(MODULE_CFG): _OPTS := -I$(VIVADOPATH)/data/verilog/src/xeclib

$(MODULE_CFG): $(MODULE_SRCS) Makefile
	@echo "LINT (verilator): $(_NAME)"
	@$(VERILATOR) --top-module top --lint-only $(_OPTS) $(_SV) $(_V)
	@mkdir -p $(_DIR)
	@echo "# auto-generated file" > $@
	@echo "set PART {$(_PART)}" >> $@
	@echo "set BITFILE {../../out/$(_NAME).bit}" >> $@
	@for x in $(_V) ; do echo "read_verilog {../../$$x}" ; done >> $@
	@for x in $(_SV) ; do echo "read_verilog -sv {../../$$x}" ; done >> $@
	@for x in $(_XDC) ; do echo "read_xdc {../../$$x}" ; done >> $@

$(MODULE_BIT): _HEX := $(MODULE_HEX_SRCS)
$(MODULE_BIT): _DIR := $(MODULE_OBJDIR)
$(MODULE_BIT): _NAME := $(MODULE_NAME)

$(MODULE_BIT): $(MODULE_HEX_SRCS) $(MODULE_CFG)
	@echo "SYNTH (vivado): $(_NAME)"
	@mkdir -p $(_DIR) out
	@rm -f $(_DIR)/log.txt
	@for hex in $(_HEX) ; do cp $$hex $(_DIR) ; done
	@(cd $(_DIR) && $(VIVADO) -mode batch -log log.txt -nojournal -source ../../build/build-bitfile.tcl)

$(MODULE_NAME): $(MODULE_BIT)

$(MODULE_NAME)-review: _DIR := $(MODULE_OBJDIR)

$(MODULE_NAME)-review: $(MODULE_BIT)
	@(cd $(_DIR) && $(VIVADO) -nolog -nojournal post-route-checkpoint.dcp)

MODULE_NAME :=
MODULE_SRCS :=
MODULE_PART :=
