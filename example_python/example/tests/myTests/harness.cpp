
#include <stdint.h>
#include <string>
#include <memory>
#include <iostream>

#include "VMyTopLevel.h"
#ifdef TRACE
#include "verilated_vcd_c.h"
#endif
#include "VMyTopLevel__Syms.h"

using namespace std;

//类的声明定义（函数、变量）
class ISignalAccess{
public:
  virtual ~ISignalAccess() {}

  virtual uint64_t getU64() = 0;
  virtual uint64_t getU64_mem(size_t index) = 0;
  virtual void setU64(uint64_t value) = 0;
  virtual void setU64_mem(uint64_t value, size_t index) = 0;
};

//类的声明定义（函数、变量）
class  CDataSignalAccess : public ISignalAccess{
public:
    CData *raw;
    CDataSignalAccess(CData *raw) : raw(raw){}
    CDataSignalAccess(CData &raw) : raw(addressof(raw)){}
    uint64_t getU64() {return *raw;}
    uint64_t getU64_mem(size_t index) {return raw[index];}
    void setU64(uint64_t value)  {*raw = value; }
    void setU64_mem(uint64_t value, size_t index){raw[index] = value; }
};

//类的声明定义（函数、变量）
class  SDataSignalAccess : public ISignalAccess{
public:
    SData *raw;
    SDataSignalAccess(SData *raw) : raw(raw){}
    SDataSignalAccess(SData &raw) : raw(addressof(raw)){}
    uint64_t getU64() {return *raw;}
    uint64_t getU64_mem(size_t index) {return raw[index];}
    void setU64(uint64_t value)  {*raw = value; }
    void setU64_mem(uint64_t value, size_t index){raw[index] = value; }
};

//类的声明定义（函数、变量）
class  IDataSignalAccess : public ISignalAccess{
public:
    IData *raw;
    IDataSignalAccess(IData *raw) : raw(raw){}
    IDataSignalAccess(IData &raw) : raw(addressof(raw)){}
    uint64_t getU64() {return * raw;}
    uint64_t getU64_mem(size_t index) {return raw[index];}
    void setU64(uint64_t value)  {*raw = value;}
    void setU64_mem(uint64_t value, size_t index){raw[index] = value;}
};

//类的声明定义（函数、变量）
class  QDataSignalAccess : public ISignalAccess{
public:
    QData *raw;
    QDataSignalAccess(QData *raw) : raw(raw){}
    QDataSignalAccess(QData &raw) : raw(addressof(raw)){}
    uint64_t getU64() {return *raw;}
    uint64_t getU64_mem(size_t index) {return raw[index];}
    void setU64(uint64_t value)  {*raw = value; }
    void setU64_mem(uint64_t value, size_t index){raw[index] = value; }
};

//类的声明定义（函数、变量）
class  WDataSignalAccess : public ISignalAccess{
public:
    WData *raw;
    uint32_t width;
    uint32_t wordsCount;
    bool sint;

    WDataSignalAccess(WData *raw, uint32_t width, bool sint) : 
      raw(raw), width(width), wordsCount((width+31)/32), sint(sint) {}

    uint64_t getU64_mem(size_t index) {
      WData *mem_el = &(raw[index*wordsCount]);
      return mem_el[0] + (((uint64_t)mem_el[1]) << 32);
    }

    uint64_t getU64() { return getU64_mem(0); }

    void setU64_mem(uint64_t value, size_t index)  {
      WData *mem_el = &(raw[index*wordsCount]);
      mem_el[0] = value;
      mem_el[1] = value >> 32;
      uint32_t padding = ((value & 0x8000000000000000l) && sint) ? 0xFFFFFFFF : 0;
      for(uint32_t idx = 2;idx < wordsCount;idx++){
        mem_el[idx] = padding;
      }

      if(width%32 != 0) mem_el[wordsCount-1] &= (1l << width%32)-1;
    }

    void setU64(uint64_t value)  {
      setU64_mem(value, 0);
    }

};

class Wrapper_1;
thread_local Wrapper_1 *simHandle1;

#include <chrono>
using namespace std::chrono;

class Wrapper_1{
public:
    uint64_t time;
    high_resolution_clock::time_point lastFlushAt;
    uint32_t timeCheck;
    bool waveEnabled;
    VMyTopLevel top;
    ISignalAccess *signalAccess[0];
    #ifdef TRACE
	  VerilatedVcdC tfp;
	#endif
    string name;

    Wrapper_1(const char * name){
      simHandle1 = this;
      time = 0;
      timeCheck = 0;
      lastFlushAt = high_resolution_clock::now();
      waveEnabled = true;

      #ifdef TRACE
      Verilated::traceEverOn(true);
      top.trace(&tfp, 99);
      tfp.open("dump.vcd");
      #endif
      this->name = name;
    }

    virtual ~Wrapper_1(){
      for(int idx = 0;idx < 0;idx++){
          delete signalAccess[idx];
      }

      #ifdef TRACE
      if(waveEnabled) tfp.dump((vluint64_t)time);
      tfp.close();
      #endif
      
    }

};

double sc_time_stamp () {
  return simHandle1->time;
}


#ifdef __cplusplus
extern "C" {
#endif
#include <stdio.h>
#include <stdint.h>

#define API __attribute__((visibility("default")))

#ifdef __cplusplus
}
#endif
     