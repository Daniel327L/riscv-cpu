// data_mem.v
// ---------------------------------------------------------------------------
// Data memory for lw / sw. Synchronous write, combinational (async) read --
// the standard arrangement for a single-cycle core so a load completes within
// the same cycle.
//
// Like instr_mem, this is word-addressed: use addr[N:2]. This subset only
// implements full-word lw/sw (no lb/lh/sb/sh), which keeps byte-lane logic out
// of scope for v1.
// ---------------------------------------------------------------------------

module data_mem #(
    parameter DEPTH = 256                 //256 is a deliberate choice, keep the memory small no need bigger
) (
    input  wire        clk,
    input  wire        mem_read,
    input  wire        mem_write,
    input  wire [31:0] addr,
    input  wire [31:0] write_data,
    output wire [31:0] read_data
);

    reg [31:0] mem [0:DEPTH-1];

    always@(posedge clk) begin
        if(mem_write)
            mem[addr[9:2]] <= write_data; //loading must be syncrhonized 
    end

    assign read_data = mem_read ? mem[addr[9:2]] : 32'b0; //simple logic for reading

    integer i = 0;
    
    initial begin  //initialize all data as 0 
    for(i = 0; i < DEPTH; i = i + 1)  
        mem[i] = 32'b0;
    end

endmodule
