# Laboratory Report Template
## 977-220 Electronics and IoT — Week 3, Slot 12
### Vivado-8: Multiply–Accumulate (MAC) Design

**Reference:** https://github.com/komsan-k/977-220/tree/main/fpga-2026/week-3/slot-12

> **Report instructions:** Replace bracketed prompts with your own work. Include original HDL and testbench code, XSim waveform captures, and verification evidence. Report actual measurements rather than assuming a PASS result.

| Student name | Student ID | Section / Group | Date |
|---|---|---|---|
| [Name] | [ID] | [Section] | [Date] |

---

## 1. Achievement

After completing this laboratory, I can:

- Implement a sequential **multiply–accumulate (MAC)** circuit, `ACC <= ACC + A * B`.
- Explain the function of the accumulator register and the active clock edge.
- Implement and verify **reset** and **enable** controls.
- Write a testbench to apply three input pairs and verify the accumulated result of **32**.
- Construct a hierarchical MAC from separate **multiplier**, **adder**, and **accumulator** modules.
- Compare behavioral simulation and structural hierarchy, and interpret waveforms in Vivado XSim.

**Achievement summary:**

[Write 100–150 words describing your completed designs, successful tests, challenges, and skills gained.]

---

## 2. Verilog/SystemVerilog Project URL (Shared)

**GitHub repository URL:** [Paste URL]

**Vivado project / shared archive URL (if applicable):** [Paste URL]

**Top module name:** [Name]  
**FPGA board / device (if used):** [Board and part]  
**Vivado version:** [Version]

**Submitted project contents:**

- [ ] Sequential MAC RTL source
- [ ] Reset/enable MAC source
- [ ] Functional testbench(s)
- [ ] Hierarchical multiplier, adder, and accumulator source modules
- [ ] Hierarchical top-level MAC module
- [ ] Simulation waveforms and console outputs
- [ ] Vivado hierarchy / elaborated RTL schematic screenshots
- [ ] README with reproduction instructions

---

## 3. Results

### Task 2 — Sequential MAC

**Objective:** Implement a clocked accumulator:

$$
ACC_{n+1}=ACC_n+A_n\times B_n.
$$

**Design configuration:**

| Parameter | Value |
|---|---|
| Width of `A` | [ ] bits |
| Width of `B` | [ ] bits |
| Width of `ACC` | [ ] bits |
| Signed or unsigned arithmetic | [ ] |
| Clock / active edge | [ ] |
| Overflow handling (wrap, widen, saturate, etc.) | [ ] |

**3.1 Architecture diagram:**

[Insert a block diagram showing A/B → Multiplier → Adder → Accumulator register → ACC, with feedback from ACC into the adder.]

**Figure 1.** Sequential MAC datapath.

**3.2 RTL implementation:**

```systemverilog
// Paste your sequential MAC module here.
```

**3.3 Basic functional verification:**

| Clock event | A | B | A × B | Expected ACC | Simulated ACC | Pass/Fail |
|---|---:|---:|---:|---:|---:|---|
| Reset / initial state | — | — | — | 0 | | |
| First enabled update | 2 | 3 | 6 | 6 | | |
| Second enabled update | 4 | 5 | 20 | 26 | | |
| Third enabled update | 1 | 6 | 6 | 32 | | |

**3.4 Waveform:**

[Insert XSim waveform showing `clk`, `A`, `B`, and `ACC`, plus controls if present.]

**Figure 2.** Sequential MAC waveform.

**Task 2 verification summary:** [Describe findings and any mismatches.]

### Task 3 — Reset and Enable

**Objective:** Add `reset` and `enable` so that the accumulator resets to zero and updates only when enabled.

**Expected behavior** (assuming a synchronous, active-high reset; change this description if your design differs):

$$
ACC_{n+1}=\begin{cases}
0,&reset=1,\\
ACC_n+A_nB_n,&reset=0\text{ and }enable=1,\\
ACC_n,&reset=0\text{ and }enable=0.
\end{cases}
$$

**3.5 Reset/enable RTL:**

```systemverilog
// Paste your modified MAC module here.
```

**3.6 Control verification:**

| Test | Reset | Enable | Applied A, B | Expected behavior | Expected ACC | Simulated ACC | Pass/Fail |
|---|:---:|:---:|---|---|---:|---:|---|
| Reset | 1 | X | [ ] | Clear accumulator | 0 | | |
| Accumulate | 0 | 1 | 2, 3 | Add 6 | 6 | | |
| Hold | 0 | 0 | 4, 5 | Keep prior value | 6 | | |
| Resume | 0 | 1 | 4, 5 | Add 20 | 26 | | |
| Reset again | 1 | X | [ ] | Clear accumulator | 0 | | |

**3.7 Reset/enable waveform:**

[Insert screenshot showing `clk`, `reset`, `enable`, `A`, `B`, `ACC` and the hold/resume intervals.]

**Figure 3.** Reset and enable verification.

**Task 3 verification summary:** [Discuss when changes took effect relative to the clock and how disabled cycles were handled.]

### Task 4 — Testbench and ACC = 32

**Objective:** Verify the sequence `(2,3)`, `(4,5)`, `(1,6)` and confirm `ACC = 32` after exactly three enabled accumulation edges from an initial zero value.

**Manual calculation:**

$$
ACC_0=0,
\quad ACC_1=0+(2\times3)=6,
\quad ACC_2=6+(4\times5)=26,
\quad ACC_3=26+(1\times6)=32.
$$

**3.8 Testbench implementation:**

```systemverilog
// Paste your testbench. Apply inputs away from the active sampling edge.
// Include clock generation, reset, enable, and checking logic.
```

**3.9 Simulation results:**

| Cycle | Inputs (A, B) | Expected product | Expected ACC | Observed ACC | Status |
|---:|---|---:|---:|---:|---|
| 0 | Reset | — | 0 | | |
| 1 | (2, 3) | 6 | 6 | | |
| 2 | (4, 5) | 20 | 26 | | |
| 3 | (1, 6) | 6 | 32 | | |

**3.10 Console / self-check evidence:**

```text
[Paste your actual simulation log, including PASS/FAIL output.]
```

**3.11 XSim waveform:**

[Insert screenshot with three accumulation edges and `ACC = 32` clearly visible.]

**Figure 4.** Three-pair MAC test sequence.

**Task 4 verification summary:** [State whether all values matched and whether the testbench checked results automatically.]

### Task 7 — Hierarchical MAC

**Objective:** Reimplement the MAC using separate **multiplier**, **adder**, and **accumulator** modules.

**3.12 Module breakdown:**

| Module | Function | Inputs | Outputs |
|---|---|---|---|
| Multiplier | Compute `A × B` | [ ] | [ ] |
| Adder | Compute `ACC + product` | [ ] | [ ] |
| Accumulator register | Store new ACC on enabled clock edge | [ ] | [ ] |
| MAC top | Connect module instances | [ ] | [ ] |

**3.13 Module implementations:**

```systemverilog
// Paste multiplier, adder, and accumulator modules here.
```

**3.14 Hierarchical MAC top module:**

```systemverilog
// Paste the top-level code showing all module instances and signal connections.
```

**3.15 Vivado design hierarchy:**

[Insert Vivado Sources → Hierarchy screenshot that identifies the multiplier, adder, and accumulator instances.]

**Figure 5.** MAC module hierarchy.

**3.16 Elaborated schematic:**

[Insert Vivado Open Elaborated Design schematic showing datapath and ACC feedback.]

**Figure 6.** Hierarchical MAC RTL schematic.

**3.17 Behavioral vs. hierarchical verification:**

| Input sequence or control case | Expected ACC | Behavioral ACC | Hierarchical ACC | Match? |
|---|---:|---:|---:|---|
| Reset | 0 | | | |
| (2,3) | 6 | | | |
| (4,5) | 26 | | | |
| (1,6) | 32 | | | |
| Enable = 0 after reaching 32 | 32 | | | |

**Task 7 verification summary:** [Explain whether both implementations behaved identically and identify any differences in hierarchy or coding style.]

### 3.18 Overall Task Verification

| Task | Deliverable | Evidence provided | Result (Pass/Fail) |
|---|---|---|---|
| 2 | Sequential MAC | RTL, accumulator results, waveform | |
| 3 | Reset and enable | Control tests, waveform | |
| 4 | Testbench reaching ACC = 32 | Testbench, log, waveform | |
| 7 | Hierarchical MAC | Module sources, hierarchy, comparison | |

**Overall result:** [Summarize completed tests, errors, corrections, and final outcome.]

---

## 4. Discussion

Answer each question using observations from **your own** RTL and simulations.

1. How does a sequential MAC differ from a purely combinational multiplier and adder?
2. Why must the MAC include an accumulator register?
3. When does `ACC` change relative to the clock edge?
4. What is the purpose of a nonblocking assignment (`<=`) in the accumulator block?
5. How does `reset` affect the stored accumulator value?
6. What happens when `enable=0`, even if `A` and `B` change?
7. Show the manual calculation that results in `ACC=32` for `(2,3)`, `(4,5)`, `(1,6)`.
8. Why is it useful to apply input changes between the active clock edges in a testbench?
9. What are the benefits of separating the multiplier, adder, and accumulator into individual modules?
10. How did you confirm that the behavioral MAC and hierarchical MAC produced identical results?
11. What happens if the accumulator width is too small to represent the mathematical sum?
12. How could this MAC architecture be extended into a multi-cycle dot-product engine or a neural-network datapath?

**Final reflection:**

[Write 100–150 words about the MAC design workflow, verification lessons, and potential FPGA applications.]

---

## Submission Checklist

- [ ] Student identification and shared project URL completed.
- [ ] Task 2 RTL, design details, and simulation evidence included.
- [ ] Task 3 reset and enable controls verified.
- [ ] Task 4 testbench verifies all three pairs and final `ACC=32`.
- [ ] Task 7 provides separate multiplier, adder, accumulator, and top-level modules.
- [ ] Vivado hierarchy and elaborated schematic screenshots provided.
- [ ] Simulation waveforms and actual console outputs included.
- [ ] All result tables and Pass/Fail fields completed.
- [ ] Discussion questions answered.
- [ ] All figures captioned and readable.
