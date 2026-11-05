package riscv_pkg;

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
        logic [1:0]  alu_op;   
    } control_s;

endpackage