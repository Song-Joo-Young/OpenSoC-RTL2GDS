// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vcounter4.h for the primary calling header

#include "Vcounter4__pch.h"
#include "Vcounter4__Syms.h"
#include "Vcounter4___024root.h"

void Vcounter4___024root___ctor_var_reset(Vcounter4___024root* vlSelf);

Vcounter4___024root::Vcounter4___024root(Vcounter4__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vcounter4___024root___ctor_var_reset(this);
}

void Vcounter4___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vcounter4___024root::~Vcounter4___024root() {
}
