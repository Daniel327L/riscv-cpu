// alu_control.v
// ---------------------------------------------------------------------------
// Second-level ALU decoder. The main control unit (control.v) emits a coarse
// 2-bit `alu_op`; this module refines it into the 4-bit `alu_ctrl` code that
// alu.v understands (see the encoding table in alu.v).
//
// Coarse alu_op meaning (this is the contract with control.v):
//   2'b00  -> memory address / jump: force ADD
//   2'b01  -> branch: force SUB (so `zero` tells you if operands are equal)
//   2'b10  -> R-type / I-type ALU: decode further from funct3 (+ funct7 bit)
//
// For alu_op == 2'b10 you decode the real operation from funct3, and for the
// two ambiguous cases you also need funct7 bit 30 (passed in as funct7_5):
//   funct3   op (funct7_5=0 / funct7_5=1)
//   ------   ----------------------------
//   3'b000   ADD  / SUB           (SUB only when R-type & funct7_5=1)
//   3'b001   SLL
//   3'b010   SLT
//   3'b011   SLTU
//   3'b100   XOR
//   3'b101   SRL  / SRA           (SRA when funct7_5=1)
//   3'b110   OR
//   3'b111   AND
// ---------------------------------------------------------------------------

module alu_control (
    input  wire [1:0] alu_op,     // coarse selector from control.v
    input  wire [2:0] funct3,     // instr[14:12]
    input  wire       funct7_5,   // instr[30]  (distinguishes ADD/SUB, SRL/SRA)
    output reg  [3:0] alu_ctrl    // fine code consumed by alu.v
);

endmodule
