`default_nettype none

module mmio_decoder (
    // CPU Data Interface
    input  logic [31:0] cpu_addr_i,
    input  logic [31:0] cpu_wdata_i,
    input  logic        cpu_we_i,
    input  logic        cpu_re_i,
    output logic [31:0] cpu_rdata_o,

    // RAM Interface
    output logic [9:0]  ram_addr_o,
    output logic [31:0] ram_wdata_o,
    output logic        ram_we_o,
    output logic        ram_re_o,
    input  logic [31:0] ram_rdata_i,

    // Screen Interface (Write Only from CPU)
    output logic        screen_we_o,
    output logic [31:0] screen_addr_o,
    output logic [31:0] screen_wdata_o,

    // Keyboard Interface (Read Only from CPU)
    input  logic [31:0] keys_rdata_i
);

    // -------------------------------------------------------------------------
    // Address Map
    // 0x0000_0000 - 0x0000_0FFF : RAM (Word Address: bits 11:2)
    // 0x1000_0000 - 0x1000_0FFF : Screen MMIO
    // 0x1000_1000               : Keyboard MMIO
    // -------------------------------------------------------------------------
    logic is_ram;
    logic is_screen;
    logic is_keys;

    assign is_ram    = (cpu_addr_i[31:12] == 20'h00000);
    assign is_screen = (cpu_addr_i[31:12] == 20'h10000);
    assign is_keys   = (cpu_addr_i == 32'h10001000);

    // Route to RAM
    assign ram_addr_o  = cpu_addr_i[11:2];
    assign ram_wdata_o = cpu_wdata_i;
    assign ram_we_o    = cpu_we_i & is_ram;
    assign ram_re_o    = cpu_re_i & is_ram;

    // Route to Screen
    assign screen_we_o    = cpu_we_i & is_screen;
    assign screen_addr_o  = cpu_addr_i;
    assign screen_wdata_o = cpu_wdata_i;

    // Route Read Data back to CPU
    always_comb begin
        if (is_ram) begin
            cpu_rdata_o = ram_rdata_i;
        end else if (is_keys) begin
            cpu_rdata_o = keys_rdata_i;
        end else begin
            cpu_rdata_o = 32'h0;
        end
    end

endmodule
