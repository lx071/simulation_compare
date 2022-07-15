#include "VMyTopLevel.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <vector>
#include <iostream>
#include <cstdio>
#include <time.h>

vluint64_t main_time = 0;   // See comments in first example
const vluint64_t sim_time = 1024;
double sc_time_stamp() { return main_time; }

std::vector<unsigned long long> inputs, outputs;

#define INN 4
#define OUTN 1
int status = 0;

void ioinit(){
    setvbuf(stdout,0,_IONBF, 0);
    setvbuf(stdin,0,_IONBF, 0);
    setvbuf(stderr,0,_IONBF, 0);
    inputs.resize(INN);
    outputs.resize(OUTN);
    return;
}

void input_handler(){
    std::cin>>status;
    if(status==1)
        return;
    for(int i = 0; i < INN; i++){
        std::cin>>inputs[i];
    }
    return;
}

void output_handler(){
    for(int i = 0; i < OUTN; i++){
        //std::cout<<outputs[i]<<" ";
    }
    //std::cout<<std::endl;
    //return;
}

void getTime(){
    std::cout <<"XXXXXXX" << std::endl;
    //获取系统时间戳
    time_t timeReal;
    time(&timeReal);
    timeReal = timeReal + 8*3600;
    tm* t = gmtime(&timeReal); 
    std::cout << timeReal << std::endl;
    printf("%d-%02d-%02d %02d:%02d:%02d", t->tm_year + 1900, t->tm_mon + 1, t->tm_mday, t->tm_hour, t->tm_min, t->tm_sec); 
}

int main(int argc, char** argv, char** env) {
    getTime();
    Verilated::commandArgs(argc, argv);
    ioinit();
    
    VMyTopLevel* top = new VMyTopLevel;
    
    Verilated::internalsDump();  // See scopes to help debug
    Verilated::traceEverOn(true);
    
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("wave.vcd");

    while (!Verilated::gotFinish()) {
        input_handler();
        if(status==1) {
            getTime();
            break;
        }
        //get inputs
        top->io_A = inputs[0];
        top->io_B = inputs[1];
        top->clk = inputs[2];
        top->reset = inputs[3];

        top->eval();
        tfp->dump(main_time);
        outputs[0] = top->io_X;

        //get output
        output_handler();
        main_time++;
    }
    
    top->final();
    tfp->close();
    delete top;
    
    return 0;
}