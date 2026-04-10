# Demo: Multiplication and Screen Output
_start:
    LUI  $t0, 0x1000      # $t0 = 0x10000000 (Screen Base)
    ADDI $t1, $zero, 7    # $t1 = 7
    ADDI $t2, $zero, 6    # $t2 = 6

    # 7 * 6 = 42 (ASCII '*')
    MULT $t1, $t2
    MFLO $t3              # $t3 = 42 ('*')

    SW   $t3, 0($t0)      # Write '*' to screen pos 0
    SW   $t3, 4($t0)      # Write '*' to screen pos 1
    SW   $t3, 8($t0)      # Write '*' to screen pos 2

    # Halt the emulator
    SW   $zero, 0x2000($t0) 
