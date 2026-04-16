module uart_tx_fifo #(
    parameter DEPTH = 4
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       push,
    input  wire       pop,
    input  wire [7:0] wdata,
    output wire [7:0] rdata,
    output wire       empty,
    output wire       full,
    output reg  [2:0] level
);

    localparam PTR_W = 2;

    reg [7:0] mem [0:DEPTH-1];
    reg [PTR_W-1:0] wr_ptr;
    reg [PTR_W-1:0] rd_ptr;

    assign empty = (level == 0);
    assign full  = (level == DEPTH);
    assign rdata = mem[rd_ptr];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            level  <= 0;
        end else begin
            case ({push && !full, pop && !empty})
                2'b10: begin
                    mem[wr_ptr] <= wdata;
                    wr_ptr <= wr_ptr + 1'b1;
                    level  <= level + 1'b1;
                end
                2'b01: begin
                    rd_ptr <= rd_ptr + 1'b1;
                    level  <= level - 1'b1;
                end
                2'b11: begin
                    mem[wr_ptr] <= wdata;
                    wr_ptr <= wr_ptr + 1'b1;
                    rd_ptr <= rd_ptr + 1'b1;
                end
                default: begin
                end
            endcase
        end
    end

endmodule
