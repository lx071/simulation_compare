#include <verilated.h>
#include <verilated_vcd_c.h>
#include <iostream>
#include "VMyTopLevel.h"

using namespace std;

VMyTopLevel* top;
VerilatedVcdC* tfp;

vluint64_t main_time = 0;
//const vluint64_t sim_time = 100000;

int num=0;
void assign(VMyTopLevel *top)
{
    top->io_A = num % 200;
    top->io_B = num % 200;
    num++;
}
#include "VMyTopLevel__Dpi.h"
#include "svdpi.h"

extern "C" void sv_print();

int main(int argc, char **argv)
{
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);
    top = new VMyTopLevel;
    //tfp = new VerilatedVcdC;
    //top->trace(tfp, 99);
    //tfp->open("dump.vcd");
    top->clk = 0;
    top->reset = 1;

    //const svScope scope = svGetScopeFromName("TOP.MyTopLevel");
    //assert(scope);  // Check for nullptr if scope not found
    //svSetScope(scope);
    //sv_print();

    while(!Verilated::gotFinish())
    {
        if(num>=2000000) break;
        if(main_time==100) top->reset=0;
        if(top->reset ==0)
        {
            top->clk = !(top->clk);
            if(top->clk==1) assign(top);
        }

        top->eval();
        //tfp->dump(main_time);
        main_time+=5;
    }

    //tfp->close();
    delete top;
    //delete tfp;
    exit(0);
    return 0;
}