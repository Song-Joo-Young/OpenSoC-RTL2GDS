// Minimal PicoRV32 SoC with SRAM
// PicoRV32 + sky130_sram_1rw1r_64x256_8 (2KB)
module picosoc_mini (
    input  wire        clk,
    input  wire        rst_n,
    output wire        trap,
    // Simple GPIO
    output reg  [7:0]  gpio_out,
    input  wire [7:0]  gpio_in
);

    // PicoRV32 memory interface
    wire        mem_valid;
    wire        mem_instr;
    wire        mem_ready;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [3:0]  mem_wstrb;
    wire [31:0] mem_rdata;

    // Address decode
    // 0x0000_0000 - 0x0000_07FF: SRAM (2KB)
    // 0x1000_0000: GPIO
    wire sram_sel = (mem_addr[31:12] == 20'h00000);
    wire gpio_sel = (mem_addr[31:12] == 20'h10000);

    // SRAM interface
    wire [63:0] sram_dout0;
    wire        sram_csb0  = ~(mem_valid & sram_sel);
    wire        sram_web0  = ~(|mem_wstrb);
    wire [7:0]  sram_addr0 = mem_addr[10:3];

    // Map 32-bit access to 64-bit SRAM
    wire addr_hi = mem_addr[2]; // select upper/lower 32 bits
    wire [63:0] sram_din0;
    wire [7:0]  sram_wmask0;

    assign sram_din0   = addr_hi ? {mem_wdata, 32'b0} : {32'b0, mem_wdata};
    assign sram_wmask0 = addr_hi ? {mem_wstrb, 4'b0}  : {4'b0, mem_wstrb};

    wire [31:0] sram_rdata = addr_hi ? sram_dout0[63:32] : sram_dout0[31:0];

    // GPIO register
    reg gpio_ready;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            gpio_out   <= 8'b0;
            gpio_ready <= 1'b0;
        end else begin
            gpio_ready <= 1'b0;
            if (mem_valid && gpio_sel && |mem_wstrb) begin
                gpio_out   <= mem_wdata[7:0];
                gpio_ready <= 1'b1;
            end else if (mem_valid && gpio_sel && !mem_wstrb) begin
                gpio_ready <= 1'b1;
            end
        end
    end

    wire [31:0] gpio_rdata = {24'b0, gpio_in};

    // Memory ready and read data mux
    reg sram_ready_r;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            sram_ready_r <= 1'b0;
        else
            sram_ready_r <= mem_valid & sram_sel & !sram_ready_r;
    end

    assign mem_ready = sram_ready_r | gpio_ready;
    assign mem_rdata = sram_sel ? sram_rdata : gpio_rdata;

    // PicoRV32 CPU
    picorv32 #(
        .ENABLE_COUNTERS  (0),
        .ENABLE_COUNTERS64(0),
        .ENABLE_MUL       (0),
        .ENABLE_DIV       (0),
        .ENABLE_IRQ       (0),
        .ENABLE_TRACE     (0),
        .BARREL_SHIFTER   (1)
    ) cpu (
        .clk      (clk),
        .resetn   (rst_n),
        .trap     (trap),
        .mem_valid (mem_valid),
        .mem_instr (mem_instr),
        .mem_ready (mem_ready),
        .mem_addr  (mem_addr),
        .mem_wdata (mem_wdata),
        .mem_wstrb (mem_wstrb),
        .mem_rdata (mem_rdata)
    );

    // SRAM instance
    sky130_sram_1rw1r_64x256_8 sram (
        .clk0   (clk),
        .csb0   (sram_csb0),
        .web0   (sram_web0),
        .wmask0 (sram_wmask0),
        .addr0  (sram_addr0),
        .din0   (sram_din0),
        .dout0  (sram_dout0),
        .clk1   (clk),
        .csb1   (1'b1),     // port 1 disabled
        .addr1  (8'b0),
        .dout1  ()
    );

endmodule
