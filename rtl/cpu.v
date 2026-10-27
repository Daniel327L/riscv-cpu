module cpu(
	input wire clk, reset, //input and output by default is wire
	input [4:0] debug_addr,
	output wire [31:0] instruction, pc_out, debug_data
);

assign pc_out = pc; 

reg [31:0] pc;
reg branch_taken;
reg [31:0] mem_data;
wire [3:0] byte_enable;
wire [31:0] write_data;


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

always@(*) begin
    mem_data = read_data;
    if(mem_read) begin
        case(instruction[14:12])
            3'b000: case(alu_result[1:0]) //lb - load byte
                        2'b00: mem_data = {{24{read_data[7]}}, read_data[7:0]};  
                        2'b01: mem_data = {{24{read_data[15]}}, read_data[15:8]};  
                        2'b10: mem_data = {{24{read_data[23]}}, read_data[23:16]};  
                        2'b11: mem_data = {{24{read_data[31]}}, read_data[31:24]};  
                    endcase
            3'b001: case(alu_result[1:0]) //lh - load half word
                        2'b00: mem_data = {{16{read_data[15]}}, read_data[15:0]};  
                        2'b10: mem_data = {{16{read_data[31]}}, read_data[31:16]};
                    endcase 
            3'b010: mem_data = read_data; //lw - load word
            3'b100: case(alu_result[1:0]) //lbu - unsigned
                        2'b00: mem_data = {24'b0, read_data[7:0]};
                        2'b01: mem_data = {24'b0, read_data[15:8]};
                        2'b10: mem_data = {24'b0, read_data[23:16]};
                        2'b11: mem_data = {24'b0, read_data[31:24]};
                    endcase 
            3'b101: case(alu_result[1:0]) //lhu - unsigned
                        2'b00: mem_data = {16'b0, read_data[15:0]}; 
                        2'b10: mem_data = {16'b0, read_data[31:16]}; 
                    endcase
        endcase
    end
end

assign byte_enable = instruction[14:12] == 3'b010 ? 4'b1111 :
                     instruction[14:12] == 3'b001 && alu_result [1:0] == 2'b00 ? 4'b0011:
                     instruction[14:12] == 3'b001 && alu_result [1:0] == 2'b10 ? 4'b1100:
                     instruction[14:12] == 3'b000 && alu_result [1:0] == 2'b00 ? 4'b0001:
                     instruction[14:12] == 3'b000 && alu_result [1:0] == 2'b01 ? 4'b0010:
                     instruction[14:12] == 3'b000 && alu_result [1:0] == 2'b10 ? 4'b0100:
                     instruction[14:12] == 3'b000 && alu_result [1:0] == 2'b11 ? 4'b1000:
                     4'b0000;
    
assign write_data = byte_enable == 4'b1111 ? rs2_data :
                    byte_enable == 4'b0011 || byte_enable == 4'b1100 ? {2{rs2_data[15:0]}} :
                    byte_enable == 4'b0001 || byte_enable == 4'b0010 || byte_enable == 4'b0100 || byte_enable == 4'b1000 ? {4{rs2_data[7:0]}} :
                    32'b0; 
                     

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
assign rd_data = mem_to_reg ? mem_data : 
                 jal || jalr ? pc + 32'd4 : //rd_data is the write back data, and it can store either the alu result or data read from memory
                 LUI ? immediate :
                 AUIPC ? pc + immediate :
                 alu_result; // but if it's jump that the write back is pc + 4; 



data_mem u7 (
.clk(clk),
.mem_read(mem_read),
.mem_write(mem_write),
.addr(alu_result), //alu_result is the address resulted from grabing a rs1_data, force add it with an immediate 
.write_data(write_data), //for sw, rs2_data = value to store in memory, rs1_data + immediate = address of that memory 
.read_data(read_data), //result from lw 
.byte_enable(byte_enable)
);



endmodule   