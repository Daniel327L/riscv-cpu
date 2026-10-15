# Single-Cycle RISC-V CPU (RV32I subset)

A single-cycle RISC-V processor core in Verilog, verified with self-checking
testbenches and deployed to an FPGA. Also utilized RISC-V test suite verify my design.

--- 

## 3-week milestone plan

Sized for "a few weeks, a few evenings each." Adjust freely.

### Week 1 — the pieces (pure simulation)
Build and unit-test the leaf modules. Each one gets its own self-checking
testbench modeled on `tb/tb_alu.v`.
- **Day 1–2:** `alu.v` → pass `tb_alu.v`. Fill in `docs/control_signals.md`.
- **Day 3:** `reg_file.v` (get x0 right) + a `tb_reg_file.v`.
- **Day 4:** `imm_gen.v` + `tb_imm_gen.v` (test I/S/B/J immediates).
- **Day 5:** `control.v` + `alu_control.v` from your filled-in table.
- **Milestone:** every leaf module passes its own testbench. //finished 

### Week 2 — the datapath (still simulation)
- Implement the memories (`instr_mem.v`, `data_mem.v`).
- Wire and complete `cpu.v`: PC register, next-PC logic, the ALU-source mux,
  the writeback mux, the branch decision. `make cpu` should elaborate clean.
- Write `tb/tb_cpu.v`: clock the core through `test/program.hex` and assert the
  expected end state (x1=5, x2=7, x3=12, x4=2, x5=12, mem[0]=12).
- **Milestone:** the core runs the smoke-test program correctly in simulation.
  This is the moment you "have a working CPU." Record it in the devlog.

### Week 3 — the FPGA demo
- Install Vivado (Standard edition, free). Create a project targeting your
  board's Artix-7 part.
- Write a small wrapper: slow the clock (a clock divider so you can see it step,
  or a button-press single-step), and route `pc_debug` / a chosen register to
  the LEDs and 7-segment display.
- Add a constraints (.xdc) file mapping those signals to physical pins.
- Synthesize, implement, generate bitstream, program the board.
- **Milestone:** your CPU steps through a program on real hardware, with values
  visible on the board. Film a 15-second clip for your portfolio.

---

## Datapath (the mental model)

```
        +----+   +------------+
   +--->| PC |-->| instr_mem  |--instr-->+------------------+
   |    +----+   +------------+          | field breakout   |
   |      ^                              | opcode,rd,rs1,rs2|
   |   next-PC mux                       | funct3, funct7   |
   |   (PC+4 / PC+imm)                   +---+----+----+----+
   |      ^                                  |    |    |
   |  take_branch/jump                       v    v    v
   |      |          +---------+        +----------------+
   |      |          | control |        |   reg_file     |
   |      |          +----+----+        | rs1_data rs2_data
   |      |               |             +----+-------+---+
   |      |         control signals          |       |
   |      |                                  |   +---(rs2)
   |      |          +---------+             |   |    |
   |      +----imm---| imm_gen |             |   v    v
   |                 +---------+             |  [alu_src mux]
   |                     |                   |     |
   |                     +--------imm------->|     v
   |                                         |   +-----+
   |                                       (rs1)-|  ALU |--result--+--> addr
   |                                             +-----+           |
   |                                               |zero           v
   |                                       branch decision   +-----------+
   |                                                          | data_mem  |
   |                                                          +-----+-----+
   |                                                                |read_data
   |                                          +---------------------+
   |                                          v
   |                                    [writeback mux]  (alu_result / mem / pc+4)
   |                                          |
   +------------------------------------------+--> reg_file.rd_data
```

---

### Future Plans:
- Pipeline it after finishing single cycle
- Add a cache
- M-extensions / branch detectors 
