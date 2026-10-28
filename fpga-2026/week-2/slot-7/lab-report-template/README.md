# Laboratory Report Template
## 977-220 Electronics and IoT — Week 2, Slot 7
### Vivado Combinational Circuits: MUX, Decoder, Comparator, and Adders

**Reference laboratory:** https://github.com/komsan-k/977-220/tree/main/fpga-2026/week-2/slot-7  
**Selected tasks:** 3, 4, 5, 6, and 7

| Student name | Student ID | Section / Group | Date |
|---|---|---|---|
| | | | |

> **Instructions:** Complete each section using your own Vivado design and behavioral simulation results. Insert actual HDL, testbench excerpts, screenshots, and shared links. Do not mark a test *Pass* until the simulated output has been compared with the expected result. The provided tables are reference expectations, not measured results.

---

## 1. Achievement

**Learning objectives**

Upon completing this laboratory, I can:

- Implement a 2-to-1 multiplexer in Verilog/SystemVerilog.
- Implement a 2-to-4 one-hot decoder using a `case` statement.
- Design a 2-bit magnitude comparator with `A > B`, `A == B`, and `A < B` outputs.
- Implement and verify a half adder's `SUM` and `CARRY`.
- Implement a four-bit adder and verify the intended result width.
- Develop testbenches and analyze Vivado behavioral-simulation waveforms.
- Compare expected truth tables with actual results and document discrepancies.

**Achievement summary (write 80–120 words):**

[Describe the circuits completed, what was verified, and important skills learned.]

---

## 2. Verilog/SystemVerilog Project URL (Shared)

**GitHub project URL:** [Insert shared link]  
**Vivado project name:** [Insert project name]  
**Vivado version / simulator:** [Insert version, e.g., Vivado XSim]  
**Top-level design module(s):** [Insert module names]

**Files submitted:**

- [ ] RTL design files (`.v` / `.sv`)
- [ ] Simulation testbenches (`.v` / `.sv`)
- [ ] Simulation waveform screenshots
- [ ] Results tables and discussion
- [ ] Project `README.md` with instructions to reproduce tests

> Share source files and instructions. Large generated Vivado directories do not need to be committed unless requested by the instructor.

---

## 3. Results

### Task 3 — Multiplexer (2-to-1)

**Objective:** Select one of two input signals according to `S`.

**Expected function:** `Y = (~S & D0) | (S & D1)`.

**3.1 RTL source code**

```systemverilog
// Paste your implemented 2-to-1 multiplexer here.
```

**3.2 Testbench / stimulus generation**

```systemverilog
// Paste the relevant testbench here.
```

**3.3 Truth-table verification**

| S | D0 | D1 | Expected Y | Simulated Y | Pass/Fail |
|:-:|:-:|:-:|:-:|:-:|:-:|
| 0 | 0 | 0 | 0 | | |
| 0 | 0 | 1 | 0 | | |
| 0 | 1 | 0 | 1 | | |
| 0 | 1 | 1 | 1 | | |
| 1 | 0 | 0 | 0 | | |
| 1 | 0 | 1 | 1 | | |
| 1 | 1 | 0 | 0 | | |
| 1 | 1 | 1 | 1 | | |

**3.4 XSim waveform screenshot:** [Insert screenshot showing `S`, `D0`, `D1`, `Y`.]

**3.5 Verification summary:** [Describe behavior and failures, if any.]

### Task 4 — Decoder (2-to-4)

**Objective:** Implement a 2-to-4 one-hot decoder using a `case` statement.

**Assumption:** Active-high outputs indexed `Y[3:0]`.

**3.6 RTL source code**

```systemverilog
// Paste the decoder implementation using case here.
```

**3.7 Testbench / stimulus**

```systemverilog
// Paste the decoder testbench here.
```

**3.8 Truth-table verification**

| A[1:0] | Expected Y[3:0] | Simulated Y[3:0] | One-hot? | Pass/Fail |
|:--:|:--:|:--:|:--:|:--:|
| 00 | 0001 | | | |
| 01 | 0010 | | | |
| 10 | 0100 | | | |
| 11 | 1000 | | | |

**3.9 XSim waveform screenshot:** [Insert screenshot showing `A[1:0]` and `Y[3:0]`.]

**3.10 Verification summary:** [Explain whether exactly one output was asserted for each input.]

### Task 5 — Comparator (2-bit magnitude comparator)

**Objective:** Compare two unsigned 2-bit inputs `A[1:0]` and `B[1:0]`.

**Expected outputs:** `GT = (A > B)`, `EQ = (A == B)`, `LT = (A < B)`.

**3.11 RTL source code**

```systemverilog
// Paste your 2-bit comparator implementation here.
```

**3.12 Testbench / stimulus**

```systemverilog
// Paste the comparator testbench here.
```

**3.13 Representative verification cases**

| A (decimal) | B (decimal) | Expected GT | Expected EQ | Expected LT | Simulated GT/EQ/LT | Pass/Fail |
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| 0 | 0 | 0 | 1 | 0 | | |
| 0 | 1 | 0 | 0 | 1 | | |
| 1 | 0 | 1 | 0 | 0 | | |
| 1 | 1 | 0 | 1 | 0 | | |
| 1 | 2 | 0 | 0 | 1 | | |
| 2 | 1 | 1 | 0 | 0 | | |
| 2 | 3 | 0 | 0 | 1 | | |
| 3 | 2 | 1 | 0 | 0 | | |
| 3 | 3 | 0 | 1 | 0 | | |

**Exhaustive verification:** There are 4 × 4 = **16** input pairs.  
Number tested: [___ / 16] · Number passed: [___] · Number failed: [___].

**3.14 XSim waveform screenshot:** [Insert screenshot showing `A`, `B`, `GT`, `EQ`, `LT`.]

**3.15 Verification summary:** [Explain whether exactly one of `GT`, `EQ`, and `LT` was asserted for every valid pair.]

### Task 6 — Half Adder

**Objective:** Implement and simulate the half-adder outputs.

**Expected equations:** `SUM = A ^ B`; `CARRY = A & B`.

**3.16 RTL source code**

```systemverilog
// Paste the half-adder implementation here.
```

**3.17 Testbench / stimulus**

```systemverilog
// Paste the half-adder testbench here.
```

**3.18 Truth-table verification**

| A | B | Expected SUM | Expected CARRY | Simulated SUM | Simulated CARRY | Pass/Fail |
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| 0 | 0 | 0 | 0 | | | |
| 0 | 1 | 1 | 0 | | | |
| 1 | 0 | 1 | 0 | | | |
| 1 | 1 | 0 | 1 | | | |

**3.19 XSim waveform screenshot:** [Insert screenshot showing `A`, `B`, `SUM`, `CARRY`.]

**3.20 Verification summary:** [Describe when the sum and carry are asserted.]

### Task 7 — Four-Bit Adder

**Objective:** Implement `SUM = A + B` for unsigned four-bit inputs `A[3:0]`, `B[3:0]`.

**Output-width convention:** For this report, record the **full five-bit result `SUM[4:0]`** so a carry is not discarded. If your laboratory module uses a four-bit `SUM` and a separate `COUT`, record both and compare `{COUT, SUM}` with the five-bit expected value.

**3.21 RTL source code**

```systemverilog
// Paste your four-bit adder implementation here.
```

**3.22 Testbench / stimulus**

```systemverilog
// Paste your adder testbench here.
```

**3.23 Verification cases**

| A (dec) | B (dec) | Expected SUM (5-bit) | Expected SUM (dec) | Simulated SUM | Pass/Fail |
|:-:|:-:|:--:|:-:|:--:|:-:|
| 0 | 0 | 00000 | 0 | | |
| 1 | 2 | 00011 | 3 | | |
| 3 | 5 | 01000 | 8 | | |
| 7 | 8 | 01111 | 15 | | |
| 8 | 8 | 10000 | 16 | | |
| 10 | 5 | 01111 | 15 | | |
| 15 | 1 | 10000 | 16 | | |
| 15 | 15 | 11110 | 30 | | |

**Exhaustive verification (optional):** 16 × 16 = **256** operand pairs.  
Number tested: [___ / 256] · Number passed: [___] · Number failed: [___].

**3.24 XSim waveform screenshot:** [Insert screenshot showing `A[3:0]`, `B[3:0]`, and `SUM[4:0]` or `SUM[3:0]` plus `COUT`.]

**3.25 Verification summary:** [Explain result width, carry behavior, and any mismatches.]

### 3.26 Overall Verification Summary

| Task | Circuit | Cases Tested | Passed | Failed | Evidence / Screenshot |
|:--:|---|---:|---:|---:|---|
| 3 | 2-to-1 MUX | | | | |
| 4 | 2-to-4 Decoder | | | | |
| 5 | 2-bit Comparator | | | | |
| 6 | Half Adder | | | | |
| 7 | 4-bit Adder | | | | |

**Overall result:** [Summarize verified behavior, discrepancies, debugging, and final status.]

---

## 4. Discussion

Respond using evidence from your own implementations and simulation results.

**Task 3 — Multiplexer**

1. How does a 2-to-1 multiplexer select between `D0` and `D1`?
2. Which input changes caused `Y` to change in your simulation?

**Task 4 — Decoder**

3. Why does the 2-to-4 decoder use a one-hot output?
4. What is the role of the `case` statement? What should happen for all valid inputs?

**Task 5 — Comparator**

5. How do the `GT`, `EQ`, and `LT` signals describe the comparison result?
6. Why should exactly one comparator output be high for valid unsigned inputs?

**Task 6 — Half Adder**

7. Why is XOR used to generate `SUM`, while AND generates `CARRY`?
8. What is the output when `A = B = 1`?

**Task 7 — Four-Bit Adder**

9. Why can the sum of two four-bit unsigned operands require five bits?
10. What happens to the carry if the result is stored in only four bits?

**Simulation and Verification**

11. What is the difference between an RTL design and its testbench?
12. How did XSim waveforms help detect or rule out logic errors?
13. Why is exhaustive testing feasible for these small circuits?
14. What changes, if any, were needed before the designs passed verification?

**Final reflection (80–120 words):**

[Explain what you learned about combinational design, RTL coding, simulation, and verification.]

---

## Submission Checklist

- [ ] Student details completed
- [ ] Shared project link supplied
- [ ] Task 3 MUX RTL, testbench, truth table, and waveform included
- [ ] Task 4 decoder `case` design, one-hot verification, and waveform included
- [ ] Task 5 comparator RTL, comparisons, and waveform included
- [ ] Task 6 half-adder RTL, truth table, and waveform included
- [ ] Task 7 four-bit adder RTL, result-width explanation, and waveform included
- [ ] Overall results table completed with actual Pass/Fail counts
- [ ] Discussion questions and reflection completed

---

*This is a student-fillable report template for the five selected tasks. Expected outputs are supplied for comparison; simulation findings must be entered by the student.*
