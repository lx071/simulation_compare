all: exec

compile:
	mkdir build
	cd build&&cmake ..&&make&&cp test_adder.so ..&&cd ..

exec:
	verilator --cc --exe --sv --timing --build hdl/tinyalu.sv hdl/bfm.v hdl/wrapper.v sim_main.cpp ../test_adder.so
	# verilator --cc --trace --exe --sv --timing --build hdl/tinyalu.sv hdl/bfm.v hdl/wrapper.v sim_main.cpp ../test_adder.so

run:
	cd obj_dir&&./Vtinyalu&&cd ..


clean:
	-rm -rf build obj_dir


	
