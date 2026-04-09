`default_nettype none

module control_unit (
    input  logic [5:0] opcode_i,
    input  logic [5:0] funct_i,
    
    // Execution control signals
    output logic [1:0] reg_dst_o,    // 00: rt, 01: rd, 10: $ra
    output logic       alu_src_o,    // 1: ALU B input is Immediate, 0: ALU B is Register rt
    output logic [4:0] alu_control_o,// 5-bit control signal for the ALU
    
    // Memory control signals
    output logic       mem_read_o,   // 1: Read memory
    output logic       mem_write_o,  // 1: Write memory
    output logic [1:0] mem_to_reg_o, // 00: ALU result, 01: Mem data, 10: PC+4
    
    // Writeback control
    output logic       reg_write_o,  // 1: Enable register write
    output logic       hilo_write_o, // 1: Enable HI/LO register write (for MULT/DIV)
    
    // PC control signals
    output logic       branch_o,     // 1: BEQ instruction
    output logic       branch_ne_o,  // 1: BNE instruction
    output logic       jump_o,       // 1: Jump instruction
    output logic       jump_reg_o    // 1: Jump Register instruction
);

    // MIPS Opcodes
    localparam logic [5:0] OPCODE_R_TYPE = 6'b000000;
    localparam logic [5:0] OPCODE_ADDI   = 6'b001000;
    localparam logic [5:0] OPCODE_LW     = 6'b100011;
    localparam logic [5:0] OPCODE_SW     = 6'b101011;
    localparam logic [5:0] OPCODE_BEQ    = 6'b000100;
    localparam logic [5:0] OPCODE_BNE    = 6'b000101;
    localparam logic [5:0] OPCODE_J      = 6'b000010;
    localparam logic [5:0] OPCODE_JAL    = 6'b000011;
    localparam logic [5:0] OPCODE_LUI    = 6'b001111;

    // R-Type Funct codes
    localparam logic [5:0] FUNCT_ADD     = 6'b100000;
    localparam logic [5:0] FUNCT_SUB     = 6'b100010;
    localparam logic [5:0] FUNCT_AND     = 6'b100100;
    localparam logic [5:0] FUNCT_OR      = 6'b100101;
    localparam logic [5:0] FUNCT_SLT     = 6'b101010;
    localparam logic [5:0] FUNCT_SLL     = 6'b000000;
    localparam logic [5:0] FUNCT_SRL     = 6'b000010;
    localparam logic [5:0] FUNCT_SRA     = 6'b000011;
    localparam logic [5:0] FUNCT_JR      = 6'b001000;
    localparam logic [5:0] FUNCT_MULT    = 6'b011000;
    localparam logic [5:0] FUNCT_DIV     = 6'b011010;
    localparam logic [5:0] FUNCT_MFHI    = 6'b010000;
    localparam logic [5:0] FUNCT_MFLO    = 6'b010010;

    // ALU Control Constants
    localparam [4:0] ALU_AND  = 5'b00000;
    localparam [4:0] ALU_OR   = 5'b00001;
    localparam [4:0] ALU_ADD  = 5'b00010;
    /* verilator lint_off UNUSEDPARAM */
    localparam [4:0] ALU_XOR  = 5'b00100;
    /* verilator lint_on UNUSEDPARAM */
    localparam [4:0] ALU_SUB  = 5'b00110;
    localparam [4:0] ALU_SLT  = 5'b00111;
    localparam [4:0] ALU_LUI  = 5'b01000;
    localparam [4:0] ALU_SLL  = 5'b01001;
    localparam [4:0] ALU_SRL  = 5'b01010;
    localparam [4:0] ALU_SRA  = 5'b01011;
    /* verilator lint_off UNUSEDPARAM */
    localparam [4:0] ALU_NOR  = 5'b01100;
    /* verilator lint_on UNUSEDPARAM */
    localparam [4:0] ALU_MULT = 5'b01101;
    localparam [4:0] ALU_DIV  = 5'b01110;
    localparam [4:0] ALU_MFHI = 5'b01111;
    localparam [4:0] ALU_MFLO = 5'b10000;

    // Internal ALUOp signals
    logic [1:0] alu_op;

    always_comb begin
        // Default assignments to prevent latches
        reg_dst_o    = 2'b00;
        alu_src_o    = 1'b0;
        mem_to_reg_o = 2'b00;
        reg_write_o  = 1'b0;
        hilo_write_o = 1'b0;
        mem_read_o   = 1'b0;
        mem_write_o  = 1'b0;
        branch_o     = 1'b0;
        branch_ne_o  = 1'b0;
        jump_o       = 1'b0;
        jump_reg_o   = 1'b0;
        alu_op       = 2'b00;

        case (opcode_i)
            OPCODE_R_TYPE: begin
                alu_op = 2'b10;
                if (funct_i == FUNCT_JR) begin
                    jump_reg_o = 1'b1;
                end else if (funct_i == FUNCT_MULT || funct_i == FUNCT_DIV) begin
                    hilo_write_o = 1'b1; // MULT/DIV write to HI/LO, not GPR
                end else begin
                    reg_dst_o   = 2'b01;
                    reg_write_o = 1'b1;
                end
            end
            OPCODE_ADDI: begin
                alu_src_o   = 1'b1;
                reg_write_o = 1'b1;
                alu_op      = 2'b00; // ADD
            end
            OPCODE_LUI: begin
                alu_src_o   = 1'b1;
                reg_write_o = 1'b1;
                alu_op      = 2'b11; // LUI
            end
            OPCODE_LW: begin
                alu_src_o   = 1'b1;
                mem_to_reg_o= 2'b01;
                reg_write_o = 1'b1;
                mem_read_o  = 1'b1;
                alu_op      = 2'b00; // ADD
            end
            OPCODE_SW: begin
                alu_src_o   = 1'b1;
                mem_write_o = 1'b1;
                alu_op      = 2'b00; // ADD
            end
            OPCODE_BEQ: begin
                branch_o    = 1'b1;
                alu_op      = 2'b01; // SUB
            end
            OPCODE_BNE: begin
                branch_ne_o = 1'b1;
                alu_op      = 2'b01; // SUB
            end
            OPCODE_J: begin
                jump_o      = 1'b1;
            end
            OPCODE_JAL: begin
                jump_o       = 1'b1;
                reg_write_o  = 1'b1;
                reg_dst_o    = 2'b10; // Write to $ra
                mem_to_reg_o = 2'b10; // Write PC+4
            end
            default: ;
        endcase
    end

    always_comb begin
        // Default to ADD
        alu_control_o = ALU_ADD;

        case (alu_op)
            2'b00: alu_control_o = ALU_ADD; // LW, SW, ADDI
            2'b01: alu_control_o = ALU_SUB; // BEQ, BNE
            2'b11: alu_control_o = ALU_LUI; // LUI
            2'b10: begin // R-Type
                case (funct_i)
                    FUNCT_ADD:  alu_control_o = ALU_ADD;
                    FUNCT_SUB:  alu_control_o = ALU_SUB;
                    FUNCT_AND:  alu_control_o = ALU_AND;
                    FUNCT_OR:   alu_control_o = ALU_OR;
                    FUNCT_SLT:  alu_control_o = ALU_SLT;
                    FUNCT_SLL:  alu_control_o = ALU_SLL;
                    FUNCT_SRL:  alu_control_o = ALU_SRL;
                    FUNCT_SRA:  alu_control_o = ALU_SRA;
                    FUNCT_MULT: alu_control_o = ALU_MULT;
                    FUNCT_DIV:  alu_control_o = ALU_DIV;
                    FUNCT_MFHI: alu_control_o = ALU_MFHI;
                    FUNCT_MFLO: alu_control_o = ALU_MFLO;
                    default:    alu_control_o = ALU_ADD;
                endcase
            end
            default: alu_control_o = ALU_ADD;
        endcase
    end

endmodule
