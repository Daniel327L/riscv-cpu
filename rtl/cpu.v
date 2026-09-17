module cpu(
input wire clk, reset,
output [31:0] instruction, pc_out
);

assign pc_out = pc; 
reg [31:0] pc;


always@(posedge clk) begin
    if(reset)begin
        pc <= pc + 32'd4; 
    end
    else begin
        pc <= 32'd0; //for pc, don't need to initialize before always block, since real hardware resets at power on.
    end
end 

instr_mem u1(
.addr(pc),
.instr(instruction)
);

endmodule   