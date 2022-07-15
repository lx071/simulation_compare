#include <verilated.h>
#include <verilated_vcd_c.h>
#include <iostream>
#include "VMyTopLevel.h"

using namespace std;

#include <pybind11/pybind11.h>
namespace py = pybind11;

VMyTopLevel* top;
VerilatedVcdC* tfp;

vluint64_t main_time = 0;
//const vluint64_t sim_time = 100000;

int num=0;
void assign(VMyTopLevel *top)
{
    top->io_A = num;
    top->io_B = num;
    num++;
}

int main(int argc, char **argv)
{
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);
    top = new VMyTopLevel;
    tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("dump.vcd");
    top->clk = 0;
    top->reset = 1;

    while(!Verilated::gotFinish())
    {
        if(num>=1000000) break;
        if(main_time==100) top->reset=0;
        if(top->reset ==0 && main_time%5==0)
        {
            top->clk = !(top->clk);
            if(top->clk==1) assign(top);
        }

        top->eval();
        tfp->dump(main_time);
        main_time++;
    }

    tfp->close();
    delete top;
    delete tfp;
    exit(0);
    return 0;
}


int add(int i, int j)
{
return i + j;
}

PYBIND11_MODULE(example, m)
{
m.doc() = "pybind11 example plugin"; // 可选的模块说明

m.def("add", &add, "A function which adds two numbers", py::arg("i"), py::arg("j"));
}
