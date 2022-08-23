import os
import subprocess
import time


# 传入文件路径和端口名列表，生成 Wrapper文件
def genWrapperCpp(top_module_file_name):
    dut_name = top_module_file_name.split('.')[0]  # 模块名
    try:
        os.mkdir("simulation")
    except FileExistsError:
        pass

    wrapper = f"""
#include <pybind11/pybind11.h>
#include <pybind11/embed.h> // everything needed for embedding
namespace py = pybind11;

#include <stdint.h>
#include <iostream>
#include <string>


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


#include "svdpi.h"

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
        tmp[31-i] = ptr[i];      
    }}
    memcpy(data, tmp, 32);
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

    m.def("doPythonApi", &doPythonApi);
    m.def("operation", &operation);

}}

"""
    fd = open(f'simulation/{dut_name}-harness.cpp', "w")
    fd.write(wrapper)
    fd.close()


# ('./hdl/', 'bfm.v')
def runCompile(dut_path, top_module_file_name):
    print("\n\n---------------------iverilog build info--------------------------\n")

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
    tfn = "../test_adder.v"
    hfn = "{}-harness.cpp".format(dut_name)  # {dut_name}-harness.cpp
    mfn = "V{}.mk".format(dut_name)  # V{dut_name}.mk
    efn = "V{}".format(dut_name)  # V{dut_name}

    # 改变当前工作目录到指定的路径--simulation
    os.chdir("./simulation")

    pybind_i = subprocess.getoutput('python3 -m pybind11 --includes')

    compile_command_0 = f"iverilog -o run.out *.sv *.v"

    compile_command_1 = f"c++ -O3 -Wall -shared -std=c++11 -fPIC {pybind_i} {hfn} -o example.so"

    compile_command_2 = f"vvp -n run.out"
    # c++ -O3 -Wall -shared -std=c++11 -fPIC $(shell python3 -m pybind11 --includes) example.cpp -o example$(shell python3-config --extension-suffix)
    # c++ -O3 -Wall -shared -std=c++11 -fPIC -I/usr/include/python3.8 -I/home/xuelin/.local/lib/python3.8/site-packages/pybind11/include example.cpp -o example.so

    print(compile_command_0)
    # print(compile_command_1)
    print(compile_command_2)

    time0 = time.time()
    os.system(compile_command_0)
    time1 = time.time()
    # os.system(compile_command_1)
    time2 = time.time()
    os.system(compile_command_2)
    time3 = time.time()
    print('compile time:', time2 - time0)
    print('simulation time:', time3 - time2)


if __name__ == '__main__':
    genWrapperCpp('test_adder.v')
    runCompile('../hdl', 'test_adder.v')
    pass
