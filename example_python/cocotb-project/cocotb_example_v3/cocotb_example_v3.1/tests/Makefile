SIM ?= icarus

TOPLEVEL_LANG ?= verilog


PWD=$(shell pwd)

ifeq ($(TOPLEVEL_LANG),verilog)
    VERILOG_SOURCES += $(PWD)/../hdl/SPI_Slave.v
    VERILOG_SOURCES += $(PWD)/../hdl/spi_initiator_bfm.v
else ifeq ($(TOPLEVEL_LANG),vhdl)
    VERILOG_SOURCES += $(PWD)/../hdl/SPI_Slave.v
    VERILOG_SOURCES += $(PWD)/../hdl/spi_initiator_bfm.v
else
    $(error "A valid value (verilog or vhdl) was not provided for TOPLEVEL_LANG=$(TOPLEVEL_LANG)")
endif

TOPLEVEL := spi_initiator_bfm
MODULE   := test_spi


include $(shell cocotb-config --makefiles)/Makefile.sim
include ../../cleanall.mk