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
//   funct3   op (funct7_5=0 / funct7_5=1) //unassigned bits in function 3 and 7 is for designer's extension or application specific purpsoe
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

module alu_control import riscv_pkg::*;(
    input  aluop_e alu_op,     // coarse selector from control.v
    input  logic [2:0] funct3,     // instr[14:12]
    input  logic       funct7_5,   // instr[30]  (distinguishes ADD/SUB, SRL/SRA, only for R type)
    output alu_e alu    // fine code consumed by alu.v
);

always_comb begin
    alu = alu_add;
    case(alu_op)
        aluop_add: alu = alu_add;
        aluop_sub: alu = alu_sub;
        aluop_r: case(funct3) //funct3 code assignment is fixed by RISC-V
               3'b000: case(funct7_5)
                       1'b0: alu = alu_add;
                       1'b1: alu = alu_sub;
                       endcase 
               3'b001: alu = alu_sll;
               3'b010: alu = alu_slt;
               3'b011: alu = alu_sltu;
               3'b100: alu = alu_xor;
               3'b101: case(funct7_5)
                       1'b0: alu = alu_srl;
                       1'b1: alu = alu_sra;
                       endcase
               3'b110: alu = alu_or;
               3'b111: alu = alu_and;
               endcase
    endcase
end

endmodule

//no need to implement a tb, just a regular LUT :)