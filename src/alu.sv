`default_nettype none

module alu (
    input  logic [31:0] a_i,
    input  logic [31:0] b_i,
    input  logic [4:0]  shamt_i,
    input  logic [3:0]  alu_op_i,
    output logic [31:0] result_o,
    output logic        zero_o
);

    // ALU Operations (Subset of MIPS)
    localparam [3:0] ALU_ADD  = 4'b0010;
    localparam [3:0] ALU_SUB  = 4'b0110;
    localparam [3:0] ALU_AND  = 4'b0000;
    localparam [3:0] ALU_OR   = 4'b0001;
    localparam [3:0] ALU_SLT  = 4'b0111;
    localparam [3:0] ALU_NOR  = 4'b1100;
    localparam [3:0] ALU_XOR  = 4'b0100;
    localparam [3:0] ALU_LUI  = 4'b1000;
    localparam [3:0] ALU_SLL  = 4'b1001;
    localparam [3:0] ALU_SRL  = 4'b1010;
    localparam [3:0] ALU_SRA  = 4'b1011;

    always_comb begin
        case (alu_op_i)
            ALU_ADD:  result_o = a_i + b_i;
            ALU_SUB:  result_o = a_i - b_i;
            ALU_AND:  result_o = a_i & b_i;
            ALU_OR:   result_o = a_i | b_i;
            ALU_XOR:  result_o = a_i ^ b_i;
            ALU_NOR:  result_o = ~(a_i | b_i);
            ALU_SLT:  result_o = ($signed(a_i) < $signed(b_i)) ? 32'h1 : 32'h0;
            ALU_LUI:  result_o = b_i << 16;
            ALU_SLL:  result_o = b_i << shamt_i;
            ALU_SRL:  result_o = b_i >> shamt_i;
            ALU_SRA:  result_o = $signed(b_i) >>> shamt_i;
            default:  result_o = 32'h0;
        endcase
    end

    assign zero_o = (result_o == 32'h0);

endmodule
