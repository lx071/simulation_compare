cmake_minimum_required(VERSION 3.4)
project(example)

# SET(ENV{变量名} 值)
# PYTHONPATH=/home/xuelin/projects/simulation_compare/example_python/pybind11-project/c_python_example/cmake_example/src/:$PATH

add_subdirectory(pybind11)
# find_package(pybind11 REQUIRED)  # or `add_subdirectory(pybind11)`

aux_source_directory(./src hello_src)

add_executable(${PROJECT_NAME} ${hello_src})
# pybind11_add_module(${PROJECT_NAME} ${hello_src})

target_link_libraries(example PRIVATE pybind11::embed)