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
void c_py_gen_packet(svBitVecVal* data) 
{
    //py::scoped_interpreter guard;
    py::module_ sys = py::module_::import("sys");
    py::list path = sys.attr("path");
    path.attr("append")("../utils");
    py::module_ utils = py::module_::import("harness_utils");

    std::cout<<"c_py_gen_packet_cpp"<<std::endl;
    //static unsigned char tmp[32] = {{0}};
    py::bytes result = utils.attr("send_msg")();
    Py_ssize_t size = PyBytes_GET_SIZE(result.ptr());
    char * ptr = PyBytes_AsString(result.ptr());    //# low bit 01 02 03 ... 20 high bit
    std::cout<<"size:"<<size<<std::endl;
    // std::cout<<ptr<<std::endl;
    
    memcpy(data, ptr, size);
}

extern "C" __attribute__((visibility("default")))
void recv_res(svBitVecVal* data) 
{
    py::module_ sys = py::module_::import("sys");
    py::list path = sys.attr("path");
    path.attr("append")("../utils");
    //py::print(sys.attr("path"));
    py::module_ utils = py::module_::import("harness_utils");

    size_t size_data = sizeof(data);

    auto res = py::array(py::buffer_info(
        data,                                       // 数据指针
        sizeof(svBitVecVal),                        // 元素大小
        py::format_descriptor<svBitVecVal>::value, // 格式化描述符
        1,                                          // 维度
        { size_data },                              // 形状
        { sizeof(svBitVecVal) }                    // 每个维度的字节数
    ));

    utils.attr("recv")(res);

}