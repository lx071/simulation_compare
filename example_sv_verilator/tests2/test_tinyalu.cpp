#include <verilated.h>
#include <verilated_vcd_c.h>
#include <iostream>
#include "Vtinyalu.h"

using namespace std;

Vtinyalu* top;
VerilatedVcdC* tfp;

vluint64_t main_time = 0;
//const vluint64_t sim_time = 100000;

int num=0;
void assign(Vtinyalu *top)
{
    top->start = 1;
    top->op = 1;
    top->A = num%200;
    top->B = num%200;  
    num++;
}

int main(int argc, char **argv)
{
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);
    top = new Vtinyalu;
    //tfp = new VerilatedVcdC;
    //top->trace(tfp, 99);
    //tfp->open("dump.vcd");
    top->clk = 0;
    top->reset_n = 0;

    //const svScope scope = svGetScopeFromName("TOP.MyTopLevel");
    //assert(scope);  // Check for nullptr if scope not found
    //svSetScope(scope);
    //sv_print();

    while(!Verilated::gotFinish())
    {
        if(num>=2000000) break;
        if(main_time==100)
        {
            top->reset_n=1;       
        }
        if(top->reset_n ==1)
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