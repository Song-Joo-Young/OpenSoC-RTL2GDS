#include "Vplaceholder_top.h"
#include "verilated.h"
#include <iostream>

static void tick(Vplaceholder_top* dut) {
    dut->clk = 0;
    dut->eval();
    dut->clk = 1;
    dut->eval();
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    auto* dut = new Vplaceholder_top;

    dut->clk = 0;
    dut->rst_n = 0;
    dut->en = 0;
    dut->eval();

    dut->rst_n = 1;
    dut->en = 1;

    tick(dut);
    std::cout << "placeholder_top smoke test: out=" << int(dut->out) << std::endl;

    delete dut;
    return 0;
}
