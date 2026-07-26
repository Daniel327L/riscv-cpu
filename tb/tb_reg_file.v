`timescale 1ns/1ps  //set time units and precision

module tb_reg_file;  //don't need (); since no real inputs and outputs or param, just reg type variables

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
    input [31:0] rd_data1,
    input [31:0] rd_data2,
    input [31:0]exp_result1,
    input [31:0]exp_result2
);
    begin
        rdaddr = rd_addr; 
        en = we;
        rddata = rd_data1;
        @(posedge clk); //this syrnchronize the test script with the reg_file, so stuff get loaded in reg_file
        #1; //1 time unit delay before reading from either rs1 or rs2
        a1_addr = rd_addr;
        rddata = rd_data2;
        rdaddr = rd_addr + 32'd1; //at rosl pf overflow, if rd_addr is 5'd31, then because it's 5 bits, the LSB 5 bits will become 0.
        @(posedge clk); 
        #1; //post clock delay 
        a2_addr = rd_addr + 32'd1;
        #1; //delay before heading to if-else evaluation
        test = test + 1;
        if((a1_data !== exp_result1) || (a2_data !== exp_result2)) begin
            $display ("FAIL we=%d addr=%d r1_in=%h r2_in=%h : r1=%h r2=%h but exp1=%h exp2=%h", we, rd_addr, rd_data1, rd_data2, 
            a1_data, a2_data, exp_result1, exp_result2);

            error = error+1;
        end
        else begin
            $display ("PASS we=%d addr=%d r1_in=%h r2_in=%h : r1=%h r2=%h ---> exp1=%h exp2=%h", we, rd_addr, rd_data1, rd_data2, 
            a1_data, a2_data, exp_result1, exp_result2);

        end     
    end
endtask

//-----stimulus section--------------------------

initial begin 
    $dumpfile("tb_reg_file.vcd"); //give a name to dump file for waveform
    $dumpvars(0, tb_reg_file); //0 means evlauate all things under the scope of tb_reg_file
    
    check (1, 5'd0, 32'd1111, 32'd2222, 32'd0, 32'd2222); //follows exact order of the check function
    check (1, 5'd10, 32'd15, 32'd16, 32'd15, 32'd16);
    check (0, 5'd10, 32'd5555, 32'd6666, 32'd15, 32'd16);

    $display("-------------------------------------------------");
    $display ("Score: %0d/%0d", test-error, test);  //the 0 in %0d control padding space, adjust this number for custom width that comes before the numbers
    
    if (error == 0)  
        $display("PASS");
    else
        $display("FAIL");
    
    $display("-------------------------------------------------");    
    $finish; //need this to terminate, or else clocks run indefinitely 
    end

endmodule