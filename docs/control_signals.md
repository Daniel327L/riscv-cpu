# Control Signal Table — fill this in BEFORE writing `control.v`

This table is the single best shortcut to a correct `control.v`. Work it out on
paper (or here) first; then the module is almost a direct transcription. Every
cell is either 0, 1, X (don't-care), or a 2-bit `alu_op` value.

`alu_op` legend (coarse selector for `alu_control.v`):
`00` = force ADD (address calc / jump) · `01` = force SUB (branch compare) ·
`10` = decode from funct3/funct7 (R/I-type ALU ops)

| instruction | opcode    | reg_write | alu_src | mem_read | mem_write | mem_to_reg | branch | jump | alu_op |
|-------------|-----------|-----------|---------|----------|-----------|------------|--------|------|--------|
| R-type      | `0110011` |           |         |          |           |            |        |      |        |
| I-type ALU  | `0010011` |           |         |          |           |            |        |      |        |
| lw          | `0000011` |           |         |          |           |            |        |      |        |
| sw          | `0100011` |           |         |          |           |            |        |      |        |
| beq (branch)| `1100011` |           |         |          |           |            |        |      |        |
| jal         | `1101111` |           |         |          |           |            |        |      |        |

## How to reason about each column

- **reg_write** — does this instruction produce a value that lands in a
  register? (Loads and ALU ops and jal do; stores and branches don't.)
- **alu_src** — is ALU operand B an immediate (1) or a register (0)? Loads,
  stores, and I-type use the immediate; R-type and branch use registers.
- **mem_read / mem_write** — only loads read, only stores write. Everything
  else is 0 (important: leaving mem_write asserted corrupts memory).
- **mem_to_reg** — for the value going back to the register file, is it from
  memory (1, loads) or the ALU (0, everything else)?
- **branch / jump** — flags the PC-update logic. Exactly one is set for
  control-flow instructions; both 0 otherwise.
- **alu_op** — see legend. Address calc for lw/sw and the target add for jal is
  `00`; branch compare is `01`; R/I-type is `10`.

Once the table is complete, `control.v` is a `case (opcode)` that sets these
outputs per row, starting from an all-zero default.
