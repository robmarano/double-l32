`default_nettype none

module alu_regfile_tb (
    input  logic        clk_i,
    input  logic        rst_ni,
    
    // Regfile controls
    input  logic [4:0]  rs_addr_i,
    input  logic [4:0]  rt_addr_i,
    input  logic [4:0]  rd_addr_i,
    input  logic [31:0] rd_data_i,
    input  logic        we_i,
    
    // ALU controls
    input  logic [4:0]  alu_op_i,
    input  logic [4:0]  shamt_i,
    input  logic [31:0] hi_i,
    input  logic [31:0] lo_i,
    
    // Outputs
    output logic [31:0] alu_result_o,
    output logic [31:0] alu_hi_o,
    output logic [31:0] alu_lo_o,
    output logic        alu_zero_o
);

    logic [31:0] rs_data;
    logic [31:0] rt_data;

    regfile u_regfile (
        .clk_i      (clk_i),
        .rst_ni     (rst_ni),
        .rs_addr_i  (rs_addr_i),
        .rt_addr_i  (rt_addr_i),
        .rd_addr_i  (rd_addr_i),
        .rd_data_i  (rd_data_i),
        .we_i       (we_i),
        .rs_data_o  (rs_data),
        .rt_data_o  (rt_data)
    );

    alu u_alu (
        .a_i        (rs_data),
        .b_i        (rt_data),
        .shamt_i    (shamt_i),
        .alu_op_i   (alu_op_i),
        .hi_i       (hi_i),
        .lo_i       (lo_i),
        .result_o   (alu_result_o),
        .hi_o       (alu_hi_o),
        .lo_o       (alu_lo_o),
        .zero_o     (alu_zero_o)
    );

endmodule
