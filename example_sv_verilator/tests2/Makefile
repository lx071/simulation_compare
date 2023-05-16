# This is a Makefile

#####################################################################

# make all

all: compile

exec: run

first:
	date +%M.%s.%N

second:
	date +%M.%s.%N

end:
	date +%M.%s.%N

# only make compile

compile:
	verilator -Wno-fatal --cc ./../hdl/tinyalu.sv --exe test_tinyalu.cpp --trace
	make -j -C ./obj_dir -f Vtinyalu.mk Vtinyalu


# only make visual ( make .elf file to the .vcd file )

run:
	./obj_dir/Vtinyalu

# only open the wave

sim:
	gtkwave dump.vcd

# clear middle files

clean:
	rm -rf ./obj_dir dump.vcd