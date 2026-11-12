package riscv_pkg;

    typedef enum logic[3:0] { 
        alu_add = 4'b0000,
        alu_sub = 4'b0001,
        alu_and = 4'b0010,
        alu_or = 4'b0011,
        alu_xor = 4'b0100,
        alu_sll = 4'b0101,
        alu_srl = 4'b0110,
        alu_sra = 4'b0111,
        alu_slt = 4'b1000,
        alu_sltu = 4'b1001
    } alu_e;

    typedef enum logic [1:0] {
        aluop_add = 2'b00,
        aluop_sub = 2'b01,
        aluop_r = 2'b10
    } aluop_e;

    typedef enum logic [6:0] {  
        op_r = 7'b0110011,
        op_i = 7'b0010011,
        op_load = 7'b0000011,
        op_store = 7'b0100011,
        op_branch = 7'b1100011,
        op_jal = 7'b1101111,
        op_jalr = 7'b1100111,
        op_LUI = 7'b0110111,
        op_AUIPC = 7'b0010111
    } opcode_e;

    typedef struct packed {
        logic        reg_write;
        logic        alu_src;
        logic        mem_read;
        logic        mem_write;
        logic        mem_to_reg;
        logic        branch;
        logic        jal; 
        logic        jalr;
        logic        LUI;
        logic        AUIPC;
        aluop_e     alu_op;   
    } control_s;

//============================ Pipeline registers ===============================================================

    typedef struct packed {
        logic [31:0] pc;
        logic [31:0] pc_plus4;
        logic [31:0] instruction;
        logic [31:0] predicted_next_pc;
        bit valid;
    } if_id_s;

    typedef struct packed {
        logic [31:0] immediate;
        logic [4:0] rs1_addr, rs2_addr, rd_addr;
        logic [31:0] rs1_data, rs2_data;
        logic [2:0] funct3;
        logic funct7_5;
        logic [31:0] pc, pc_plus4;
        logic [31:0] predicted_next_pc;
        control_s ctrl;
        bit valid;
    } id_ex_s;

    typedef struct packed {
        logic [31:0] alu_result; //used for MEM address
        logic [31:0] ex_result;
        logic [31:0] rs2_data; //used for storing operation in MEM
        logic [4:0] rd_addr;
        logic [2:0] funct3;
        control_s ctrl;
        bit valid;
    } ex_mem_s;

    typedef struct packed {
        logic [4:0] rd_addr;
        logic [1:0] byte_sel;
        logic [31:0] ex_result;
        logic [2:0] funct3;
        control_s ctrl;
        bit valid;
    } mem_wb_s;

//============================ Branch predictor ==============================

    typedef struct packed {
        logic valid;
        logic [23:0] tag; //upper pc bit, since 6 pc bit is used for index
        logic [31:0] target; 
        logic is_cond; //if it's branch or jump
    } btb_s;

    //bht is only 2 bit entry = 2 bit saturating counter

endpackage