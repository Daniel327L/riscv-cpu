module cpu import riscv_pkg::*;(
	input logic clk, reset, 
	output logic [31:0] instruction_out, pc_out
);
               
assign pc_out = pc;
assign instruction_out = if_instruction;

if_id_s if_id; //put on top, because Quartus is upset that struct variable is used before it's declared.
id_ex_s id_ex;
ex_mem_s ex_mem; 
mem_wb_s mem_wb;

// ========================== IF stage =====================================================

logic [31:0] pc, if_instruction;

instr_mem u1(   //IF stages outputs pc, instruction and pc_plus4 to go into ID stage.
.addr(pc),
.instr(if_instruction)
);


//------------------------ branch prediction unit, mainly BTB------------------------------------------

btb_s btb [0:63]; //6 bits for btb
logic [1:0] bht_counter [0:127]; //means has 128 entries
logic [6:0] bht_index;
logic [5:0] btb_index;
logic btb_hit;
logic predict_taken;

logic mispredict;
logic [31:0]predicted_next_pc;

assign bht_index = pc[9:2];
assign btb_index = pc[7:2];
assign btb_hit = btb[btb_index].valid && (btb[btb_index].tag == pc[31:8]);

assign predict_taken = btb_hit && (btb[btb_index].is_cond ? bht_counter[bht_index][1] : '1 );
assign predicted_next_pc = predict_taken ? btb[btb_index].target : pc + 32'd4;



//------------------------- end of branch prediction unit ----------------------------------------------------

always_ff@(posedge clk) begin
    if(!reset)begin
        pc <= '0; 
    end else if(mispredict) begin
        pc <= actual_next_pc;     
    end else if(load_use_stall)begin 
        pc <= pc;
    end else begin 
        pc <= predicted_next_pc; 
    end
end


//============================ IF -> ID reg ===========================================

always_ff@(posedge clk) begin        
    if(!reset || mispredict) begin //redirect = IF and ID current instruction not used, so flush both pipeline reg.
        if_id <= '0;
        if_id.valid <= 0;
    end else if (load_use_stall) begin
        if_id <= if_id;
        if_id.valid <= 1;
    end else begin
        if_id.pc <= pc;
        if_id.instruction <= if_instruction;
        if_id.pc_plus4 <= pc + 32'd4;
        if_id.predicted_next_pc <= predicted_next_pc;
        if_id.valid <= 1;
    end
end

//============================ ID stage ============================================================

logic [31:0] immediate, rs1_data, rs2_data;
control_s ctrl;
opcode_e opcode;

logic wb_reg_write; //all 3 driven in WB stage
logic [31:0] wb_result;
logic [4:0] wb_addr;

//------------------------------- Load stall logic ------------------------------------

logic load_use_stall;
logic read_rs1, read_rs2;  //for checking do we actually read rs1 or rs2; 

assign load_use_stall = id_ex.ctrl.mem_read && 
                        id_ex.rd_addr != 0 &&
                        ( (read_rs1 && if_id.instruction[19:15] == id_ex.rd_addr) || 
                        (read_rs2 && if_id.instruction[24:20] == id_ex.rd_addr) );


always_comb begin
    read_rs1 = '1;
    read_rs2 = '1;
    case(opcode)
        op_i, op_load, op_jalr:     read_rs2 = '0;
        op_jal, op_LUI, op_AUIPC: begin 
                                    read_rs1 = '0;
                                    read_rs2 = '0;
                                  end
        default: ; //for op_r, op_store and op_branch 
    endcase
end

//----------------------------------- End of load stall logic ----------------------------------

logic R_type, I_type_sr, function7_5;
assign R_type = (opcode == op_r);
assign I_type_sr = ((opcode == op_i) && (if_id.instruction[14:12] == 3'b101)); //special case for I type alu for SRLI or SRAI
assign function7_5 = R_type || I_type_sr ? if_id.instruction[30] : 1'b0;

assign opcode = opcode_e'(if_id.instruction[6:0]);


imm_gen u2 (
.instr(if_id.instruction),
.imm(immediate)
);

control u3 (
.opcode(opcode),         
.ctrl(ctrl)
);

reg_file u4 (
.clk(clk),        
//Read section      
.rs1_addr(if_id.instruction[19:15]),    
.rs2_addr(if_id.instruction[24:20]),         
.rs1_data(rs1_data),
.rs2_data(rs2_data),
//write section
.we(wb_reg_write),  //ctrl.reg_write from wb
.rd_addr(wb_addr), 
.rd_data(wb_result)
);

//============================ ID -> EX reg ===================================================================

always_ff@(posedge clk) begin
    if(!reset || mispredict || load_use_stall)begin //load_use_stall insert a NO-OP bubble to stall for one cycle
        id_ex <= '0; 
        id_ex.valid <= 0;
    end
    else begin
        id_ex.immediate <= immediate;
        id_ex.rs1_addr <= if_id.instruction[19:15];  //both rs1 and rs2 has forwarding for WB already in reg unit
        id_ex.rs2_addr <= if_id.instruction[24:20]; 
        id_ex.rd_addr <= if_id.instruction[11:7]; 
        id_ex.rs1_data <= rs1_data;
        id_ex.rs2_data <= rs2_data; 
        id_ex.funct3 <= if_id.instruction[14:12];
        id_ex.funct7_5 <= function7_5;
        id_ex.pc <= if_id.pc;
        id_ex.pc_plus4 <= if_id.pc_plus4;
        id_ex.ctrl <= ctrl;
        id_ex.valid <= if_id.valid;
        id_ex.predicted_next_pc <= if_id.predicted_next_pc;
    end
end

//================================ EX stage ===============================================================================

logic [31:0] alu_a, alu_b, alu_result, read_data;
logic [31:0] ex_result; //ex_result is for any write back data
logic zero;
alu_e alu_sel;
logic branch_taken;
logic redirect;
logic [31:0] redirect_target;
logic [31:0] actual_next_pc;


//branch predictor write
logic [6:0] bht_wr;
logic [5:0] btb_wr;

// --------------- Forwarding unit for alu a and b ----------------------------

logic [31:0] frwd_rs1, frwd_rs2;

assign alu_a = frwd_rs1;
assign alu_b = id_ex.ctrl.alu_src ? id_ex.immediate : frwd_rs2;

always_comb begin 
    if(ex_mem.ctrl.reg_write && ex_mem.rd_addr == id_ex.rs1_addr && ex_mem.rd_addr != 0)
        frwd_rs1 = ex_mem.ex_result; 
    else if (mem_wb.ctrl.reg_write && mem_wb.rd_addr == id_ex.rs1_addr && mem_wb.rd_addr != 0)
        frwd_rs1 = mem_wb.wb_data;
    else
        frwd_rs1 = id_ex.rs1_data;
end

always_comb begin 
    if(ex_mem.ctrl.reg_write && ex_mem.rd_addr == id_ex.rs2_addr && ex_mem.rd_addr != 0)
        frwd_rs2 = ex_mem.ex_result; 
    else if (mem_wb.ctrl.reg_write && mem_wb.rd_addr == id_ex.rs2_addr && mem_wb.rd_addr != 0)
        frwd_rs2 = mem_wb.wb_data;
    else
        frwd_rs2 = id_ex.rs2_data;
    end

//this forwarding + the one in reg unit, covers all three cases of forwarding: ex_mem, mem_wb, wb_reg (for writing into rs1 or rs2 address)

//------------------ End of Forwarding units ----------------------------------------------

alu_control u5 (
.alu_op(id_ex.ctrl.alu_op),  
.funct3(id_ex.funct3),
.funct7_5(id_ex.funct7_5),
.alu(alu_sel)
);

alu u6 (
.alu_op(alu_sel),
.a(alu_a),
.b(alu_b),
.result(alu_result),
.zero(zero)
);

always_comb begin 
    branch_taken = '0;
    if(id_ex.ctrl.branch)begin
        case(id_ex.funct3)
            3'b000: branch_taken = zero; //beq
            3'b001: branch_taken = !zero; //bne
            3'b110: branch_taken = frwd_rs1 < frwd_rs2; //bltu (usigned)
            3'b111: branch_taken = frwd_rs1 >= frwd_rs2; //bgeu (usigned)
            3'b100: branch_taken = signed'(frwd_rs1) < signed'(frwd_rs2); //blt (signed) 
            3'b101: branch_taken = signed'(frwd_rs1) >= signed'(frwd_rs2); //bge (signed)
            default: ;
        endcase
    end
end

assign ex_result = id_ex.ctrl.jal || id_ex.ctrl.jalr ? id_ex.pc_plus4 :     
                   id_ex.ctrl.LUI ? id_ex.immediate :
                   id_ex.ctrl.AUIPC ? id_ex.pc + id_ex.immediate :
                   alu_result;


assign redirect_target = branch_taken ? id_ex.pc + id_ex.immediate : //imm is already sign extended in imm_gen
                         id_ex.ctrl.jal ? id_ex.pc + id_ex.immediate :
                         id_ex.ctrl.jalr ? (alu_a + id_ex.immediate) & ~ 32'b1 :
                         '0;

assign actual_next_pc = (branch_taken || id_ex.ctrl.jal || id_ex.ctrl.jalr) ? redirect_target :
                        id_ex.pc_plus4;
                        
assign mispredict = id_ex.valid && (actual_next_pc != id_ex.predicted_next_pc);

//--------------------------- Writing for branch predictor ---------------------------------------

assign bht_wr = id_ex.pc[11:2];
assign btb_wr = id_ex.pc[7:2];

always_ff@(posedge clk) begin
    if(id_ex.valid) begin //for BTB
        if((id_ex.ctrl.branch && branch_taken) || id_ex.ctrl.jal || id_ex.ctrl.jalr) begin
            btb[btb_wr].valid <= '1;
            btb[btb_wr].tag <= id_ex.pc[31:8];
            btb[btb_wr].target <= redirect_target;
            btb[btb_wr].is_cond <= id_ex.ctrl.branch; //check for conditional or not
        end
        if(id_ex.ctrl.branch) begin
            if(branch_taken) //for BHT
                bht_counter[bht_wr] <= (bht_counter[bht_wr] == 2'b11) ? bht_counter[bht_wr] :  bht_counter[bht_wr] +1 ;
            else
                bht_counter[bht_wr] <= (bht_counter[bht_wr] == 2'b00) ? bht_counter[bht_wr] :  bht_counter[bht_wr] -1 ;
        end 
    end
end

initial begin //initialize all valid bit as 0 
    for(int i = 0; i < 64; i++)
        btb[i].valid = '0; 
end

//------------------------------ End of branch predictor writing ------------------------------------------

//====================================== EX -> MEM reg =========================================================

always_ff@(posedge clk) begin
    if(!reset) begin
        ex_mem <= '0;
        ex_mem.valid <= 0;
    end
    else begin
        ex_mem.alu_result <= alu_result;
        ex_mem.ex_result <= ex_result;
        ex_mem.rs2_data <= frwd_rs2;
        ex_mem.rd_addr <= id_ex.rd_addr;
        ex_mem.funct3 <= id_ex.funct3;
        ex_mem.ctrl <= id_ex.ctrl;
        ex_mem.valid <= id_ex.valid;
    end
end

//====================================== MEM stage ==========================================================

logic [31:0] wb_data;
logic [31:0] mem_data;
logic [3:0] byte_enable;
logic [31:0] write_data;
logic [1:0] byte_sel;

assign byte_sel = ex_mem.alu_result[1:0];
assign wb_data = ex_mem.ctrl.mem_to_reg ? mem_data : ex_mem.ex_result;

assign write_data = byte_enable == 4'b1111 ? ex_mem.rs2_data :
                    byte_enable == 4'b0011 || byte_enable == 4'b1100 ? {2{ex_mem.rs2_data[15:0]}} :
                    byte_enable == 4'b0001 || byte_enable == 4'b0010 || byte_enable == 4'b0100 || byte_enable == 4'b1000 ? {4{ex_mem.rs2_data[7:0]}} :
                    32'b0; 

assign byte_enable = ex_mem.funct3 == 3'b010 ? 4'b1111 :
                     ex_mem.funct3 == 3'b001 && byte_sel == 2'b00 ? 4'b0011:
                     ex_mem.funct3 == 3'b001 && byte_sel == 2'b10 ? 4'b1100:
                     ex_mem.funct3 == 3'b000 && byte_sel == 2'b00 ? 4'b0001:
                     ex_mem.funct3 == 3'b000 && byte_sel == 2'b01 ? 4'b0010:
                     ex_mem.funct3 == 3'b000 && byte_sel == 2'b10 ? 4'b0100:
                     ex_mem.funct3 == 3'b000 && byte_sel == 2'b11 ? 4'b1000:
                     4'b0000;

always_comb begin
    mem_data = read_data;
    if(ex_mem.ctrl.mem_read) begin
        case(ex_mem.funct3)
            3'b000: case(byte_sel) //lb - load byte
                        2'b00: mem_data = {{24{read_data[7]}}, read_data[7:0]};  
                        2'b01: mem_data = {{24{read_data[15]}}, read_data[15:8]};  
                        2'b10: mem_data = {{24{read_data[23]}}, read_data[23:16]};  
                        2'b11: mem_data = {{24{read_data[31]}}, read_data[31:24]};  
                        default: ;
                    endcase
            3'b001: case(byte_sel) //lh - load half word
                        2'b00: mem_data = {{16{read_data[15]}}, read_data[15:0]};  
                        2'b10: mem_data = {{16{read_data[31]}}, read_data[31:16]};
                        default: ;
                    endcase 
            3'b010: mem_data = read_data; //lw - load word
            3'b100: case(byte_sel) //lbu - unsigned
                        2'b00: mem_data = {24'b0, read_data[7:0]};
                        2'b01: mem_data = {24'b0, read_data[15:8]};
                        2'b10: mem_data = {24'b0, read_data[23:16]};
                        2'b11: mem_data = {24'b0, read_data[31:24]};
                        default: ;
                    endcase 
            3'b101: case(byte_sel) //lhu - unsigned
                        2'b00: mem_data = {16'b0, read_data[15:0]}; 
                        2'b10: mem_data = {16'b0, read_data[31:16]}; 
                        default: ;
                    endcase
            default: ;
        endcase
    end
end


data_mem u7 (  //let read be async for now, chagne to sync when synthesizing to use BRAM for memory
.clk(clk),
.mem_read(ex_mem.ctrl.mem_read),
.mem_write(ex_mem.ctrl.mem_write), 
.addr(ex_mem.alu_result), 
.write_data(write_data), 
.read_data(read_data),  
.byte_enable(byte_enable)
);


//==================================== MEM -> WB reg ================================================================

always_ff@(posedge clk) begin
    if(!reset) begin
        mem_wb <= '0;
        mem_wb.valid <= 0;
    end
    else begin
        mem_wb.rd_addr <= ex_mem.rd_addr;
        mem_wb.wb_data <= wb_data;
        mem_wb.ctrl <= ex_mem.ctrl;
        mem_wb.valid <= ex_mem.valid;
    end
end

//====================================== WB stage ===================================================================

assign wb_reg_write = mem_wb.ctrl.reg_write;
assign wb_result = mem_wb.wb_data;
assign wb_addr = mem_wb.rd_addr;


endmodule   