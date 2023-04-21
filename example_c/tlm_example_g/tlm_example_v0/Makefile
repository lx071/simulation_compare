all: compile

compile:
	g++ -shared -fPIC -o libadd.so sim_main.cpp -I /usr/local/systemc-2.3.4/include -L /usr/local/systemc-2.3.4/lib-linux64 -l systemc
	galaxsim hdl/wrapper.v hdl/bfm.v hdl/Add.v sim_main.cpp libadd.so
# galaxsim hdl/wrapper.v hdl/bfm.v hdl/Add.v sim_main.cpp -XCFLAGS="-I/usr/local/systemc-2.3.4/include" -XLDFLAGS="-L/usr/local/systemc-2.3.4/lib-linux64 -lsystemc"

run:
	./xsim
	
clean:
	-rm -rf obj_dir *.log *.dmp *.vpd core dump.vcd xsim*
