// 2x2 Systolic Array for Matrix Multiplication
// Computes C = A × B (2x2 × 2x2)
// Data flows: A left-to-right, B top-to-bottom
// Each PE: multiply-accumulate (MAC)

module systolic_2x2 #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 20
) (
    input  wire                    clk,
    input  wire                    rst_n,
    input  wire                    start,
    input  wire                    clear,

    // A matrix inputs (left side)
    input  wire [DATA_WIDTH-1:0]   a_in_0,
    input  wire [DATA_WIDTH-1:0]   a_in_1,

    // B matrix inputs (top side)
    input  wire [DATA_WIDTH-1:0]   b_in_0,
    input  wire [DATA_WIDTH-1:0]   b_in_1,

    // Result outputs (accumulated values)
    output wire [ACC_WIDTH-1:0]    c_00,
    output wire [ACC_WIDTH-1:0]    c_01,
    output wire [ACC_WIDTH-1:0]    c_10,
    output wire [ACC_WIDTH-1:0]    c_11,

    output wire                    valid
);

    // Inter-PE wires
    wire [DATA_WIDTH-1:0] a_pe00_to_pe01;
    wire [DATA_WIDTH-1:0] a_pe10_to_pe11;
    wire [DATA_WIDTH-1:0] b_pe00_to_pe10;
    wire [DATA_WIDTH-1:0] b_pe01_to_pe11;

    // Valid pipeline
    reg [3:0] valid_pipe;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            valid_pipe <= 4'b0;
        else
            valid_pipe <= {valid_pipe[2:0], start};
    end
    assign valid = valid_pipe[3];

    // PE[0][0] — top-left
    pe #(.DATA_WIDTH(DATA_WIDTH), .ACC_WIDTH(ACC_WIDTH)) pe_00 (
        .clk(clk), .rst_n(rst_n), .clear(clear),
        .a_in(a_in_0),   .b_in(b_in_0),
        .a_out(a_pe00_to_pe01), .b_out(b_pe00_to_pe10),
        .acc(c_00)
    );

    // PE[0][1] — top-right
    pe #(.DATA_WIDTH(DATA_WIDTH), .ACC_WIDTH(ACC_WIDTH)) pe_01 (
        .clk(clk), .rst_n(rst_n), .clear(clear),
        .a_in(a_pe00_to_pe01), .b_in(b_in_1),
        .a_out(),               .b_out(b_pe01_to_pe11),
        .acc(c_01)
    );

    // PE[1][0] — bottom-left
    pe #(.DATA_WIDTH(DATA_WIDTH), .ACC_WIDTH(ACC_WIDTH)) pe_10 (
        .clk(clk), .rst_n(rst_n), .clear(clear),
        .a_in(a_in_1),          .b_in(b_pe00_to_pe10),
        .a_out(a_pe10_to_pe11), .b_out(),
        .acc(c_10)
    );

    // PE[1][1] — bottom-right
    pe #(.DATA_WIDTH(DATA_WIDTH), .ACC_WIDTH(ACC_WIDTH)) pe_11 (
        .clk(clk), .rst_n(rst_n), .clear(clear),
        .a_in(a_pe10_to_pe11),  .b_in(b_pe01_to_pe11),
        .a_out(),               .b_out(),
        .acc(c_11)
    );

endmodule

// Processing Element: multiply-accumulate
module pe #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 20
) (
    input  wire                    clk,
    input  wire                    rst_n,
    input  wire                    clear,
    input  wire [DATA_WIDTH-1:0]   a_in,
    input  wire [DATA_WIDTH-1:0]   b_in,
    output reg  [DATA_WIDTH-1:0]   a_out,
    output reg  [DATA_WIDTH-1:0]   b_out,
    output reg  [ACC_WIDTH-1:0]    acc
);

    wire [2*DATA_WIDTH-1:0] product;
    assign product = a_in * b_in;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_out <= 0;
            b_out <= 0;
            acc   <= 0;
        end else if (clear) begin
            acc <= 0;
        end else begin
            a_out <= a_in;
            b_out <= b_in;
            acc   <= acc + {{(ACC_WIDTH-2*DATA_WIDTH){1'b0}}, product};
        end
    end

endmodule
