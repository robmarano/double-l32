#include <iostream>
#include <memory>
#include <cassert>
#include "Valu_regfile_tb.h"
#include "verilated.h"

void tick(std::unique_ptr<Valu_regfile_tb>& top) {
    top->clk_i = 0;
    top->eval();
    top->clk_i = 1;
    top->eval();
}

void reset(std::unique_ptr<Valu_regfile_tb>& top) {
    top->rst_ni = 0;
    tick(top);
    top->rst_ni = 1;
    tick(top);
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    auto top = std::make_unique<Valu_regfile_tb>();

    reset(top);

    std::cout << "Test 1: Write to Register 1 and 2, then ADD them" << std::endl;
    
    // Write 10 to Reg 1
    top->rd_addr_i = 1;
    top->rd_data_i = 10;
    top->we_i = 1;
    tick(top);

    // Write 20 to Reg 2
    top->rd_addr_i = 2;
    top->rd_data_i = 20;
    top->we_i = 1;
    tick(top);

    top->we_i = 0;

    // Read Reg 1 and 2 into ALU
    top->rs_addr_i = 1;
    top->rt_addr_i = 2;
    top->alu_op_i = 0x2; // ALU_ADD
    top->eval();

    std::cout << "ALU Result: " << top->alu_result_o << " (Expected 30)" << std::endl;
    assert(top->alu_result_o == 30);

    std::cout << "Test 2: SUB Reg 2 - Reg 1" << std::endl;
    top->rs_addr_i = 2; // 20
    top->rt_addr_i = 1; // 10
    top->alu_op_i = 0x6; // ALU_SUB
    top->eval();
    std::cout << "ALU Result: " << top->alu_result_o << " (Expected 10)" << std::endl;
    assert(top->alu_result_o == 10);

    std::cout << "Test 3: Ensure Reg 0 is always 0" << std::endl;
    top->rd_addr_i = 0;
    top->rd_data_i = 999;
    top->we_i = 1;
    tick(top);
    top->we_i = 0;
    top->rs_addr_i = 0;
    top->eval();
    // Note: rs_data is internal, but we can check via ALU if we set ALU to ADD with Reg 0
    top->rt_addr_i = 1; // Reg 1 is 10
    top->alu_op_i = 0x2; // ADD
    top->eval();
    std::cout << "ALU Result (0 + 10): " << top->alu_result_o << " (Expected 10)" << std::endl;
    assert(top->alu_result_o == 10);

    std::cout << "All tests passed!" << std::endl;
    
    top->final();
    return 0;
}
