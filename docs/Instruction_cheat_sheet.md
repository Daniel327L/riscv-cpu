    === R-TYPE INSTRUCTIONS (Opcode: 0110011) ===
[x]  ADD   | funct3: 000 | funct7: 0000000       
[x]  SUB   | funct3: 000 | funct7: 0100000
[x]  SLL   | funct3: 001 | funct7: 0000000
[x]  SLT   | funct3: 010 | funct7: 0000000
[x]  SLTU  | funct3: 011 | funct7: 0000000
[x]  XOR   | funct3: 100 | funct7: 0000000
[x]  SRL   | funct3: 101 | funct7: 0000000
[x]  SRA   | funct3: 101 | funct7: 0100000
[x]  OR    | funct3: 110 | funct7: 0000000
[x]  AND   | funct3: 111 | funct7: 0000000

    === I-TYPE ALU INSTRUCTIONS (Opcode: 0010011) ===
[x]  ADDI  | funct3: 000 | funct7: N/A
[x]  SLTI  | funct3: 010 | funct7: N/A
[x]  SLTIU | funct3: 011 | funct7: N/A
[x]  XORI  | funct3: 100 | funct7: N/A
[x]  ORI   | funct3: 110 | funct7: N/A
[x]  ANDI  | funct3: 111 | funct7: N/A
[x]  SLLI  | funct3: 001 | funct7: 0000000 (Imm bits 31-25)
[x]  SRLI  | funct3: 101 | funct7: 0000000 (Imm bits 31-25)
[x]  SRAI  | funct3: 101 | funct7: 0100000 (Imm bits 31-25)

    === I-TYPE LOAD INSTRUCTIONS (Opcode: 0000011) ===
[]  LB    | funct3: 000 | funct7: N/A
[]  LH    | funct3: 001 | funct7: N/A
[x]  LW    | funct3: 010 | funct7: N/A
[]  LBU   | funct3: 100 | funct7: N/A
[]  LHU   | funct3: 101 | funct7: N/A

    === I-TYPE JUMP INSTRUCTION (Opcode: 1100111) ===
[x]  JALR  | funct3: 000 | funct7: N/A

    === I-TYPE SYSTEM INSTRUCTIONS (Opcode: 1110011) ===  *optional*
[]  ECALL  | funct3: 000 | funct7: N/A (Imm: 000000000000)
[]  EBREAK | funct3: 000 | funct7: N/A (Imm: 000000000001)
[]  CSRRW  | funct3: 001 | funct7: N/A
[]  CSRRS  | funct3: 010 | funct7: N/A
[]  CSRRC  | funct3: 011 | funct7: N/A
[]  CSRRWI | funct3: 101 | funct7: N/A
[]  CSRRSI | funct3: 110 | funct7: N/A
[]  CSRRCI | funct3: 111 | funct7: N/A

    === S-TYPE STORE INSTRUCTIONS (Opcode: 0100011) ===
[]  SB    | funct3: 000 | funct7: N/A
[]  SH    | funct3: 001 | funct7: N/A
[x]  SW    | funct3: 010 | funct7: N/A

    === B-TYPE BRANCH INSTRUCTIONS (Opcode: 1100011) ===
[x]  BEQ   | funct3: 000 | funct7: N/A
[x]  BNE   | funct3: 001 | funct7: N/A
[x]  BLT   | funct3: 100 | funct7: N/A
[x]  BGE   | funct3: 101 | funct7: N/A
[x]  BLTU  | funct3: 110 | funct7: N/A
[x]  BGEU  | funct3: 111 | funct7: N/A

    === J-TYPE JUMP INSTRUCTION (Opcode: 1101111) ===
[x]  JAL   | funct3: N/A | funct7: N/A

    === U-TYPE INSTRUCTIONS (Opcodes: 0110111 / 0010111) ===
[x]  LUI   | funct3: N/A | funct7: N/A (Opcode: 0110111)
[x]  AUIPC | funct3: N/A | funct7: N/A (Opcode: 0010111)
