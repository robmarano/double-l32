`default_nettype none

module mips_core (
    input  logic        clk_i,
    input  logic        rst_ni,
    
    // Instruction Memory Interface
    output logic [31:0] inst_addr_o,
    input  logic [31:0] inst_data_i,
    
    // Data Memory Interface
    output logic [31:0] data_addr_o,
    output logic [31:0] data_wdata_o,
    input  logic [31:0] data_rdata_i,
    output logic        data_we_o,
    output logic        data_re_o
);

    // -------------------------------------------------------------------------
    // Program Counter
    // -------------------------------------------------------------------------
    logic [31:0] pc_current;
    logic [31:0] pc_next;
    logic [31:0] pc_plus_4;
    logic [31:0] pc_branch;
    logic [31:0] pc_jump;
    
    assign pc_plus_4 = pc_current + 32'd4;
    assign inst_addr_o = pc_current;

    pc_reg u_pc (
        .clk_i      (clk_i),
        .rst_ni     (rst_ni),
        .en_i       (1'b1), // Always enabled for now
        .next_pc_i  (pc_next),
        .pc_o       (pc_current)
    );

    // -------------------------------------------------------------------------
    // Instruction Decoding
    // -------------------------------------------------------------------------
    logic [5:0]  opcode;
    logic [4:0]  rs;
    logic [4:0]  rt;
    logic [4:0]  rd;
    logic [4:0]  shamt;
    logic [5:0]  funct;
    logic [15:0] imm16;
    logic [25:0] jump_addr;

    assign opcode    = inst_data_i[31:26];
    assign rs        = inst_data_i[25:21];
    assign rt        = inst_data_i[20:16];
    assign rd        = inst_data_i[15:11];
    assign shamt     = inst_data_i[10:6];
    assign funct     = inst_data_i[5:0];
    assign imm16     = inst_data_i[15:0];
    assign jump_addr = inst_data_i[25:0];

    logic [31:0] sign_ext_imm;
    assign sign_ext_imm = {{16{imm16[15]}}, imm16};

    // -------------------------------------------------------------------------
    // Control Unit
    // -------------------------------------------------------------------------
    logic [1:0] reg_dst;
    logic       alu_src;
    logic [4:0] alu_control;
    logic       mem_read;
    logic       mem_write;
    logic [1:0] mem_to_reg;
    logic       reg_write;
    logic       hilo_write;
    logic       branch_eq;
    logic       branch_ne;
    logic       jump;
    logic       jump_reg;

    control_unit u_control (
        .opcode_i      (opcode),
        .funct_i       (funct),
        .reg_dst_o     (reg_dst),
        .alu_src_o     (alu_src),
        .alu_control_o (alu_control),
        .mem_read_o    (mem_read),
        .mem_write_o   (mem_write),
        .mem_to_reg_o  (mem_to_reg),
        .reg_write_o   (reg_write),
        .hilo_write_o  (hilo_write),
        .branch_o      (branch_eq),
        .branch_ne_o   (branch_ne),
        .jump_o        (jump),
        .jump_reg_o    (jump_reg)
    );

    // -------------------------------------------------------------------------
    // Register File
    // -------------------------------------------------------------------------
    logic [4:0]  write_reg;
    logic [31:0] write_data;
    logic [31:0] read_data1;
    logic [31:0] read_data2;

    always_comb begin
        if (reg_dst == 2'b01)      write_reg = rd;
        else if (reg_dst == 2'b10) write_reg = 5'd31; // $ra
        else                       write_reg = rt;
    end

    regfile u_regfile (
        .clk_i      (clk_i),
        .rst_ni     (rst_ni),
        .rs_addr_i  (rs),
        .rt_addr_i  (rt),
        .rd_addr_i  (write_reg),
        .rd_data_i  (write_data),
        .we_i       (reg_write),
        .rs_data_o  (read_data1),
        .rt_data_o  (read_data2)
    );

    // -------------------------------------------------------------------------
    // HI / LO Registers
    // -------------------------------------------------------------------------
    logic [31:0] hi_q, lo_q;
    logic [31:0] alu_hi_out, alu_lo_out;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            hi_q <= 32'h0;
            lo_q <= 32'h0;
        end else if (hilo_write) begin
            hi_q <= alu_hi_out;
            lo_q <= alu_lo_out;
        end
    end

    // -------------------------------------------------------------------------
    // ALU
    // -------------------------------------------------------------------------
    logic [31:0] alu_b_in;
    logic [31:0] alu_result;
    logic        alu_zero;

    assign alu_b_in = (alu_src) ? sign_ext_imm : read_data2;

    alu u_alu (
        .a_i        (read_data1),
        .b_i        (alu_b_in),
        .shamt_i    (shamt),
        .alu_op_i   (alu_control),
        .hi_i       (hi_q),
        .lo_i       (lo_q),
        .result_o   (alu_result),
        .hi_o       (alu_hi_out),
        .lo_o       (alu_lo_out),
        .zero_o     (alu_zero)
    );

    // -------------------------------------------------------------------------
    // Memory Interface & Writeback
    // -------------------------------------------------------------------------
    assign data_addr_o  = alu_result;
    assign data_wdata_o = read_data2;
    assign data_we_o    = mem_write;
    assign data_re_o    = mem_read;

    always_comb begin
        if (mem_to_reg == 2'b01)      write_data = data_rdata_i;
        else if (mem_to_reg == 2'b10) write_data = pc_plus_4;
        else                          write_data = alu_result;
    end

    // -------------------------------------------------------------------------
    // Next PC Logic (Branch / Jump)
    // -------------------------------------------------------------------------
    assign pc_branch = pc_plus_4 + (sign_ext_imm << 2);
    assign pc_jump   = {pc_plus_4[31:28], jump_addr, 2'b00};

    logic take_branch;
    assign take_branch = (branch_eq & alu_zero) | (branch_ne & ~alu_zero);

    always_comb begin
        if (jump_reg) begin
            pc_next = read_data1; // JR
        end else if (jump) begin
            pc_next = pc_jump;
        end else if (take_branch) begin
            pc_next = pc_branch;
        end else begin
            pc_next = pc_plus_4;
        end
    end

endmodule
