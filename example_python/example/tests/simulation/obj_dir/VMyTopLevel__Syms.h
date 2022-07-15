// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef _VMYTOPLEVEL__SYMS_H_
#define _VMYTOPLEVEL__SYMS_H_  // guard

#include "verilated.h"

// INCLUDE MODULE CLASSES
#include "VMyTopLevel.h"

// SYMS CLASS
class VMyTopLevel__Syms : public VerilatedSyms {
  public:
    
    // LOCAL STATE
    const char* __Vm_namep;
    bool __Vm_activity;  ///< Used by trace routines to determine change occurred
    uint32_t __Vm_baseCode;  ///< Used by trace routines when tracing multiple models
    bool __Vm_didInit;
    
    // SUBCELL STATE
    VMyTopLevel*                   TOPp;
    
    // CREATORS
    VMyTopLevel__Syms(VMyTopLevel* topp, const char* namep);
    ~VMyTopLevel__Syms() = default;
    
    // METHODS
    inline const char* name() { return __Vm_namep; }
    
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);

#endif  // guard
