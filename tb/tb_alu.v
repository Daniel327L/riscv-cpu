// tb_alu.v  --  WORKED EXAMPLE testbench (this one is written FOR you)
// ---------------------------------------------------------------------------
// Study this file closely. It demonstrates the self-checking testbench pattern
// that every other module's testbench should copy:
//
//   1. Instantiate the DUT (device under test).
//   2. Define a `check` task that drives inputs, waits, compares against an
//      expected value, prints PASS/FAIL, and counts errors.
//   3. Call `check` many times covering normal cases AND edge cases.
//   4. At the end, print a single clear summary line and $finish.
//
// Run it with:  make test_alu
// Waveforms:    make wave_alu   (opens tb_alu.vcd in gtkwave)
//
// It will FAIL until you implement alu.v -- that failure is the starting line,
// not a problem. Make it say "ALL ALU TESTS PASSED".
// ---------------------------------------------------------------------------

`timescale 1ns/1ps

module tb_alu;

    // DUT interface signals.
    reg  [31:0] a, b;
    reg  [3:0]  alu_op;
    wire [31:0] result;
    wire        zero;

    integer errors = 0;
    integer tests  = 0;

    // ALU op encodings (must match rtl/alu.v).
    localparam [3:0] OP_ADD  = 4'b0000,
                     OP_SUB  = 4'b0001,
                     OP_AND  = 4'b0010,
                     OP_OR   = 4'b0011,
                     OP_XOR  = 4'b0100,
                     OP_SLL  = 4'b0101,
                     OP_SRL  = 4'b0110,
                     OP_SRA  = 4'b0111,
                     OP_SLT  = 4'b1000,
                     OP_SLTU = 4'b1001;

    // Instantiate the device under test.
    alu #(.WIDTH(32)) dut (
        .a      (a),
        .b      (b),
        .alu_op (alu_op),
        .result (result),
        .zero   (zero)
    );

    // ----- self-checking task ---------------------------------------------
    // Drive inputs, let combinational logic settle, compare result AND zero.
    task check; //function definition of check 
        input [3:0]  op;
        input [31:0] in_a;
        input [31:0] in_b;
        input [31:0] exp_result;
        begin
            alu_op = op;
            a      = in_a;
            b      = in_b;
            #1;  // allow combinational settle
            tests = tests + 1;
            if (result !== exp_result) begin  //!== check types and values
                errors = errors + 1;
                $display("FAIL  op=%b a=%h b=%h : result=%h expected=%h",
                         op, in_a, in_b, result, exp_result);
            end else if (zero !== (exp_result == 32'b0)) begin
                errors = errors + 1;
                $display("FAIL  op=%b a=%h b=%h : zero=%b but result=%h",
                         op, in_a, in_b, zero, result);
            end else begin
                $display("pass  op=%b a=%h b=%h -> %h (zero=%b)",
                         op, in_a, in_b, result, zero);
            end
        end
    endtask

    // ----- stimulus --------------------------------------------------------
    initial begin
        // dump waveforms for `make wave_alu`
        $dumpfile("tb_alu.vcd");
        $dumpvars(0, tb_alu);

        // ADD
        check(OP_ADD, 32'd5,        32'd7,        32'd12); //call functoin check, with the following input: op, in_a, in_b, exp_result
        check(OP_ADD, 32'hFFFFFFFF, 32'd1,        32'd0);        // wrap -> zero
        check(OP_ADD, 32'h7FFFFFFF, 32'd1,        32'h80000000); // overflow wraps

        // SUB
        check(OP_SUB, 32'd10,       32'd10,       32'd0);        // -> zero
        check(OP_SUB, 32'd3,        32'd5,        32'hFFFFFFFE);  // -2 two's comp

        // Bitwise
        check(OP_AND, 32'hF0F0F0F0, 32'h0FF00FF0, 32'h00F000F0);
        check(OP_OR,  32'hF0F0F0F0, 32'h0F0F0F0F, 32'hFFFFFFFF);
        check(OP_XOR, 32'hAAAAAAAA, 32'hFFFFFFFF, 32'h55555555);

        // Shifts (shift amount is low 5 bits of b)
        check(OP_SLL, 32'h00000001, 32'd4,        32'h00000010);
        check(OP_SRL, 32'h80000000, 32'd4,        32'h08000000); // logical: zero-fill
        check(OP_SRA, 32'h80000000, 32'd4,        32'hF8000000); // arithmetic: sign-fill
        check(OP_SLL, 32'h00000001, 32'd32,       32'h00000001); // uses b[4:0]=0 -> no shift

        // Set-less-than (signed)
        check(OP_SLT, 32'hFFFFFFFF, 32'd1,        32'd1);        // -1 < 1 -> 1
        check(OP_SLT, 32'd1,        32'hFFFFFFFF, 32'd0);        //  1 < -1 -> 0

        // Set-less-than (unsigned)
        check(OP_SLTU, 32'hFFFFFFFF, 32'd1,       32'd0);        // big < 1 -> 0
        check(OP_SLTU, 32'd1,        32'hFFFFFFFF, 32'd1);       // 1 < big -> 1

        // ----- summary -----------------------------------------------------
        $display("-------------------------------------------------");
        if (errors == 0)
            $display("ALL ALU TESTS PASSED  (%0d/%0d)", tests, tests);
        else
            $display("ALU TESTS FAILED: %0d of %0d failed", errors, tests);
        $display("-------------------------------------------------");
        $finish;
    end

endmodule
