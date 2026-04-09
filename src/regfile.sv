`default_nettype none

module regfile (
    input  logic        clk_i,
    input  logic        rst_ni,
    input  logic [4:0]  rs_addr_i,
    input  logic [4:0]  rt_addr_i,
    input  logic [4:0]  rd_addr_i,
    input  logic [31:0] rd_data_i,
    input  logic        we_i,
    output logic [31:0] rs_data_o,
    output logic [31:0] rt_data_o
);

    logic [31:0] registers [31:0];

    // Asynchronous Read
    // Register 0 is hardwired to zero
    assign rs_data_o = (rs_addr_i == 5'h0) ? 32'h0 : registers[rs_addr_i];
    assign rt_data_o = (rt_addr_i == 5'h0) ? 32'h0 : registers[rt_addr_i];

    // Synchronous Write
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            for (int i = 0; i < 32; i++) begin
                registers[i] <= 32'h0;
            end
        end else if (we_i && (rd_addr_i != 5'h0)) begin
            registers[rd_addr_i] <= rd_data_i;
        end
    end

endmodule
