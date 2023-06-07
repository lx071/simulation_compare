VERILOG_SOURCES += $(PWD)/../hdl/PoseidonTopLevelTestbench.v
VERILOG_SOURCES += $(PWD)/../hdl/PoseidonTopLevel.v

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
	galaxsim ../test_hash.so ${VERILOG_SOURCES}
        
clean:
	rm -rf xsim* dump.vcd run.out
	