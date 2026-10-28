# Laboratory Report Template
## 977-220 Electronics and IoT — Week 2, Slot 5
### Vivado RTL Project, Behavioral Simulation, and Truth-Table Verification

**Reference:** https://github.com/komsan-k/977-220/tree/main/fpga-2026/week-2/slot-5  
**Student name:** ______________________________  
**Student ID:** ______________________________  
**Section / Group:** ______________________________  
**Date:** ______________________________  
**Vivado version:** ______________________________

---

## 1. Achievement

**Learning objectives:**
- Create a new Vivado RTL project and organize source and simulation files.
- Implement the combinational logic function **Y = (A AND B) OR C**.
- Write a testbench that exercises all eight combinations of three binary inputs.
- Run Vivado **XSim behavioral simulation** and inspect waveforms.
- Verify simulated outputs against the expected truth table.
- Use `$monitor` to report signal values in the simulation console.
- Replace manually written input stimuli with a `for` loop.

**Achievement summary (write 80–150 words):**

> [Describe what you designed, simulated, verified, and learned.]

---

## 2. Verilog/SystemVerilog Project URL (Shared)

**Shared GitHub repository URL:** [Paste URL]  
**Project or source folder:** [Paste path]  
**Vivado project name:** [Enter name]  
**Top design module:** [Enter module]  
**Testbench module:** [Enter module]

**Files included (edit as appropriate):**
- `[design_file].v` or `[design_file].sv` — circuit design
- `[testbench_file].v` or `[testbench_file].sv` — simulation stimulus
- `README.md` — project explanation and reproduction steps
- `results/` — waveform screenshots and console output evidence

> **Submission note:** Share the source/testbench and instructions needed to recreate the Vivado project. Do not rely solely on machine-specific project paths.

---

## 3. Results

### Task 1 — Create Vivado Project

**Objective:** Create a new Vivado RTL project.

| Project setting | Configuration used |
|---|---|
| Project name | |
| Project location | |
| Project type | RTL Project |
| HDL language | |
| Target board / FPGA part (if selected) | |
| Design sources added | |
| Simulation sources added | |
| Simulation tool | Vivado XSim |

**Evidence:** [Insert screenshot of the Vivado project, Sources panel, and selected top modules.]

**Result/observations:** [Briefly describe project creation and whether the files compiled successfully.]

### Task 2 — Design Basic Logic Circuit

**Objective:** Implement **Y = (A ∧ B) ∨ C**.

**Boolean expression:** `Y = (A & B) | C`

**Block or gate-level diagram:** [Insert diagram showing A and B feeding an AND gate, followed by OR with C, producing Y.]

**Your Verilog/SystemVerilog design:**

```verilog
// Paste your implemented design module here.
```

**Result/observations:** [Explain how the module realizes the equation.]

### Task 3 — Create Testbench

**Objective:** Generate all eight input combinations for A, B, and C.

**Your testbench (manual stimulus version):**

```verilog
// Paste your initial testbench here.
```

**Stimulus coverage:**

| Combination number | A | B | C | Stimulus generated? |
|---:|:---:|:---:|:---:|:---:|
| 0 | 0 | 0 | 0 | |
| 1 | 0 | 0 | 1 | |
| 2 | 0 | 1 | 0 | |
| 3 | 0 | 1 | 1 | |
| 4 | 1 | 0 | 0 | |
| 5 | 1 | 0 | 1 | |
| 6 | 1 | 1 | 0 | |
| 7 | 1 | 1 | 1 | |

**Evidence:** [Insert testbench code screenshot or simulation stimulus log.]

### Task 4 — Run Behavioral Simulation

**Objective:** Launch Vivado XSim and observe the waveform.

**Simulation setup:**

| Parameter | Value |
|---|---|
| Simulation top | |
| Run duration | |
| Stimulus interval | |
| Signals added to wave window | A, B, C, Y |
| Compile / elaboration status | |

**Waveform evidence:** [Insert labeled XSim waveform screenshot showing all eight input combinations and output Y.]

**Observations:** [Describe how Y responds to changes in A, B, and C.]

### Task 5 — Verify Truth Table

**Objective:** Compare simulated outputs with the expected truth table for `Y = (A & B) | C`.

| A | B | C | Expected Y | Simulated Y | Pass / Fail |
|:---:|:---:|:---:|:---:|:---:|:---:|
| 0 | 0 | 0 | 0 | | |
| 0 | 0 | 1 | 1 | | |
| 0 | 1 | 0 | 0 | | |
| 0 | 1 | 1 | 1 | | |
| 1 | 0 | 0 | 0 | | |
| 1 | 0 | 1 | 1 | | |
| 1 | 1 | 0 | 1 | | |
| 1 | 1 | 1 | 1 | | |

**Tests passed:** _____ / 8  
**Tests failed:** _____ / 8

**Verification summary:** [Explain whether the output matches the expected Boolean function in all cases, including any discrepancies and fixes.]

### Task 6 — Add `$monitor`

**Objective:** Display the current signal values in the XSim console when monitored signals change.

**Relevant `$monitor` implementation:**

```verilog
// Paste the $monitor code from your testbench here.
```

**Console evidence:** [Insert screenshot or a short excerpt of the XSim console output.]

| Checkpoint | Expected evidence | Observed evidence |
|---|---|---|
| Monitor enabled | A, B, C, and Y printed | |
| Input changes | Console reflects changed inputs | |
| Logic evaluation | Printed Y matches expected Y | |

**Observations:** [Discuss how console monitoring supplements waveform analysis.]

### Task 7 — Use a Loop

**Objective:** Replace manual input assignments with a `for` loop that covers all eight combinations.

**Your loop-based testbench:**

```verilog
// Paste your revised testbench with a for loop here.
```

**Comparison:**

| Criterion | Manual stimulus | `for` loop stimulus |
|---|---|---|
| Number of input combinations reached | | |
| Truth-table verification result | | |
| Ease of modification | | |
| Code length / readability | | |

**Evidence:** [Insert loop source code and a waveform or console screenshot confirming eight combinations.]

**Verification summary:** [Explain whether the loop-based version gives the same results as the manual testbench.]

### Overall Verification Summary

| Task | Deliverable | Completed? | Evidence reference |
|---|---|:---:|---|
| 1 | Vivado RTL project | | |
| 2 | Logic module | | |
| 3 | Eight-combination testbench | | |
| 4 | XSim waveform | | |
| 5 | Completed truth table | | |
| 6 | `$monitor` console log | | |
| 7 | Loop-based testbench | | |

**Overall result:** [Write 2–4 sentences summarizing successful verification, problems, and corrections.]

---

## 4. Discussion

Answer each question briefly, referring to your own results where possible.

1. **Vivado project:** Why are design sources and simulation sources organized separately?
2. **Boolean logic:** Under what conditions is `Y = (A & B) | C` equal to 1?
3. **Test coverage:** Why are there exactly eight combinations for three one-bit inputs?
4. **Behavioral simulation:** What information is available in XSim before the design is implemented on an FPGA?
5. **Truth-table verification:** Which test cases are most useful for distinguishing `(A & B) | C` from `A & (B | C)`?
6. **Waveforms:** How can a waveform reveal a missing stimulus combination or an incorrect output?
7. **Console monitoring:** What does `$monitor` display, and how does it differ from a simple one-time print?
8. **Testbench loops:** How does a `for` loop improve completeness and maintainability?
9. **Debugging:** If an output disagreed with the truth table, how did you locate and correct the error?
10. **Reflection:** How could the same project workflow be extended to a multiplexer, decoder, or adder?

**Final reflection (80–150 words):**

> [Summarize what Vivado/XSim contributed to your understanding of HDL design and verification.]

---

## Submission Checklist

- [ ] Student information is complete.
- [ ] GitHub project link is accessible.
- [ ] Task 1 project settings and screenshot are included.
- [ ] Task 2 HDL source and logic diagram are included.
- [ ] Task 3 testbench covers all eight input combinations.
- [ ] Task 4 XSim waveform includes A, B, C, and Y.
- [ ] Task 5 truth table is complete with Pass/Fail results.
- [ ] Task 6 `$monitor` code and console evidence are included.
- [ ] Task 7 loop-based testbench and comparison are included.
- [ ] All discussion questions and final reflection are answered.

**Reference lab:** https://github.com/komsan-k/977-220/tree/main/fpga-2026/week-2/slot-5
