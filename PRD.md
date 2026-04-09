# Product Requirements Document (PRD): double-l32 Emulator

## 1. Product Vision & Goal
**double-l32** is an educational and functional hardware-level emulator. The goal is to build a MIPS 32-bit compatible CPU entirely in SystemVerilog, simulate it at high speeds using Verilator, and interact with it through a custom C++ frontend that emulates an old-school ASCII terminal.

The product bridges hardware engineering (RTL) and software engineering (C++ UI/Simulation) to deliver a nostalgic, interactive computer experience.

## 2. Target Audience
*   Hardware enthusiasts and students learning SystemVerilog/MIPS architecture.
*   Retro-computing hobbyists who want to write low-level assembly/C for a custom MIPS machine and see it render text on a simulated phosphor screen.

## 3. Core Features & Requirements (MVP)

### 3.1. CPU Core (SystemVerilog)
*   **Architecture:** MIPS 32-bit instruction set (subset sufficient to run basic C-compiled programs and memory-mapped I/O operations).
*   **Design:** Synthesizable SystemVerilog, adhering to the project's strict naming and synchronous logic guidelines. 
*   **Components:** Program Counter, ALU, 32x32-bit Register File, Control Unit.

### 3.2. Memory Hierarchy & Interconnect
*   **Main Memory:** Synchronous RAM component.
*   **Cache:** Basic L1 Cache (Instruction/Data) to demonstrate memory hierarchy concepts.
*   **MMIO (Memory-Mapped I/O):** Specific address ranges reserved for peripherals, crucially the ASCII Screen buffer and keyboard input buffer.

### 3.3. Frontend & Simulation (C++ / SDL2)
*   **Verilator Host:** A C++ wrapper that steps the Verilated SystemVerilog model.
*   **Display:** Uses SDL2 (or similar) to render an ASCII grid. When the CPU writes a byte to the MMIO video memory address, the C++ wrapper renders that character on screen.
*   **Input:** Captures keyboard events and writes them to the MMIO keyboard buffer for the CPU to read.

## 4. Non-Goals (Out of Scope for MVP)
*   Full Linux/OS boot capability (requires full MMU and complete exception handling).
*   Floating Point Unit (FPU).
*   Advanced superscalar or deeply out-of-order execution (stick to single-cycle or a classic 5-stage pipeline for the MVP).
*   Complex graphical rendering beyond ASCII/Text mode.

## 5. Acceptance Criteria
*   **AC1 (Build):** A single `make` command compiles the SystemVerilog via Verilator and builds the C++ executable without errors or warnings.
*   **AC2 (Logic):** Unit tests pass for core MIPS instructions (ADD, SUB, BEQ, J, LW, SW, etc.).
*   **AC3 (I/O):** A simple MIPS assembly "Hello World" ROM successfully writes to the MMIO screen buffer.
*   **AC4 (UI):** The C++ executable opens a window and renders the "Hello World" string based on the simulated MMIO state.
