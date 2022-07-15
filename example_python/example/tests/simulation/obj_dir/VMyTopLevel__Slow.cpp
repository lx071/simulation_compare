// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See VMyTopLevel.h for the primary calling header

#include "VMyTopLevel.h"
#include "VMyTopLevel__Syms.h"

//==========

VL_CTOR_IMP(VMyTopLevel) {
    VMyTopLevel__Syms* __restrict vlSymsp = __VlSymsp = new VMyTopLevel__Syms(this, name());
    VMyTopLevel* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Reset internal values
    
    // Reset structure values
    _ctor_var_reset();
}

void VMyTopLevel::__Vconfigure(VMyTopLevel__Syms* vlSymsp, bool first) {
    if (false && first) {}  // Prevent unused
    this->__VlSymsp = vlSymsp;
    if (false && this->__VlSymsp) {}  // Prevent unused
    Verilated::timeunit(-9);
    Verilated::timeprecision(-12);
}

VMyTopLevel::~VMyTopLevel() {
    VL_DO_CLEAR(delete __VlSymsp, __VlSymsp = nullptr);
}

void VMyTopLevel::_settle__TOP__2(VMyTopLevel__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VMyTopLevel::_settle__TOP__2\n"); );
    VMyTopLevel* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->io_X = (0xffU & ((IData)(vlTOPp->MyTopLevel__DOT__a) 
                             + (IData)(vlTOPp->MyTopLevel__DOT__b)));
}

void VMyTopLevel::_eval_initial(VMyTopLevel__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VMyTopLevel::_eval_initial\n"); );
    VMyTopLevel* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->__Vclklast__TOP__clk = vlTOPp->clk;
    vlTOPp->__Vclklast__TOP__reset = vlTOPp->reset;
}

void VMyTopLevel::final() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VMyTopLevel::final\n"); );
    // Variables
    VMyTopLevel__Syms* __restrict vlSymsp = this->__VlSymsp;
    VMyTopLevel* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
}

void VMyTopLevel::_eval_settle(VMyTopLevel__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VMyTopLevel::_eval_settle\n"); );
    VMyTopLevel* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->_settle__TOP__2(vlSymsp);
}

void VMyTopLevel::_ctor_var_reset() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VMyTopLevel::_ctor_var_reset\n"); );
    // Body
    io_A = VL_RAND_RESET_I(8);
    io_B = VL_RAND_RESET_I(8);
    io_X = VL_RAND_RESET_I(8);
    clk = VL_RAND_RESET_I(1);
    reset = VL_RAND_RESET_I(1);
    MyTopLevel__DOT__a = VL_RAND_RESET_I(8);
    MyTopLevel__DOT__b = VL_RAND_RESET_I(8);
    for (int __Vi0=0; __Vi0<1; ++__Vi0) {
        __Vm_traceActivity[__Vi0] = VL_RAND_RESET_I(1);
    }
}
