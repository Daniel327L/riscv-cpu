`timescale 1ns/1ps

module tb_cpu;
reg reset = 1;
reg clk = 0;
wire [31:0]pc_out, instr;


always #5 clk = ~clk;

integer cycle = 0, retired_instr = 0;
reg done = 1'b0;


cpu dut(
.reset(reset),
.clk(clk),
.instruction_out(instr),
.pc_out(pc_out)
);

always@(posedge clk) begin
    $display("pc=%h instr=%h reset=%h", pc_out, instr, reset);
end

always @(posedge clk) begin
    if (reset && !done) begin                    // reset==1 = RUNNING (active-low)
        if (cycle > 20 && pc_out == 32'h08)
            done <= 1;                           // returned to halt → stop counting
        else begin
            cycle <= cycle + 1;
            if (dut.mem_wb.valid)
                retired_instr <= retired_instr + 1;
        end
    end
end

initial begin
    $dumpfile("tb_cpu.vcd");
    $dumpvars(0, tb_cpu);
    
    reset = 0;
    #10 reset = 1;  
    repeat (200) @(posedge clk); //repeat @(posedge clk) delay 10 times

    $display("x10=%h",  dut.u4.regs[10]);
    $display("cycle=%0d retired_instruction=%0d CPI=%0.3f", cycle, retired_instr, cycle*1.0/retired_instr);
    $finish;
end


endmodule 

