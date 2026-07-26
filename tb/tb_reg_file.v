`timescale 1ns/1ps

module tb_reg_file;

reg en;
reg [4:0] a1_addr, a2_addr, rdaddr;
reg [31:0] a1_data, a2_data, rddata; 

reg clk = 0; //initialize as 0, needs to be reg since it's gonna be in always block next line
 
always #5 clk = ~clk; //always means repeat forever, # 5 = delay 5 time unit, and flip clk level

integer error = 0;
integer test = 0;

reg_file dut(  //device under test
.clk(clk),
.we(en),
.rs1_addr(a1_addr),
.rs2_addr(a2_addr),
.rd_addr(rdaddr),
.rs1_data(a1_data),
.rs2_data(a2_data),
.rd_data(rddata)
);


task check ( //every initial, always, begin end block runs sequentially
    input we,
    input [4:0] rd_addr,
    input [31:0] rd_data,
    input [31:0]exp_result
);
    begin
        rdaddr = rd_addr; 
        en = we;
        rddata = rd_data;
        @(posedge clk); //this syrnchronize the test script with the reg_file, so stuff get loaded in reg_file
        #1; //1 time unit delay before reading from either rs1 or rs2
        a1_addr = rd_addr;
        test = test + 1;
        if(a1_data !== exp_result) begin
            $display ("FAIL enable=%d address=%d got=%h but expected=%h", we, rd_addr, rd_data, exp_result);
            error = error+1;
        end
        else begin
            $display ("PASS enable=%d address=%d got=%h --> expected=%h", we, rd_addr, rd_data, exp_result);
        end     
    end
endtask

//-----stimulus section--------------------------

initial begin
    $dumpfile("tb_reg_file.vcd");
    $dumpvars(0, tb_reg_file);

    $display("testing");


end





endmodule