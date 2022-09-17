# This is a Makefile

#####################################################################

# make all

all: first compile second run end

first:
	date +%M.%s.%N

second:
	date +%M.%s.%N

end:
	date +%M.%s.%N

# only make compile

compile:
	verilator --cc ./../hdl/tinyalu.sv --exe test_tinyalu.cpp --trace


# only make visual ( make .elf file to the .vcd file )

run:
	make -j -C ./obj_dir -f Vtinyalu.mk Vtinyalu
	./obj_dir/Vtinyalu

# only open the wave

sim:
	gtkwave dump.vcd

# clear middle files

clean:
	rm -rf ./obj_dir dump.vcd