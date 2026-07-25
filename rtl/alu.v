// alu.v
// ---------------------------------------------------------------------------
// Arithmetic Logic Unit for the RV32I single-cycle core.
//
// This is the FIRST module you should implement. It is small, self-contained,
// and it has a fully-written testbench (tb/tb_alu.v) waiting for it. Getting
// "ALL ALU TESTS PASSED" is your first milestone.
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

    // TODO: drive `result` with a combinational always block (case on alu_op).
    //   Hints:
    //   - Use `$signed(a)` / `$signed(b)` for SUB comparisons and SRA/SLT.
    //   - Shift amount is only the low 5 bits: b[4:0].
    //   - Give the case a `default` so `result` never latches.
    //
    // always @(*) begin
    //     case (alu_op)
    //         4'b0000: result = ... ;
    //         ...
    //         default: result = {WIDTH{1'b0}};
    //     endcase
    // end

    // TODO: assign `zero` from `result`.
    // assign zero = ...;

endmodule
