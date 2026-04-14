// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef VERILATED_VCOUNTER4__SYMS_H_
#define VERILATED_VCOUNTER4__SYMS_H_  // guard

#include "verilated.h"

// INCLUDE MODEL CLASS

#include "Vcounter4.h"

// INCLUDE MODULE CLASSES
#include "Vcounter4___024root.h"

// SYMS CLASS (contains all model state)
class alignas(VL_CACHE_LINE_BYTES)Vcounter4__Syms final : public VerilatedSyms {
  public:
    // INTERNAL STATE
    Vcounter4* const __Vm_modelp;
    VlDeleter __Vm_deleter;
    bool __Vm_didInit = false;

    // MODULE INSTANCE STATE
    Vcounter4___024root            TOP;

    // CONSTRUCTORS
    Vcounter4__Syms(VerilatedContext* contextp, const char* namep, Vcounter4* modelp);
    ~Vcounter4__Syms();

    // METHODS
    const char* name() { return TOP.name(); }
};

#endif  // guard
