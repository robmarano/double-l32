# Initial Task Plan: double-l32 Emulator

This plan outlines the execution strategy for the engineering team. Tasks are broken down by phase and assigned to the relevant Principal subagents.

## Phase 1: Foundation & Build Pipeline
**Goal:** Establish the repository structure, build scripts, and empty module templates.
*   [ ] **Task 1.1:** Setup project directory structure (`src/`, `sim/`, `test/`, `roms/`). *(Assignee: `@devops-principal`)*
*   [ ] **Task 1.2:** Create the basic `Makefile` and Verilator build configuration. *(Assignee: `@devops-principal`)*
*   [ ] **Task 1.3:** Create the C++ entry point (`sim/main.cpp`) with a basic Verilator evaluation loop (no SDL2 yet). *(Assignee: `@frontend-sde`)*
*   [ ] **Task 1.4:** Create the top-level SystemVerilog module (`src/mips_top.sv`) with clock and reset. *(Assignee: `@backend-sde-core`)*

## Phase 2: CPU Core (MVP MIPS ISA)
**Goal:** Implement the MIPS 32-bit datapath and control logic.
*   [ ] **Task 2.1:** Implement the ALU (`src/alu.sv`) and Register File (`src/regfile.sv`). *(Assignee: `@backend-sde-core`)*
*   [ ] **Task 2.2:** Implement Instruction Fetch and Decode logic. *(Assignee: `@backend-sde-core`)*
*   [ ] **Task 2.3:** Write C++ and SV unit tests for the ALU and Register File. *(Assignee: `@qa-automation`)*

## Phase 3: Memory & I/O Hierarchy
**Goal:** Implement RAM, Cache, and Memory-Mapped I/O logic.
*   [ ] **Task 3.1:** Implement basic Block RAM module for main memory. *(Assignee: `@backend-sde-data`)*
*   [ ] **Task 3.2:** Implement the Address Decoder for MMIO (separate RAM accesses from screen/keyboard accesses). *(Assignee: `@backend-sde-data`)*
*   [ ] **Task 3.3:** Integrate the CPU core with the memory bus. *(Assignee: `@backend-sde-core` & `@backend-sde-data`)*

## Phase 4: Frontend ASCII Rendering
**Goal:** Bring the system to life visually.
*   [ ] **Task 4.1:** Integrate SDL2 into the `Makefile` and C++ wrapper. *(Assignee: `@devops-principal` & `@frontend-sde`)*
*   [ ] **Task 4.2:** Implement the UI loop to read MMIO screen buffer changes from the Verilator model and render ASCII characters. *(Assignee: `@frontend-sde`)*
*   [ ] **Task 4.3:** Implement keyboard event capture and feed into MMIO registers. *(Assignee: `@frontend-sde`)*

## Phase 5: Integration, ROMs & UAT
**Goal:** Run actual programs and ensure stability.
*   [ ] **Task 5.1:** Write a basic MIPS assembly "Hello World" ROM, compile to hex, and load into the SV memory model. *(Assignee: `@qa-automation` & `@devops-principal`)*
*   [ ] **Task 5.2:** Profile the simulation loop and optimize SDL2 rendering overhead. *(Assignee: `@qa-sec-perf`)*
*   [ ] **Task 5.3:** End-to-end user validation: Can a user boot the emulator and type on the screen? *(Assignee: `@uat-business`)*
