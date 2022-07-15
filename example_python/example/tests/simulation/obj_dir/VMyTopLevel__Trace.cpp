// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "VMyTopLevel__Syms.h"


void VMyTopLevel::traceChgTop0(void* userp, VerilatedVcd* tracep) {
    VMyTopLevel__Syms* __restrict vlSymsp = static_cast<VMyTopLevel__Syms*>(userp);
    VMyTopLevel* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Variables
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    {
        vlTOPp->traceChgSub0(userp, tracep);
    }
}

void VMyTopLevel::traceChgSub0(void* userp, VerilatedVcd* tracep) {
    VMyTopLevel__Syms* __restrict vlSymsp = static_cast<VMyTopLevel__Syms*>(userp);
    VMyTopLevel* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    vluint32_t* const oldp = tracep->oldp(vlSymsp->__Vm_baseCode + 1);
    if (false && oldp) {}  // Prevent unused
    // Body
    {
        tracep->chgCData(oldp+0,(vlTOPp->io_A),8);
        tracep->chgCData(oldp+1,(vlTOPp->io_B),8);
        tracep->chgCData(oldp+2,(vlTOPp->io_X),8);
        tracep->chgBit(oldp+3,(vlTOPp->clk));
        tracep->chgBit(oldp+4,(vlTOPp->reset));
        tracep->chgCData(oldp+5,(vlTOPp->MyTopLevel__DOT__a),8);
        tracep->chgCData(oldp+6,(vlTOPp->MyTopLevel__DOT__b),8);
    }
}

void VMyTopLevel::traceCleanup(void* userp, VerilatedVcd* /*unused*/) {
    VMyTopLevel__Syms* __restrict vlSymsp = static_cast<VMyTopLevel__Syms*>(userp);
    VMyTopLevel* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlSymsp->__Vm_activity = false;
        vlTOPp->__Vm_traceActivity[0U] = 0U;
    }
}
