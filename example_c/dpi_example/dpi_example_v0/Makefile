all: compile

compile:
	verilator --timing --trace -cc --exe --build --top-module wrapper hdl/wrapper.v hdl/bfm.v hdl/Add.v sim_main.cpp
run:
	obj_dir/Vwrapper
	
clean:
	-rm -rf obj_dir *.log *.dmp *.vpd core dump.vcd
