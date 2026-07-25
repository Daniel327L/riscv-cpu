// control.v
// ---------------------------------------------------------------------------
// Main control unit. Decodes the 7-bit opcode into the datapath control
// signals. This is the module most worth planning on paper FIRST: fill in
// docs/control_signals.md completely, then this module is almost a
// transcription of that table.
//
// Opcodes in the RV32I subset this core targets:
//   7'b0110011  R-type   (add, sub, and, or, xor, sll, srl, sra, slt, sltu)
//   7'b0010011  I-type   (addi, andi, ori, xori, slti, sltiu, slli, srli, srai)
//   7'b0000011  load     (lw)
//   7'b0100011  store    (sw)
//   7'b1100011  branch   (beq, bne, blt, bge, bltu, bgeu)
//   7'b1101111  jal
//   (jalr / lui / auipc are good stretch goals once the above works)
//
// Signal meanings:
//   reg_write   write result back to the register file
//   alu_src     ALU operand B source: 0 = rs2_data, 1 = immediate
//   mem_read    data memory read enable  (load)
//   mem_write   data memory write enable (store)
//   mem_to_reg  writeback source: 0 = ALU result, 1 = memory read data
//   branch      instruction is a conditional branch
//   jump        instruction is an unconditional jump (jal)
//   alu_op      coarse selector for alu_control.v (see that file)
// ---------------------------------------------------------------------------

module control (
    input  wire [6:0] opcode,
    output reg        reg_write,
    output reg        alu_src,
    output reg        mem_read,
    output reg        mem_write,
    output reg        mem_to_reg,
    output reg        branch,
    output reg        jump,
    output reg [1:0]  alu_op
);

    // TODO: one combinational `case (opcode)` that sets every output for each
    // opcode above. Start every branch from a known-safe default (all zeros)
    // so you never accidentally leave a signal asserted:
    //
    //   always @(*) begin
    //       {reg_write, alu_src, mem_read, mem_write,
    //        mem_to_reg, branch, jump} = 7'b0;
    //       alu_op = 2'b00;
    //       case (opcode)
    //           7'b0110011: begin ... end   // R-type
    //           ...
    //       endcase
    //   end

endmodule
