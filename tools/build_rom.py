import os

# Keyboard Echo Program
# $t0 = Screen MMIO Base (0x10000000)
# $t1 = Keyboard MMIO Address (0x10001000)
# $t2 = Current Screen Pointer (starts at 0x10000000)
# $t3 = Data register

instructions = [
    # Initialization
    0x3C081000, # LUI $t0, 0x1000      -> $t0 = 0x1000_0000
    0x3C091000, # LUI $t1, 0x1000
    0x21291000, # ADDI $t1, $t1, 0x1000 -> $t1 = 0x1000_1000 (Keys)
    0x01005021, # ADDU $t2, $t0, $zero  -> $t2 = current screen ptr
    
    # Loop: Poll Keyboard
    # loop:
    0x8D2B0000, # LW $t3, 0($t1)        -> Read key
    0x1160FFFE, # BEQ $t3, $zero, -2    -> If key == 0, jump back to LW (offset -2 words)
    
    # Key pressed! Echo to screen
    0xAD4B0000, # SW $t3, 0($t2)        -> Write key to screen
    0x214A0004, # ADDI $t2, $t2, 4      -> Increment screen pointer
    
    # Wait for key release to avoid repeated echo
    # wait_release:
    0x8D2B0000, # LW $t3, 0($t1)
    0x1560FFFF, # BNE $t3, $zero, -1    -> If key != 0, jump back to LW (offset -1 word)
    
    # Repeat
    0x08000004  # J loop (loop is at index 4)
]

# Write to a hex file readable by Verilog's $readmemh
rom_path = os.path.join("roms", "boot.hex")
with open(rom_path, "w") as f:
    for inst in instructions:
        f.write(f"{inst:08X}\n")

print(f"Generated {rom_path} (Echo Program) with {len(instructions)} instructions.")
