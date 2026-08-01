`timescale 1ns/1ps

module tb_data_mem;

reg clk =0;
reg mem_read;
reg mem_write;
reg [31:0] write_data;
wire [31:0] read_data;
reg [31:0] addr;

always #5 clk = ~clk;

data_mem dut (
.clk(clk),
.mem_read(mem_read),
.mem_write(mem_write),
.write_data(write_data),
.read_data(read_data),
.addr(addr)
);

integer test = 0;
integer error = 0;

task check;
    input read, write; 
    input [31:0] data, address;
    input [31:0] exp;
 
    begin    
    test = test + 1;
    mem_write = write;
    write_data = data;
    addr = address;
    @(posedge clk);
    mem_read = read;
    #1;

    if(read_data !== exp) begin
        error = error + 1;
        $display("<FAIL> write=%d read=%d addr=%h write_data=%h : data=%h but expected=%h", write, read, addr, data, read_data, exp);
        end
    else
        $display("<PASS> write=%d read=%d addr=%h write_data=%h : data=%h --> expected=%h", write, read, addr, data, read_data, exp);
    
    end
endtask

//---------stimulus------

initial begin
    $dumpfile("tb_data_mem.vcd");
    $dumpvars(0, tb_data_mem);

    check(1,0, 32'hFFF, 32'd14, 32'h0);
    check(0,1, 32'hFFF, 32'd14, 32'h0);
    check(1,0, 32'hFFF, 32'd14, 32'hFFF);
    check(1,1, 32'hABC, 32'd14, 32'hABC);
    check(1,1, 32'hCBA, 32'd14, 32'hCBA);
    check(1,1,  32'hCDE, 32'd0, 32'hCDE);
    check(1,1, 32'HDEF, 32'd1024, 32'hDEF); //wraps around to address 0


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