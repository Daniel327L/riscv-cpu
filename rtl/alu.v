// alu.v
// ---------------------------------------------------------------------------
// Arithmetic Logic Unit for the RV32I single-cycle core.
//
//
// The `alu_op` encoding below is the contract the rest of the datapath relies
// on. alu_control.v produces these codes; do not change them without also
// updating alu_control.v and tb/tb_alu.v.
//
//   alu_op   operation        notes
//   ------   ---------        -----
//   4'b0000  ADD              a + b
//   4'b0001  SUB              a - b
//   4'b0010  AND              a & b
//   4'b0011  OR               a | b
//   4'b0100  XOR              a ^ b
//   4'b0101  SLL              a << b[4:0]        (shift amount = low 5 bits)
//   4'b0110  SRL              a >> b[4:0]        (logical, zero-fill)
//   4'b0111  SRA              a >>> b[4:0]       (arithmetic, sign-fill)
//   4'b1000  SLT              (signed)   result = ($signed(a) < $signed(b)) ? 1 : 0
//   4'b1001  SLTU             (unsigned) result = (a < b) ? 1 : 0
//
// `zero` must be 1 exactly when `result` == 0 (used by branch logic).
// ---------------------------------------------------------------------------

module alu #(
    parameter WIDTH = 32
) (
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire [3:0]       alu_op,
    output reg  [WIDTH-1:0] result,
    output wire             zero
);

always @(*) begin //combinational, level sensitive like latches
    case(alu_op) //parallel and faster than just if-else
        4'b0000: result = a+b; //block assignment since it's combinational
        4'b0001: result = a-b;
        4'b0010: result = a&b;
        4'b0011: result = a|b;
        4'b0100: result = a^b;
        4'b0101: result = a<<b[4:0]; //can only shift 32 bits at most
        4'b0110: result = a>>b[4:0];
        4'b0111: result = $signed(a)>>>b[4:0]; //fill vacated bits with the sign bits
        4'b1000: result = $signed(a) < $signed(b) ? 32'd1 : 32'd0; //32'd mactches wdith of result, d for decimal  
        4'b1001: result = a < b ? 32'd1 : 32'd0; 
        default: result = {WIDTH{1'b0}}; //repeat 1'b0 by WIDTH times, need both bracket to avoid syntax error
    endcase

end

    assign zero = (result == 0);

endmodule
