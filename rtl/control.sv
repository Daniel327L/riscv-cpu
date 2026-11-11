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

module control import riscv_pkg::*; ( //import the packge and use * to include whatever is needed in here
    input  opcode_e opcode,
    output control_s ctrl
);

    always_comb begin
        ctrl = '0;
        case(opcode)
            op_r: begin //R-type
                ctrl.reg_write = 1'b1;
                ctrl.alu_op = aluop_r;
            end
            op_i: begin //I-type alu
                ctrl.reg_write = 1'b1;
                ctrl.alu_src = 1'b1;
                ctrl.alu_op = aluop_r;
            end
            op_load: begin //I-type load
                ctrl.reg_write = 1'b1;
                ctrl.alu_src = 1'b1;
                ctrl.mem_read = 1'b1;
                ctrl.mem_to_reg = 1'b1;
                ctrl.alu_op = aluop_add;
            end
            op_store: begin //S-type
                ctrl.alu_src = 1'b1;
                ctrl.mem_write = 1'b1;
                ctrl.alu_op = aluop_add;
            end
            op_branch: begin //B-type
                ctrl.branch = 1'b1;
                ctrl.alu_op = aluop_sub;
            end
            op_jal: begin //J-type
                ctrl.reg_write = 1'b1;
                ctrl.jal = 1'b1;
                ctrl.alu_op = aluop_add;
            end
            op_jalr: begin //for jalr
                ctrl.reg_write = 1'b1;
                ctrl.jalr = 1'b1;
                ctrl.alu_op = aluop_add;
            end
            op_LUI: begin //LUI - Load upper immediate
                ctrl.reg_write = 1'b1;
                ctrl.LUI = 1'b1;
            end
            op_AUIPC: begin //AUIPC - Add upper immediate to PC
                ctrl.AUIPC = 1'b1;
                ctrl.reg_write = 1'b1;
            end
            default: ;
        endcase
    end
   
endmodule
