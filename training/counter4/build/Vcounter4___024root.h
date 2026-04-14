// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vcounter4.h for the primary calling header

#ifndef VERILATED_VCOUNTER4___024ROOT_H_
#define VERILATED_VCOUNTER4___024ROOT_H_  // guard

#include "verilated.h"


class Vcounter4__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vcounter4___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(clk,0,0);
    VL_IN8(rst_n,0,0);
    VL_IN8(en,0,0);
    VL_OUT8(count,3,0);
    CData/*0:0*/ __Vtrigprevexpr___TOP__clk__0;
    CData/*0:0*/ __Vtrigprevexpr___TOP__rst_n__0;
    CData/*0:0*/ __VactContinue;
    IData/*31:0*/ __VactIterCount;
    VlTriggerVec<2> __VactTriggered;
    VlTriggerVec<2> __VnbaTriggered;

    // INTERNAL VARIABLES
    Vcounter4__Syms* const vlSymsp;

    // CONSTRUCTORS
    Vcounter4___024root(Vcounter4__Syms* symsp, const char* v__name);
    ~Vcounter4___024root();
    VL_UNCOPYABLE(Vcounter4___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
