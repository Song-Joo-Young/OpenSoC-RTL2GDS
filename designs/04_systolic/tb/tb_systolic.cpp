#include "Vsystolic_2x2.h"
#include "verilated.h"
#include <cstdio>
#include <cstdint>

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Vsystolic_2x2* dut = new Vsystolic_2x2;
    auto tick = [&]() {
        dut->clk = 0; dut->eval();
        dut->clk = 1; dut->eval();
    };

    // Reset
    dut->rst_n = 0; dut->start = 0; dut->clear = 0;
    dut->a_in_0 = 0; dut->a_in_1 = 0;
    dut->b_in_0 = 0; dut->b_in_1 = 0;
    tick(); tick();
    dut->rst_n = 1;

    // Clear accumulators
    dut->clear = 1; tick(); dut->clear = 0;

    // Matrix multiplication:
    // A = [[1, 2], [3, 4]]
    // B = [[5, 6], [7, 8]]
    // C = [[19, 22], [43, 50]]

    // Systolic feeding pattern (skewed)
    dut->start = 1;
    dut->a_in_0 = 1; dut->a_in_1 = 0;
    dut->b_in_0 = 5; dut->b_in_1 = 0;
    tick();

    dut->a_in_0 = 2; dut->a_in_1 = 3;
    dut->b_in_0 = 7; dut->b_in_1 = 6;
    tick();

    dut->a_in_0 = 0; dut->a_in_1 = 4;
    dut->b_in_0 = 0; dut->b_in_1 = 8;
    tick();

    dut->start = 0;
    dut->a_in_0 = 0; dut->a_in_1 = 0;
    dut->b_in_0 = 0; dut->b_in_1 = 0;
    for (int i = 0; i < 4; ++i) tick();

    struct Expect {
        const char* name;
        uint32_t got;
        uint32_t want;
    } checks[] = {
        {"C[0][0]", dut->c_00, 19},
        {"C[0][1]", dut->c_01, 22},
        {"C[1][0]", dut->c_10, 43},
        {"C[1][1]", dut->c_11, 50},
    };

    int errors = 0;
    for (const auto& check : checks) {
        if (check.got != check.want) {
            printf("FAIL %s: expected %u, got %u\n", check.name, check.want, check.got);
            ++errors;
        } else {
            printf("PASS %s = %u\n", check.name, check.got);
        }
    }

    if (dut->valid != 0) {
        printf("FAIL valid: expected 0 after pipeline drain, got %d\n", dut->valid);
        ++errors;
    }

    if (errors == 0)
        printf("PASS: systolic array tests passed\n");
    else
        printf("FAIL: %d systolic checks failed\n", errors);

    dut->final();
    delete dut;
    return errors;
}
