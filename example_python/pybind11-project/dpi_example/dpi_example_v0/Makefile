all: exec

compile:
	mkdir build
	cd build&&cmake ..&&make&&cp test_adder.so ..&&cd ..

exec:
	verilator --cc --exe --sv --timing --build hdl/MyTopLevel.v hdl/bfm.v hdl/wrapper.sv sim_main.cpp ../test_adder.so

run:
	cd obj_dir&&./VMyTopLevel&&cd ..

first:
	date +%M.%s.%N

middle:
	date +%M.%s.%N

end:
	date +%M.%s.%N

clean:
	-rm -rf build obj_dir


	
