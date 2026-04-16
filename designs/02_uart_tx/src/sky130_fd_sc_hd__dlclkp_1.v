(* blackbox *)
module sky130_fd_sc_hd__dlclkp_1 (
    input  wire CLK,
    input  wire GATE,
    output wire GCLK
);
`ifdef VERILATOR
    reg gate_latched;

    /* verilator lint_off LATCH */
    always @ (CLK or GATE) begin
        if (!CLK)
            gate_latched = GATE;
    end
    /* verilator lint_on LATCH */

    assign GCLK = CLK & gate_latched;
`endif
endmodule
