all: compile

compile:
	galaxsim hdl/wrapper.v hdl/bfm.v hdl/Add.v sim_main.cpp -XCFLAGS="-I/usr/local/systemc-2.3.4/include" -XLDFLAGS="-L/usr/local/systemc-2.3.4/lib-linux64 -lsystemc"

run:
	./xsim
	
clean:
	-rm -rf obj_dir *.log *.dmp *.vpd core dump.vcd xsim*
