all: first compile middle exec end

compile:
# no wave
# 	verilator -CFLAGS -fPIC -CFLAGS -m64 -CFLAGS -shared -CFLAGS -Wno-attributes -LDFLAGS -fPIC -LDFLAGS -m64 -LDFLAGS -shared -LDFLAGS -Wno-attributes -CFLAGS -I/usr/include/python3.8 -CFLAGS -I/home/xuelin/.local/lib/python3.8/site-packages/pybind11/include -CFLAGS -fvisibility=hidden -LDFLAGS -fvisibility=hidden --Mdir verilator --cc hdl/MyTopLevel.v --trace --exe example.cpp
# wave
	verilator -CFLAGS -fPIC -CFLAGS -m64 -CFLAGS -shared -CFLAGS -Wno-attributes -LDFLAGS -fPIC -LDFLAGS -m64 -LDFLAGS -shared -LDFLAGS -Wno-attributes -CFLAGS -I/usr/include/python3.8 -CFLAGS -I/home/xuelin/.local/lib/python3.8/site-packages/pybind11/include -CFLAGS -fvisibility=hidden -LDFLAGS -fvisibility=hidden -CFLAGS -DTRACE --Mdir verilator --cc hdl/MyTopLevel.v --trace --exe example.cpp
# 	set -e ; verilator -CFLAGS -fPIC -CFLAGS -m64 -CFLAGS -shared -CFLAGS -Wno-attributes -LDFLAGS -fPIC -LDFLAGS -m64 -LDFLAGS -shared -LDFLAGS -Wno-attributes -CFLAGS -I/usr/include/python3.8 -CFLAGS -I/home/xuelin/.local/lib/python3.8/site-packages/pybind11/include -CFLAGS -fvisibility=hidden -LDFLAGS -fvisibility=hidden -CFLAGS -std=c++11 -LDFLAGS -std=c++11 --autoflush   --output-split 5000 --output-split-cfuncs 500 --output-split-ctrace 500 -Wno-WIDTH -Wno-UNOPTFLAT -Wno-CMPCONST -Wno-UNSIGNED --x-assign unique --x-initial-edge --trace-depth 0 -O3 -CFLAGS -O0 -CFLAGS -DTRACE --trace  --Mdir verilator --top-module MyTopLevel  -cc hdl/MyTopLevel.v --trace --exe example.cpp
	make -j -C ./verilator -f VMyTopLevel.mk VMyTopLevel

	c++ -O3 -Wall -shared -std=c++11 -fPIC -faligned-new -I./verilator $(shell python3 -m pybind11 --includes) -I/usr/local/share/verilator/include ./verilator/*.o -o example$(shell python3-config --extension-suffix)

exec:
	python test.py

first:
	date +%M.%s.%N

middle:
	date +%M.%s.%N

end:
	date +%M.%s.%N

clean:
	-rm -r *.so ./verilator dump.vcd


	
