// -*- SystemC -*-
// DESCRIPTION: Verilator Example: Top level main for invoking SystemC model
//
// This file ONLY is placed under the Creative Commons Public Domain, for
// any use, without warranty, 2017 by Wilson Snyder.
// SPDX-License-Identifier: CC0-1.0
//======================================================================

// Include common routines
#include <verilated.h>

// Include model header, generated from Verilating "top.v"
#include "Vwrapper.h"

#include "svdpi.h"
#include "Vwrapper__Dpi.h"
#include <iostream>

using namespace std;

unsigned char *arr;

// typedef unsigned __int32 uint32_t;
// typedef uint32_t svBitVecVal;
extern "C" __attribute__((visibility("default")))
void gen_tlm_data(svBitVecVal* data, int num) 
{
    //int num = 100;
    // unsigned char arr[num*2];
    arr = new unsigned char[num*2];

    for (int i = 0; i < num; i = i + 1) {
        arr[i*2] = i%100;
        arr[i*2+1] = i%100;
    }
    // unsigned char arr[] = {0x1, 0x2, 0x3, 0x4, 0x5};
    unsigned char *payload_data = arr;
    // const unsigned int* sv_data = reinterpret_cast<const unsigned int*>(payload_data);
    // set_data(sv_data);

    memcpy(data, payload_data, num*2);
}


int main(int argc, char* argv[]) {
    
    // Vwrapper* top = new Vwrapper{"wrapper"};
    
    auto contextp {make_unique<VerilatedContext>()};
    auto top {make_unique<Vwrapper>(contextp.get())};
    contextp->commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    // Simulate until $finish
    while (!Verilated::gotFinish()) {       
        top->eval();
        contextp->timeInc(1000);
    }

    // Final model cleanup
    top->final();

    // Return good completion status
    return 0;
}