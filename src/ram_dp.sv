`default_nettype none

module ram_dp #(
    parameter int ADDR_WIDTH = 10,  // 1024 words = 4KB
    parameter int DATA_WIDTH = 32
)(
    input  logic                  clk_i,
    
    // Port A: Instruction Fetch (Read Only, Async for Single-Cycle CPU)
    input  logic [ADDR_WIDTH-1:0] inst_addr_i,
    output logic [DATA_WIDTH-1:0] inst_data_o,
    
    // Port B: Data Read/Write (Async Read, Sync Write)
    input  logic [ADDR_WIDTH-1:0] data_addr_i,
    input  logic [DATA_WIDTH-1:0] data_wdata_i,
    input  logic                  data_we_i,
    input  logic                  data_re_i,
    output logic [DATA_WIDTH-1:0] data_rdata_o
);

    localparam int DEPTH = 1 << ADDR_WIDTH;
    logic [DATA_WIDTH-1:0] mem [DEPTH-1:0];

    // Initialize memory to 0 and load ROM
    initial begin
        for (int i = 0; i < DEPTH; i++) begin
            mem[i] = '0;
        end
        $readmemh("roms/boot.hex", mem);
    end

    // Port A: Instruction Read
    assign inst_data_o = mem[inst_addr_i];

    // Port B: Data Read
    assign data_rdata_o = (data_re_i) ? mem[data_addr_i] : '0;

    // Port B: Data Write
    always_ff @(posedge clk_i) begin
        if (data_we_i) begin
            mem[data_addr_i] <= data_wdata_i;
        end
    end

endmodule
