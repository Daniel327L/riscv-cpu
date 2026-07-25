# Devlog

Keep this as you go. It costs two minutes per bug and it is the source of your
best interview answers. When a screener asks "tell me about a hard bug you
debugged," you want a specific, concrete story with a symptom, a hypothesis, and
a fix — not "um, I had some bugs." Each entry below becomes one of those.

Template to copy for each entry:

---

## [DATE] — one-line title

**Symptom:** what you observed (a failing test, a wrong value, a waveform that
looked off). Be specific: "SRA of 0x80000000 by 4 gave 0x08000000 instead of
0xF8000000".

**Hypothesis:** what you thought was wrong and why.

**Investigation:** how you narrowed it down (which signals you probed in
gtkwave, what you printed, what you changed to isolate it).

**Root cause:** the actual bug. (e.g. "used `>>` instead of `>>>`, so the shift
was logical not arithmetic; `>>>` on an unsigned reg is still logical, so I also
had to make the operand `$signed`.")

**Fix + lesson:** what you changed, and the general lesson so you don't repeat
the class of bug.

---

## Starter prompts (common bugs on this project, so you know what to watch for)

- x0 not hardwired to zero → mysterious nonzero reads.
- Off-by-4 memory indexing (using byte address as word index).
- Missing `default` in a case → inferred latch / X propagation.
- Logical vs arithmetic shift (`>>` vs `>>>`, and signedness of the operand).
- Branch immediate assembled wrong bit order → jumps to wrong target.
- mem_write left asserted on non-store instructions → memory corruption.
