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

## [2026-11-11] - Fmax dropped after adding the branch predictor

**Symptom:** After adding the BTB + BHT branch predictor, CPI improved nicely (1.42 -> 1.30) but Fmax *dropped* from ~64 MHz to ~50 MHz, and kept sliding toward 44 MHz as I made changes. Net throughput actually went *down*. Something I added was sitting on the critical path.

![](../Images/Reg%20in%20M9K.png)
*The register file was being inferred into M9K (ALTSYNCRAM), with write-first bypass glue around it.*

**Hypothesis:** My first guess was fabric congestion — the BTB's big asynchronous LUT muxes crowding the chip. So I shrank the BHT, forced the register file in and out of M9K, converted memory toward BRAM... and Fmax barely moved, or got *worse*.

**Investigation:** I stopped guessing and read the Quartus Timing Analyzer critical path at every step. It kept pointing somewhere different than I expected, and each fix just exposed the *next* path underneath:
- Reg-file **write-first bypass** (`mem_wb.rd_addr -> id_ex.rs1_data`) — a combinational chain from the WB writeback value, through the register read, into the ID/EX reg.
- Forcing the reg file *out* of M9K made it *worse* (added fabric) — proof the problem wasn't the reg file's implementation.
- The data memory **wasn't inferring BRAM at all** — my byte-enable *slice* writes didn't match any template Quartus recognizes, so all 8k bits stayed in logic.
- The **mispredict 32-bit comparator** (`actual_next_pc != predicted`) stacked on the end of the branch-resolution path, right in the PC feedback loop.

**Root cause:** It was never one thing, and it was never congestion. It was a *stack* of combinational paths all converging on the PC / ID-EX register — dominated by the register-file write-first bypass and the mispredict comparator. The predictor added the comparator; the synchronous-memory restructure later added the WB byte-select into the forwarding path.

**Fix + lesson:** Three targeted fixes, each verified on the timing report:
1. **Negedge-write register file** — write on the falling edge so a distance-3 read sees the value without any combinational bypass. Deletes the `wb_data -> bypass -> id_ex` chain entirely.
2. **Byte-lane data memory** — four byte-wide arrays with per-lane enables and a registered read. Quartus finally inferred M9K (8,192 bits), freeing ~8,100 flops and halving logic.
3. **Direction-based mispredict** — precompute the comparisons from registered values and select with the 1-bit `branch_taken`, moving the 32-bit compare *off* the PC loop. `jalr` always-flushes (indirect target is late + rare).

Fmax went 44 -> 51.72 MHz. Lessons: (1) trust the timing report over intuition — I guessed the critical path wrong three times and the report was right every time; (2) Fmax costs are paid by *every* instruction while CPI costs only hit the instruction that triggers them, so never put rare-event logic (like jalr detection) on the critical path; (3) RAM inference is *template-matching*, not synthesis — write the vendor's exact template or it falls back to logic; (4) the honest architectural finding — a branch predictor doesn't pay for itself on a core that resolves branches in EX, because the resolution path *is* the clock limiter. Realizing its benefit needs early branch resolution or a deeper front end.

![](../Images/branch%20predictor%20fix%203.png)
*Final: Fmax 51.72 MHz, data memory in BRAM, logic usage halved.* 

---
