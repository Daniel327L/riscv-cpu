# Devlog

---

## [2026-07-26] — Time delay element in testbench involving register

**Symptom:** When I was running the testbench file `tb_reg_file.v` I notice that even though the expected value matches with my actual stored value in the targeted register, the result was a failure for some reason. 

**Hypothesis:** I initially thought I might have wrongly assumed what the output should be and thus the actual output should be the correct one

**Investigation:** I looked through the actual v file `reg_file.v` and see if the logic made sense, I followed each line of codes and at the end my assumption of the output was correct. Then I moved on to `tb_reg_file.v` and investigate if my testbench was actually functioning as intended. 

**Root cause:** The actual bug is missing time delay, because the module im testbenching relies on a clock line to continuous update its value, I have to add the appropriate time delay element in my testbench to ensure enough time to set up and hold. In this case, in my `test check()`, I first assigned the inputs of the the function check into inputs that goes to the instantiated `reg_file`, and then I added a `@(posedge clk)` line below that, next that I choose which register to read from and immediately evaluate the result with if-else statement below. However, that is excatly the problem, I didn't give enough time (t~setup) to allow the address to change before evaluating the output of the register at that address.

**Fix + lesson:** To fix this issue, I added a `#1;` line below that befor the if-else statement. It is a short line of code yet it is really significant in ensuring the functionality of my testbench. A takeaway from this is that when I'm dealing with syncrhonous deisgn and to testbench it correctly, I must pay attention to the delay element as well.

---

## Starter prompts (common bugs on this project, so you know what to watch for)

- x0 not hardwired to zero → mysterious nonzero reads.
- Off-by-4 memory indexing (using byte address as word index).
- Missing `default` in a case → inferred latch / X propagation.
- Branch immediate assembled wrong bit order → jumps to wrong target.
- mem_write left asserted on non-store instructions → memory corruption.
