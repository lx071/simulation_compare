#include <pybind11/pybind11.h>
namespace py = pybind11;

#include <stdint.h>
#include <iostream>
#include <string>

#include "VMyTopLevel.h"
#ifdef TRACE
#include "verilated_vcd_c.h"
#endif
#include "VMyTopLevel__Syms.h"

//8个字节
//typedef uint64_t CData;

//usr/local/share/verilator/include/verilated.h
//typedef vluint8_t    CData;     ///< Verilated pack data, 1-8 bits
//typedef vluint16_t   SData;     ///< Verilated pack data, 9-16 bits
//typedef vluint32_t   IData;     ///< Verilated pack data, 17-32 bits
//typedef vluint64_t   QData;     ///< Verilated pack data, 33-64 bits
//typedef vluint32_t   EData;     ///< Verilated pack element of WData array
//typedef EData        WData;     ///< Verilated pack data, >64 bits, as an array
class Signal
{
    public:
        //指针指向信号值
        CData* raw;
        Signal(CData *raw) : raw(raw){}
        Signal(CData &raw) : raw(std::addressof(raw)){}
        uint64_t getValue() {return *raw;}
        void setValue(uint64_t value)  {*raw = value; }
};


class Wrapper
{
    public:
        uint64_t time;
        std::string name;
        // 指针数组, 指向各个Signal
        Signal *signal[5];
        // 是否产生波形
        bool waveEnabled;
        //dut
        VMyTopLevel top;
        #ifdef TRACE
        VerilatedVcdC tfp;
	    #endif

        Wrapper(const char * name)
        {
            signal[0] = new Signal(top.io_A);
            signal[1] = new Signal(top.io_B);
            signal[2] = new Signal(top.io_X);
            signal[3] = new Signal(top.clk);
            signal[4] = new Signal(top.reset);

            time = 0;
            waveEnabled = true;
            #ifdef TRACE
            Verilated::traceEverOn(true);
            top.trace(&tfp, 99);
            tfp.open("dump.vcd");
            #endif
            this->name = name;
        }

        // 析构函数在对象消亡时即自动被调用
        virtual ~Wrapper()
        {
            for(int idx = 0;idx < 5;idx++)
            {
                delete signal[idx];
            }
            #ifdef TRACE
            if(waveEnabled) tfp.dump((uint64_t)time);
            tfp.close();
            #endif
            std::cout<<"closeAll()"<<std::endl;
        }
};

Wrapper* getHandle(const char * name)
{
    Wrapper* handle = new Wrapper(name);
    return handle;
}

void setValue(Wrapper* handle, int id, uint64_t newValue)
{
    handle->signal[id]->setValue(newValue);
//    std::cout<<"set value:"<<id<<" :"<<newValue<<std::endl;
}

uint64_t getValue(Wrapper* handle, int id)
{
    return handle->signal[id]->getValue();
}

bool eval(Wrapper* handle)
{
    handle->top.eval();
//    std::cout<<"time:"<<handle->time<<std::endl;
    #ifdef TRACE
    if(handle->waveEnabled) handle->tfp.dump((uint64_t)handle->time);
    #endif
    handle->time ++;
    return Verilated::gotFinish();
}

void sleep_cycles(Wrapper* handle, uint64_t cycles)
{
    #ifdef TRACE
    if(handle->waveEnabled)
    {
        handle->tfp.dump((uint64_t)handle->time);
    }
    #endif
    handle->time += cycles;
}

void deleteHandle(Wrapper *handle)
{
    delete handle;
}

// 启动产生波形
void enableWave(Wrapper *handle)
{
    handle->waveEnabled = true;
}

// 关闭产生波形
void disableWave(Wrapper *handle)
{
    handle->waveEnabled = false;
}

//定义Python与C++之间交互的func与class
PYBIND11_MODULE(example, m)
{
    py::class_<Wrapper>(m, "Wrapper")
        .def(py::init<const char *>());

    m.def("getHandle", &getHandle, py::return_value_policy::reference);
    m.def("setValue", &setValue);
    m.def("getValue", &getValue);
    m.def("eval", &eval);
    m.def("sleep_cycles", &sleep_cycles);
    m.def("deleteHandle", &deleteHandle);
    m.def("enableWave", &enableWave);
    m.def("disableWave", &disableWave);
}
