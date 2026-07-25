// tb_template.v  --  copy this to tb/tb_<module>.v and adapt.
// ---------------------------------------------------------------------------
// The same self-checking pattern as tb_alu.v, stripped to a skeleton. For a
// module named `foo`, save as tb/tb_foo.v and run `make test_foo`.
//
// For SEQUENTIAL modules (reg_file, data_mem) you need a clock: generate one
// with `always #5 clk = ~clk;` and drive writes on clock edges instead of #1.
// ---------------------------------------------------------------------------

`timescale 1ns/1ps

module tb_template;

    // TODO: declare regs for DUT inputs, wires for DUT outputs.
    // reg  [31:0] in_x;
    // wire [31:0] out_y;

    integer errors = 0;
    integer tests  = 0;

    // TODO: instantiate the DUT.
    // mymodule dut ( .x(in_x), .y(out_y) );

    // Self-checking task: adapt the port list + comparison.
    task check;
        // input [31:0] stim; input [31:0] expected;
        begin
            // drive inputs...
            #1;
            tests = tests + 1;
            // if (out_y !== expected) begin
            //     errors = errors + 1;
            //     $display("FAIL ... got=%h exp=%h", out_y, expected);
            // end else $display("pass ...");
        end
    endtask

    initial begin
        $dumpfile("tb_template.vcd");
        $dumpvars(0, tb_template);

        // TODO: call check(...) with normal + edge cases.

        $display("-------------------------------------------------");
        if (errors == 0) $display("ALL TESTS PASSED (%0d/%0d)", tests, tests);
        else             $display("TESTS FAILED: %0d of %0d", errors, tests);
        $display("-------------------------------------------------");
        $finish;
    end

endmodule
