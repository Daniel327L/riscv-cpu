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
    input  wire [4:0]  rs1_addr,
    input  wire [4:0]  rs2_addr,
    input  wire [4:0]  rd_addr,
    input  wire [31:0] rd_data,
    output wire [31:0] rs1_data,
    output wire [31:0] rs2_data
);

    // 32 architectural registers.
    reg [31:0] regs [0:31];

    // TODO (reads): drive rs1_data / rs2_data combinationally, returning 0 when
    // the address is 0.
    //   assign rs1_data = (rs1_addr == 5'd0) ? 32'b0 : regs[rs1_addr];
    //   assign rs2_data = ...;

    // TODO (write): on posedge clk, if we and rd_addr != 0, write rd_data.
    //   always @(posedge clk) begin
    //       if (we && rd_addr != 5'd0)
    //           regs[rd_addr] <= rd_data;
    //   end

    // Optional but handy for simulation: initialize all registers to 0 so
    // waveforms don't start as X. (Synthesis on the FPGA ignores this.)
    integer i;
    initial for (i = 0; i < 32; i = i + 1) regs[i] = 32'b0;

endmodule
