`timescale 1ns/1ps


module tb_instr_mem;

wire [31:0]instr;
reg [31:0]addr;

instr_mem dut(
.addr(addr),
.instr(instr)
);

integer test = 0;
integer error = 0;

task check; 
    input [31:0]exp_result;
    input [31:0]addr_in;
    begin 
        test = test + 1;
        addr = addr_in;
        #1; 
        if(instr !== exp_result)begin
            error = error + 1;
            $display("<FAIL> addr=%d : instr=%h but expected=%h", addr[9:2], instr, exp_result);
        end
        else 
            $display("<PASS> addr=%d : instr=%h --> expected=%h", addr[9:2], instr, exp_result);
    end
endtask

//----------stimulus-----------

//below is the reference table to check
// instr       addr index 
//00500093         0
//00700113         1
//002081b3         2
//40110233         3   
//00302023         4
//00002283         5

initial begin
    $dumpfile("tb_instr_mem.vcd");
    $dumpvars(0, tb_instr_mem);

    check(32'h00500093, 32'h0);
    #1;
    check(32'h00700113, 32'h4);
    #1;
    check(32'h002081b3, 32'h8);
    #1;
    check(32'h40110233, 32'hc);
    #1;
    check(32'h00302023, 32'h10);
    #1;
    check(32'h00002283, 32'h14);


    $display("-------------------------------------------------");
    $display ("Score: %0d/%0d", test-error, test);  //the 0 in %0d control padding space, adjust this number for custom width that comes before the numbers
    
    if (error == 0)  
        $display("PASS");
    else
        $display("FAIL");
    
    $display("-------------------------------------------------");    
    $finish;
end

endmodule