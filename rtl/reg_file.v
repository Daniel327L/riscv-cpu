// reg_file.v
// ---------------------------------------------------------------------------
// 32 x 32-bit register file. Two asynchronous (combinational) read ports and
// one synchronous write port.
//
// The single most common bug here: x0. Register x0 is hardwired to zero in
// RV32I. Writes to it must be ignored, and reads of it must always return 0.
// Bake that in and you avoid an entire class of confusing failures later.
//
// Timing convention for this single-cycle core:
//   - Reads are combinational (rs1_data/rs2_data reflect the current addresses).
//   - Writes commit on the rising edge of clk when we == 1.
// ---------------------------------------------------------------------------

module reg_file (
    input  wire        clk,    
    input  wire        we,          // write enable
    input  wire [4:0]  rs1_addr,    //first input register address
    input  wire [4:0]  rs2_addr,    //second input register address
    input  wire [4:0]  rd_addr,     //which register to store the result of the operation
    input  wire [31:0] rd_data,     //result of operation on input 1 and 2
    output wire [31:0] rs1_data,    //first input 
    output wire [31:0] rs2_data     //second input
);

    // 32 architectural registers.
    reg [31:0] regs [31:0]; //reg type array consisting of elemenents with 32 bits width (left), 32 element in total (right)
                            //default as unkowns (X) by Verilog 

always @(posedge clk) begin

    if(we && rd_addr != 5'd0) begin
        regs[rd_addr] <= rd_data;
    end
       //don't need else statement here, since it uses a clock driven sequential block instead of latches that might ended up with inferred latches if don't
end

assign rs1_data = (rs1_addr != 5'd0) ? regs[rs1_addr] : 32'b0;  //in RISC-V, address 0 always rep b0 so that 
assign rs2_data = (rs2_addr != 5'd0) ? regs[rs2_addr] : 32'b0;  //arithemtic operation with 0 is easier to deal with

    
    integer i;
    initial for (i = 0; i < 32; i = i + 1) regs[i] = 32'b0; //initialize all register as 0 just for the sake of simulation

endmodule
