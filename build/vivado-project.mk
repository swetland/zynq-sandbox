## Copyright 2014 Brian Swetland <swetland@frotz.net>
##
## Licensed under the Apache License, Version 2.0 
## http://www.apache.org/licenses/LICENSE-2.0

MODULE_NAME := $(strip $(MODULE_NAME))
ifeq ("$(MODULE_NAME)","")
$(error no module name)
endif

$(MODULE_NAME).xpr: _NAME := $(MODULE_NAME)
$(MODULE_NAME).xpr: _SRC := $(MODULE_SRCS)
$(MODULE_NAME).xpr: $(MODULE_SRCS)
	@echo "CREATE (project): $(_NAME)"
	$(VIVADO) -mode batch -nolog -nojournal -source $(_SRC)

$(MODULE_NAME)-spotless; _NAME := $(MODULE_NAME)
$(MODULE_NAME)-spotless:
	@echo "CLEAN (project): $(_NAME)"
	@rm -rf $(_NAME).cache $(_NAME).runs $(_NAME).srcs
	@rm -rf $(_NAME).xpr

$(MODULE_NAME): _NAME := $(MODULE_NAME)
$(MODULE_NAME): $(MODULE_NAME).xpr
	@echo "BUILD (bitstream): $(_NAME)"
	$(VIVADO) -mode batch -nolog -nojournal -source build/vivado-project.tcl $(_NAME).xpr

$(MODULE_NAME)-ide: _NAME := $(MODULE_NAME)
$(MODULE_NAME)-ide:
	$(VIVADO) -nolog -nojournal $(_NAME).xpr

MODULE_NAME :=
MODULE_SRCS :=
