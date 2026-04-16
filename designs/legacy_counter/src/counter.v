// Parameterized up/down counter with load and enable
module counter #(
    parameter WIDTH = 8
) (
    input  wire             clk,
    input  wire             rst_n,
    input  wire             en,
    input  wire             load,
    input  wire             up_dn,    // 1=up, 0=down
    input  wire [WIDTH-1:0] din,
    output reg  [WIDTH-1:0] count,
    output wire             zero,
    output wire             max_val
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= {WIDTH{1'b0}};
        else if (load)
            count <= din;
        else if (en) begin
            if (up_dn)
                count <= count + 1'b1;
            else
                count <= count - 1'b1;
        end
    end

    assign zero    = (count == {WIDTH{1'b0}});
    assign max_val = (count == {WIDTH{1'b1}});

endmodule
