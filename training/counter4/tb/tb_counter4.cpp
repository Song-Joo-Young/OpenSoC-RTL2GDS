#include "Vcounter4.h"
#include "verilated.h"
#include <cstdio>

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Vcounter4* dut = new Vcounter4;

    auto tick = [&]() {
        dut->clk = 0; dut->eval();
        dut->clk = 1; dut->eval();
    };

    // Reset
    dut->rst_n = 0; dut->en = 0;
    tick(); tick();
    printf("After reset: count=%d (expected 0)\n", dut->count);

    // Count up
    dut->rst_n = 1; dut->en = 1;
    for (int i = 0; i < 20; i++) {
        tick();
        int expected = (i + 1) & 0xF;
        printf("Cycle %2d: count=%2d %s\n", i+1, dut->count,
               dut->count == expected ? "OK" : "FAIL");
        if (dut->count != expected) return 1;
    }

    // Hold test
    dut->en = 0;
    int saved = dut->count;
    tick(); tick();
    printf("Enable=0 hold: count=%d %s\n", dut->count,
           dut->count == saved ? "OK" : "FAIL");

    printf("\n=== ALL TESTS PASSED ===\n");
    dut->final();
    delete dut;
    return 0;
}
