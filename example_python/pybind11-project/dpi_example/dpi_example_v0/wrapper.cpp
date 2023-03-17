#include <pybind11/embed.h>
#include <pybind11/pybind11.h>
#include <pybind11/numpy.h>
#include <dlfcn.h>
#include <unordered_map>
#include <iostream>
#include <memory>
#include <sys/time.h>
#include "svdpi.h"

namespace py=pybind11;

extern "C" __attribute__((visibility("default")))
 void gen_rand_arr(/* output */ svOpenArrayHandle arr)
{
        timeval t1, t2;
        gettimeofday(&t1, NULL);
        py::scoped_interpreter guard;

        int len = svSize(arr, 1);

        auto np = py::module::import("numpy");

        // or change to be exec
        auto from_arr = np.attr("random")
                        .attr("randint")(0, 127, len, "byte").cast<py::array_t<uint8_t>>();

        for(int i = 0; i<len; ++i){
            *(uint8_t*)svGetArrElemPtr1(arr, i) = from_arr.at(i);
        }
        gettimeofday(&t2, NULL);


        double timeuse  = (t2.tv_sec-t1.tv_sec) + (double)(t2.tv_usec-t1.tv_usec)/1000000.0;
        std::cout << "data transfer time used: "<< timeuse << "s" << std::endl;

        // delete guard;
}