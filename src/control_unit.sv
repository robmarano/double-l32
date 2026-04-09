`default_nettype none

module control_unit (
    input  logic [5:0] opcode_i,
    input  logic [5:0] funct_i,
    
    // Execution control signals
    output logic [1:0] reg_dst_o,    // 00: rt, 01: rd, 10: $ra
    output logic       alu_src_o,    // 1: ALU B input is Immediate, 0: ALU B is Register rt
    output logic [3:0] alu_control_o,// 4-bit control signal for the ALU
    
    // Memory control signals
    output logic       mem_read_o,   // 1: Read memory
    output logic       mem_write_o,  // 1: Write memory
    output logic [1:0] mem_to_reg_o, // 00: ALU result, 01: Mem data, 10: PC+4
    
    // Writeback control
    output logic       reg_write_o,  // 1: Enable register write
    
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

    // ALU Control Constants
    localparam logic [3:0] ALU_ADD  = 4'b0010;
    localparam logic [3:0] ALU_SUB  = 4'b0110;
    localparam logic [3:0] ALU_AND  = 4'b0000;
    localparam logic [3:0] ALU_OR   = 4'b0001;
    localparam logic [3:0] ALU_SLT  = 4'b0111;
    localparam logic [3:0] ALU_LUI  = 4'b1000;
    localparam logic [3:0] ALU_SLL  = 4'b1001;
    localparam logic [3:0] ALU_SRL  = 4'b1010;
    localparam logic [3:0] ALU_SRA  = 4'b1011;

    // Internal ALUOp signals
    logic [1:0] alu_op;

    always_comb begin
        // Default assignments to prevent latches
        reg_dst_o    = 2'b00;
        alu_src_o    = 1'b0;
        mem_to_reg_o = 2'b00;
        reg_write_o  = 1'b0;
        mem_read_o   = 1'b0;
        mem_write_o  = 1'b0;
        branch_o     = 1'b0;
        branch_ne_o  = 1'b0;
        jump_o       = 1'b0;
        jump_reg_o   = 1'b0;
        alu_op       = 2'b00;

        case (opcode_i)
            OPCODE_R_TYPE: begin
                if (funct_i == FUNCT_JR) begin
                    jump_reg_o = 1'b1;
                end else begin
                    reg_dst_o   = 2'b01;
                    reg_write_o = 1'b1;
                    alu_op      = 2'b10;
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
                    FUNCT_ADD: alu_control_o = ALU_ADD;
                    FUNCT_SUB: alu_control_o = ALU_SUB;
                    FUNCT_AND: alu_control_o = ALU_AND;
                    FUNCT_OR:  alu_control_o = ALU_OR;
                    FUNCT_SLT: alu_control_o = ALU_SLT;
                    FUNCT_SLL: alu_control_o = ALU_SLL;
                    FUNCT_SRL: alu_control_o = ALU_SRL;
                    FUNCT_SRA: alu_control_o = ALU_SRA;
                    default:   alu_control_o = ALU_ADD;
                endcase
            end
            default: alu_control_o = ALU_ADD;
        endcase
    end

endmodule
