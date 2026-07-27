// imm_gen.v
// ---------------------------------------------------------------------------
// Immediate generator. Extracts and sign-extends the immediate field from the
// instruction according to its format. RISC-V scrambles the immediate bits
// across the instruction word (this was a deliberate hardware simplification
// so the sign bit is always instr[31]); this module unscrambles them.
//
// Formats you need for the subset:
//   I-type (opcode 0010011, 0000011):  imm = {{20{instr[31]}}, instr[31:20]}
//   S-type (opcode 0100011):           imm = {{20{instr[31]}}, instr[31:25], instr[11:7]}
//   B-type (opcode 1100011):           imm = {{19{instr[31]}}, instr[31], instr[7],
//                                              instr[30:25], instr[11:8], 1'b0}
//   J-type (opcode 1101111):           imm = {{11{instr[31]}}, instr[31], instr[19:12],
//                                              instr[20], instr[30:21], 1'b0}
//
// Note B and J immediates are inherently even (low bit is 0) because branch
// and jump targets are 2-byte aligned.
// ---------------------------------------------------------------------------

module imm_gen (
    input  wire [31:0] instr, //bit width of instruction must be 32 bits to match with other numebrs in the system,
    output reg  [31:0] imm    //so you extend the number by padding it with 0(positive) or 1(if negative) due to 2's complement.
);
    wire [6:0] opcode = instr[6:0]; //the first 6 bits rep the operations of the imm.

always@(*) begin
    case(opcode)
        7'b0010011, 7'b0000011: imm = {{20{instr[31]}}, instr[31:20]}; // based on the imm op code, gather all scrambled imm number bits tgt to get the number.
        7'b0100011: imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
        7'b1100011: imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
        7'b1101111: imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};    
        default: imm = 32'b0; //always add default for combinational, since FF and register holds value so u don't need a default.
    endcase
end
       
endmodule
