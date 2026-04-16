#include "Vuart_tx.h"
#include "verilated.h"
#include <cstdint>
#include <cstdio>

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Vuart_tx* dut = new Vuart_tx;
    const int baud_div = 8;
    int errors = 0;

    auto tick = [&]() {
        dut->clk = 0;
        dut->eval();
        dut->clk = 1;
        dut->eval();
    };

    auto push_byte = [&](uint8_t value) {
        while (!dut->in_ready) {
            tick();
        }
        dut->in_valid = 1;
        dut->in_data = value;
        tick();
        dut->in_valid = 0;
    };

    auto sample_frame = [&](uint8_t expected) {
        while (dut->txd != 0) {
            tick();
        }

        for (int i = 0; i < baud_div / 2; ++i) {
            tick();
        }
        if (dut->txd != 0) {
            std::printf("FAIL: start bit expected 0, got %d\n", dut->txd);
            errors++;
        }

        uint8_t observed = 0;
        for (int bit = 0; bit < 8; ++bit) {
            for (int i = 0; i < baud_div; ++i) {
                tick();
            }
            observed |= (dut->txd ? 1U : 0U) << bit;
        }

        for (int i = 0; i < baud_div; ++i) {
            tick();
        }
        if (dut->txd != 1) {
            std::printf("FAIL: stop bit expected 1, got %d\n", dut->txd);
            errors++;
        }

        if (observed != expected) {
            std::printf("FAIL: frame expected 0x%02x, got 0x%02x\n", expected, observed);
            errors++;
        } else {
            std::printf("PASS: frame 0x%02x observed correctly\n", observed);
        }
    };

    dut->clk = 0;
    dut->rst_n = 0;
    dut->in_valid = 0;
    dut->in_data = 0;
    tick();
    tick();
    dut->rst_n = 1;

    push_byte(0xA5);
    push_byte(0x3C);

    if (!dut->busy) {
        std::printf("FAIL: busy expected 1 after preload, got %d\n", dut->busy);
        errors++;
    }

    if (dut->fifo_level < 1) {
        std::printf("FAIL: fifo_level expected at least 1 after preload, got %d\n", dut->fifo_level);
        errors++;
    }

    sample_frame(0xA5);
    sample_frame(0x3C);

    for (int i = 0; i < baud_div * 2; ++i) {
        tick();
    }

    if (dut->busy != 0) {
        std::printf("FAIL: busy expected 0 after transmit, got %d\n", dut->busy);
        errors++;
    }

    if (dut->fifo_level != 0) {
        std::printf("FAIL: fifo_level expected 0 after drain, got %d\n", dut->fifo_level);
        errors++;
    }

    if (errors == 0) {
        std::printf("PASS: uart_tx tests passed\n");
    } else {
        std::printf("FAIL: uart_tx had %d error(s)\n", errors);
    }

    dut->final();
    delete dut;
    return errors;
}
