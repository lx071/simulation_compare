// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "VMyTopLevel__Syms.h"


//======================

void VMyTopLevel::trace(VerilatedVcdC* tfp, int, int) {
    tfp->spTrace()->addInitCb(&traceInit, __VlSymsp);
    traceRegister(tfp->spTrace());
}

void VMyTopLevel::traceInit(void* userp, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    VMyTopLevel__Syms* __restrict vlSymsp = static_cast<VMyTopLevel__Syms*>(userp);
    if (!Verilated::calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
                        "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->module(vlSymsp->name());
    tracep->scopeEscape(' ');
    VMyTopLevel::traceInitTop(vlSymsp, tracep);
    tracep->scopeEscape('.');
}

//======================


void VMyTopLevel::traceInitTop(void* userp, VerilatedVcd* tracep) {
    VMyTopLevel__Syms* __restrict vlSymsp = static_cast<VMyTopLevel__Syms*>(userp);
    VMyTopLevel* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlTOPp->traceInitSub0(userp, tracep);
    }
}

void VMyTopLevel::traceInitSub0(void* userp, VerilatedVcd* tracep) {
    VMyTopLevel__Syms* __restrict vlSymsp = static_cast<VMyTopLevel__Syms*>(userp);
    VMyTopLevel* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    const int c = vlSymsp->__Vm_baseCode;
    if (false && tracep && c) {}  // Prevent unused
    // Body
    {
        tracep->declBus(c+1,"io_A", false,-1, 7,0);
        tracep->declBus(c+2,"io_B", false,-1, 7,0);
        tracep->declBus(c+3,"io_X", false,-1, 7,0);
        tracep->declBit(c+4,"clk", false,-1);
        tracep->declBit(c+5,"reset", false,-1);
        tracep->declBus(c+1,"MyTopLevel io_A", false,-1, 7,0);
        tracep->declBus(c+2,"MyTopLevel io_B", false,-1, 7,0);
        tracep->declBus(c+3,"MyTopLevel io_X", false,-1, 7,0);
        tracep->declBit(c+4,"MyTopLevel clk", false,-1);
        tracep->declBit(c+5,"MyTopLevel reset", false,-1);
        tracep->declBus(c+6,"MyTopLevel a", false,-1, 7,0);
        tracep->declBus(c+7,"MyTopLevel b", false,-1, 7,0);
        tracep->declBit(c+8,"MyTopLevel when_MyTopLevel_l36", false,-1);
    }
}

void VMyTopLevel::traceRegister(VerilatedVcd* tracep) {
    // Body
    {
        tracep->addFullCb(&traceFullTop0, __VlSymsp);
        tracep->addChgCb(&traceChgTop0, __VlSymsp);
        tracep->addCleanupCb(&traceCleanup, __VlSymsp);
    }
}

void VMyTopLevel::traceFullTop0(void* userp, VerilatedVcd* tracep) {
    VMyTopLevel__Syms* __restrict vlSymsp = static_cast<VMyTopLevel__Syms*>(userp);
    VMyTopLevel* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlTOPp->traceFullSub0(userp, tracep);
    }
}

void VMyTopLevel::traceFullSub0(void* userp, VerilatedVcd* tracep) {
    VMyTopLevel__Syms* __restrict vlSymsp = static_cast<VMyTopLevel__Syms*>(userp);
    VMyTopLevel* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    vluint32_t* const oldp = tracep->oldp(vlSymsp->__Vm_baseCode);
    if (false && oldp) {}  // Prevent unused
    // Body
    {
        tracep->fullCData(oldp+1,(vlTOPp->io_A),8);
        tracep->fullCData(oldp+2,(vlTOPp->io_B),8);
        tracep->fullCData(oldp+3,(vlTOPp->io_X),8);
        tracep->fullBit(oldp+4,(vlTOPp->clk));
        tracep->fullBit(oldp+5,(vlTOPp->reset));
        tracep->fullCData(oldp+6,(vlTOPp->MyTopLevel__DOT__a),8);
        tracep->fullCData(oldp+7,(vlTOPp->MyTopLevel__DOT__b),8);
        tracep->fullBit(oldp+8,(1U));
    }
}
