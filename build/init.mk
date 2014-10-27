## Copyright 2014 Brian Swetland <swetland@frotz.net>
##
## Licensed under the Apache License, Version 2.0 
## http://www.apache.org/licenses/LICENSE-2.0

VERILATOR := VERILATOR_ROOT=/work/verilator /work/verilator/bin/verilator

VIVADOPATH := /work/xilinx/Vivado/2014.3
XSDKPATH := /work/xilinx/SDK/2014.3

VIVADO := $(VIVADOPATH)/bin/vivado
XELAB := $(VIVADOPATH)/bin/xelab
XSIM := $(VIVADOPATH)/bin/xsim
XMD := $(XSDKPATH)/bin/xmd

ifeq ("$(VERBOSE)","")
# reduce the firehose of output chatter from Vivado
VIVADO_FILTER := | grep -e "^INFO:.*Inferred" -e "^WARNING:" -e "^ERROR:"
VIVADO_FILTER += | grep -v '\[Board 49-26\]'
endif

ALL_TARGETS :=

# default: assume build is adjacent to top level Makefile
BUILD ?= build
