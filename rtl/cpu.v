module cpu(
input wire clk, reset, //input and output by default is wire
output [31:0] instruction, pc_out
);

assign pc_out = pc; 
reg [31:0] pc;


always@(posedge clk) begin
    if(reset)begin
        pc <= pc + 32'd4; 
    end
    else begin
        pc <= 32'd0; //for pc, don't need to initialize before always block, since real hardware resets at power on.
    end
end 

instr_mem u1(
.addr(pc),
.instr(instruction)
);

wire [31:0] immediate, rd_data, rs1_data, rs2_data, alu_b, alu_result;
wire reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, jump, zero;
wire [1:0] alu_op;
wire [3:0] finer_alu_op;


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
.jump(jump),
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
.rs2_data(rs2_data)
);

alu_control u5 (
.alu_op(alu_op),
.funct3(instruction[14:12]),
.funct7_5(instruction[30]),
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
assign rd_data = alu_result; //not complete, but just for the sake of preventing floating rd_data, assign it to alu result for now.

endmodule   