# double-l32 Usage Guide

Welcome to the double-l32 MIPS emulator! This guide will teach you how to write assembly programs and run them on the emulator.

## 1. Writing Assembly Programs

The custom assembler (`double-l32-asm`) processes `.s` or `.asm` text files into raw hexadecimal machine code.

### Syntax Rules
*   **Comments**: Use `#` to write comments.
*   **Labels**: Use `label_name:` to define jump/branch targets.
*   **Registers**: Use MIPS standard register names (e.g., `$zero`, `$t0`, `$s1`, `$ra`).
*   **Immediates**: Base-10 (e.g., `100`, `-4`) or Hexadecimal (e.g., `0x1000`) are supported.

### The Memory Map
To do anything interesting, you must interact with the hardware via Memory-Mapped I/O (MMIO):
*   **`0x10000000` (Screen Buffer Base):** Writing a 32-bit word here updates a character on the screen. The screen is 80x25. `0x10000000` is the top-left character, `0x10000004` is the next character to the right.
*   **`0x10001000` (Keyboard Input):** Reading from this address returns the ASCII value of the currently pressed key, or `0` if no key is pressed.
*   **`0x10002000` (Halt Signal):** Writing *any* value to this address immediately halts the CPU and closes the emulator window.

## 2. Example: A Simple Polling Loop

Here is a basic program that waits for the user to press 'q' (ASCII 113) to quit the emulator.

```mips
_start:
    LUI  $t1, 0x1000
    ADDI $t1, $t1, 0x1000 # $t1 = 0x10001000 (Keyboard)
    
    LUI  $t0, 0x1000      # $t0 = 0x10000000 (Screen Base)
    ADDI $t4, $zero, 113  # $t4 = 113 ('q')

loop:
    LW   $t3, 0($t1)      # Read keyboard
    BEQ  $t3, $zero, loop # If 0, keep waiting
    BEQ  $t3, $t4, quit   # If 'q', go to quit

    # (Add logic here to do something with other keys)

wait_release:
    LW   $t3, 0($t1)
    BNE  $t3, $zero, wait_release # Wait for key release
    J    loop

quit:
    SW   $zero, 0x2000($t0) # Halt emulator
```

## 3. Compiling and Running

1. **Assemble**:
   Convert your text file into a `.hex` ROM file.
   ```bash
   double-l32-asm my_program.s my_program.hex
   ```

2. **Run**:
   Load the `.hex` file into the Verilator emulator.
   ```bash
   double-l32-run my_program.hex
   ```

## 4. Reference
For a complete list of supported instructions and register mappings, consult the **Green Sheet**:
```bash
cat ~/.double-l32/docs/green_sheet.md
```