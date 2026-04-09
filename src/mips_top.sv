`default_nettype none

module mips_top (
    input  logic clk_i,
    input  logic rst_ni,
    
    // MMIO External Interface (to C++ Simulator)
    output logic        mmio_screen_we_o,
    output logic [31:0] mmio_screen_addr_o,
    output logic [31:0] mmio_screen_wdata_o,
    input  logic [31:0] mmio_keys_i
);

    // -------------------------------------------------------------------------
    // Interconnect Signals
    // -------------------------------------------------------------------------
    /* verilator lint_off UNUSEDSIGNAL */
    logic [31:0] inst_addr;
    /* verilator lint_on UNUSEDSIGNAL */
    logic [31:0] inst_data;
    
    logic [31:0] cpu_data_addr;
    logic [31:0] cpu_data_wdata;
    logic [31:0] cpu_data_rdata;
    logic        cpu_data_we;
    logic        cpu_data_re;

    logic [9:0]  ram_data_addr;
    logic [31:0] ram_data_wdata;
    logic        ram_data_we;
    logic        ram_data_re;
    logic [31:0] ram_data_rdata;

    // -------------------------------------------------------------------------
    // MIPS Core
    // -------------------------------------------------------------------------
    mips_core u_core (
        .clk_i        (clk_i),
        .rst_ni       (rst_ni),
        .inst_addr_o  (inst_addr),
        .inst_data_i  (inst_data),
        .data_addr_o  (cpu_data_addr),
        .data_wdata_o (cpu_data_wdata),
        .data_rdata_i (cpu_data_rdata),
        .data_we_o    (cpu_data_we),
        .data_re_o    (cpu_data_re)
    );

    // -------------------------------------------------------------------------
    // MMIO Decoder
    // -------------------------------------------------------------------------
    mmio_decoder u_mmio (
        .cpu_addr_i     (cpu_data_addr),
        .cpu_wdata_i    (cpu_data_wdata),
        .cpu_we_i       (cpu_data_we),
        .cpu_re_i       (cpu_data_re),
        .cpu_rdata_o    (cpu_data_rdata),

        .ram_addr_o     (ram_data_addr),
        .ram_wdata_o    (ram_data_wdata),
        .ram_we_o       (ram_data_we),
        .ram_re_o       (ram_data_re),
        .ram_rdata_i    (ram_data_rdata),

        .screen_we_o    (mmio_screen_we_o),
        .screen_addr_o  (mmio_screen_addr_o),
        .screen_wdata_o (mmio_screen_wdata_o),

        .keys_rdata_i   (mmio_keys_i)
    );

    // -------------------------------------------------------------------------
    // Main Dual-Port RAM (4KB)
    // -------------------------------------------------------------------------
    // inst_addr is byte address, convert to word address for 1K depth
    logic [9:0] ram_inst_addr;
    assign ram_inst_addr = inst_addr[11:2];

    ram_dp #(
        .ADDR_WIDTH (10),
        .DATA_WIDTH (32)
    ) u_ram (
        .clk_i        (clk_i),
        .inst_addr_i  (ram_inst_addr),
        .inst_data_o  (inst_data),
        
        .data_addr_i  (ram_data_addr),
        .data_wdata_i (ram_data_wdata),
        .data_we_i    (ram_data_we),
        .data_re_i    (ram_data_re),
        .data_rdata_o (ram_data_rdata)
    );

endmodule
