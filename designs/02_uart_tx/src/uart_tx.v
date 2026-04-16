module uart_tx #(
    parameter BAUD_DIV = 8
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       in_valid,
    input  wire [7:0] in_data,
    output wire       in_ready,
    output wire       txd,
    output wire       busy,
    output wire [2:0] fifo_level
);

    wire [7:0] fifo_rdata;
    wire       fifo_empty;
    wire       fifo_full;
    wire       start_tx;
    wire       serializer_busy;
    wire       serializer_clk;
    wire       serializer_clk_en;

    assign start_tx          = !serializer_busy && !fifo_empty;
    assign serializer_clk_en = serializer_busy | start_tx;
    assign in_ready          = !fifo_full;
    assign busy              = serializer_busy | !fifo_empty;

    uart_tx_fifo #(
        .DEPTH(4)
    ) u_fifo (
        .clk   (clk),
        .rst_n (rst_n),
        .push  (in_valid && in_ready),
        .pop   (start_tx),
        .wdata (in_data),
        .rdata (fifo_rdata),
        .empty (fifo_empty),
        .full  (fifo_full),
        .level (fifo_level)
    );

    sky130_fd_sc_hd__dlclkp_1 u_serializer_icg (
        .CLK  (clk),
        .GATE (serializer_clk_en),
        .GCLK (serializer_clk)
    );

    uart_tx_serializer #(
        .BAUD_DIV(BAUD_DIV)
    ) u_serializer (
        .clk        (serializer_clk),
        .rst_n      (rst_n),
        .start      (start_tx),
        .start_data (fifo_rdata),
        .txd        (txd),
        .busy       (serializer_busy)
    );

endmodule
