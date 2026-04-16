module uart_tx_serializer #(
    parameter BAUD_DIV = 8
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       start,
    input  wire [7:0] start_data,
    output wire       txd,
    output reg        busy
) ;

    reg [7:0] shifter;
    reg [3:0] symbol_idx;
    reg [3:0] baud_cnt;
    reg       txd_r;

    assign txd = txd_r;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shifter    <= 8'h00;
            symbol_idx <= 4'd0;
            baud_cnt   <= 4'd0;
            txd_r      <= 1'b1;
            busy       <= 1'b0;
        end else if (start) begin
            shifter    <= start_data;
            symbol_idx <= 4'd0;
            baud_cnt   <= 4'd0;
            txd_r      <= 1'b0;
            busy       <= 1'b1;
        end else if (busy) begin
            if (baud_cnt == BAUD_DIV - 1) begin
                baud_cnt <= 4'd0;
                if (symbol_idx < 4'd8) begin
                    txd_r      <= shifter[0];
                    shifter    <= {1'b0, shifter[7:1]};
                    symbol_idx <= symbol_idx + 1'b1;
                end else if (symbol_idx == 4'd8) begin
                    txd_r      <= 1'b1;
                    symbol_idx <= 4'd9;
                end else begin
                    txd_r      <= 1'b1;
                    symbol_idx <= 4'd0;
                    busy       <= 1'b0;
                end
            end else begin
                baud_cnt <= baud_cnt + 1'b1;
            end
        end else begin
            txd_r <= 1'b1;
        end
    end

endmodule
