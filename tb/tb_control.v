`timescale 1ns/1ps

module tb_control;
reg [6:0]opcode;
wire reg_write;
wire alu_src;
wire mem_read;
wire mem_to_reg;
wire mem_write;
wire branch;
wire jump;
wire [1:0] alu_op;
reg [8*7-1:0]typ; 


control dut(
.opcode(opcode),
.reg_write(reg_write),
.alu_src(alu_src),
.mem_read(mem_read),
.mem_write(mem_write),
.mem_to_reg(mem_to_reg),
.branch(branch),
.jump(jump),
.alu_op(alu_op)
);

task display;

input [6:0] opcode_in;

begin 
    opcode = opcode_in;
    #1;
    case (opcode)
        7'b0110011:             typ = "R-type";
        7'b0010011, 7'b0000011: typ = "I-type";
        7'b0100011:             typ = "S-type";
        7'b1100011:             typ = "B-type";
        7'b1101111:             typ = "J-type";
        default:                typ = "UNKNOWN";
    endcase
    $display("%0s reg_write=%b alu_src=%b mem_read=%b mem_write=%b mem_to_reg=%b branch=%b jump=%b alu_op=%b"
            , typ, reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, jump, alu_op);
end

endtask

//-------checknig section-----
initial begin
$dumpfile("tb_control.vcd");
$dumpvars(0, tb_control);
$display();
display(7'b0110011);
display(7'b0010011);
display(7'b0000011);
display(7'b0100011);
display(7'b1100011);
display(7'b1101111);
$display();
$display("Just check it with the table you have:)");
$finish;
end


endmodule