# This is a Makefile

#####################################################################

# make all

all: compile

first:
	date +%M.%s.%N

second:
	date +%M.%s.%N

end:
	date +%M.%s.%N

# only make compile

compile:
	verilator -Wno-fatal --cc ./../hdl/MyTopLevel.v --exe test_adder.cpp --trace
	make -j -C ./obj_dir -f VMyTopLevel.mk VMyTopLevel


# only make visual ( make .elf file to the .vcd file )

run:
	./obj_dir/VMyTopLevel


# only open the wave

sim:
	gtkwave dump.vcd

# clear middle files

clean:
	rm -rf ./obj_dir dump.vcd