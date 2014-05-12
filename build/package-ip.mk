## Copyright 2014 Brian Swetland <swetland@frotz.net>
##
## Licensed under the Apache License, Version 2.0 
## http://www.apache.org/licenses/LICENSE-2.0

MODULE_NAME := $(strip $(MODULE_NAME))
ifeq ("$(MODULE_NAME)","")
$(error no module name)
endif

IP_NAME := $(MODULE_NAME)
IP_SRCS := $(MODULE_SRCS)

IP_DIR := ip/$(IP_NAME)
IP_FILE := $(IP_DIR)/component.xml
IP_LINKS := $(addprefix $(IP_DIR)/hdl/,$(IP_SRCS))

$(IP_DIR)/hdl/%.v: hdl/%.v
	@mkdir -p $(dir $@)
	@ln -sf ../../../$< $@

$(IP_DIR)/hdl/%.sv: hdl/%.sv
	@mkdir -p $(dir $@)
	@ln -sf ../../../$< $@

$(IP_FILE): _NAME := $(IP_NAME)
$(IP_FILE): _DIR := $(IP_DIR)

$(IP_FILE): $(IP_LINKS) $(addprefix hdl/,$(IP_SRCS))
	@echo "LINT (verilator): $(_NAME)"
	@$(VERILATOR) --lint-only -I$(_DIR)/hdl $(_DIR)/hdl/$(_NAME)_ip.v
	@echo "PACKAGE-IP (vivado): $(_NAME)"
	@$(VIVADO) -nolog -nojournal -mode batch -source build/package-ip.tcl -tclargs $(_DIR) $(VIVADO_FILTER)

IP_ALL += $(IP_FILE)

MODULE_NAME :=
MODULE_SRCS :=

