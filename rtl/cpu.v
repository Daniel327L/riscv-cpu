module cpu(
	input wire clk, reset, //input and output by default is wire
	input [4:0] debug_addr,
	output wire [31:0] instruction, pc_out, debug_data
);

assign pc_out = pc; 
reg [31:0] pc;
reg branch_taken;

always@(posedge clk) begin
    if(!reset)begin
        pc <= 32'd0; 
    end
    else if ((branch_taken) || jal )  begin
        pc <= pc + immediate;
    end
    else if (jalr) begin
        pc <= (rs1_data + immediate) & ~32'b1;
    end
    else begin
        pc <= pc + 32'd4; 
    end
end 

always@(*) begin
    branch_taken = 1'b0;
    if(branch)begin
        case(instruction[14:12])
            3'b000: branch_taken = zero; //beq
            3'b001: branch_taken = !zero; //bne
            3'b110: branch_taken = rs1_data < rs2_data; //bltu (usigned)
            3'b111: branch_taken = rs1_data >= rs2_data; //bgeu (usigned)
            3'b100: branch_taken = $signed(rs1_data) < $signed(rs2_data); //blt (signed) 
            3'b101: branch_taken = $signed(rs1_data) >= $signed(rs2_data); //bge (signed)
        endcase
    end
end


instr_mem u1(
.addr(pc),
.instr(instruction)
);

wire [31:0] immediate, rd_data, rs1_data, rs2_data, alu_b, alu_result, read_data;
wire reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, jal, zero, jalr, LUI, AUIPC;
wire [1:0] alu_op;
wire [3:0] finer_alu_op;
wire R_type = (instruction[6:0] == 7'b0110011);
wire I_type_sr = ((instruction[6:0] == 7'b0010011) && (instruction[14:12] == 3'b101)); //special case for I type alu for SRLI or SRAI
wire function7_5 = R_type || I_type_sr ? instruction[30] : 1'b0;

imm_gen u2 (
.instr(instruction),
.imm(immediate)
);

control u3 (
.opcode(instruction[6:0]),         
.reg_write(reg_write),
.alu_src(alu_src),
.mem_read(mem_read),
.mem_write(mem_write),
.mem_to_reg(mem_to_reg),
.branch(branch),
.jal(jal),
.jalr(jalr),
.LUI(LUI),
.AUIPC(AUIPC),
.alu_op(alu_op)
);

reg_file u4 (
.clk(clk),    
.we(reg_write),          
.rs1_addr(instruction[19:15]),    
.rs2_addr(instruction[24:20]),    
.rd_addr(instruction[11:7]),    
.rd_data(rd_data), 
.rs1_data(rs1_data),
.rs2_data(rs2_data),
.debug_addr(debug_addr),
.debug_data(debug_data)
);

alu_control u5 (
.alu_op(alu_op),
.funct3(instruction[14:12]),
.funct7_5(function7_5),
.alu_ctrl(finer_alu_op)
);

alu u6 (
.alu_op(finer_alu_op),
.a(rs1_data),
.b(alu_b),
.result(alu_result),
.zero(zero)
);

assign alu_b = alu_src ? immediate : rs2_data; 
assign rd_data = mem_to_reg ? read_data : 
                 jal || jalr ? pc + 32'd4 : //rd_data is the write back data, and it can store either the alu result or data read from memory
                 LUI ? immediate :
                 AUIPC ? pc + immediate :
                 alu_result; // but if it's jump that the write back is pc + 4; 

data_mem u7 (
.clk(clk),
.mem_read(mem_read),
.mem_write(mem_write),
.addr(alu_result), //for lw, alu_result is the address resulted from grabing a rs1_data, force add it with an immediate 
.write_data(rs2_data), //for sw, rs2_data = value to store in memory, rs1_data + immediate = address of that memory 
.read_data(read_data) //result from lw 
);



endmodule   