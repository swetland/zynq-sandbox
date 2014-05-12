## Copyright 2014 Brian Swetland <swetland@frotz.net>
##
## Licensed under the Apache License, Version 2.0 
## http://www.apache.org/licenses/LICENSE-2.0

MODULE_NAME := $(strip $(MODULE_NAME))
ifeq ("$(MODULE_NAME)","")
$(error no module name)
endif

MODULE_BIN := bin/$(MODULE_NAME)
MODULE_OBJDIR := obj/verilated/$(MODULE_NAME)

MODULE_OPTS := --top-module testbench -Ihdl
MODULE_OPTS += --Mdir $(MODULE_OBJDIR)
MODULE_OPTS += --exe ../../build/testbench.cpp
MODULE_OPTS += --cc

MODULE_OPTS += -CFLAGS -DTRACE --trace

$(MODULE_BIN): _OPTS := $(MODULE_OPTS)
$(MODULE_BIN): _SRCS := $(MODULE_SRCS)
$(MODULE_BIN): _DIR := $(MODULE_OBJDIR)
$(MODULE_BIN): _NAME := $(MODULE_NAME)

$(MODULE_BIN): $(MODULE_SRCS)
	@mkdir -p $(_DIR) bin
	@echo "COMPILE (verilator): $(_NAME)"
	@$(VERILATOR) $(_OPTS) $(_SRCS)
	@echo "COMPILE (C++): $(_NAME)"
	@make -C $(_DIR) -f Vtestbench.mk
	@cp $(_DIR)/Vtestbench $@

VERILATOR_ALL += $(MODULE_BIN)

MODULE_NAME :=
MODULE_SRCS :=
