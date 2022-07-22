//main.cpp
#include<pybind11/embed.h>
#include<iostream>
namespace py=pybind11;
int main() {
    py::scoped_interpreter python;
    //查看系统路径
    py::module sys=py::module::import("sys");
    py::print(sys.attr("path"));
    //用import函数导入python模块
    auto module=py::module::import("calc");
    //调用函数时要用attr（）进行类型转换
    module.attr("add")(1,2);
    return 0;
}