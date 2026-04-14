// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vcounter4.h for the primary calling header

#include "Vcounter4__pch.h"
#include "Vcounter4___024root.h"

void Vcounter4___024root___eval_act(Vcounter4___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcounter4___024root___eval_act\n"); );
    Vcounter4__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

void Vcounter4___024root___nba_sequent__TOP__0(Vcounter4___024root* vlSelf);

void Vcounter4___024root___eval_nba(Vcounter4___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcounter4___024root___eval_nba\n"); );
    Vcounter4__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((3ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        Vcounter4___024root___nba_sequent__TOP__0(vlSelf);
    }
}

VL_INLINE_OPT void Vcounter4___024root___nba_sequent__TOP__0(Vcounter4___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcounter4___024root___nba_sequent__TOP__0\n"); );
    Vcounter4__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if (vlSelfRef.rst_n) {
        if (vlSelfRef.en) {
            vlSelfRef.count = (0xfU & ((IData)(1U) 
                                       + (IData)(vlSelfRef.count)));
        }
    } else {
        vlSelfRef.count = 0U;
    }
}

void Vcounter4___024root___eval_triggers__act(Vcounter4___024root* vlSelf);

bool Vcounter4___024root___eval_phase__act(Vcounter4___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcounter4___024root___eval_phase__act\n"); );
    Vcounter4__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    VlTriggerVec<2> __VpreTriggered;
    CData/*0:0*/ __VactExecute;
    // Body
    Vcounter4___024root___eval_triggers__act(vlSelf);
    __VactExecute = vlSelfRef.__VactTriggered.any();
    if (__VactExecute) {
        __VpreTriggered.andNot(vlSelfRef.__VactTriggered, vlSelfRef.__VnbaTriggered);
        vlSelfRef.__VnbaTriggered.thisOr(vlSelfRef.__VactTriggered);
        Vcounter4___024root___eval_act(vlSelf);
    }
    return (__VactExecute);
}

bool Vcounter4___024root___eval_phase__nba(Vcounter4___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcounter4___024root___eval_phase__nba\n"); );
    Vcounter4__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = vlSelfRef.__VnbaTriggered.any();
    if (__VnbaExecute) {
        Vcounter4___024root___eval_nba(vlSelf);
        vlSelfRef.__VnbaTriggered.clear();
    }
    return (__VnbaExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vcounter4___024root___dump_triggers__nba(Vcounter4___024root* vlSelf);
#endif  // VL_DEBUG
#ifdef VL_DEBUG
VL_ATTR_COLD void Vcounter4___024root___dump_triggers__act(Vcounter4___024root* vlSelf);
#endif  // VL_DEBUG

void Vcounter4___024root___eval(Vcounter4___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcounter4___024root___eval\n"); );
    Vcounter4__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    IData/*31:0*/ __VnbaIterCount;
    CData/*0:0*/ __VnbaContinue;
    // Body
    __VnbaIterCount = 0U;
    __VnbaContinue = 1U;
    while (__VnbaContinue) {
        if (VL_UNLIKELY(((0x64U < __VnbaIterCount)))) {
#ifdef VL_DEBUG
            Vcounter4___024root___dump_triggers__nba(vlSelf);
#endif
            VL_FATAL_MT("src/counter4.v", 1, "", "NBA region did not converge.");
        }
        __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
        __VnbaContinue = 0U;
        vlSelfRef.__VactIterCount = 0U;
        vlSelfRef.__VactContinue = 1U;
        while (vlSelfRef.__VactContinue) {
            if (VL_UNLIKELY(((0x64U < vlSelfRef.__VactIterCount)))) {
#ifdef VL_DEBUG
                Vcounter4___024root___dump_triggers__act(vlSelf);
#endif
                VL_FATAL_MT("src/counter4.v", 1, "", "Active region did not converge.");
            }
            vlSelfRef.__VactIterCount = ((IData)(1U) 
                                         + vlSelfRef.__VactIterCount);
            vlSelfRef.__VactContinue = 0U;
            if (Vcounter4___024root___eval_phase__act(vlSelf)) {
                vlSelfRef.__VactContinue = 1U;
            }
        }
        if (Vcounter4___024root___eval_phase__nba(vlSelf)) {
            __VnbaContinue = 1U;
        }
    }
}

#ifdef VL_DEBUG
void Vcounter4___024root___eval_debug_assertions(Vcounter4___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcounter4___024root___eval_debug_assertions\n"); );
    Vcounter4__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if (VL_UNLIKELY(((vlSelfRef.clk & 0xfeU)))) {
        Verilated::overWidthError("clk");}
    if (VL_UNLIKELY(((vlSelfRef.rst_n & 0xfeU)))) {
        Verilated::overWidthError("rst_n");}
    if (VL_UNLIKELY(((vlSelfRef.en & 0xfeU)))) {
        Verilated::overWidthError("en");}
}
#endif  // VL_DEBUG
