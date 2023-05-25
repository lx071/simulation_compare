#include "verilated.h"
#include "Vbfm.h"

#include <iostream>
#include "svdpi.h"

using namespace std;

extern "C" void init(svOpenArrayHandle input_data, svOpenArrayHandle output_data);
extern "C" void gen_data();
extern "C" void recv_data();


class Mem {
public:

    Mem(int count){
        cout << "Mem" << endl;
    }
    unsigned char *dut_in_data = nullptr;
    unsigned char *dut_out_data = nullptr;

    void init(unsigned char* in_data, unsigned char* out_data) 
    {
        // cout << "init" << endl;
        dut_in_data = in_data;
        dut_out_data = out_data;
    }

    void gen_data()
    {
        for(int i = 0;i < 5; i++)
        {
            dut_in_data[i] = i;
        }
    }
    void recv_data()
    {
        cout << "recv_data:";
        for(int i = 0;i < 5; i++)
        {
            printf("%02x", dut_out_data[i]);
        }
        cout << endl;
    }
};


Mem mem(0);

void gen_data()
{

    mem.gen_data();
}

void recv_data()
{

    mem.recv_data();
}

void init(svOpenArrayHandle input_data, svOpenArrayHandle output_data) 
{
    unsigned char *in_data;
    unsigned char *out_data;
    in_data = ( unsigned char* ) svGetArrayPtr(input_data);
    out_data = ( unsigned char* ) svGetArrayPtr(output_data);

    mem.init(in_data, out_data);

}

int main(int argc, char** argv)
{
    auto contextp {make_unique<VerilatedContext>()};
    // std::unique_ptr<VerilatedContext> contextp_;
    // Vwrapper* top_;
    contextp->commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    auto top {make_unique<Vbfm>(contextp.get())};
    while(!contextp->gotFinish()){
        top->eval();
        contextp->timeInc(4000);
    }

    return 0;
}