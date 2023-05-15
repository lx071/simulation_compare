all: compile

compile:
	galaxsim hdl/wrapper.v hdl/bfm.v hdl/tinyalu.sv sim_main.cpp

run:
	./xsim
	
clean:
	-rm -rf obj_dir *.log *.dmp *.vpd core dump.vcd xsim*
