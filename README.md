# Single-Cycle RISC-V CPU (RV32I subset)

A single-cycle RISC-V processor core in Verilog, verified with self-checking
testbenches and deployed to an FPGA. Also utilized RISC-V test suite verify my design.

---

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
- Pipeline it 
- Add a cache
- M-extensions / branch detectors 
