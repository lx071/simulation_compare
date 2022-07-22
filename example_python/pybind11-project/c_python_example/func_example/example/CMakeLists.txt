cmake_minimum_required(VERSION 3.4)
project(example)

# add_subdirectory(pybind11)
find_package(pybind11 REQUIRED)  # or `add_subdirectory(pybind11)`

# 将自己pybind11头文件路径包含进来
# INCLUDE_DIRECTORIES(~/pybind/pybind11-2.3.0/include/pybind11)
INCLUDE_DIRECTORIES(/home/xuelin/.local/lib/python3.8/site-packages/pybind11/include/pybind11)


add_executable(example main.cpp)
target_link_libraries(example PRIVATE pybind11::embed)