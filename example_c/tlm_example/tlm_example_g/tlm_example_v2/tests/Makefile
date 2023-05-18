VERILOG_SOURCES += $(PWD)/../hdl/PoseidonTopLevel.v
VERILOG_SOURCES += $(PWD)/../hdl/PoseidonTopLevelTestbench.v
VERILOG_SOURCES += $(PWD)/../hdl/ModAdder.v
VERILOG_SOURCES += $(PWD)/../hdl/MontMultiplierBasics.v
VERILOG_SOURCES += $(PWD)/../hdl/ModMultiplier.v

all: first compile second

first:
	date +%M.%s.%N

second:
	date +%M.%s.%N

end:
	date +%M.%s.%N


# 编译后会生成被指定的目标可执行文件 run.out ，但此文件执行后只会在终端上显示仿真时文字信息，需要使用 vvp 工具将其可视化成 .vcd 文件

# only make compile
compile:
	# verilator --cc --exe --sv --timing --build ${VERILOG_SOURCES} sim_main.cpp
	# galaxsim ../test_hash.so ${VERILOG_SOURCES} -Xutil=1
	g++ -shared -fPIC -o libadd.so ../sim_main.cpp -I /usr/local/systemc-2.3.4/include -L /usr/local/systemc-2.3.4/lib-linux64 -l systemc
	galaxsim ${VERILOG_SOURCES} libadd.so

run:
	./xsim
	
clean:
	rm -rf xsim* dump.vcd run.out
	