import sys
import re

REGISTERS = {
    "$zero": 0, "$0": 0, "$at": 1, "$v0": 2, "$v1": 3,
    "$a0": 4, "$a1": 5, "$a2": 6, "$a3": 7,
    "$t0": 8, "$t1": 9, "$t2": 10, "$t3": 11, "$t4": 12, "$t5": 13, "$t6": 14, "$t7": 15,
    "$s0": 16, "$s1": 17, "$s2": 18, "$s3": 19, "$s4": 20, "$s5": 21, "$s6": 22, "$s7": 23,
    "$t8": 24, "$t9": 25, "$k0": 26, "$k1": 27, "$gp": 28, "$sp": 29, "$fp": 30, "$ra": 31
}

OPCODES = {
    "R":     0x00,
    "ADDI":  0x08,
    "LUI":   0x0F,
    "LW":    0x23,
    "SW":    0x2B,
    "BEQ":   0x04,
    "BNE":   0x05,
    "J":     0x02,
    "JAL":   0x03
}

FUNCTS = {
    "ADD": 0x20,
    "SUB": 0x22,
    "AND": 0x24,
    "OR":  0x25,
    "SLT": 0x2A,
    "SLL": 0x00,
    "SRL": 0x02,
    "SRA": 0x03,
    "JR":  0x08
}

def parse_reg(reg_str):
    reg_str = reg_str.strip().strip(',')
    return REGISTERS.get(reg_str, 0)

def parse_imm(imm_str):
    imm_str = imm_str.strip().strip(',')
    if imm_str.startswith("0x"):
        val = int(imm_str, 16)
    else:
        val = int(imm_str)
    # Handle negative values for 16-bit 2's complement
    if val < 0:
        val = (1 << 16) + val
    return val & 0xFFFF

def assemble(input_file, output_file):
    with open(input_file, 'r') as f:
        lines = f.readlines()

    # Pass 1: Extract labels
    labels = {}
    pc = 0
    clean_lines = []
    
    for line in lines:
        # Strip comments
        line = line.split('#')[0].strip()
        if not line:
            continue
            
        # Check for label
        if ':' in line:
            parts = line.split(':')
            label = parts[0].strip()
            labels[label] = pc
            # Rest of the line might be an instruction
            line = parts[1].strip()
            if not line:
                continue
        
        clean_lines.append((pc, line))
        pc += 4

    # Pass 2: Generate machine code
    machine_codes = []
    
    for pc, line in clean_lines:
        parts = re.split(r'[ \t]+', line, maxsplit=1)
        mnemonic = parts[0].upper()
        args = parts[1] if len(parts) > 1 else ""
        
        code = 0
        
        if mnemonic in FUNCTS: # R-Type
            if mnemonic in ["SLL", "SRL", "SRA"]:
                # Format: mnemonic rd, rt, shamt
                r = args.replace(' ', '').split(',')
                rd = parse_reg(r[0])
                rt = parse_reg(r[1])
                shamt = parse_imm(r[2]) & 0x1F
                code = (OPCODES["R"] << 26) | (0 << 21) | (rt << 16) | (rd << 11) | (shamt << 6) | FUNCTS[mnemonic]
            elif mnemonic == "JR":
                # Format: JR rs
                rs = parse_reg(args.replace(' ', ''))
                code = (OPCODES["R"] << 26) | (rs << 21) | (0 << 16) | (0 << 11) | (0 << 6) | FUNCTS[mnemonic]
            else:
                # Format: mnemonic rd, rs, rt
                r = args.replace(' ', '').split(',')
                rd = parse_reg(r[0])
                rs = parse_reg(r[1])
                rt = parse_reg(r[2])
                code = (OPCODES["R"] << 26) | (rs << 21) | (rt << 16) | (rd << 11) | (0 << 6) | FUNCTS[mnemonic]
            
        elif mnemonic == "ADDI":
            # Format: ADDI rt, rs, imm
            r = args.replace(' ', '').split(',')
            rt = parse_reg(r[0])
            rs = parse_reg(r[1])
            imm = parse_imm(r[2])
            code = (OPCODES["ADDI"] << 26) | (rs << 21) | (rt << 16) | imm
            
        elif mnemonic == "LUI":
            # Format: LUI rt, imm
            r = args.replace(' ', '').split(',')
            rt = parse_reg(r[0])
            imm = parse_imm(r[1])
            code = (OPCODES["LUI"] << 26) | (0 << 21) | (rt << 16) | imm
            
        elif mnemonic in ["LW", "SW"]:
            # Format: LW rt, offset(rs)
            # Match groups: 1=rt, 2=offset, 3=rs
            m = re.match(r'([^,]+),\s*([^\s()]+)\s*\(([^)]+)\)', args)
            if not m:
                print(f"Syntax error in {mnemonic} instruction at PC 0x{pc:08X}: {line}")
                sys.exit(1)
            rt = parse_reg(m.group(1))
            offset = parse_imm(m.group(2))
            rs = parse_reg(m.group(3))
            op = OPCODES[mnemonic]
            code = (op << 26) | (rs << 21) | (rt << 16) | offset
            
        elif mnemonic in ["BEQ", "BNE"]:
            # Format: BEQ rs, rt, label
            r = args.replace(' ', '').split(',')
            rs = parse_reg(r[0])
            rt = parse_reg(r[1])
            target = r[2]
            
            if target in labels:
                # Calculate relative offset in words
                offset = (labels[target] - (pc + 4)) // 4
            else:
                offset = parse_imm(target) # Fallback to numeric
                
            # Handle negative offset
            if offset < 0:
                offset = (1 << 16) + offset
            offset = offset & 0xFFFF
            
            op = OPCODES[mnemonic]
            code = (op << 26) | (rs << 21) | (rt << 16) | offset
            
        elif mnemonic in ["J", "JAL"]:
            # Format: J/JAL label
            target = args.strip()
            if target in labels:
                addr = labels[target] // 4
            else:
                addr = int(target, 0)
            op = OPCODES[mnemonic]
            code = (op << 26) | (addr & 0x03FFFFFF)
            
        else:
            print(f"Error: Unknown mnemonic '{mnemonic}' at PC 0x{pc:08X}")
            sys.exit(1)
            
        machine_codes.append(code)

    # Write output
    with open(output_file, 'w') as f:
        for code in machine_codes:
            f.write(f"{code:08X}\n")
            
    print(f"Successfully assembled {len(machine_codes)} instructions to {output_file}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 assembler.py <input.s> <output.hex>")
        sys.exit(1)
        
    assemble(sys.argv[1], sys.argv[2])
