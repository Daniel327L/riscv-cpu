// imm_gen.v
// ---------------------------------------------------------------------------
// Immediate generator. Extracts and sign-extends the immediate field from the
// instruction according to its format. RISC-V scrambles the immediate bits
// across the instruction word (this was a deliberate hardware simplification
// so the sign bit is always instr[31]); this module unscrambles them.
//
// Formats you need for the subset:
//   I-type (opcode 0010011, 0000011, 1100111):  imm = {{20{instr[31]}}, instr[31:20]}
//   S-type (opcode 0100011):           imm = {{20{instr[31]}}, instr[31:25], instr[11:7]}
//   B-type (opcode 1100011):           imm = {{19{instr[31]}}, instr[31], instr[7],
//                                              instr[30:25], instr[11:8], 1'b0}
//   J-type (opcode 1101111):           imm = {{11{instr[31]}}, instr[31], instr[19:12],
//                                              instr[20], instr[30:21], 1'b0} 
//
// Note B and J immediates are inherently even (low bit is 0) because branch
// and jump targets are 2-byte aligned.
//even thougth I'm only building a processor with strictly 4 byte aligned instruction, the program guarantees to give only multiples of 4 for immedaite offset
// ---------------------------------------------------------------------------

module imm_gen import riscv_pkg::*; (
    input  logic [31:0] instr, //bit width of instruction must be 32 bits to match with other numebrs in the system,
    output logic  [31:0] imm    //so you extend the number by padding it with 0(positive) or 1(if negative) due to 2's complement.
);
    opcode_e opcode;
    assign opcode = opcode_e'(instr[6:0]);


always_comb begin
    case(opcode)
        op_i, op_load, op_jalr: imm = {{20{instr[31]}}, instr[31:20]}; // based on the imm op code, gather all scrambled imm number bits tgt to get the number.
        op_store: imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
        op_branch: imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
        op_jal: imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
        op_LUI, op_AUIPC: imm = {instr[31:12], 12'b0};
        default: imm = '0; 
    endcase
end
       
endmodule
