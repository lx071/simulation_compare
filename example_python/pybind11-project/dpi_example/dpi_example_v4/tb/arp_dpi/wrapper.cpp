#include <pybind11/embed.h>
#include <pybind11/pybind11.h>
#include <pybind11/numpy.h>
#include <dlfcn.h>
#include <unordered_map>
#include <iostream>
#include <memory>
#include <sys/time.h>
#include "svdpi.h"

//typedef unsigned char uint8_t;
//typedef unsigned int uint32_t; 
//typedef uint8_t svScalar;
//typedef svScalar svBit;
//typedef uint32_t svBitVecVal;

namespace py=pybind11;

py::scoped_interpreter guard;


extern "C" __attribute__((visibility("default")))
void recv_data(svBitVecVal* data, int n) 
{
    py::module_ sys = py::module_::import("sys");
    py::list path = sys.attr("path");
    path.attr("append")("../utils");    //for verilator
    // path.attr("append")("./utils");    //for galaxsim
    py::module_ utils = py::module_::import("harness_utils");
   
    size_t size_data = sizeof(data);
    
    auto res = py::array(py::buffer_info(
        data,                              // 数据指针
        sizeof(char),                      // 元素大小
        py::format_descriptor<char>::value, // 格式化描述符
        1,                                  // 维度
        { n },                           // 形状
        { sizeof(char) }                    // 每个维度的字节数
    ));
    
    utils.attr("recv_res")(res);

}

extern "C" __attribute__((visibility("default")))
void c_py_gen_data(svBitVecVal* data) 
{
    py::module_ sys = py::module_::import("sys");
    py::list path = sys.attr("path");
    path.attr("append")("../utils");    //for verilator
    // path.attr("append")("./utils");    //for galaxsim
    py::module_ utils = py::module_::import("harness_utils");

    py::bytes result = utils.attr("send_data")();
    Py_ssize_t size = PyBytes_GET_SIZE(result.ptr());
    char * ptr = PyBytes_AsString(result.ptr());    //# low bit 01 02 03 ... 20 high bit

    memcpy(data, ptr, size);
}

