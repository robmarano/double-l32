# double-l32 MIPS Green Sheet

## Architecture Overview
The **double-l32** is a 32-bit RISC architecture implementing a subset of the classic MIPS I instruction set. The CPU currently executes single-cycle instructions with separate instruction and data memory interfaces (Harvard architecture at the L1 level).

All instructions are 32 bits wide, and the memory is byte-addressable (though currently implemented mostly for aligned word accesses).

---

## 1. Supported Instruction Set

### R-Type Instructions
**Format:** `[ Opcode (6) | rs (5) | rt (5) | rd (5) | shamt (5) | funct (6) ]`
*Note: `shamt` is currently ignored (00000) as shift instructions are not yet implemented.*

| Instruction | Mnemonic             | Opcode (Hex) | Funct (Hex) | Action                        |
|:------------|:---------------------|:------------:|:------------|:------------------------------|
| ADD         | `ADD rd, rs, rt`     | 0x00         | 0x20        | `rd = rs + rt`                |
| SUB         | `SUB rd, rs, rt`     | 0x00         | 0x22        | `rd = rs - rt`                |
| AND         | `AND rd, rs, rt`     | 0x00         | 0x24        | `rd = rs & rt`                |
| OR          | `OR rd, rs, rt`      | 0x00         | 0x25        | `rd = rs | rt`                |
| SLT         | `SLT rd, rs, rt`     | 0x00         | 0x2A        | `rd = (rs < rt) ? 1 : 0`      |

### I-Type Instructions
**Format:** `[ Opcode (6) | rs (5) | rt (5) | Immediate (16) ]`

| Instruction | Mnemonic             | Opcode (Hex) | Action                               |
|:------------|:---------------------|:------------:|:-------------------------------------|
| ADDI        | `ADDI rt, rs, imm`   | 0x08         | `rt = rs + SignExt(imm)`             |
| LUI         | `LUI rt, imm`        | 0x0F         | `rt = imm << 16`                     |
| LW          | `LW rt, offset(rs)`  | 0x23         | `rt = Mem[rs + SignExt(offset)]`     |
| SW          | `SW rt, offset(rs)`  | 0x2B         | `Mem[rs + SignExt(offset)] = rt`     |
| BEQ         | `BEQ rs, rt, label`  | 0x04         | `if (rs == rt) PC = PC + 4 + (imm<<2)`|
| BNE         | `BNE rs, rt, label`  | 0x05         | `if (rs != rt) PC = PC + 4 + (imm<<2)`|

### J-Type Instructions
**Format:** `[ Opcode (6) | Address (26) ]`

| Instruction | Mnemonic             | Opcode (Hex) | Action                               |
|:------------|:---------------------|:------------:|:-------------------------------------|
| J           | `J label`            | 0x02         | `PC = (PC+4)[31:28] \| (target<<2)`  |

---

## 2. Register Layout

The MIPS architecture has 32 general-purpose registers (32-bit width).

| Register Name | Number | Usage                                  | Preserved across call? |
|:--------------|:------:|:---------------------------------------|:-----------------------|
| `$zero`       | 0      | The Constant Value 0                   | N/A                    |
| `$at`         | 1      | Assembler Temporary                    | No                     |
| `$v0 - $v1`   | 2-3    | Values for results and expression eval | No                     |
| `$a0 - $a3`   | 4-7    | Arguments                              | No                     |
| `$t0 - $t7`   | 8-15   | Temporaries                            | No                     |
| `$s0 - $s7`   | 16-23  | Saved Temporaries                      | Yes                    |
| `$t8 - $t9`   | 24-25  | Temporaries                            | No                     |
| `$k0 - $k1`   | 26-27  | Reserved for OS Kernel                 | N/A                    |
| `$gp`         | 28     | Global Pointer                         | Yes                    |
| `$sp`         | 29     | Stack Pointer                          | Yes                    |
| `$fp`         | 30     | Frame Pointer                          | Yes                    |
| `$ra`         | 31     | Return Address                         | Yes                    |

---

## 3. Memory Map & Hierarchy

The `double-l32` implements a strictly partitioned memory-mapped I/O (MMIO) architecture.
The 32-bit address space is segmented as follows:

| Address Range                 | Region Name    | Size / Scope  | Access | Description                           |
|:------------------------------|:---------------|:--------------|:-------|:--------------------------------------|
| `0x0000_0000 - 0x0000_03FF`   | **Text Segment**| 1 KB          | R/W    | Boot ROM and executed Instructions.   |
| `0x0000_0400 - 0x0000_0BFF`   | **Data Segment**| 2 KB          | R/W    | Global data and heap memory.          |
| `0x0000_0C00 - 0x0000_0FFF`   | **Stack**      | 1 KB          | R/W    | Stack memory (grows downwards).       |
| `0x0000_1000 - 0x0FFF_FFFF`   | **Unmapped**   | ~256 MB       | None   | Undefined behavior.                   |
| `0x1000_0000 - 0x1000_0FFF`   | **MMIO Screen**| 4 KB          | Write  | Writing a byte renders an ASCII char. |
| `0x1000_1000`                 | **MMIO Keyboard**| 4 Bytes       | Read   | Reading returns ASCII keycode.        |
| `0x1000_2000`                 | **MMIO Halt**  | 4 Bytes       | Write  | Writing here gracefully shuts down the emulator. |
| `0x1000_2004 - 0xFFFF_FFFF`   | **Unmapped**   | ~3.7 GB       | None   | Undefined behavior.                   |

*Note: The hardware RAM module is currently hardcoded to 4KB (1024 words). Trying to access beyond `0x0FFF` without hitting an MMIO address will result in zeros.*
