cmake_minimum_required(VERSION 2.4)
set(CMAKE_CXX_STANDARD 11)
project(test_adder)

find_package(pybind11 REQUIRED)

# add_subdirectory(utils)
# aux_source_directory(./utils/harness_utils.py hello_src)
# aux_source_directory(./utils hello_src)


pybind11_add_module(test_adder MODULE wrapper.cpp)
# message(STATUS hello_src=${hello_src})
# message(STATUS PROJECT_NAME=${PROJECT_NAME})

# pybind11_add_module(test_adder ${hello_src})

target_link_libraries(test_adder PRIVATE pybind11::embed)

set(SHARED_LIB_EXT ".so")

add_definitions(-DPYTHON_LIBRARY="/usr/lib/x86_64-linux-gnu/libpython3.8.so")

set_target_properties(test_adder PROPERTIES PREFIX ""
        SUFFIX ${SHARED_LIB_EXT})