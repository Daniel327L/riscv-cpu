.text
.globl _start
_start:
    li   sp, 0x400        # stack pointer = top of data memory (grows down)
    jal  ra, main         # call main()  (ra = x1 = return address)
    # main's return value is now in a0 (x10)
halt:
    j halt                # spin forever
