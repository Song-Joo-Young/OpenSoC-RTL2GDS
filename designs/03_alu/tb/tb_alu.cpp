#include "Valu.h"
#include "verilated.h"
#include <cstdio>
#include <cstdint>

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Valu* dut = new Valu;

    int errors = 0;
    auto tick = [&]() {
        dut->clk = 0; dut->eval();
        dut->clk = 1; dut->eval();
    };

    // Reset
    dut->rst_n = 0; dut->op = 0; dut->a = 0; dut->b = 0;
    tick(); tick();
    dut->rst_n = 1;

    // Helper: apply op and wait 2 cycles (pipeline)
    auto apply = [&](int op, int a, int b) {
        dut->op = op; dut->a = a; dut->b = b;
        tick(); // stage 1: latch inputs
        dut->op = 0; dut->a = 0; dut->b = 0;
        tick(); // stage 2: latch result
    };

    // ADD: 100 + 50 = 150
    apply(0x0, 100, 50);
    if (dut->result != 150) { printf("FAIL ADD: expected 150, got %d\n", dut->result); errors++; }

    // SUB: 100 - 30 = 70
    apply(0x1, 100, 30);
    if (dut->result != 70) { printf("FAIL SUB: expected 70, got %d\n", dut->result); errors++; }

    // AND: 0xF0 & 0x3C = 0x30
    apply(0x2, 0xF0, 0x3C);
    if (dut->result != 0x30) { printf("FAIL AND: expected 0x30, got 0x%x\n", dut->result); errors++; }

    // OR: 0xF0 | 0x0F = 0xFF
    apply(0x3, 0xF0, 0x0F);
    if (dut->result != 0xFF) { printf("FAIL OR: expected 0xFF, got 0x%x\n", dut->result); errors++; }

    // XOR: 0xFF ^ 0x0F = 0xF0
    apply(0x4, 0xFF, 0x0F);
    if (dut->result != 0xF0) { printf("FAIL XOR: expected 0xF0, got 0x%x\n", dut->result); errors++; }

    // NOT: ~0x55 = 0xAA
    apply(0x5, 0x55, 0);
    if (dut->result != 0xAA) { printf("FAIL NOT: expected 0xAA, got 0x%x\n", dut->result); errors++; }

    // Zero flag: 0 + 0 = 0
    apply(0x0, 0, 0);
    if (!dut->zero) { printf("FAIL ZERO flag not set\n"); errors++; }

    // Carry: 200 + 200 = 400 (overflow 8-bit)
    apply(0x0, 200, 200);
    if (!dut->carry) { printf("FAIL CARRY not set\n"); errors++; }

    if (errors == 0)
        printf("PASS: All ALU tests passed\n");
    else
        printf("FAIL: %d errors\n", errors);

    dut->final();
    delete dut;
    return errors;
}
