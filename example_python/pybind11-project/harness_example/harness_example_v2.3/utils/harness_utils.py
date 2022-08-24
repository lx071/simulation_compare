import os
# import random
import subprocess
import re


def do_python_api():
    print('do_python_api')
    return 0


def add(a, b):
    return a + b


def recv(data):
    print('recv_python:', data)


def send_msg():
    data_all = 0
    # 01 02 03 ... 20
    for i in range(512):
        # data = random.randint(1, 100)
        # print(data)
        data = i % 100
        data_all = (data_all << 8) + data

    bytes_val = data_all.to_bytes(512, 'big')
    return bytes_val
    pass


# 解析verilog代码, 返回输入端口名列表 和 输出端口名列表
def verilog_parse(dut_path, top_module_file_name):
    dut_name = top_module_file_name.split('.')[0]  # 模块名
    top_module_path = os.path.join(dut_path, top_module_file_name)
    # print(top_module_path)
    module_begin_match = r"module\s+([a-zA-Z0-9_]+)"
    # 匹配输入端口        input clock, input [31:0] io_a
    input_port_match = r"input\s+(reg|wire)*\s*(\[[0-9]+\:[0-9]+\]*)*\s*([a-zA-Z0-9_]+)"
    # 匹配输出端口        output [31:0] io_c
    output_port_match = r"output\s+(reg|wire)*\s*(\[[0-9]+\:[0-9]+\]*)*\s*([a-zA-Z0-9_]+)"
    current_module_name = ''
    input_ports_name = []
    output_ports_name = []
    with open(top_module_path, "r") as verilog_file:
        while verilog_file:
            verilog_line = verilog_file.readline().strip(' ')  # 读取一行
            # print(verilog_line)
            if verilog_line == "":  # 注：如果是空行，为'\n'
                break
            if "DPI-C" in verilog_line or "function" in verilog_line or "task" in verilog_line:
                continue
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
def genWrapperCpp(ports_name, top_module_file_name):
    dut_name = top_module_file_name.split('.')[0]  # 模块名
    try:
        os.mkdir("simulation")
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
        //构造函数      单冒号(:)的作用是表示后面是初始化列表,对类成员进行初始化
        Signal(CData *raw) : raw(raw){{}}
        Signal(CData &raw) : raw(std::addressof(raw)){{}}
        uint64_t getValue() {{return *raw;}}
        void setValue(uint64_t value)  {{*raw = value; }}
}};

class Wrapper;
thread_local Wrapper *simHandle1;
thread_local Wrapper *simHandle2;

class Wrapper
{{
    public:
        //当前时间
        uint64_t time;
        std::string name;
        int clk_id;
        uint64_t clk_cycles;
        uint64_t cycle_num;
        //const char* send_message_func_name;
        std::string send_message_func_name;

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
            //for DPI-C
            //const svScope scope = svGetScopeFromName("TOP.{dut_name}");
            //assert(scope);  // Check for nullptr if scope not found
            //svSetScope(scope);
            
            simHandle1 = this;
            simHandle2 = this;
            
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
    //std::cout<<"setValue: "<<id<<", "<<newValue<<std::endl;
    //std::cout<<(uint64_t)simHandle1->time<<std::endl;
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

//根据当前时间产生时钟信号
void gen_clk()
{{
    uint64_t time;
    int clk_id = simHandle1->clk_id;
    uint64_t clk_edge_period = simHandle1->clk_cycles/2;
    uint64_t cycle_num = simHandle1->cycle_num;
    uint64_t num = 0;
    simHandle1->signal[1]->setValue(1);
    while(!Verilated::gotFinish())
    {{
        if(num == 20)
        {{
            simHandle1->signal[1]->setValue(0);
        }}
        if(num > 2 * cycle_num) break;
        time = simHandle1->time;
        if(time == 0) simHandle1->signal[clk_id]->setValue(0);
        else if(time % clk_edge_period==0)
        {{
            uint64_t value = simHandle1->signal[clk_id]->getValue();
            if(value == 0) 
            {{
                simHandle1->signal[clk_id]->setValue(1);
                //py::module_ utils = py::module_::import("harness_utils");
                //utils.attr("clk_on")();
            }}
            else simHandle1->signal[clk_id]->setValue(0);
        }}
        eval();
        dump();
        simHandle1->time = time + clk_edge_period;
        //std::cout<<"simHandle1->time:"<<simHandle1->time<<std::endl;
        num++;
    }} 
}}

//设置时钟信号的信息
void set_clk_info(int id, uint64_t cycles, uint64_t cycle_num)
{{    
    std::cout<<"set_clk_info"<<std::endl;
    simHandle1->clk_id = id;
    simHandle1->clk_cycles = cycles;
    simHandle1->cycle_num = cycle_num;
    gen_clk();
}}

void sleep_cycles(uint64_t cycles)
{{
    dump();
    simHandle1->time += cycles;
    gen_clk();
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
    
    py::module_ utils = py::module_::import("utils.harness_utils");
    utils.attr("do_python_api")();
}}
 
 
int operation(char *func_name, int x, int y)
{{
    py::module_ utils = py::module_::import("harness_utils");
    py::object result = utils.attr(func_name)(x, y);
    int n = result.cast<int>();
    return n;
}}

void set_send_message_func(std::string func_name)
{{
    simHandle1->send_message_func_name = func_name;
}}

#include "svdpi.h"
#include "V{dut_name}__Dpi.h"

//typedef unsigned char uint8_t;
//typedef unsigned int uint32_t; 
//typedef uint8_t svScalar;
//typedef svScalar svBit;
//typedef uint32_t svBitVecVal;

extern void c_py_gen_packet(svBitVecVal* data);
extern void recv(int data);

void c_py_gen_packet(svBitVecVal* data) 
{{
    const char * func_name = simHandle1->send_message_func_name.c_str();
    //std::cout<<"func_name_2:"<<func_name<<std::endl;
    static unsigned char tmp[256] = {{0}};
    py::module_ utils = py::module_::import("utils.harness_utils");
    py::bytes result = utils.attr(func_name)();
    Py_ssize_t size = PyBytes_GET_SIZE(result.ptr());
    char * ptr = PyBytes_AsString(result.ptr());    //# low bit 01 02 03 ... 20 high bit
    int i;
    for(i = 0; i < size; i++)
    {{
        tmp[255-i] = ptr[i];      
    }}
    memcpy(data, ptr, 256);
}}

void recv(int data) 
{{
    py::module_ utils = py::module_::import("utils.harness_utils");
    utils.attr("recv")(data);
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
    m.def("set_clk_info", &set_clk_info);
    m.def("operation", &operation);
    m.def("set_send_message_func", &set_send_message_func);
}}

"""
    fd = open(f'simulation/{dut_name}-harness.cpp', "w")
    fd.write(wrapper)
    fd.close()


# ('./hdl/', 'bfm.v')
def runCompile(dut_path, top_module_file_name):
    print("\n\n---------------------verilator build info--------------------------\n")

    dut_name = top_module_file_name.split('.')[0]  # 模块名

    # 在当前目录创建simulation文件夹
    try:
        os.mkdir("simulation")
    except FileExistsError:
        pass

    if not dut_path.endswith('/'):
        dut_path = dut_path + '/'

    # 把所有dut文件复制到simulation文件夹下
    os.system("cp {}* ./simulation/".format(dut_path))

    # vfn = "{}.v".format(self.dut_name)              # {dut_name}.v
    vfn = top_module_file_name
    hfn = "{}-harness.cpp".format(dut_name)  # {dut_name}-harness.cpp
    mfn = "V{}.mk".format(dut_name)  # V{dut_name}.mk
    efn = "V{}".format(dut_name)  # V{dut_name}

    # 改变当前工作目录到指定的路径--simulation
    os.chdir("./simulation")

    pybind_i = subprocess.getoutput('python3 -m pybind11 --includes')
    pybind_CFLAGS = pybind_i.replace(' ', ' -CFLAGS ')

    # 由硬件设计文件得到C++模型以及相关文件
    compile_command_1 = f"verilator -CFLAGS -fPIC -CFLAGS -m64 -CFLAGS -shared -CFLAGS -Wno-attributes -LDFLAGS -fPIC -LDFLAGS -m64 -LDFLAGS -shared -LDFLAGS -Wno-attributes -CFLAGS {pybind_CFLAGS} -CFLAGS -fvisibility=hidden -LDFLAGS -fvisibility=hidden -CFLAGS -DTRACE --Mdir verilator --cc {vfn} --trace --exe {hfn}"
    # 得到相关库文件(.o)以及可执行文件
    compile_command_2 = f"make -j -C ./verilator -f {mfn}"
    # 由各个库文件(.o)得到共享库文件(.so)
    compile_command_3 = f"c++ -O3 -Wall -shared -std=c++11 -fPIC -faligned-new ./verilator/*.o -o verilator/wrapper.so"

    print(compile_command_1)
    os.system(compile_command_1)
    os.system(compile_command_2)
    os.system(compile_command_3)


class sim:
    # s = sim('./hdl/', 'bfm.v')
    def __init__(self, dut_path, top_module_file_name):
        input_ports_name, output_ports_name = verilog_parse(dut_path, top_module_file_name)
        ports_name = input_ports_name + output_ports_name
        list_n = [i for i in range(len(ports_name))]
        self.signal_id = dict(zip(ports_name, list_n))
        # print(self.signal_id)
        self.dut_path = dut_path
        genWrapperCpp(ports_name, top_module_file_name)
        runCompile(dut_path, top_module_file_name)
        # print(os.getcwd())
        from simulation.verilator import wrapper
        self.wp = wrapper
        self.getHandle('sim_wrapper')

    def setValue(self, signal_name, value):
        self.wp.setValue(self.signal_id[signal_name], value)

    def getValue(self, signal_name):
        return self.wp.getValue(self.signal_id[signal_name])

    def getHandle(self, sim_name):
        return self.wp.getHandle(sim_name)

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

    def set_clk_info(self, clk_name, cycles, cycle_num):
        self.wp.set_clk_info(self.signal_id[clk_name], cycles, cycle_num)

    def operation(self, func_name, a, b):
        return self.wp.operation(func_name, a, b)

    def set_send_message_func(self, clk_name):
        self.wp.set_send_message_func(clk_name)

    def disableWave(self):
        self.wp.disableWave()


if __name__ == '__main__':
    pass
