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
    
    reset = 0;
    #10 reset = 1;  
    repeat (50) @(posedge clk); //repeat @(posedge clk) delay 10 times
    $display("x1=%h  x2=%h  x3=%h  x4=%h",  dut.u4.regs[1],  dut.u4.regs[2],  dut.u4.regs[3],  dut.u4.regs[4]);
    $display("x8=%h  x9=%h  x10=%h x11=%h", dut.u4.regs[8],  dut.u4.regs[9],  dut.u4.regs[10], dut.u4.regs[11]);
    $display("x12=%h x13=%h",               dut.u4.regs[12], dut.u4.regs[13]);
    $display("x14=%h x15=%h x16=%h",        dut.u4.regs[14], dut.u4.regs[15], dut.u4.regs[16]);
    $display("x18=%h x22=%h x23=%h x24=%h", dut.u4.regs[18], dut.u4.regs[22], dut.u4.regs[23], dut.u4.regs[24]);
    $display("x25=%h x26=%h x28=%h x29=%h", dut.u4.regs[25], dut.u4.regs[26], dut.u4.regs[28], dut.u4.regs[29]);
    $display("x30=%h x31=%h",               dut.u4.regs[30], dut.u4.regs[31]);
    $finish;
    
end
endmodule 

