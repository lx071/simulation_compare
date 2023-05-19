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

DUT      = arp
TOPLEVEL = bfm
MODULE   = test_$(DUT)
VERILOG_SOURCES += bfm.v
VERILOG_SOURCES += ../../rtl/$(DUT).v
VERILOG_SOURCES += ../../rtl/arp_eth_rx.v
VERILOG_SOURCES += ../../rtl/arp_eth_tx.v
VERILOG_SOURCES += ../../rtl/arp_cache.v
VERILOG_SOURCES += ../../rtl/lfsr.v


compile_v:
# 	verilator -Wno-WIDTH --cc --exe --sv --timing --build ${VERILOG_SOURCES} sim_main.cpp
	verilator -Wno-WIDTH --trace --cc --exe --sv --timing --build ${VERILOG_SOURCES} sim_main.cpp  -CFLAGS "$(shell python3 -m pybind11 --includes)" -LDFLAGS "-lpython3.8" -CFLAGS "-I/usr/local/systemc-2.3.4/include" -LDFLAGS "-L/usr/local/systemc-2.3.4/lib-linux64 -lsystemc"

exec_v:
	export PYTHONPATH=$PYTHONPATH:/home/lx071/.local/lib/python3.8/site-packages && \
	cd obj_dir&&./Vbfm&&cd ..


compile_g:
	g++ -shared -fPIC -o test_arp.so wrapper.cpp -std=c++11 $(shell python3 -m pybind11 --includes) -lpython3.8
	galaxsim test_arp.so ${VERILOG_SOURCES}

exec_g:
	./xsim

clean::
	@rm -rf iverilog_dump.v sim_build results.xml __pycache__ dump.vcd* obj_dir build utils/__pycache__ xsim*
	@rm -rf dump.fst $(TOPLEVEL).fst
