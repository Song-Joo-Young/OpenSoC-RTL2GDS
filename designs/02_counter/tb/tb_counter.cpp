#include "Vcounter.h"
#include "verilated.h"
#include <cstdio>

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Vcounter* dut = new Vcounter;

    int errors = 0;
    int cycles = 0;

    auto tick = [&]() {
        dut->clk = 0; dut->eval();
        dut->clk = 1; dut->eval();
        cycles++;
    };

    // Reset
    dut->rst_n = 0; dut->en = 0; dut->load = 0; dut->up_dn = 1; dut->din = 0;
    tick(); tick();
    dut->rst_n = 1;

    // Test 1: count up
    dut->en = 1; dut->up_dn = 1;
    for (int i = 0; i < 10; i++) tick();
    if (dut->count != 10) { printf("FAIL: count up expected 10, got %d\n", dut->count); errors++; }

    // Test 2: count down
    dut->up_dn = 0;
    for (int i = 0; i < 5; i++) tick();
    if (dut->count != 5) { printf("FAIL: count down expected 5, got %d\n", dut->count); errors++; }

    // Test 3: load
    dut->load = 1; dut->din = 200;
    tick();
    dut->load = 0;
    if (dut->count != 200) { printf("FAIL: load expected 200, got %d\n", dut->count); errors++; }

    // Test 4: zero flag
    dut->load = 1; dut->din = 0;
    tick();
    dut->load = 0;
    if (!dut->zero) { printf("FAIL: zero flag not set\n"); errors++; }

    // Test 5: max_val flag
    dut->load = 1; dut->din = 255;
    tick();
    dut->load = 0;
    if (!dut->max_val) { printf("FAIL: max_val flag not set\n"); errors++; }

    // Test 6: enable=0 holds value
    dut->en = 0;
    tick(); tick();
    if (dut->count != 255) { printf("FAIL: hold expected 255, got %d\n", dut->count); errors++; }

    if (errors == 0)
        printf("PASS: All tests passed (%d cycles)\n", cycles);
    else
        printf("FAIL: %d errors (%d cycles)\n", errors, cycles);

    dut->final();
    delete dut;
    return errors;
}
