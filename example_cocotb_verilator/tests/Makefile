SIM ?= verilator

TOPLEVEL_LANG ?= verilog

EXTRA_ARGS += --trace

PWD=$(shell pwd)

ifeq ($(TOPLEVEL_LANG),verilog)
    # VERILOG_SOURCES = $(PWD)/../hdl/adder.sv
    VERILOG_SOURCES = $(PWD)/../hdl/MyTopLevel.v
else ifeq ($(TOPLEVEL_LANG),vhdl)
    VHDL_SOURCES = $(PWD)/../hdl/adder.vhdl
else
    $(error "A valid value (verilog or vhdl) was not provided for TOPLEVEL_LANG=$(TOPLEVEL_LANG)")
endif

TOPLEVEL := MyTopLevel
MODULE   := test_adder

include $(shell cocotb-config --makefiles)/Makefile.sim
