# Test Multiplication and Division
# Expected: 
#   $t0 = 10, $t1 = 3
#   MULT $t0, $t1 -> LO = 30, HI = 0
#   DIV  $t0, $t1 -> LO = 3,  HI = 1
#   We will write the results to MMIO screen just to visualize or we can just halt and test in C++.
# Let's halt right after.

_start:
    ADDI $t0, $zero, 10
    ADDI $t1, $zero, 3
    
    MULT $t0, $t1
    MFLO $t2    # $t2 should be 30
    MFHI $t3    # $t3 should be 0

    DIV  $t0, $t1
    MFLO $t4    # $t4 should be 3
    MFHI $t5    # $t5 should be 1

    # End simulation
    LUI  $at, 0x1000
    SW   $zero, 0x2000($at)
