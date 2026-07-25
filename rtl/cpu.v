// cpu.v
// ---------------------------------------------------------------------------
// Top-level single-cycle RV32I datapath. This file WIRES the leaf modules
// together and holds the program counter. The submodule instantiations are
// provided so everything "clicks" once you implement the leaf logic -- but the
// DATAPATH DECISIONS are left to you, because those are exactly what you'll be
// asked to explain in an interview:
//
//   1. The program counter register + reset behavior.
//   2. The next-PC logic (PC+4 vs branch/jump target).
//   3. The ALU-source mux    (rs2_data vs immediate).
//   4. The writeback mux      (ALU result vs memory data vs PC+4 for jal).
//   5. The branch-taken condition (uses `branch`, `jump`, funct3, and `zero`).
//
// Build the datapath diagram in the README as you fill these in.
// ---------------------------------------------------------------------------

module cpu (
    input  wire        clk,
    input  wire        rst,
    // Debug taps -- wire these to LEDs / 7-seg on the FPGA later.
    output wire [31:0] pc_debug,
    output wire [31:0] instr_debug
);

    // ----- Program counter -------------------------------------------------
    reg  [31:0] pc;
    wire [31:0] pc_next;      // TODO: you compute this below
    wire [31:0] pc_plus4 = pc + 32'd4;

    // TODO: PC register.
    //   always @(posedge clk) begin
    //       if (rst) pc <= 32'b0;
    //       else     pc <= pc_next;
    //   end

    // ----- Instruction fetch ----------------------------------------------
    wire [31:0] instr;

    instr_mem u_imem (
        .addr  (pc),
        .instr (instr)
    );

    // Instruction field breakouts (pure wiring -- provided for you).
    wire [6:0] opcode = instr[6:0];
    wire [4:0] rd     = instr[11:7];
    wire [2:0] funct3 = instr[14:12];
    wire [4:0] rs1    = instr[19:15];
    wire [4:0] rs2    = instr[24:20];
    wire       funct7_5 = instr[30];

    // ----- Control ---------------------------------------------------------
    wire       reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, jump;
    wire [1:0] alu_op;

    control u_control (
        .opcode     (opcode),
        .reg_write  (reg_write),
        .alu_src    (alu_src),
        .mem_read   (mem_read),
        .mem_write  (mem_write),
        .mem_to_reg (mem_to_reg),
        .branch     (branch),
        .jump       (jump),
        .alu_op     (alu_op)
    );

    // ----- Register file ---------------------------------------------------
    wire [31:0] rs1_data, rs2_data;
    wire [31:0] wb_data;      // writeback value (TODO: driven by writeback mux)

    reg_file u_regs (
        .clk      (clk),
        .we       (reg_write),
        .rs1_addr (rs1),
        .rs2_addr (rs2),
        .rd_addr  (rd),
        .rd_data  (wb_data),
        .rs1_data (rs1_data),
        .rs2_data (rs2_data)
    );

    // ----- Immediate -------------------------------------------------------
    wire [31:0] imm;

    imm_gen u_imm (
        .instr (instr),
        .imm   (imm)
    );

    // ----- ALU + ALU control ----------------------------------------------
    wire [3:0]  alu_ctrl;
    wire [31:0] alu_b;        // TODO: alu_src mux output
    wire [31:0] alu_result;
    wire        alu_zero;

    alu_control u_aluctl (
        .alu_op   (alu_op),
        .funct3   (funct3),
        .funct7_5 (funct7_5),
        .alu_ctrl (alu_ctrl)
    );

    alu u_alu (
        .a      (rs1_data),
        .b      (alu_b),
        .alu_op (alu_ctrl),
        .result (alu_result),
        .zero   (alu_zero)
    );

    // ----- Data memory -----------------------------------------------------
    wire [31:0] mem_rdata;

    data_mem u_dmem (
        .clk        (clk),
        .mem_read   (mem_read),
        .mem_write  (mem_write),
        .addr       (alu_result),
        .write_data (rs2_data),
        .read_data  (mem_rdata)
    );

    // ----- Datapath decisions (YOUR JOB) ----------------------------------
    // TODO 1: alu_b mux  -> assign alu_b = alu_src ? imm : rs2_data;
    // TODO 2: writeback mux -> choose among alu_result / mem_rdata / pc_plus4(jal)
    //         assign wb_data = ...;
    // TODO 3: branch decision. For beq, "take" when branch && alu_zero. Extend
    //         with funct3 for bne/blt/bge/bltu/bgeu once beq works.
    //         wire take_branch = ...;
    // TODO 4: next-PC mux -> branch/jump target = pc + imm; else pc_plus4.
    //         assign pc_next = (take_branch || jump) ? (pc + imm) : pc_plus4;

    // ----- Debug taps ------------------------------------------------------
    assign pc_debug    = pc;
    assign instr_debug = instr;

endmodule
