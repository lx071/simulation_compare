SIM ?= verilator

# EXTRA_ARGS += --trace
EXTRA_ARGS += --timing

TOPLEVEL_LANG ?= verilog


PWD=$(shell pwd)

ifeq ($(TOPLEVEL_LANG),verilog)
    # VERILOG_SOURCES = $(PWD)/../hdl/adder.sv
    VERILOG_SOURCES += $(PWD)/../hdl/tinyalu.sv
    VERILOG_SOURCES += $(PWD)/../hdl/bfm.v
else ifeq ($(TOPLEVEL_LANG),vhdl)
    VHDL_SOURCES = $(PWD)/../hdl/adder.vhdl
else
    $(error "A valid value (verilog or vhdl) was not provided for TOPLEVEL_LANG=$(TOPLEVEL_LANG)")
endif

TOPLEVEL := bfm
MODULE   := test_adder


include $(shell cocotb-config --makefiles)/Makefile.sim
include ../cleanall.mk