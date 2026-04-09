# double-l32

A 32-bit RISC MIPS I emulator built entirely in SystemVerilog, simulated via Verilator, and featuring a custom C++ SDL2 frontend that emulates an old-school phosphor ASCII terminal.

This project bridges hardware engineering (RTL) and software engineering (C++ UI/Simulation) to deliver a nostalgic, interactive computer experience.

## Features

*   **Custom MIPS CPU Core**: Single-cycle datapath executing a core subset of the MIPS ISA (including arithmetic, branching, jumping, shifting, and multiplication/division via HI/LO registers).
*   **Memory-Mapped I/O (MMIO)**: Explicit memory mapping for RAM (`0x00000000`), a 80x25 ASCII Screen Buffer (`0x10000000`), Keyboard Input (`0x10001000`), and Halt signals.
*   **Built-in Python Assembler**: Write `.s` or `.asm` files natively instead of raw hexadecimal machine code.
*   **Interactive Frontend**: Typing on your physical keyboard translates to live ASCII characters appearing on a simulated hardware screen.
*   **Global Toolbelt**: A one-line bash installer to make the emulator and assembler globally accessible on your machine.

## Prerequisites

*   `verilator` (v5.0+ recommended)
*   `sdl2` and `sdl2_ttf` (Install via `brew install sdl2 sdl2_ttf`)
*   `python3` (for the assembler)
*   `make`

## Installation

You can install the `double-l32` toolbelt globally on your machine using the provided script. This places the assembler (`double-l32-asm`) and the emulator runner (`double-l32-run`) into `/usr/local/bin`.

```bash
# Clone the repository
git clone https://github.com/robmarano/double-l32.git
cd double-l32

# Install the dependencies (macOS example)
brew install verilator sdl2 sdl2_ttf

# Run the installer (will ask for sudo to copy to /usr/local/bin)
./install.sh
```

## Quick Start

Once installed globally, you can write and run MIPS assembly programs from anywhere.

1. **Write a Program** (`my_game.s`):
```mips
_start:
    LUI  $t0, 0x1000      # Screen MMIO Base
    LUI  $t1, 0x1000
    ADDI $t1, $t1, 0x1000 # Keyboard MMIO Base
    ADD  $t2, $t0, $zero  # Current Screen Pointer
    ADDI $t4, $zero, 113  # 'q' key to quit

loop:
    LW   $t3, 0($t1)      # Poll keyboard
    BEQ  $t3, $zero, loop
    BEQ  $t3, $t4, quit   # Check for 'q'
    SW   $t3, 0($t2)      # Echo to screen
    ADDI $t2, $t2, 4

wait_release:
    LW   $t3, 0($t1)
    BNE  $t3, $zero, wait_release
    J    loop

quit:
    SW   $zero, 0x2000($t0) # Halt emulator
```

2. **Assemble the Program**:
```bash
double-l32-asm my_game.s my_game.hex
```

3. **Run the Emulator**:
```bash
double-l32-run my_game.hex
```
*A phosphor-green terminal window will open. Start typing! Press 'q' to gracefully halt the CPU.*

## Documentation

*   [**Green Sheet**](docs/green_sheet.md): Instruction Set, Opcode formats, Register Layout, and the MMIO Memory Map.
*   [**Architecture**](docs/ARCHITECTURE.md): Component diagrams, CPU datapath routing, and Keyboard Echo sequence flows (UML/Mermaid).
*   [**PRD**](PRD.md): The overarching product vision and acceptance criteria.
