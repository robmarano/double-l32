`default_nettype none

module control_unit (
    input  logic [5:0] opcode_i,
    input  logic [5:0] funct_i,
    
    // Execution control signals
    output logic       reg_dst_o,    // 1: Write to rd, 0: Write to rt
    output logic       alu_src_o,    // 1: ALU B input is Immediate, 0: ALU B is Register rt
    output logic [3:0] alu_control_o,// 4-bit control signal for the ALU
    
    // Memory control signals
    output logic       mem_read_o,   // 1: Read memory
    output logic       mem_write_o,  // 1: Write memory
    output logic       mem_to_reg_o, // 1: Write mem data to reg, 0: Write ALU result to reg
    
    // Writeback control
    output logic       reg_write_o,  // 1: Enable register write
    
    // PC control signals
    output logic       branch_o,     // 1: BEQ instruction
    output logic       branch_ne_o,  // 1: BNE instruction
    output logic       jump_o        // 1: Jump instruction
);

    // MIPS Opcodes
    localparam logic [5:0] OPCODE_R_TYPE = 6'b000000;
    localparam logic [5:0] OPCODE_ADDI   = 6'b001000;
    localparam logic [5:0] OPCODE_LW     = 6'b100011;
    localparam logic [5:0] OPCODE_SW     = 6'b101011;
    localparam logic [5:0] OPCODE_BEQ    = 6'b000100;
    localparam logic [5:0] OPCODE_BNE    = 6'b000101;
    localparam logic [5:0] OPCODE_J      = 6'b000010;
    localparam logic [5:0] OPCODE_LUI    = 6'b001111;

    // R-Type Funct codes
    localparam logic [5:0] FUNCT_ADD     = 6'b100000;
    localparam logic [5:0] FUNCT_SUB     = 6'b100010;
    localparam logic [5:0] FUNCT_AND     = 6'b100100;
    localparam logic [5:0] FUNCT_OR      = 6'b100101;
    localparam logic [5:0] FUNCT_SLT     = 6'b101010;

    // ALU Control Constants (Matching alu.sv)
    localparam logic [3:0] ALU_ADD  = 4'b0010;
    localparam logic [3:0] ALU_SUB  = 4'b0110;
    localparam logic [3:0] ALU_AND  = 4'b0000;
    localparam logic [3:0] ALU_OR   = 4'b0001;
    localparam logic [3:0] ALU_SLT  = 4'b0111;
    localparam logic [3:0] ALU_LUI  = 4'b1000;

    // Internal ALUOp signals from Main Control to ALU Control
    logic [1:0] alu_op;

    // -------------------------------------------------------------------------
    // Main Control Decoder
    // -------------------------------------------------------------------------
    always_comb begin
        // Default assignments to prevent latches
        reg_dst_o    = 1'b0;
        alu_src_o    = 1'b0;
        mem_to_reg_o = 1'b0;
        reg_write_o  = 1'b0;
        mem_read_o   = 1'b0;
        mem_write_o  = 1'b0;
        branch_o     = 1'b0;
        branch_ne_o  = 1'b0;
        jump_o       = 1'b0;
        alu_op       = 2'b00;

        case (opcode_i)
            OPCODE_R_TYPE: begin
                reg_dst_o   = 1'b1;
                reg_write_o = 1'b1;
                alu_op      = 2'b10;
            end
            OPCODE_ADDI: begin
                alu_src_o   = 1'b1;
                reg_write_o = 1'b1;
                alu_op      = 2'b00; // ADD
            end
            OPCODE_LUI: begin
                alu_src_o   = 1'b1;
                reg_write_o = 1'b1;
                alu_op      = 2'b11; // Custom for LUI
            end
            OPCODE_LW: begin
                alu_src_o   = 1'b1;
                mem_to_reg_o= 1'b1;
                reg_write_o = 1'b1;
                mem_read_o  = 1'b1;
                alu_op      = 2'b00; // ADD for address calc
            end
            OPCODE_SW: begin
                alu_src_o   = 1'b1;
                mem_write_o = 1'b1;
                alu_op      = 2'b00; // ADD for address calc
            end
            OPCODE_BEQ: begin
                branch_o    = 1'b1;
                alu_op      = 2'b01; // SUB for comparison
            end
            OPCODE_BNE: begin
                branch_ne_o = 1'b1;
                alu_op      = 2'b01; // SUB for comparison
            end
            OPCODE_J: begin
                jump_o      = 1'b1;
            end
            default: ; // Do nothing for unimplemented instructions
        endcase
    end

    // -------------------------------------------------------------------------
    // ALU Control Decoder
    // -------------------------------------------------------------------------
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
                    default:   alu_control_o = ALU_ADD;
                endcase
            end
            default: alu_control_o = ALU_ADD;
        endcase
    end

endmodule
