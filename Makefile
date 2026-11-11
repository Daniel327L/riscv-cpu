IVERILOG := iverilog #Icarus
VVP      := vvp
GTKWAVE  := gtkwave
IFLAGS   := -g2012 -Wall

RTL := rtl
TB  := tb
BUILD := build

RVGCC     := riscv64-unknown-elf-gcc
RVOBJCOPY := riscv64-unknown-elf-objcopy
RVFLAGS   := -march=rv32i -mabi=ilp32 -nostdlib -nostartfiles -Ttext=0x0

# All RTL sources (used when elaborating the full CPU).
RTL_SRCS := $(RTL)/riscv_pkg.sv $(filter-out $(RTL)/riscv_pkg.sv,$(wildcard $(RTL)/*.sv))

# shared across both targets (Verilator)
VSRC   = rtl/riscv_pkg.sv $(filter-out rtl/riscv_pkg.sv,$(wildcard rtl/*.sv)) tb/tb_cpu.v
VFLAGS = --binary --timing -j 0 -Wno-fatal --top-module tb_cpu

.PHONY: all clean cpu
all: test_alu

$(BUILD):
	@mkdir -p $(BUILD)

# ---------------------------------------------------------------------------
# Per-module test target pattern.
#   make test_<name>   compiles tb/tb_<name>.v + rtl/<name>.v and runs it.
# For modules with dependencies (e.g. the full cpu), add them explicitly below.
# ---------------------------------------------------------------------------
test_%: $(BUILD)
	$(IVERILOG) $(IFLAGS) -o $(BUILD)/$*.vvp $(TB)/tb_$*.sv $(RTL)/$*.sv
	$(VVP) $(BUILD)/$*.vvp
	
test_cpu:  #because cpu module needs to instantiate all other 8 modules, so need special make command
	$(IVERILOG) $(IFLAGS) -o $(BUILD)/cpu.vvp $(TB)/tb_cpu.v $(RTL_SRCS)
	vvp build/cpu.vvp



# fast path — no trace, this is your everyday run
verilate:
	verilator $(VFLAGS) $(VSRC)
	./obj_dir/Vtb_cpu

# traced path — only when you need waveforms
wave:
	verilator $(VFLAGS) --trace --trace-structs $(VSRC)
	./obj_dir/Vtb_cpu
	gtkwave tb_cpu.vcd &

# Open the waveform a test produced. Assumes the tb dumps tb_<name>.vcd.
wave_%:
	"/mnt/c/Users/danie/Desktop/Work/gtkwave-3.3.100-bin-win64/gtkwave64/bin/gtkwave.exe" tb_$*.vcd &

# ---------------------------------------------------------------------------
# Whole-core elaboration. This does NOT run a program (you'll add tb_cpu.v in
# Week 3); it just proves every module compiles and connects. Great smoke test
# after you finish wiring cpu.v.
# ---------------------------------------------------------------------------
cpu: $(BUILD)
	$(IVERILOG) $(IFLAGS) -o $(BUILD)/cpu.vvp $(RTL_SRCS)
	@echo "cpu elaborated OK (all modules compile + connect)"
	
hex: $(BUILD)  #Turn assembly into EML (Executable and Linkable file), then binary then hex.
	$(RVGCC) $(RVFLAGS) -o $(BUILD)/$(PROG).elf test/$(PROG).s
	$(RVOBJCOPY) -O binary $(BUILD)/$(PROG).elf $(BUILD)/$(PROG).bin
	python3 scripts/bin2hex.py $(BUILD)/$(PROG).bin > test/$(PROG).hex
	@echo "wrote test/$(PROG).hex"

clean:
	rm -rf $(BUILD) *.vcd
