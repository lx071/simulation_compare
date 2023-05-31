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
    svOpenArrayHandle dut_in_data;
    svOpenArrayHandle dut_out_data;

    void init(svOpenArrayHandle in_data, svOpenArrayHandle out_data) 
    {
        // cout << "init" << endl;
        dut_in_data = in_data;
        dut_out_data = out_data;
        for(int i = 0;i < 5; i++)
        {
            // dut_in_data[i] = i;
            *(uint8_t*)svGetArrElemPtr1(in_data, i) = i;
        }
    }

    void gen_data()
    {
        for(int i = 0;i < 5; i++)
        {
            *(uint8_t*)svGetArrElemPtr1(in_data, i) = i + 1;
        }
    }
    void recv_data()
    {
        cout << "recv_data:";
        for(int i = 0;i < 5; i++)
        {
            printf("%02x", *(uint8_t*)svGetArrElemPtr1(out_data, i));
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
    // unsigned char *in_data;
    // unsigned char *out_data;
    // in_data = ( unsigned char* ) svGetArrayPtr(input_data);
    // out_data = ( unsigned char* ) svGetArrayPtr(output_data);

    mem.init(input_data, output_data);

}