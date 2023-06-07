# This is a Makefile

# 编译、elaboration、仿真

# 编译: 就是识别Verilog文件，转成内部的数据库。经过编译后，各个Verilog文件在库里是独立的.

# elaboration: 就是把库里的数据，有机的组织成一个树型结构，树的顶端是root，往下是tb或者设计顶层，然后是例化的子模块.
# 经过处理后，这个树型结构就可以准确的表达整个设计（包括testbench）。elaboration最终会输出一个类似汇编的vvp文件.

# 仿真
# 仿真时读入vvp文件，送进vvp虚拟机执行.

VERILOG_SOURCES += $(PWD)/../hdl/PoseidonTopLevelTestbench.v
VERILOG_SOURCES += $(PWD)/../hdl/PoseidonTopLevel.v

VERILOG_SOURCES += $(PWD)/../hdl/ModAdder.v
VERILOG_SOURCES += $(PWD)/../hdl/MontMultiplierBasics.v
VERILOG_SOURCES += $(PWD)/../hdl/ModMultiplier.v

all: compile


# 编译后会生成被指定的目标可执行文件 run.out ，但此文件执行后只会在终端上显示仿真时文字信息，需要使用 vvp 工具将其可视化成 .vcd 文件

# only make compile
compile:
	iverilog -o run.out ./../hdl/*.v


compile_g:
	galaxsim $(VERILOG_SOURCES)


run:
	vvp -n run.out


clean:
	rm -rf dump.vcd run.out xsim*
