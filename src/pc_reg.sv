`default_nettype none

module pc_reg (
    input  logic        clk_i,
    input  logic        rst_ni,
    input  logic        en_i,         // 1: Update PC, 0: Stall PC
    input  logic [31:0] next_pc_i,    // Next Program Counter value
    output logic [31:0] pc_o          // Current Program Counter value
);

    // MIPS typically boots from a specific reset vector.
    // For this simple MVP, we will boot from 32'h0000_0000.
    localparam logic [31:0] RESET_VECTOR = 32'h0000_0000;

    logic [31:0] pc_q;
    logic [31:0] pc_d;

    assign pc_d = (en_i) ? next_pc_i : pc_q;
    
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            pc_q <= RESET_VECTOR;
        end else begin
            pc_q <= pc_d;
        end
    end

    assign pc_o = pc_q;

endmodule
