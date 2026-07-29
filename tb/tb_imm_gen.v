`timescale 1ns/1ps


module tb_imm_gen;

reg [31:0] instruction; //reg if in a procedural block, think of it as storage that you can change values.
wire [31:0] immediate; //wire because not used in procedural block like initial, always and task, wire treat it as only a constant signal driven by smth.
reg [8*8-1:0] typ; //each char takes up 8 bits, so in here there's 8 char of space.

integer error = 0;
integer test = 0;

imm_gen dut(
.instr(instruction),
.imm(immediate)
);



task check;
    input [31:0] instr_in;
    input [31:0] exp_result;
begin
    test = test+1;
    instruction = instr_in; 
    #1;

    case (instr_in[6:0])
        7'b0010011, 7'b0000011: typ = "I-type";
        7'b0100011:             typ = "S-type";
        7'b1100011:             typ = "B-type";
        7'b1101111:             typ = "J-type";
        default:                typ = "UNKNOWN";
    endcase

    if(immediate !== exp_result) begin
        $display("<FAIL> opcode=%b (%0s): generated=%h but expected=%h", instr_in[6:0], typ, immediate, exp_result); //%s for string type
        error = error + 1;
    end
    else if(immediate == exp_result) begin
        $display("<PASS> opcode=%b (%0s): generated=%h --> expected=%h", instr_in[6:0], typ, immediate, exp_result);
    end
    else begin //just in case there is something I didn't account for.
        $display("<UNKOWN> opcode=%b (%0s): generated=%h and expected=%h", instr_in[6:0], typ, immediate, exp_result); 
    end

end

endtask

//------stimulus------
initial begin

    $dumpfile("tb_imm_gen.vcd"); //always put it inside initial block, else never get executing --> floating
    $dumpvars(0, tb_imm_gen);

    //I-type: 7'b0010011, 7'b0000011
    check( {12'h800, 13'h0, 7'b0010011}, 32'hFFFFF800); //imm = -800 or just 800 in hex form, placed at instr[31:20].
    check( {12'h0, 13'h0, 7'b0000011}, 32'h0 ); //imm = 0; 

    //S-type: 7'b0100011
    check({7'b1111111, 13'b0, 5'b11111, 7'b0100011}, 32'hFFFFFFFF);
    check({7'b0111111, 13'b0, 5'b11111, 7'b0100011}, 32'h000007FF);

    //B-type: 7'b1100011
    check( {7'b1110000, 13'b0, 5'b00001 ,7'b1100011}, {19'b1111111111111111111 ,12'hF00 ,1'b0});
    check( {7'b1000000, 13'b0, 5'b00000 ,7'b1100011}, {20'b11111111111111111111, 12'b0});

    //J-type: 7'b1101111
    check({20'b10000000000000000000, 12'b1101111}, {12'hFFF, 20'b0});
    check({20'b1, 12'b1101111}, 32'h1000);

    $display("-------------------------------------------------");
    $display ("Score: %0d/%0d", test-error, test); 
    
    if (error == 0)  
        $display("PASS");
    else
        $display("FAIL");
    
    $display("-------------------------------------------------");    
    $finish;  

end

endmodule