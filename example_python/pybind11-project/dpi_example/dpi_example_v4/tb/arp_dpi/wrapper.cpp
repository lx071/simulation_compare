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
 void gen_rand_arr(/* output */ svOpenArrayHandle arr)
{

        timeval t1, t2;
        gettimeofday(&t1, NULL);
        //py::scoped_interpreter guard;

        int len = svSize(arr, 1);

        auto np = py::module::import("numpy");

        // or change to be exec
        auto op = np.attr("random")
                        .attr("randint")(1, 2, len/3, "byte").cast<py::array_t<uint8_t>>();
        
        auto a = np.attr("random")
                        .attr("randint")(0, 127, len/3, "byte").cast<py::array_t<uint8_t>>();
        
        auto b = np.attr("random")
                        .attr("randint")(0, 127, len/3, "byte").cast<py::array_t<uint8_t>>();

        for(int i = 0; i<len/3; ++i){
        
            *(uint8_t*)svGetArrElemPtr1(arr, i*3) = op.at(i);
            *(uint8_t*)svGetArrElemPtr1(arr, i*3+1) = a.at(i);
            *(uint8_t*)svGetArrElemPtr1(arr, i*3+2) = b.at(i);
            
        }
        gettimeofday(&t2, NULL);


        double timeuse  = (t2.tv_sec-t1.tv_sec) + (double)(t2.tv_usec-t1.tv_usec)/1000000.0;
        std::cout << "data transfer time used: "<< timeuse << "s" << std::endl;

        // delete guard;
}


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
    /*
    static unsigned char tmp[32] = {{0}};
    memcpy(tmp, data, 32);
    */
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


extern "C" __attribute__((visibility("default")))
void recv_data(svBitVecVal* data) 
{
    
    py::module_ sys = py::module_::import("sys");
    py::list path = sys.attr("path");
    path.attr("append")("../utils");
    //py::print(sys.attr("path"));
    py::module_ utils = py::module_::import("harness_utils");
   
    size_t size_data = sizeof(data);
    // std::cout<<"size_data:"<<size_data<<std::endl;
    // std::cout<<"sizeof(svBitVecVal)"<<sizeof(svBitVecVal)<<std::endl;
    
    auto res = py::array(py::buffer_info(
        data,                              // 数据指针
        sizeof(char),                      // 元素大小
        py::format_descriptor<char>::value, // 格式化描述符
        1,                                  // 维度
        { 42 },                           // 形状
        { sizeof(char) }                    // 每个维度的字节数
    ));
    
    utils.attr("recv_res")(res);

}

extern "C" __attribute__((visibility("default")))
void c_py_gen_data(svBitVecVal* data) 
{
    //py::scoped_interpreter guard;
    py::module_ sys = py::module_::import("sys");
    py::list path = sys.attr("path");
    path.attr("append")("../utils");
    py::module_ utils = py::module_::import("harness_utils");

    // std::cout<<"send_data"<<std::endl;
    //static unsigned char tmp[32] = {{0}};
    py::bytes result = utils.attr("send_data")();
    Py_ssize_t size = PyBytes_GET_SIZE(result.ptr());
    char * ptr = PyBytes_AsString(result.ptr());    //# low bit 01 02 03 ... 20 high bit
    // std::cout<<"size:"<<size<<std::endl;
    // std::cout<<ptr<<std::endl;
    
    memcpy(data, ptr, size);
}