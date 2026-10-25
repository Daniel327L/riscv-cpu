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
    output reg        jal, jalr,
    output reg        LUI, AUIPC,
    output reg [1:0]  alu_op
);

    always @(*) begin
        {reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, jal, jalr, LUI, AUIPC} = '0; //'0 autosize to whatever u have
        alu_op = 2'b0;
        case(opcode)
        7'b0110011: begin //R-type
            reg_write = 1'b1;
            alu_op = 2'b10;
        end
        7'b0010011: begin //I-type alu
            reg_write = 1'b1;
            alu_src = 1'b1;
            alu_op = 2'b10;
        end
        7'b0000011: begin //I-type load
            reg_write = 1'b1;
            alu_src = 1'b1;
            mem_read = 1'b1;
            mem_to_reg = 1'b1;
            alu_op = 2'b0;
        end
        7'b0100011: begin //S-type
            alu_src = 1'b1;
            mem_write = 1'b1;
            alu_op = 2'b0;
        end
        7'b1100011: begin //B-type
            branch = 1'b1;
            alu_op = 2'b01;
        end
        7'b1101111: begin //J-type
            reg_write = 1'b1;
            jal = 1'b1;
            alu_op = 2'b0;
        end
        7'b1100111: begin //for jalr
            reg_write = 1'b1;
            jalr = 1'b1;
            alu_op = 2'b0;
        end
        7'b0110111: begin //LUI - Load upper immediate
            reg_write = 1'b1;
            LUI = 1'b1;
        end
        7'b0010111: begin //AUIPC - Add upper immediate to PC
            AUIPC = 1'b1;
            reg_write = 1'b1;
        end
        endcase

    end
   
endmodule
