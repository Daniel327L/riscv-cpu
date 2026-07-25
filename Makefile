# Makefile -- iverilog + gtkwave build system for the RV32I single-cycle core.
#
# Quick start:
#   make test_alu     # compile + run the ALU testbench (fails until alu.v works)
#   make wave_alu     # open the ALU waveform in gtkwave
#   make cpu          # elaborate the whole core (checks it wires together)
#   make clean        # remove build artifacts
#
# Requires: iverilog, vvp, gtkwave  (all free, open source).
#   Ubuntu/Debian : sudo apt install iverilog gtkwave
#   macOS (brew)  : brew install icarus-verilog gtkwave
#   Windows       : use WSL2 + the apt command above, or oss-cad-suite.

IVERILOG := iverilog
VVP      := vvp
GTKWAVE  := gtkwave
IFLAGS   := -g2012 -Wall

RTL := rtl
TB  := tb
BUILD := build

# All RTL sources (used when elaborating the full CPU).
RTL_SRCS := $(wildcard $(RTL)/*.v)

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
	$(IVERILOG) $(IFLAGS) -o $(BUILD)/$*.vvp $(TB)/tb_$*.v $(RTL)/$*.v
	$(VVP) $(BUILD)/$*.vvp

# Open the waveform a test produced. Assumes the tb dumps tb_<name>.vcd.
wave_%:
	$(GTKWAVE) tb_$*.vcd &

# ---------------------------------------------------------------------------
# Whole-core elaboration. This does NOT run a program (you'll add tb_cpu.v in
# Week 3); it just proves every module compiles and connects. Great smoke test
# after you finish wiring cpu.v.
# ---------------------------------------------------------------------------
cpu: $(BUILD)
	$(IVERILOG) $(IFLAGS) -o $(BUILD)/cpu.vvp $(RTL_SRCS)
	@echo "cpu elaborated OK (all modules compile + connect)"

clean:
	rm -rf $(BUILD) *.vcd
