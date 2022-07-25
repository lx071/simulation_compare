#include <pybind11/pybind11.h>
#include <pybind11/embed.h> // everything needed for embedding
#include <iostream>
namespace py = pybind11;
using namespace py::literals;

int main() {
    //py::scoped_interpreter guard{}; // start the interpreter and keep it alive

    py::print("Hello, World!"); // use the Python API

    py::exec(R"(
        kwargs = dict(name="World", number=42)
        message = "Hello, {name}! The answer is {number}".format(**kwargs)
        print(message)
    )");

    // using namespace py::literals;
    auto kwargs = py::dict("name"_a="Pybind11", "number"_a=66);
    auto message = "Hello, {name}! The answer is {number}"_s.format(**kwargs);
    py::print(message);

    auto locals = py::dict("name"_a="Cn", "number"_a=77);
    py::exec(R"(
        messagee = "Hello, {name}! The answer is {number}".format(**locals())
    )", py::globals(), locals);

    auto messagee = locals["messagee"].cast<std::string>();
    std::cout << messagee << std::endl;

    py::module_ sys = py::module_::import("sys");
    py::print(sys.attr("path"));


    py::module_ calc = py::module_::import("calc");
    py::object result = calc.attr("add")(1, 2);
    int n = result.cast<int>();
    assert(n == 3);
    std::cout << n << std::endl;
    return 11;
}

int add(int i, int j)
{
    std::cout << i + j << std::endl;
    return i + j;
}

PYBIND11_MODULE(example, m)
{
m.doc() = "pybind11 example plugin"; // 可选的模块说明

m.def("add", &add, "A function which adds two numbers", py::arg("i"), py::arg("j"));
m.def("main", &main);

}