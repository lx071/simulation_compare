cmake_minimum_required(VERSION 2.4)
set(CMAKE_CXX_STANDARD 11)
project(test_arp)

find_package(pybind11 REQUIRED)

pybind11_add_module(${PROJECT_NAME} MODULE wrapper.cpp)

# message(STATUS PROJECT_NAME=${PROJECT_NAME})
# pybind11_add_module(${PROJECT_NAME} ${hello_src})

target_link_libraries(${PROJECT_NAME} PRIVATE pybind11::embed)

set(SHARED_LIB_EXT ".so")

add_definitions(-DPYTHON_LIBRARY="/usr/lib/x86_64-linux-gnu/libpython3.8.so")

set_target_properties(${PROJECT_NAME} PROPERTIES PREFIX ""
        SUFFIX ${SHARED_LIB_EXT})