# Control Signal Table — fill this in BEFORE writing `control.v`

## Context

For each type of opreation implemented previously in imm_gen, some of them require access to memory, some need a destination registr, and some don't even need an immediate, so this table basically organize all signals and label them as need / don't need, and for alu_op
column, it's 00, 01 or 10 that I'll implement after this control unit in `alu_control.v`.

- R-type: 
  * Needs two register to read from, do math on both values from those two register and store in destination register.
- I-type: 
  * addi / subi / xori ..... all means do math with a value from one read register and a number (immediate), then save result in a destination.
  * lw --> extract a value from one read register, offset it by an immediate, and use it as a address in memory, and load the extracted result form memory into a regiter.
- S-type:
  * sw --> similar to lw, but instead of writing into a register, write the value from a register into a memory which its address is another read register + an offset (immediate).
- B-type:
  * Compare two read register, if [condition], then jump to nearby instruction (PC + immediate, where PC means program counter, address for current instruction) dictate by the immediate offset.
- J-type:
  * Always jump to a target and return the return address (PC+4) to a register, why plus 4? cuz the next instruction is 4 bytes away from where you jumped off. Speaking of which, memory counts bytes, so instruction 0 is at address0, next one is 4, then 8 so on.


`alu_op` legend (coarse selector for `alu_control.v`):
`00` = force ADD (address calc / jump) · `01` = force SUB (branch compare) ·
`10` = decode from funct3/funct7 (R/I-type ALU ops)

| instruction | opcode    | reg_write | alu_src | mem_read | mem_write | mem_to_reg | branch | jump | alu_op |
|-------------|-----------|-----------|---------|----------|-----------|------------|--------|------|--------|
| R-type      | `0110011` |    1      |   0     |   0      |   0       |    0       | 0      |  0   |  10    |
| I-type ALU  | `0010011` |    1      |   1     |   0      |   0       |    0       | 0      |  0   |  10    |
| lw          | `0000011` |    1      |   1     |   1      |   0       |    1       | 0      |  0   |  00    |
| sw          | `0100011` |    0      |   1     |   0      |   1       |    0       | 0      |  0   |  00    |
| beq (branch)| `1100011` |    0      |   0     |   0      |   0       |    0       | 1      |  0   |  01    |
| jal         | `1101111` |    1      |   0     |   0      |   0       |    0       | 0      |  1   |  00    | 

* for alu_op for branch, it checks if the two register are equal by subtracting them see if they equal zero, thats why FORCE SUB. 
* for jal, 00 just because it doesn't use ALU at all, PC + 4 and PC offsetting is done by PC logic not ALU. Same as the immediate offset for branch, handled by PC logic.


