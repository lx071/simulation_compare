cmake_minimum_required(VERSION 2.4)
set(CMAKE_CXX_STANDARD 11)
project(test_adder)

find_package(pybind11 REQUIRED)

pybind11_add_module(test_adder MODULE wrapper.cpp)

target_link_libraries(test_adder PRIVATE pybind11::embed)

set(SHARED_LIB_EXT ".so")

add_definitions(-DPYTHON_LIBRARY="/usr/lib/x86_64-linux-gnu/libpython3.10.so")

set_target_properties(test_adder PROPERTIES PREFIX ""
        SUFFIX ${SHARED_LIB_EXT})