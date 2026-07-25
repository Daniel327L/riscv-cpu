// instr_mem.v
// ---------------------------------------------------------------------------
// Instruction memory (read-only during execution). Word-addressed internally.
// The program is loaded from a hex file at simulation start via $readmemh.
//
// The PC counts bytes (increments by 4), but this memory is an array of
// 32-bit words. So index it with addr[N:2] (drop the low 2 bits) rather than
// addr directly -- a classic off-by-4 bug if you forget.
//
// `MEM_FILE` defaults to the sample program in test/. Override it from the
// testbench with a defparam or parameter override to run other programs.
// ---------------------------------------------------------------------------

module instr_mem #(
    parameter DEPTH    = 256,                 // number of 32-bit words
    parameter MEM_FILE = "test/program.hex"
) (
    input  wire [31:0] addr,
    output wire [31:0] instr
);

    reg [31:0] mem [0:DEPTH-1];

    initial begin
        // $readmemh loads whitespace/newline-separated hex words into mem[].
        $readmemh(MEM_FILE, mem);
    end

    // TODO: word-align the byte address and read.
    //   assign instr = mem[addr[31:2]];   // (mask to log2(DEPTH) bits if needed)

endmodule
