module placeholder_top (
    input  wire clk,
    input  wire rst_n,
    input  wire en,
    output reg  out
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            out <= 1'b0;
        else if (en)
            out <= ~out;
    end
endmodule
