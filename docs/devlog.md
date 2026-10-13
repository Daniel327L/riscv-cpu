# Devlog

---

## [2026-07-26] - Time delay element in testbench involving register

**Symptom:** When I was running the testbench file `tb_reg_file.v` I notice that even though the expected value matches with my actual stored value in the targeted register, the result was a failure for some reason. 

**Hypothesis:** I initially thought I might have wrongly assumed what the output should be and thus the actual output should be the correct one

**Investigation:** I looked through the actual v file `reg_file.v` and see if the logic made sense, I followed each line of codes and at the end my assumption of the output was correct. Then I moved on to `tb_reg_file.v` and investigate if my testbench was actually functioning as intended. 

**Root cause:** The actual bug is missing time delay, because the module im testbenching relies on a clock line to continuous update its value, I have to add the appropriate time delay element in my testbench to ensure enough time to set up and hold. In this case, in my `test check()`, I first assigned the inputs of the the function check into inputs that goes to the instantiated `reg_file`, and then I added a `@(posedge clk)` line below that, next that I choose which register to read from and immediately evaluate the result with if-else statement below. However, that is excatly the problem, I didn't give enough time (t~setup) to allow the address to change before evaluating the output of the register at that address.

**Fix + lesson:** To fix this issue, I added a `#1;` line below that befor the if-else statement. It is a short line of code yet it is really significant in ensuring the functionality of my testbench. A takeaway from this is that when I'm dealing with syncrhonous deisgn and to testbench it correctly, I must pay attention to the delay element as well.

---

## [2026-10-12] - Implicit 1-bit wire truncated ALU result

**Symptom:** I was examining the waveform of the cpu at stage 3 when I noticed the arithmetic operation wasn't as expected, specifically, every value collapsed to either 0 or 1. However, the alu operation was correct despite this bug. For example, `add x3, x1, x2` didn't produce a 12 as expected, instead, it registers `a` as 1 and `b` as 1 which resulted in a 2 in the case of addition.

![](../Images/Implicite%201%20bit%20wire%20bug.png) 

**Hypothesis:** I thought there's error within the registers causing the address where the value should be read from is wrong.

**Investigation:** I looked at the waveform result more carefully and I discovered that there's mismatch between signal wires that were supposedely identical. To explain in more detail, the wire `rd_data` is assigned to `alu_result` which is assigned to `result`, therefore whatever shows up in `result` should match with the value in `rd_data`, which is not the case.

**Root cause:** Turns out I did not declare the wire `alu_result`, which by default in Verilog, it was created as 1-bit wire, therefore any odd number result would shows up as 1, and for even it would be 0. 

**Fix + lesson:** The fix for this is simple and self-explanatory, by declareing a 32 bit wire `alu_result`, it was able to capture the full 32 bit result from any operations. A takeaway from this is to always check for undeclared wires and signals, which is quite common to miss out. In addition, this also strenghens my root cause finding skills, by just carefully observing the result, I can pinpoint where the code went wrong. 

---
