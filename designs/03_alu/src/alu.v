// 8-bit pipelined ALU with registered output
module alu #(
    parameter WIDTH = 8
) (
    input  wire             clk,
    input  wire             rst_n,
    input  wire [3:0]       op,
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    output reg  [WIDTH-1:0] result,
    output reg              carry,
    output reg              zero
);

    // Pipeline stage 1: operand register
    reg [WIDTH-1:0] a_reg, b_reg;
    reg [3:0]       op_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_reg  <= 0;
            b_reg  <= 0;
            op_reg <= 0;
        end else begin
            a_reg  <= a;
            b_reg  <= b;
            op_reg <= op;
        end
    end

    // Combinational ALU core
    reg [WIDTH:0] alu_out;  // extra bit for carry

    always @(*) begin
        alu_out = 0;
        case (op_reg)
            4'h0: alu_out = {1'b0, a_reg} + {1'b0, b_reg};       // ADD
            4'h1: alu_out = {1'b0, a_reg} - {1'b0, b_reg};       // SUB
            4'h2: alu_out = {1'b0, a_reg & b_reg};                // AND
            4'h3: alu_out = {1'b0, a_reg | b_reg};                // OR
            4'h4: alu_out = {1'b0, a_reg ^ b_reg};                // XOR
            4'h5: alu_out = {1'b0, ~a_reg};                       // NOT
            4'h6: alu_out = {a_reg[0], a_reg[WIDTH-1:1]};         // SHR
            4'h7: alu_out = {1'b0, a_reg[WIDTH-2:0], 1'b0};      // SHL
            4'h8: alu_out = (a_reg < b_reg)  ? {{WIDTH{1'b0}}, 1'b1} : {(WIDTH+1){1'b0}};  // SLT
            4'h9: alu_out = (a_reg == b_reg) ? {{WIDTH{1'b0}}, 1'b1} : {(WIDTH+1){1'b0}};       // SEQ
            default: alu_out = 0;
        endcase
    end

    // Pipeline stage 2: result register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result <= 0;
            carry  <= 0;
            zero   <= 0;
        end else begin
            result <= alu_out[WIDTH-1:0];
            carry  <= alu_out[WIDTH];
            zero   <= (alu_out[WIDTH-1:0] == 0);
        end
    end

endmodule
