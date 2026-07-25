# Single-Cycle RISC-V CPU (RV32I subset)

A single-cycle RISC-V processor core in Verilog, verified with self-checking
testbenches and deployed to an FPGA. This is the canonical "I want to do
processors" project: it forces you to write real RTL, build a real verification
harness, and produce a tangible hardware demo.

**The one-liner this earns you:** *"Designed and verified a RISC-V CPU core in
Verilog, deployed to FPGA."* That sentence, backed by a repo you can walk an
interviewer through for 20 minutes, is what moves you into the digital-design /
verification tier.

The datapath logic is intentionally left for **you** to write. The scaffold
gives you the structure, the interfaces, one fully-worked testbench, and the
build system — but the thinking (and therefore the interview stories) is yours.

---

## Quick start (do this tonight)

1. **Install the tools** (free, open source):
   - Ubuntu/Debian: `sudo apt install iverilog gtkwave`
   - macOS: `brew install icarus-verilog gtkwave`
   - Windows: use WSL2 + the apt command, or install `oss-cad-suite`.
2. **Run the ALU test:** `make test_alu` → it FAILS, because `rtl/alu.v` is
   empty. That failure is your starting line.
3. **Implement `rtl/alu.v`** until you see `ALL ALU TESTS PASSED`. That first
   green line is your foothold.
4. Then move on in order: `reg_file` → `imm_gen` → `control` → `alu_control` →
   memories → wire it all together in `cpu.v`.

You need **no hardware** for steps 1–3, or in fact for all of Weeks 1–2. The
board only comes in for the Week-3 demo.

---

## Repository layout

```
riscv-cpu/
├── README.md              this file
├── Makefile               make test_<module>, make wave_<module>, make cpu
├── rtl/                   the core — 8 module skeletons, ports defined, logic = TODO
│   ├── alu.v              arithmetic/logic unit          (start here)
│   ├── alu_control.v      refines control's alu_op into the ALU's 4-bit code
│   ├── control.v          main opcode decoder → datapath control signals
│   ├── reg_file.v         32×32 register file (x0 hardwired to 0)
│   ├── imm_gen.v          immediate extraction + sign-extension
│   ├── instr_mem.v        instruction memory (loads test/program.hex)
│   ├── data_mem.v         data memory for lw/sw
│   └── cpu.v              top-level datapath (wires modules; PC/muxes = TODO)
├── tb/
│   ├── tb_alu.v           FULLY WORKED self-checking testbench (your template)
│   └── tb_template.v      skeleton to copy for every other module
├── docs/
│   ├── control_signals.md control-signal table to fill in BEFORE coding control.v
│   └── devlog.md          bug-story log (fills your interview answers)
└── test/
    └── program.hex        starter smoke-test program
```

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
- **Milestone:** every leaf module passes its own testbench.

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

**Stretch (great follow-ups, mention them in interviews):** add `jalr`, `lui`,
`auipc`, and the full branch set; assemble larger programs with the RISC-V GNU
toolchain; then the big one — **pipeline it** (5-stage: IF/ID/EX/MEM/WB with
hazard detection and forwarding). The pipeline is the natural "what would you do
next" answer and shows you understand the hard part.

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

Draw your own version as you build — being able to redraw this from memory at a
whiteboard is exactly the interview skill this project trains.

---

## Instruction subset (v1 target)

R-type: `add sub and or xor sll srl sra slt sltu` ·
I-type: `addi andi ori xori slti sltiu slli srli srai` ·
Load: `lw` · Store: `sw` · Branch: `beq` (extend to `bne/blt/bge/bltu/bgeu`) ·
Jump: `jal`. This is enough to run real programs (loops, conditionals, memory).
`jalr/lui/auipc` are easy adds once the above works.

---

## Recommended board & toolchain

- **Board:** Digilent **Basys 3** (Artix-7 XC7A35T) — 16 switches, 16 LEDs,
  4-digit 7-segment, USB-JTAG + USB-UART on board, ~$124 with academic pricing.
  Ideal for showing a CPU's state without buying extra parts. The **Arty A7-35T**
  is an equally good same-chip alternative if you later want Ethernet/DDR3.
- **Simulation:** Icarus Verilog (`iverilog`/`vvp`) + GTKWave — Weeks 1–2.
- **Synthesis:** AMD **Vivado** Standard edition (free) — Week 3. Large install
  (~50–100 GB, wants 8 GB+ RAM), runs on your laptop.

---

## Interview prep — questions you'll actually get

Keep a real answer to each of these; the project gives you the material.

1. **"Walk me through your datapath."** Redraw the diagram above from memory and
   trace one instruction (e.g. `lw`) through every stage.
2. **"Why single-cycle, and what's the downside?"** Simple control, but the
   clock period is set by the slowest instruction's whole path (load: PC →
   imem → regfile → ALU → dmem → writeback). Pipelining fixes throughput.
3. **"How did you verify it?"** Self-checking testbenches per module, then a
   whole-core test asserting end state. Show `tb_alu.v` and a waveform.
4. **"Tell me about a hard bug."** Pull a concrete entry from `docs/devlog.md`:
   symptom → hypothesis → how you found it in the waveform → root cause → fix.
5. **"How is x0 handled?"** Hardwired to zero: writes ignored, reads return 0.
6. **"Logical vs arithmetic shift?"** `srl` zero-fills, `sra` sign-fills;
   in Verilog that's `>>` vs `>>>` on a `$signed` operand.
7. **"What would you do next?"** Pipeline it — and explain hazards (data hazards
   → forwarding/stalls; control hazards → branch handling). This answer alone
   signals you understand where the real difficulty lives.

---

## Verification is the point

The self-checking testbench pattern in `tb/tb_alu.v` is not busywork — it's the
exact skill co-op screeners for verification roles (often a lower bar than
design roles, same industry) look for. Write one for every module. "I verified
it" with waveforms to show beats "I built it" every time.

Ship the repo, put it at the top of your Projects section, drop a photo/clip of
the board running in your portfolio, and the digital-design conversations stop
being ones where you have nothing to point at.
