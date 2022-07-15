#include <pybind11/pybind11.h>
namespace py = pybind11;

class Box
{
    public:
        double length;   // 长度
        double breadth;  // 宽度
        double height;   // 高度
        // 构造函数定义
        Box(double l=2.0, double b=2.0, double h=2.0)
        {
            cout <<"Constructor called." << endl;
            length = l;
            breadth = b;
            height = h;
        }
}
int add(int i, int j)
{
    return i + j;
}

int getNum()
{
    Box b;
    return b.length;
}

PYBIND11_MODULE(example, m)
{
m.doc() = "pybind11 example plugin"; // 可选的模块说明

m.def("add", &add, "A function which adds two numbers", py::arg("i"), py::arg("j"));

}
