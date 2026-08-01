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
    parameter DEPTH    = 256,  //256 is a deliberate choice, keep the memory small no need bigger
    parameter MEM_FILE = "test/program.hex" //parameter runs during compilation, cannot change during runtime
) (
    input  wire [31:0] addr, //address are written in byte form by the program, each address increment by 4 bytes
    output wire [31:0] instr
);

    reg [31:0] mem [0:DEPTH-1]; //mem is our actual memory, up to 256 instructions storing capability. 

    initial begin
        $readmemh(MEM_FILE, mem); //read each line of in MEM_FILE as hex (our instruction in hex), and put them into array slots in mem.
    end

    assign instr = mem[addr[9:2]]; // disregard first 2 bits to convert byte address into word index, so 4 --> 1, 8 -->2 , 12 -->3 so on
                                   //address sent by progrma can be huge, but here we only have 256 spot, so 8 bits will do (2^8 goes up to 256)
endmodule
