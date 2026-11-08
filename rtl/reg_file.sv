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
    input  logic        clk,    
    input  logic        we,          // write enable
    input  logic [4:0]  rs1_addr,    //first  register address to extract value inside
    input  logic [4:0]  rs2_addr,    //second register address to extract value inside
    input  logic [4:0]  rd_addr,	 //which register to store rd_data
    input  logic [31:0] rd_data,     //values you want to store 
	input  logic [4:0]  debug_addr,
    output logic [31:0] rs1_data,    //first output 
    output logic [31:0] rs2_data,     //second output
	output logic [31:0] debug_data
);

    // 32 architectural registers.
    logic [31:0] regs [31:0]; //reg type array consisting of elemenents with 32 bits width (left), 32 element in total (right)
                            

always_ff@(posedge clk) begin 
    if(we && rd_addr != 5'd0) begin //logic here stays untouched
        regs[rd_addr] <= rd_data;
    end
end      

assign rs1_data = (rs1_addr == '0) ? '0 : //includes forwarding of WB data for both rs1 and 2 
                  (we && rd_addr == rs1_addr) ? rd_data :
                  regs[rs1_addr];

assign rs2_data = (rs2_addr == '0) ? '0 :
                  (we && rd_addr == rs2_addr) ? rd_data :
                  regs[rs2_addr];

assign debug_data = (debug_addr != 5'd0) ? regs[debug_addr] : 32'b0 ;

endmodule
