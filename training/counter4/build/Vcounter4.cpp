// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vcounter4__pch.h"

//============================================================
// Constructors

Vcounter4::Vcounter4(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vcounter4__Syms(contextp(), _vcname__, this)}
    , clk{vlSymsp->TOP.clk}
    , rst_n{vlSymsp->TOP.rst_n}
    , en{vlSymsp->TOP.en}
    , count{vlSymsp->TOP.count}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vcounter4::Vcounter4(const char* _vcname__)
    : Vcounter4(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vcounter4::~Vcounter4() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vcounter4___024root___eval_debug_assertions(Vcounter4___024root* vlSelf);
#endif  // VL_DEBUG
void Vcounter4___024root___eval_static(Vcounter4___024root* vlSelf);
void Vcounter4___024root___eval_initial(Vcounter4___024root* vlSelf);
void Vcounter4___024root___eval_settle(Vcounter4___024root* vlSelf);
void Vcounter4___024root___eval(Vcounter4___024root* vlSelf);

void Vcounter4::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vcounter4::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vcounter4___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vcounter4___024root___eval_static(&(vlSymsp->TOP));
        Vcounter4___024root___eval_initial(&(vlSymsp->TOP));
        Vcounter4___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vcounter4___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vcounter4::eventsPending() { return false; }

uint64_t Vcounter4::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vcounter4::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vcounter4___024root___eval_final(Vcounter4___024root* vlSelf);

VL_ATTR_COLD void Vcounter4::final() {
    Vcounter4___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vcounter4::hierName() const { return vlSymsp->name(); }
const char* Vcounter4::modelName() const { return "Vcounter4"; }
unsigned Vcounter4::threads() const { return 1; }
void Vcounter4::prepareClone() const { contextp()->prepareClone(); }
void Vcounter4::atClone() const {
    contextp()->threadPoolpOnClone();
}
