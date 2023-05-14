all: compile

compile:
	g++ -shared -fPIC -o libadd.so sim_main.cpp -I /usr/local/systemc-2.3.4/include -L /usr/local/systemc-2.3.4/lib-linux64 -l systemc
	galaxsim hdl/wrapper.v hdl/bfm.v hdl/tinyalu.sv libadd.so
	
run:
	./xsim
	
clean:
	-rm -rf obj_dir *.log *.dmp *.vpd core dump.vcd xsim* *.so
