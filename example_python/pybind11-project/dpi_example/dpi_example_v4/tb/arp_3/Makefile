# Copyright (c) 2020 Alex Forencich
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

all: compile_v

TOPLEVEL_LANG = verilog

# SIM ?= verilator
# WAVES ?= 0

# COCOTB_HDL_TIMEUNIT = 1ns
# COCOTB_HDL_TIMEPRECISION = 1ps

DUT      = arp
TOPLEVEL = bfm
MODULE   = test_$(DUT)
VERILOG_SOURCES += bfm.v
VERILOG_SOURCES += ../../rtl/$(DUT).v
VERILOG_SOURCES += ../../rtl/arp_eth_rx.v
VERILOG_SOURCES += ../../rtl/arp_eth_tx.v
VERILOG_SOURCES += ../../rtl/arp_cache.v
VERILOG_SOURCES += ../../rtl/lfsr.v

# EXTRA_ARGS += --timing

# the -Wall option enables all warning messages
# the -Wno-WIDTH option disables the WIDTH warning message specifically.
compile_v:
# 	verilator -Wno-WIDTH --cc --exe --sv --timing --build ${VERILOG_SOURCES} sim_main.cpp
	verilator -Wno-WIDTH --trace --cc --exe --sv --timing --build ${VERILOG_SOURCES} sim_main.cpp

run_v:
	cd obj_dir&&./Vbfm&&cd ..


compile_g:
	galaxsim ${VERILOG_SOURCES}

run_g:
	./xsim

clean::
	@rm -rf iverilog_dump.v sim_build results.xml __pycache__ dump.vcd* obj_dir build utils/__pycache__ xsim*
	@rm -rf dump.fst $(TOPLEVEL).fst
