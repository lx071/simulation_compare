import os
import subprocess
import re


def do_python_api():
    print('do_python_api')
    return 0


# 解析verilog代码, 返回输入端口名列表 和 输出端口名列表
def verilog_parse(dut_path, top_module_file_name):
    dut_name = top_module_file_name.split('.')[0]  # 模块名
    top_module_path = os.path.join(dut_path, top_module_file_name)
    # print(top_module_path)
    module_begin_match = r"module\s*([a-zA-Z0-9_]+)"
    # 匹配输入端口        input clock, input [31:0] io_a
    input_port_match = r"input\s*(reg|wire)*\s*(\[[0-9]+\:[0-9]+\]*)*\s*([a-zA-Z0-9_]+)"
    # 匹配输出端口        output [31:0] io_c
    output_port_match = r"output\s*(reg|wire)*\s*(\[[0-9]+\:[0-9]+\]*)*\s*([a-zA-Z0-9_]+)"
    current_module_name = ''
    input_ports_name = []
    output_ports_name = []
    with open(top_module_path, "r") as verilog_file:
        while verilog_file:
            verilog_line = verilog_file.readline().strip(' ')  # 读取一行
            # print(verilog_line)
            if verilog_line == "":  # 注：如果是空行，为'\n'
                break

            module_begin = re.search(module_begin_match, verilog_line)

            if module_begin:
                current_module_name = module_begin.group(1)
                # print(current_module_name)

            if current_module_name == dut_name:
                input_port = re.search(input_port_match, verilog_line)
                output_port = re.search(output_port_match, verilog_line)
                if input_port:
                    # 输入端口名列表
                    input_ports_name.append(input_port.group(3))
                if output_port:
                    # 输出端口名列表
                    output_ports_name.append(output_port.group(3))
    # print(dut_name)
    # print(input_ports_name)
    # print(output_ports_name)
    return input_ports_name, output_ports_name


# 传入文件路径和端口名列表，生成 Wrapper文件
def genWrapperCpp(wrapper_name, ports_name, top_module_file_name):
    dut_name = top_module_file_name.split('.')[0]  # 模块名
    try:
        os.mkdir("verilator")
    except FileExistsError:
        pass

    def signal_connect(ports_name):
        str = ''
        for i in range(len(ports_name)):
            str = str + f"""
            signal[{i}] = new Signal(top.{ports_name[i]});"""
        return str

    wrapper = f"""
#include <pybind11/pybind11.h>
#include <pybind11/embed.h> // everything needed for embedding
namespace py = pybind11;

#include <stdint.h>
#include <iostream>
#include <string>

#include "V{dut_name}.h"
#ifdef TRACE
#include "verilated_vcd_c.h"
#endif
#include "V{dut_name}__Syms.h"

//8个字节
//typedef uint64_t CData;

//usr/local/share/verilator/include/verilated.h
//typedef vluint8_t    CData;     ///< Verilated pack data, 1-8 bits
//typedef vluint16_t   SData;     ///< Verilated pack data, 9-16 bits
//typedef vluint32_t   IData;     ///< Verilated pack data, 17-32 bits
//typedef vluint64_t   QData;     ///< Verilated pack data, 33-64 bits
//typedef vluint32_t   EData;     ///< Verilated pack element of WData array
//typedef EData        WData;     ///< Verilated pack data, >64 bits, as an array
class Signal
{{
    public:
        //指针指向信号值
        CData* raw;
        Signal(CData *raw) : raw(raw){{}}
        Signal(CData &raw) : raw(std::addressof(raw)){{}}
        uint64_t getValue() {{return *raw;}}
        void setValue(uint64_t value)  {{*raw = value; }}
}};

class Wrapper;
thread_local Wrapper *simHandle1;

class Wrapper
{{
    public:
        uint64_t time;
        std::string name;

        // 指针数组, 指向各个Signal
        Signal *signal[5];
        // 是否产生波形
        bool waveEnabled;
        //dut
        V{dut_name} top;
        #ifdef TRACE
        VerilatedVcdC tfp;
	    #endif

        Wrapper(const char * name)
        {{
            simHandle1 = this;
            {signal_connect(ports_name)}
            
            time = 0;
            waveEnabled = true;
            #ifdef TRACE
            Verilated::traceEverOn(true);
            top.trace(&tfp, 99);
            tfp.open("dump.vcd");
            #endif
            this->name = name;
        }}

        // 析构函数在对象消亡时即自动被调用
        virtual ~Wrapper()
        {{
            for(int idx = 0;idx < {len(ports_name)};idx++)
            {{
                delete signal[idx];
            }}
            #ifdef TRACE
            if(waveEnabled) tfp.dump((uint64_t)time);
            tfp.close();
            #endif
            std::cout<<"closeAll()"<<std::endl;
        }}
}};

double sc_time_stamp() 
{{
    return simHandle1->time;
}}

void getHandle(const char * name)
{{
    Wrapper* handle = new Wrapper(name);
}}

void setValue(int id, uint64_t newValue)
{{
    simHandle1->signal[id]->setValue(newValue);
}}

uint64_t getValue(int id)
{{
    return simHandle1->signal[id]->getValue();
}}

void dump()
{{
    #ifdef TRACE
    if(simHandle1->waveEnabled) simHandle1->tfp.dump((uint64_t)simHandle1->time);
    #endif
}}

bool eval()
{{
    simHandle1->top.eval();
//    std::cout<<"time:"<<simHandle1->time<<std::endl;
    return Verilated::gotFinish();
}}

void sleep_cycles(uint64_t cycles)
{{
    dump();
    simHandle1->time += cycles;
}}

void deleteHandle()
{{
    delete simHandle1;
}}

// 启动产生波形
void enableWave()
{{
    simHandle1->waveEnabled = true;
}}

// 关闭产生波形
void disableWave()
{{
    simHandle1->waveEnabled = false;
}}

void doPythonApi()
{{
    py::print("Hello, World!"); // use the Python API
    py::module_ calc = py::module_::import("calc");
    
    for(int i=0;i<1000000;i++)
        calc.attr("add")(i%100, i%100);
    py::object result = calc.attr("add")(1, 2);
    int n = result.cast<int>();
    assert(n == 3);
    std::cout << n << std::endl;
    
    py::module_ utils = py::module_::import("harness_utils");
    utils.attr("do_python_api")();
}}


//定义Python与C++之间交互的func与class
PYBIND11_MODULE(wrapper, m)
{{
    py::class_<Wrapper>(m, "Wrapper")
        .def(py::init<const char *>());

    m.def("getHandle", &getHandle);
    m.def("setValue", &setValue);
    m.def("getValue", &getValue);
    m.def("dump", &dump);
    m.def("eval", &eval);
    m.def("sleep_cycles", &sleep_cycles);
    m.def("deleteHandle", &deleteHandle);
    m.def("enableWave", &enableWave);
    m.def("disableWave", &disableWave);
    m.def("doPythonApi", &doPythonApi);
}}

"""
    fd = open(f'verilator/{wrapper_name}', "w")
    fd.write(wrapper)
    fd.close()


def runCompile(dut_path, top_module_file_name, wrapper_file_name):
    dut_name = top_module_file_name.split('.')[0]  # 模块名
    top_module_path = os.path.join(dut_path, top_module_file_name)
    pybind_i = subprocess.getoutput('python3 -m pybind11 --includes')
    pybind_CFLAGS = pybind_i.replace(' ', ' -CFLAGS ')
    # 由硬件设计文件得到C++模型以及相关文件
    compile_command_1 = f"verilator -CFLAGS -fPIC -CFLAGS -m64 -CFLAGS -shared -CFLAGS -Wno-attributes -LDFLAGS -fPIC -LDFLAGS -m64 -LDFLAGS -shared -LDFLAGS -Wno-attributes -CFLAGS {pybind_CFLAGS} -CFLAGS -fvisibility=hidden -LDFLAGS -fvisibility=hidden -CFLAGS -DTRACE --Mdir verilator --cc {top_module_path} --trace --exe {wrapper_file_name}"
    # 得到相关库文件(.o)以及可执行文件
    compile_command_2 = f"make -j -C ./verilator -f V{dut_name}.mk"
    # 由各个库文件(.o)得到共享库文件(.so)
    compile_command_3 = f"c++ -O3 -Wall -shared -std=c++11 -fPIC -faligned-new ./verilator/*.o -o verilator/wrapper.so"

    # print(compile_command_3)
    os.system(compile_command_1)
    os.system(compile_command_2)
    os.system(compile_command_3)


class sim:
    def __init__(self, dut_path, top_module_file_name, wrapper_name):
        input_ports_name, output_ports_name = verilog_parse(dut_path, top_module_file_name)
        ports_name = input_ports_name + output_ports_name
        list_n = [i for i in range(len(ports_name))]
        self.signal_id = dict(zip(ports_name, list_n))
        # print(self.signal_id)
        genWrapperCpp(wrapper_name, ports_name, top_module_file_name)
        runCompile(dut_path, top_module_file_name, wrapper_name)
        from verilator import wrapper
        self.wp = wrapper
        self.getHandle('sim_wrapper')

    def setValue(self, signal_name, value):
        self.wp.setValue(self.signal_id[signal_name], value)

    def getValue(self, signal_name):
        return self.wp.getValue(self.signal_id[signal_name])

    def getHandle(self, sim_name):
        self.wp.getHandle(sim_name)

    def deleteHandle(self):
        self.wp.deleteHandle()

    def eval(self):
        self.wp.eval()

    def dump(self):
        self.wp.dump()

    def sleep_cycles(self, cycles):
        self.wp.sleep_cycles(cycles)

    def doPythonApi(self):
        self.wp.doPythonApi()


def simple_sim_test(s):
    from verilator import wrapper

    # {'io_A': 0, 'io_B': 1, 'clk': 2, 'reset': 3, 'io_X': 4}
    signal_id = s.signal_id

    def setValue(signal_name, value):
        wrapper.setValue(signal_id[signal_name], value)

    def getValue(signal_name):
        return wrapper.getValue(signal_id[signal_name])

    def assign(num):
        setValue("io_A", num % 100)
        setValue("io_B", num % 100)

    def test():
        setValue("clk", 0)
        setValue("reset", 1)
        main_time = 0
        num = 0
        reset_value = 1
        while True:
            if num >= 10000:
                break
            if main_time == 100:
                setValue("reset", 0)
            if reset_value == 1:
                reset_value = getValue("reset")
            if reset_value == 0 and main_time % 5 == 0:
                if getValue("clk") == 0:
                    setValue("clk", 1)
                    assign(num)
                    num = num + 1
                else:
                    setValue("clk", 0)
            wrapper.eval()
            wrapper.sleep_cycles(5)
            main_time = main_time + 5

    wrapper.getHandle('add_dut')
    test()
    wrapper.deleteHandle()


if __name__ == '__main__':
    pass
