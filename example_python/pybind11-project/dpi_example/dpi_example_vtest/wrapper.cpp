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

//ref_inputs_2 = [[0x5f6d26e8b89772df73b49b719b5e946cdf1d5518ba3eefca94032a29cc0a4c5f,
//0x5f6d26e8b89772df73b49b719b5e946cdf1d5518ba3eefca94032a29cc0a4c5f,
//0x5f6d26e8b89772df73b49b719b5e946cdf1d5518ba3eefca94032a29cc0a4c5f] for i in range(CASES_NUM)]
//ref_outputs_2 = [0x132e0fb58f03f49eafd655b559cbf6e2bd371c269f8039cbd3fa6f6b17a29797 for i in range(CASES_NUM)]


extern "C" __attribute__((visibility("default")))
 void gen_rand_arr(/* output */ svOpenArrayHandle arr)
{

        timeval t1, t2;
        gettimeofday(&t1, NULL);
        py::scoped_interpreter guard;

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

extern void c_py_gen_packet(svBitVecVal* data);
extern void recv(int data);

void c_py_gen_packet(svBitVecVal* data) 
{
    static unsigned char tmp[256] = {{0}};
    py::module_ utils = py::module_::import("utils.harness_utils");
    py::bytes result = utils.attr(func_name)();
    Py_ssize_t size = PyBytes_GET_SIZE(result.ptr());
    char * ptr = PyBytes_AsString(result.ptr());    //# low bit 01 02 03 ... 20 high bit
    int i;
    for(i = 0; i < size; i++)
    {
        tmp[255-i] = ptr[i];      
    }
    memcpy(data, ptr, 256);
}

void recv(int data) 
{
    py::module_ utils = py::module_::import("utils.harness_utils");
    utils.attr("recv")(data);
}