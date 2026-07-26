# Progress log

> #Day 1 - 2026-07-25

## Done 
- Finished building the Arithmetic Logic Unit or ALU in short (`alu.v`). Tsted with a dedicated testbench file (`tb_alu.v`), all 16 test passed. Wrote combinational case for all 10 alu ops; learned signed shifts + b[4:0] slicing. 
- Learned about how to write a testbench, element such as time delay (#1), $display format, $random, etc. (`tb_alu.v`)
- Sidenote: spent like 1 hour fighting a nasty two copies of the repo bug (OneDrive vs Desktop).
- Completed register portion (`reg_file.v`), basic application of sequential circuit knowledge from digital circuit course, aka ECE124.

![](Images/alu_test.png)
*ALU Passing*

## Doing 
- Working on testbench for register, (`tb_reg_file.v`), learning how to generate a periodic clock signal to test it since it contains synchronous logic. 

