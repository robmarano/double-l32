---
name: verilator
description: Guidelines and workflows for compiling SystemVerilog with Verilator and writing the C++ simulation testbenches for the double-l32 project. Use when setting up simulation, interacting with the Verilator CLI, or writing the C++ simulator wrapper (especially with SDL2).
---

# Verilator Guidelines

## Overview

This skill provides the required workflow and boilerplate for taking the SystemVerilog HDL in the `double-l32` project and turning it into a fast C++ simulation using Verilator. It also covers the structure of the C++ wrapper that serves as the hardware testbench, particularly for emulating an ASCII screen via Memory-Mapped I/O.

## Standard Verilator Compilation

To compile the SystemVerilog code, use the following typical flags for a clean, strict compilation:

```bash
verilator --cc --exe --build -j 0 -Wall -Wno-DECLFILENAME \
  --top-module top_module_name \
  src/*.sv sim/main.cpp
```

### Important Flags:
- `--cc`: Create C++ output.
- `--exe`: Create an executable.
- `--build`: Invoke make to build the executable automatically.
- `-Wall`: Enable all warnings.
- `-Wno-DECLFILENAME`: Suppress the warning if the module name does not match the filename (though matching is preferred).

## C++ Testbench Structure

A standard C++ testbench in Verilator should look like this:

```cpp
#include <iostream>
#include <memory>
#include "Vtop_module.h" // Replace with actual module name
#include "verilated.h"

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    
    // Instantiate the module
    auto top = std::make_unique<Vtop_module>();
    
    // Initialize inputs
    top->clk_i = 0;
    top->rst_ni = 0; // Assert reset
    
    // Evaluation loop
    vluint64_t main_time = 0;
    while (!Verilated::gotFinish() && main_time < 1000) {
        // Toggle clock
        top->clk_i = !top->clk_i;
        
        // Deassert reset after a few cycles
        if (main_time > 10) {
            top->rst_ni = 1;
        }
        
        // Evaluate the model
        top->eval();
        
        // Handle memory-mapped I/O (e.g., ASCII screen writes) here
        // if (top->clk_i && top->mem_write_en_o && top->mem_addr_o == ASCII_SCREEN_ADDR) {
        //     std::cout << (char)top->mem_data_o;
        // }
        
        main_time++;
    }
    
    // Finalize
    top->final();
    return 0;
}
```

## Memory-Mapped I/O and SDL2

Since the `double-l32` project features an old-school ASCII screen, it is highly recommended to use a library like `SDL2` or just `ncurses` (for pure terminal) inside the C++ testbench to render the screen buffer.

When memory-mapped I/O operations occur in the HDL (e.g., writing to a specific address), the C++ testbench should catch the outgoing signals (`mem_write_en_o`, `mem_addr_o`, `mem_data_o`) during the evaluation loop and forward that data to the SDL2 rendering context.

If using SDL2, include it in the compilation:
```bash
verilator --cc --exe --build -j 0 --top-module top_module_name \
  -LDFLAGS "-lSDL2 -lSDL2_ttf" \
  src/*.sv sim/main.cpp
```
