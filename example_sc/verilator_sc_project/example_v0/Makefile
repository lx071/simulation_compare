all: compile

compile:
	verilator --trace --timing -sc --exe --build --top-module wrapper -j hdl/wrapper.v hdl/bfm.v hdl/Add.v sc_main.cpp

run:
	obj_dir/Vwrapper

clean:
	-rm -rf obj_dir *.log *.dmp *.vpd core dump.vcd