---
name: systemverilog
description: Guidelines and best practices for writing SystemVerilog modules and testbenches, specifically tailored for the double-l32 MIPS 32-bit emulator project. Use when writing, refactoring, or reviewing SystemVerilog (.sv) code.
---

# SystemVerilog Guidelines

## Overview

This skill provides the architectural and styling guidelines for developing the SystemVerilog codebase for the `double-l32` MIPS 32-bit emulator. It ensures code quality, readability, and consistency across the CPU, memory hierarchy, and I/O devices.

## Naming Conventions

Strict adherence to naming conventions prevents bugs and improves readability.

- **Modules:** Use `snake_case` (e.g., `alu_core`, `mips_cpu`).
- **Parameters/Constants:** Use `UPPER_SNAKE_CASE` (e.g., `DATA_WIDTH`, `OPCODE_ADD`).
- **Ports:**
  - Inputs must end with `_i` (e.g., `clk_i`, `rst_ni`, `data_i`).
  - Outputs must end with `_o` (e.g., `result_o`, `valid_o`).
  - Active-low signals must end with `_n` before the port direction (e.g., `rst_ni` for active-low reset input).
- **Internal Signals:**
  - Registered (sequential) signals: end with `_q`.
  - Next-state (combinational) signals: end with `_d`.

## Coding Best Practices

### 1. Synchronous vs Asynchronous Logic
- Use **asynchronous active-low resets** consistently across the design.
- Always use `always_ff @(posedge clk_i or negedge rst_ni)` for sequential logic.
- Always use `always_comb` for combinational logic instead of `always @*`.
- Never mix combinational and sequential logic in the same `always` block.

```systemverilog
// Example of Sequential Logic
always_ff @(posedge clk_i or negedge rst_ni) begin
  if (!rst_ni) begin
    state_q <= STATE_IDLE;
  end else begin
    state_q <= state_d;
  end
end
```

### 2. Parameterization
- Parameterize data widths and standard sizes. Hardcoding `31:0` is acceptable for strict MIPS 32-bit buses, but prefer parameterizing cache line sizes, memory depths, and custom data paths.
- Use `localparam` for internal state machine encodings. 
- Use `enum` with typed logic for state machines:
```systemverilog
typedef enum logic [1:0] {
  STATE_IDLE  = 2'b00,
  STATE_FETCH = 2'b01,
  STATE_EXEC  = 2'b10
} state_e;
state_e state_d, state_q;
```

### 3. Types
- Default to using the `logic` type instead of `wire` or `reg`.
- Use packed arrays/structs where logical grouping is beneficial.

### 4. Instantiation
- Always use explicit port mapping (e.g., `.clk_i(clk)`). Never use positional mapping.

## MIPS 32-bit Specifics
- Ensure the PC (Program Counter) starts at the correct reset vector.
- The default instruction width is 32 bits.
- Support memory-mapped I/O. Leave designated address ranges for the ASCII screen and other peripherals.

## Testbench Structure
- Use class-based testbenches or straightforward module-based testbenches depending on the complexity.
- For this project, Verilator will be heavily used. Ensure SystemVerilog code is synthesizable and friendly to Verilator (avoid unsupported SystemVerilog simulation-only constructs in the RTL).
