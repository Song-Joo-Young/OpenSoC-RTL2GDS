// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Valu.h for the primary calling header

#include "Valu__pch.h"
#include "Valu___024root.h"

VL_ATTR_COLD void Valu___024root___eval_static(Valu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu___024root___eval_static\n"); );
    Valu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__Vtrigprevexpr___TOP__clk__0 = vlSelfRef.clk;
    vlSelfRef.__Vtrigprevexpr___TOP__rst_n__0 = vlSelfRef.rst_n;
}

VL_ATTR_COLD void Valu___024root___eval_initial(Valu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu___024root___eval_initial\n"); );
    Valu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

VL_ATTR_COLD void Valu___024root___eval_final(Valu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu___024root___eval_final\n"); );
    Valu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Valu___024root___dump_triggers__stl(Valu___024root* vlSelf);
#endif  // VL_DEBUG
VL_ATTR_COLD bool Valu___024root___eval_phase__stl(Valu___024root* vlSelf);

VL_ATTR_COLD void Valu___024root___eval_settle(Valu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu___024root___eval_settle\n"); );
    Valu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    IData/*31:0*/ __VstlIterCount;
    CData/*0:0*/ __VstlContinue;
    // Body
    __VstlIterCount = 0U;
    vlSelfRef.__VstlFirstIteration = 1U;
    __VstlContinue = 1U;
    while (__VstlContinue) {
        if (VL_UNLIKELY(((0x64U < __VstlIterCount)))) {
#ifdef VL_DEBUG
            Valu___024root___dump_triggers__stl(vlSelf);
#endif
            VL_FATAL_MT("src/alu.v", 2, "", "Settle region did not converge.");
        }
        __VstlIterCount = ((IData)(1U) + __VstlIterCount);
        __VstlContinue = 0U;
        if (Valu___024root___eval_phase__stl(vlSelf)) {
            __VstlContinue = 1U;
        }
        vlSelfRef.__VstlFirstIteration = 0U;
    }
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Valu___024root___dump_triggers__stl(Valu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu___024root___dump_triggers__stl\n"); );
    Valu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1U & (~ vlSelfRef.__VstlTriggered.any()))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelfRef.__VstlTriggered.word(0U))) {
        VL_DBG_MSGF("         'stl' region trigger index 0 is active: Internal 'stl' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Valu___024root___stl_sequent__TOP__0(Valu___024root* vlSelf);

VL_ATTR_COLD void Valu___024root___eval_stl(Valu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu___024root___eval_stl\n"); );
    Valu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VstlTriggered.word(0U))) {
        Valu___024root___stl_sequent__TOP__0(vlSelf);
    }
}

VL_ATTR_COLD void Valu___024root___stl_sequent__TOP__0(Valu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu___024root___stl_sequent__TOP__0\n"); );
    Valu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
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

VL_ATTR_COLD void Valu___024root___eval_triggers__stl(Valu___024root* vlSelf);

VL_ATTR_COLD bool Valu___024root___eval_phase__stl(Valu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu___024root___eval_phase__stl\n"); );
    Valu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    CData/*0:0*/ __VstlExecute;
    // Body
    Valu___024root___eval_triggers__stl(vlSelf);
    __VstlExecute = vlSelfRef.__VstlTriggered.any();
    if (__VstlExecute) {
        Valu___024root___eval_stl(vlSelf);
    }
    return (__VstlExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Valu___024root___dump_triggers__act(Valu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu___024root___dump_triggers__act\n"); );
    Valu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1U & (~ vlSelfRef.__VactTriggered.any()))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelfRef.__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 0 is active: @(posedge clk)\n");
    }
    if ((2ULL & vlSelfRef.__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 1 is active: @(negedge rst_n)\n");
    }
}
#endif  // VL_DEBUG

#ifdef VL_DEBUG
VL_ATTR_COLD void Valu___024root___dump_triggers__nba(Valu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu___024root___dump_triggers__nba\n"); );
    Valu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1U & (~ vlSelfRef.__VnbaTriggered.any()))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 0 is active: @(posedge clk)\n");
    }
    if ((2ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 1 is active: @(negedge rst_n)\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Valu___024root___ctor_var_reset(Valu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu___024root___ctor_var_reset\n"); );
    Valu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelf->clk = VL_RAND_RESET_I(1);
    vlSelf->rst_n = VL_RAND_RESET_I(1);
    vlSelf->op = VL_RAND_RESET_I(4);
    vlSelf->a = VL_RAND_RESET_I(8);
    vlSelf->b = VL_RAND_RESET_I(8);
    vlSelf->result = VL_RAND_RESET_I(8);
    vlSelf->carry = VL_RAND_RESET_I(1);
    vlSelf->zero = VL_RAND_RESET_I(1);
    vlSelf->alu__DOT__a_reg = VL_RAND_RESET_I(8);
    vlSelf->alu__DOT__b_reg = VL_RAND_RESET_I(8);
    vlSelf->alu__DOT__op_reg = VL_RAND_RESET_I(4);
    vlSelf->alu__DOT__alu_out = VL_RAND_RESET_I(9);
    vlSelf->__Vtrigprevexpr___TOP__clk__0 = VL_RAND_RESET_I(1);
    vlSelf->__Vtrigprevexpr___TOP__rst_n__0 = VL_RAND_RESET_I(1);
}
