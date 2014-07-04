## Copyright 2014 Brian Swetland <swetland@frotz.net>
##
## Licensed under the Apache License, Version 2.0 
## http://www.apache.org/licenses/LICENSE-2.0

MODULE_NAME := $(strip $(MODULE_NAME))
ifeq ("$(MODULE_NAME)","")
$(error no module name)
endif

MODULE_OBJDIR := sim/$(MODULE_NAME)-vsim
MODULE_RUN := $(MODULE_NAME)-vsim
MODULE_BIN := $(MODULE_OBJDIR)/Vtestbench

MODULE_HEX_SRCS := $(filter %.hex,$(MODULE_SRCS))
MODULE_VLG_SRCS := $(filter-out %.hex,$(MODULE_SRCS))

MODULE_OPTS := --top-module testbench 
#-Ihdl
MODULE_OPTS += --Mdir $(MODULE_OBJDIR)
MODULE_OPTS += --exe ../../build/testbench.cpp
MODULE_OPTS += --cc
MODULE_OPTS += -DSIMULATION

MODULE_OPTS += -CFLAGS -DTRACE --trace

$(MODULE_BIN): _OPTS := $(MODULE_OPTS)
$(MODULE_BIN): _SRCS := $(MODULE_VLG_SRCS)
$(MODULE_BIN): _HEX := $(MODULE_HEX_SRCS)
$(MODULE_BIN): _DIR := $(MODULE_OBJDIR)
$(MODULE_BIN): _NAME := $(MODULE_NAME)

$(MODULE_BIN): $(MODULE_SRCS) $(MODULE_HEX_SRCS)
	@mkdir -p $(_DIR) bin
	@for hex in $(_HEX) ; do cp $$hex $(_DIR) ; done
	@echo "COMPILE (verilator): $(_NAME)"
	$(VERILATOR) $(_OPTS) $(_SRCS)
	@echo "COMPILE (C++): $(_NAME)"
	@make -C $(_DIR) -f Vtestbench.mk

$(MODULE_RUN): _BIN := $(MODULE_BIN)
$(MODULE_RUN): _DIR := $(MODULE_OBJDIR)

$(MODULE_RUN): $(MODULE_BIN)
	@(cd $(_DIR) && ./Vtestbench)

MODULE_NAME :=
MODULE_SRCS :=
