// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See VMyTopLevel.h for the primary calling header

#include "VMyTopLevel.h"
#include "VMyTopLevel__Syms.h"

//==========

void VMyTopLevel::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate VMyTopLevel::eval\n"); );
    VMyTopLevel__Syms* __restrict vlSymsp = this->__VlSymsp;  // Setup global symbol table
    VMyTopLevel* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
#ifdef VL_DEBUG
    // Debug assertions
    _eval_debug_assertions();
#endif  // VL_DEBUG
    // Initialize
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) _eval_initial_loop(vlSymsp);
    // Evaluate till stable
    int __VclockLoop = 0;
    QData __Vchange = 1;
    do {
        VL_DEBUG_IF(VL_DBG_MSGF("+ Clock loop\n"););
        vlSymsp->__Vm_activity = true;
        _eval(vlSymsp);
        if (VL_UNLIKELY(++__VclockLoop > 100)) {
            // About to fail, so enable debug to see what's not settling.
            // Note you must run make with OPT=-DVL_DEBUG for debug prints.
            int __Vsaved_debug = Verilated::debug();
            Verilated::debug(1);
            __Vchange = _change_request(vlSymsp);
            Verilated::debug(__Vsaved_debug);
            VL_FATAL_MT("MyTopLevel.v", 7, "",
                "Verilated model didn't converge\n"
                "- See DIDNOTCONVERGE in the Verilator manual");
        } else {
            __Vchange = _change_request(vlSymsp);
        }
    } while (VL_UNLIKELY(__Vchange));
}

void VMyTopLevel::_eval_initial_loop(VMyTopLevel__Syms* __restrict vlSymsp) {
    vlSymsp->__Vm_didInit = true;
    _eval_initial(vlSymsp);
    vlSymsp->__Vm_activity = true;
    // Evaluate till stable
    int __VclockLoop = 0;
    QData __Vchange = 1;
    do {
        _eval_settle(vlSymsp);
        _eval(vlSymsp);
        if (VL_UNLIKELY(++__VclockLoop > 100)) {
            // About to fail, so enable debug to see what's not settling.
            // Note you must run make with OPT=-DVL_DEBUG for debug prints.
            int __Vsaved_debug = Verilated::debug();
            Verilated::debug(1);
            __Vchange = _change_request(vlSymsp);
            Verilated::debug(__Vsaved_debug);
            VL_FATAL_MT("MyTopLevel.v", 7, "",
                "Verilated model didn't DC converge\n"
                "- See DIDNOTCONVERGE in the Verilator manual");
        } else {
            __Vchange = _change_request(vlSymsp);
        }
    } while (VL_UNLIKELY(__Vchange));
}

VL_INLINE_OPT void VMyTopLevel::_sequent__TOP__1(VMyTopLevel__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VMyTopLevel::_sequent__TOP__1\n"); );
    VMyTopLevel* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    if (vlTOPp->reset) {
        vlTOPp->MyTopLevel__DOT__b = 0U;
        vlTOPp->MyTopLevel__DOT__a = 0U;
    } else {
        vlTOPp->MyTopLevel__DOT__b = vlTOPp->io_B;
        vlTOPp->MyTopLevel__DOT__a = vlTOPp->io_A;
    }
    vlTOPp->io_X = (0xffU & ((IData)(vlTOPp->MyTopLevel__DOT__a) 
                             + (IData)(vlTOPp->MyTopLevel__DOT__b)));
}

void VMyTopLevel::_eval(VMyTopLevel__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VMyTopLevel::_eval\n"); );
    VMyTopLevel* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    if ((((IData)(vlTOPp->clk) & (~ (IData)(vlTOPp->__Vclklast__TOP__clk))) 
         | ((IData)(vlTOPp->reset) & (~ (IData)(vlTOPp->__Vclklast__TOP__reset))))) {
        vlTOPp->_sequent__TOP__1(vlSymsp);
    }
    // Final
    vlTOPp->__Vclklast__TOP__clk = vlTOPp->clk;
    vlTOPp->__Vclklast__TOP__reset = vlTOPp->reset;
}

VL_INLINE_OPT QData VMyTopLevel::_change_request(VMyTopLevel__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VMyTopLevel::_change_request\n"); );
    VMyTopLevel* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    return (vlTOPp->_change_request_1(vlSymsp));
}

VL_INLINE_OPT QData VMyTopLevel::_change_request_1(VMyTopLevel__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VMyTopLevel::_change_request_1\n"); );
    VMyTopLevel* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    // Change detection
    QData __req = false;  // Logically a bool
    return __req;
}

#ifdef VL_DEBUG
void VMyTopLevel::_eval_debug_assertions() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VMyTopLevel::_eval_debug_assertions\n"); );
    // Body
    if (VL_UNLIKELY((clk & 0xfeU))) {
        Verilated::overWidthError("clk");}
    if (VL_UNLIKELY((reset & 0xfeU))) {
        Verilated::overWidthError("reset");}
}
#endif  // VL_DEBUG
