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

module alu_control (
    input  wire [1:0] alu_op,     // coarse selector from control.v
    input  wire [2:0] funct3,     // instr[14:12]
    input  wire       funct7_5,   // instr[30]  (distinguishes ADD/SUB, SRL/SRA)
    output reg  [3:0] alu_ctrl    // fine code consumed by alu.v
);

always@(*) begin
    alu_ctrl = 4'b0;
    case(alu_op)
        2'b00: alu_ctrl = 4'b0;
        2'b01: alu_ctrl = 4'b1;
        2'b10: case(funct3) //funct3 code assignment is fixed by RISC-V
               3'b000: case(funct7_5)
                       1'b0: alu_ctrl = 4'b0;
                       1'b1: alu_ctrl = 4'b1;
                       endcase 
               3'b001: alu_ctrl = 4'b101;
               3'b010: alu_ctrl = 4'b1000;
               3'b011: alu_ctrl = 4'b1001;
               3'b100: alu_ctrl = 4'b100;
               3'b101: case(funct7_5)
                       1'b0: alu_ctrl = 4'b110;
                       1'b1: alu_ctrl = 4'b111;
                       endcase
               3'b110: alu_ctrl = 4'b11;
               3'b111: alu_ctrl = 4'b10;
               endcase
    endcase
end

endmodule

//no need to implement a tb, just a regular LUT :)