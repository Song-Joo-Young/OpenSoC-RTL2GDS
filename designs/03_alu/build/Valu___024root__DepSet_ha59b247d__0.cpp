// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Valu.h for the primary calling header

#include "Valu__pch.h"
#include "Valu___024root.h"

void Valu___024root___eval_act(Valu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu___024root___eval_act\n"); );
    Valu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

void Valu___024root___nba_sequent__TOP__0(Valu___024root* vlSelf);

void Valu___024root___eval_nba(Valu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu___024root___eval_nba\n"); );
    Valu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((3ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        Valu___024root___nba_sequent__TOP__0(vlSelf);
    }
}

VL_INLINE_OPT void Valu___024root___nba_sequent__TOP__0(Valu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu___024root___nba_sequent__TOP__0\n"); );
    Valu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if (vlSelfRef.rst_n) {
        vlSelfRef.result = (0xffU & (IData)(vlSelfRef.alu__DOT__alu_out));
        vlSelfRef.alu__DOT__a_reg = vlSelfRef.a;
        vlSelfRef.alu__DOT__b_reg = vlSelfRef.b;
        vlSelfRef.alu__DOT__op_reg = vlSelfRef.op;
    } else {
        vlSelfRef.result = 0U;
        vlSelfRef.alu__DOT__a_reg = 0U;
        vlSelfRef.alu__DOT__b_reg = 0U;
        vlSelfRef.alu__DOT__op_reg = 0U;
    }
    vlSelfRef.zero = ((IData)(vlSelfRef.rst_n) && (0U 
                                                   == 
                                                   (0xffU 
                                                    & (IData)(vlSelfRef.alu__DOT__alu_out))));
    vlSelfRef.carry = ((IData)(vlSelfRef.rst_n) && 
                       (1U & ((IData)(vlSelfRef.alu__DOT__alu_out) 
                              >> 8U)));
    vlSelfRef.alu__DOT__alu_out = (0x1ffU & ((8U & (IData)(vlSelfRef.alu__DOT__op_reg))
                                              ? ((4U 
                                                  & (IData)(vlSelfRef.alu__DOT__op_reg))
                                                  ? 0U
                                                  : 
                                                 ((2U 
                                                   & (IData)(vlSelfRef.alu__DOT__op_reg))
                                                   ? 0U
                                                   : 
                                                  ((1U 
                                                    & (IData)(vlSelfRef.alu__DOT__op_reg))
                                                    ? 
                                                   (((IData)(vlSelfRef.alu__DOT__a_reg) 
                                                     == (IData)(vlSelfRef.alu__DOT__b_reg))
                                                     ? 1U
                                                     : 0U)
                                                    : 
                                                   (((IData)(vlSelfRef.alu__DOT__a_reg) 
                                                     < (IData)(vlSelfRef.alu__DOT__b_reg))
                                                     ? 1U
                                                     : 0U))))
                                              : ((4U 
                                                  & (IData)(vlSelfRef.alu__DOT__op_reg))
                                                  ? 
                                                 ((2U 
                                                   & (IData)(vlSelfRef.alu__DOT__op_reg))
                                                   ? 
                                                  ((1U 
                                                    & (IData)(vlSelfRef.alu__DOT__op_reg))
                                                    ? 
                                                   (0xfeU 
                                                    & ((IData)(vlSelfRef.alu__DOT__a_reg) 
                                                       << 1U))
                                                    : 
                                                   ((0x80U 
                                                     & ((IData)(vlSelfRef.alu__DOT__a_reg) 
                                                        << 7U)) 
                                                    | (0x7fU 
                                                       & ((IData)(vlSelfRef.alu__DOT__a_reg) 
                                                          >> 1U))))
                                                   : 
                                                  ((1U 
                                                    & (IData)(vlSelfRef.alu__DOT__op_reg))
                                                    ? 
                                                   (0xffU 
                                                    & (~ (IData)(vlSelfRef.alu__DOT__a_reg)))
                                                    : 
                                                   ((IData)(vlSelfRef.alu__DOT__a_reg) 
                                                    ^ (IData)(vlSelfRef.alu__DOT__b_reg))))
                                                  : 
                                                 ((2U 
                                                   & (IData)(vlSelfRef.alu__DOT__op_reg))
                                                   ? 
                                                  ((1U 
                                                    & (IData)(vlSelfRef.alu__DOT__op_reg))
                                                    ? 
                                                   ((IData)(vlSelfRef.alu__DOT__a_reg) 
                                                    | (IData)(vlSelfRef.alu__DOT__b_reg))
                                                    : 
                                                   ((IData)(vlSelfRef.alu__DOT__a_reg) 
                                                    & (IData)(vlSelfRef.alu__DOT__b_reg)))
                                                   : 
                                                  ((1U 
                                                    & (IData)(vlSelfRef.alu__DOT__op_reg))
                                                    ? 
                                                   ((IData)(vlSelfRef.alu__DOT__a_reg) 
                                                    - (IData)(vlSelfRef.alu__DOT__b_reg))
                                                    : 
                                                   ((IData)(vlSelfRef.alu__DOT__a_reg) 
                                                    + (IData)(vlSelfRef.alu__DOT__b_reg)))))));
}

void Valu___024root___eval_triggers__act(Valu___024root* vlSelf);

bool Valu___024root___eval_phase__act(Valu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu___024root___eval_phase__act\n"); );
    Valu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    VlTriggerVec<2> __VpreTriggered;
    CData/*0:0*/ __VactExecute;
    // Body
    Valu___024root___eval_triggers__act(vlSelf);
    __VactExecute = vlSelfRef.__VactTriggered.any();
    if (__VactExecute) {
        __VpreTriggered.andNot(vlSelfRef.__VactTriggered, vlSelfRef.__VnbaTriggered);
        vlSelfRef.__VnbaTriggered.thisOr(vlSelfRef.__VactTriggered);
        Valu___024root___eval_act(vlSelf);
    }
    return (__VactExecute);
}

bool Valu___024root___eval_phase__nba(Valu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu___024root___eval_phase__nba\n"); );
    Valu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = vlSelfRef.__VnbaTriggered.any();
    if (__VnbaExecute) {
        Valu___024root___eval_nba(vlSelf);
        vlSelfRef.__VnbaTriggered.clear();
    }
    return (__VnbaExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Valu___024root___dump_triggers__nba(Valu___024root* vlSelf);
#endif  // VL_DEBUG
#ifdef VL_DEBUG
VL_ATTR_COLD void Valu___024root___dump_triggers__act(Valu___024root* vlSelf);
#endif  // VL_DEBUG

void Valu___024root___eval(Valu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu___024root___eval\n"); );
    Valu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
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
            Valu___024root___dump_triggers__nba(vlSelf);
#endif
            VL_FATAL_MT("src/alu.v", 2, "", "NBA region did not converge.");
        }
        __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
        __VnbaContinue = 0U;
        vlSelfRef.__VactIterCount = 0U;
        vlSelfRef.__VactContinue = 1U;
        while (vlSelfRef.__VactContinue) {
            if (VL_UNLIKELY(((0x64U < vlSelfRef.__VactIterCount)))) {
#ifdef VL_DEBUG
                Valu___024root___dump_triggers__act(vlSelf);
#endif
                VL_FATAL_MT("src/alu.v", 2, "", "Active region did not converge.");
            }
            vlSelfRef.__VactIterCount = ((IData)(1U) 
                                         + vlSelfRef.__VactIterCount);
            vlSelfRef.__VactContinue = 0U;
            if (Valu___024root___eval_phase__act(vlSelf)) {
                vlSelfRef.__VactContinue = 1U;
            }
        }
        if (Valu___024root___eval_phase__nba(vlSelf)) {
            __VnbaContinue = 1U;
        }
    }
}

#ifdef VL_DEBUG
void Valu___024root___eval_debug_assertions(Valu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu___024root___eval_debug_assertions\n"); );
    Valu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if (VL_UNLIKELY(((vlSelfRef.clk & 0xfeU)))) {
        Verilated::overWidthError("clk");}
    if (VL_UNLIKELY(((vlSelfRef.rst_n & 0xfeU)))) {
        Verilated::overWidthError("rst_n");}
    if (VL_UNLIKELY(((vlSelfRef.op & 0xf0U)))) {
        Verilated::overWidthError("op");}
}
#endif  // VL_DEBUG
