`timescale 1ns/1ps


module tb_imm_gen;

wire [31:0] instruction;
wire [31:0] immediate; 

integer error = 0;
integer test = 0;

imm_gen dut(
.instr(instruction),
.imm(immediate)
);

test check( 
    input [32:0] instr_in,
    input [32:0] exp_result
);

always@(*) begin
    test = test+1;

    if(immediate !== exp_result) begin
        $display(FAIL opcode=%b )

    end


end







endmodule