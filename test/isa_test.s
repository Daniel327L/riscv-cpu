.text
.globl _start
_start:
    addi  x1,  x0, 5        # x1 = 5
    addi  x2,  x0, 10       # x2 = 10

    bne   x1, x2, L1        # 5 != 10  -> taken
    addi  x3,  x0, 99       # skipped
L1: addi  x3,  x0, 1        # x3 = 1

    lui   x4,  0xABCDE      # x4 = 0xABCDE000
    auipc x5,  0            # x5 = address of this instruction

    addi  x6,  x0, -1       # x6 = 0xFFFFFFFF
    addi  x7,  x0, 1        # x7 = 1

    blt   x6, x7, L2        # signed: -1 < 1  -> taken
    addi  x8,  x0, 99       # skipped
L2: addi  x8,  x0, 2        # x8 = 2

    bge   x7, x6, L3        # signed: 1 >= -1 -> taken
    addi  x12, x0, 99       # skipped
L3: addi  x12, x0, 6        # x12 = 6

    bltu  x6, x7, Lbad      # unsigned: huge < 1 -> NOT taken
    addi  x9,  x0, 3        # x9 = 3 (fall through)
    beq   x0, x0, L4
Lbad: addi x9, x0, 99       # bug if reached
L4:
    bgeu  x6, x7, L5        # unsigned: huge >= 1 -> taken
    addi  x13, x0, 99       # skipped
L5: addi  x13, x0, 8        # x13 = 8

    jal   x1, func          # call; x1 = return address
    addi  x10, x0, 7        # x10 = 7 (returned)
    addi  x14, x0, -16     # x14 = 0xFFFFFFF0   ← NEW
    srai  x15, x14, 2      # arithmetic shift   ← NEW
    srli  x16, x14, 2      # logical shift      ← NEW
    beq   x0, x0, halt

func:
    addi  x11, x0, 42       # x11 = 42
    jalr  x0, 0(x1)         # return

halt:
    beq   x0, x0, halt      # spin forever