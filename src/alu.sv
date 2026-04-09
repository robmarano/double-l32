`default_nettype none

module alu (
    input  logic [31:0] a_i,
    input  logic [31:0] b_i,
    input  logic [4:0]  shamt_i,
    input  logic [4:0]  alu_op_i,
    input  logic [31:0] hi_i,
    input  logic [31:0] lo_i,
    output logic [31:0] result_o,
    output logic [31:0] hi_o,
    output logic [31:0] lo_o,
    output logic        zero_o
);

    // ALU Operations (Subset of MIPS)
    localparam [4:0] ALU_AND  = 5'b00000;
    localparam [4:0] ALU_OR   = 5'b00001;
    localparam [4:0] ALU_ADD  = 5'b00010;
    localparam [4:0] ALU_XOR  = 5'b00100;
    localparam [4:0] ALU_SUB  = 5'b00110;
    localparam [4:0] ALU_SLT  = 5'b00111;
    localparam [4:0] ALU_LUI  = 5'b01000;
    localparam [4:0] ALU_SLL  = 5'b01001;
    localparam [4:0] ALU_SRL  = 5'b01010;
    localparam [4:0] ALU_SRA  = 5'b01011;
    localparam [4:0] ALU_NOR  = 5'b01100;
    localparam [4:0] ALU_MULT = 5'b01101;
    localparam [4:0] ALU_DIV  = 5'b01110;
    localparam [4:0] ALU_MFHI = 5'b01111;
    localparam [4:0] ALU_MFLO = 5'b10000;

    logic signed [63:0] mult_result;
    
    always_comb begin
        // Default HI/LO passthrough unless multiplying or dividing
        hi_o = hi_i;
        lo_o = lo_i;
        
        mult_result = $signed(a_i) * $signed(b_i);

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
            ALU_MFHI: result_o = hi_i;
            ALU_MFLO: result_o = lo_i;
            ALU_MULT: begin
                result_o = 32'h0;
                hi_o = mult_result[63:32];
                lo_o = mult_result[31:0];
            end
            ALU_DIV: begin
                result_o = 32'h0;
                if (b_i != 32'h0) begin
                    lo_o = $signed(a_i) / $signed(b_i); // Quotient
                    hi_o = $signed(a_i) % $signed(b_i); // Remainder
                end
            end
            default:  result_o = 32'h0;
        endcase
    end

    assign zero_o = (result_o == 32'h0);

endmodule
