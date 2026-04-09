# Project Status Update

## Completed Phases
*   **Phase 1: Foundation & Build Pipeline:** Done. The Verilator Makefile is fast and works correctly with `-j` multithreading.
*   **Phase 2: CPU Core (MVP MIPS ISA):** Done. The `mips_core.sv` has a functional PC, Control Unit, ALU, and Register File. We implemented `R-Type`, `ADDI`, `LW`, `SW`, `BEQ`, `J`, and later added `LUI` and `BNE` based on test findings.
*   **Phase 3: Memory & I/O Hierarchy:** Done. We have a robust `mmio_decoder.sv` that maps address `0x00000000` to `ram_dp.sv`, `0x10000000` to the Screen, and `0x10001000` to the Keyboard.
*   **Phase 4: Frontend ASCII Rendering:** Done. The C++ wrapper uses SDL2 to render a window. It correctly maps SDL keyboard events (`SDL_KEYDOWN` and `SDL_KEYUP`) into the MMIO register, and renders any character written to the `0x10000000` range onto an 80x25 character buffer.
*   **Phase 5: Integration, ROMs & UAT:** Done. We generated a binary MIPS ROM (`boot.hex`) that successfully initialized memory pointers, polled the keyboard memory address using `BNE` and `BEQ`, and correctly echoed the typed 'h' character to the screen buffer in the UI before manually closing it.
*   **Phase 6: Extended ISA & Assembler:** Done. Expanded the ALU and Control Unit to support Shifts (`SLL`, `SRL`, `SRA`), Multiplication/Division (`MULT`, `DIV`, `MFHI`, `MFLO`), and Jumps (`JR`, `JAL`). Developed a custom Python two-pass assembler (`tools/assembler.py`) supporting labels and instruction mapping.
*   **Phase 7: Packaging & Deployment:** Done. Converted the emulator to load ROMs dynamically at runtime using `+plusargs`. Packaged the executable and assembler with a global installer script (`install.sh`), bridging the local environment to the `/usr/local/bin` `$PATH`.
*   **Phase 8: Architecture & Documentation Update:** Done. Consolidated Green Sheet (`docs/green_sheet.md`), generated UML diagrams (`docs/ARCHITECTURE.md`), and updated `README.md` for seamless onboarding.

## Current State
The `double-l32` MIPS emulator is fully functional. Hardware logic, memory mapping, software integration, and a dedicated compilation toolchain are working harmoniously. It has graduated from an MVP to a globally installable local toolbelt.

## Next Steps
The project is complete. Potential future expansions:
1.  Adding a VGA/Pixel mode to the SDL2 wrapper instead of just an ASCII buffer.
2.  Adding floating-point (FPU) support.
3.  Supporting interrupts and an OS trap system (CP0 Coprocessor).
