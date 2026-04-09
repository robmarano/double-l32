# Keyboard Echo Program with Quit Support
# $t0 = Screen MMIO Base (0x10000000)
# $t1 = Keyboard MMIO Address (0x10001000)
# $t2 = Current Screen Pointer
# $t3 = Data register (Current Key)
# $t4 = Constant holding ASCII 'q' (113)

_start:
    LUI  $t0, 0x1000      # $t0 = 0x1000_0000 (Screen Base)
    
    LUI  $t1, 0x1000
    ADDI $t1, $t1, 0x1000 # $t1 = 0x1000_1000 (Keys)
    
    ADD  $t2, $t0, $zero  # $t2 = current screen ptr
    ADDI $t4, $zero, 113  # $t4 = 113 ('q' in ASCII)

loop:
    LW   $t3, 0($t1)      # Read key into $t3
    BEQ  $t3, $zero, loop # Wait for key press

    # Check if 'q' was pressed
    BEQ  $t3, $t4, quit

    # If not 'q', echo to screen
    SW   $t3, 0($t2)      # Write key to screen
    ADDI $t2, $t2, 4      # Increment screen ptr

wait_release:
    LW   $t3, 0($t1)
    BNE  $t3, $zero, wait_release # Wait for key release

    J    loop

quit:
    SW   $zero, 0x2000($t0) # Write 0 to 0x10002000 to halt emulator
