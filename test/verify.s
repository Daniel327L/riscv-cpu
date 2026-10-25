.text
.globl _start
_start:
    addi x1, x0, 5
    addi x2, x0, 7
    add  x3, x1, x2
    sub  x4, x2, x1
    sw   x3, 0(x0)
    lw   x5, 0(x0)