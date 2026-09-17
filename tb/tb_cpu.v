`timescale 1ns/1ps

module tb_cpu;
reg reset = 1;
reg clk = 0;
wire [31:0]pc_out, instr;


always #5 clk = ~clk;


cpu dut(
.reset(reset),
.clk(clk),
.instruction(instr),
.pc_out(pc_out)
);

always@(posedge clk) begin
    $display("pc=%h instr=%h reset=%h", pc_out, instr, reset);
end

initial begin
    $dumpfile("tb_cpu.vcd");
    $dumpvars(0, tb_cpu);
    
    reset = 1;
    #12 reset = 0;
    #12 reset = 1;
    repeat (5) @(posedge clk); //repeat @(posedge clk) delay 10 times

    reset = 0;
    #12 reset = 1;
    repeat (5) @(posedge clk);
    $finish;
    
end
endmodule 

