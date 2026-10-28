# Laboratory Report Template
## 977-220 Electronics and IoT — Week 3, Slot 9
### Hierarchical Four-Bit Ripple-Carry Adder (Vivado / Nexys A7)

**Student name:** ____________________  
**Student ID:** ____________________  
**Date:** ____________________  

**Laboratory reference:** https://github.com/komsan-k/977-220/tree/main/fpga-2026/week-3/slot-9

> Complete **Tasks 3, 4, 5, and 7** only. Insert your own source files, screenshots, test data, and observations. Do not mark an item PASS without evidence. Pin numbers and board mappings must come from the actual board's master XDC and your implemented constraints.

---

## 1. Achievement

**Learning objectives**

- Build a 4-bit ripple-carry adder hierarchically from **four full-adder instances**.
- Recognize the top-level module and its submodules in Vivado's hierarchy view.
- Trace `CIN → C1 → C2 → C3 → COUT` in the elaborated RTL schematic.
- Implement and test an FPGA design in which **switches supply the operands and LEDs display outputs**.

**Achievement summary (5–8 sentences):**  
[Describe what was designed, simulated, synthesized/implemented, and observed on the FPGA.]

---

## 2. Verilog/SystemVerilog 


**Project checklist:**

- [ ] Source HDL files (full-adder module and 4-bit adder top module)
- [ ] Testbench and simulation evidence
- [ ] XDC constraints for switches and LEDs
- [ ] Hierarchy and elaborated RTL screenshots
- [ ] Implementation / bitstream / hardware-testing evidence

---

## 3. Results

### Task 3 — Four-Bit Adder (Four Full-Adder Instances)

**Objective:** Implement a 4-bit ripple-carry adder with four instantiated full adders.

**Design interface**

| Signal | Direction | Width | Description |
|---|---|---:|---|
| `A[3:0]` | Input | 4 | First operand |
| `B[3:0]` | Input | 4 | Second operand |
| `CIN` | Input | 1 | Initial carry-in |
| `SUM[3:0]` | Output | 4 | Four-bit sum |
| `COUT` | Output | 1 | Final carry-out |

**Source code — full-adder module:**

```systemverilog
// Paste your full-adder source code here.
```

**Source code — top-level 4-bit adder:**

```systemverilog
// Paste your hierarchical 4-bit adder code here.
// Show all four full-adder instances and the carry connections.
```

**Instance and carry mapping**

| Bit stage | Full-adder instance name | Carry input | Carry output |
|---|---|---|---|
| 0 | [name] | `CIN` | `C1` |
| 1 | [name] | `C1` | `C2` |
| 2 | [name] | `C2` | `C3` |
| 3 | [name] | `C3` | `COUT` |

**Functional verification** — the expected *five-bit unsigned result* is `A + B + CIN`, with `{COUT, SUM}` as the outputs.

| A (decimal) | B (decimal) | CIN | Expected `{COUT,SUM}` (5 bits) | Simulated `{COUT,SUM}` | Pass/Fail |
|---:|---:|:---:|:---:|:---:|:---:|
| 0 | 0 | 0 | `00000` | | |
| 3 | 5 | 0 | `01000` | | |
| 7 | 8 | 1 | `10000` | | |
| 15 | 0 | 0 | `01111` | | |
| 15 | 15 | 0 | `11110` | | |
| 15 | 15 | 1 | `11111` | | |
| [custom] | [custom] | [0/1] | | | |

**Figure 1 — Functional simulation waveform:**  
[Insert screenshot showing A, B, CIN, SUM, COUT, and the relevant carry signals.]

**Task 3 verification summary:**  
[Explain whether the expected five-bit results matched the simulation.]

### Task 4 — Hierarchy Verification

**Objective:** Open the Vivado hierarchy and identify each full-adder instance.

**Figure 2 — Vivado hierarchy:**  
[Insert screenshot of the Sources / Hierarchy view, with the top module and four instantiated full adders visible.]

| Hierarchical element | Observed module / instance name | Verified? |
|---|---|---|
| Top-level 4-bit adder | | [ ] Yes / [ ] No |
| Full adder, bit 0 | | [ ] Yes / [ ] No |
| Full adder, bit 1 | | [ ] Yes / [ ] No |
| Full adder, bit 2 | | [ ] Yes / [ ] No |
| Full adder, bit 3 | | [ ] Yes / [ ] No |

**Task 4 observations:**  
[State how the hierarchy confirms module reuse and how many full-adder instances appear.]

### Task 5 — RTL Schematic and Carry-Chain Tracing

**Objective:** Inspect the elaborated RTL schematic and trace `CIN → C1 → C2 → C3 → COUT`.

**Figure 3 — Elaborated RTL schematic:**  
[Insert screenshot showing the four full-adder stages and highlight/annotate carry propagation.]

| Carry net | Driven by | Connected to | Verified in schematic? |
|---|---|---|---|
| `CIN` | Top-level input | Stage 0 carry-in | |
| `C1` | Stage 0 carry-out | Stage 1 carry-in | |
| `C2` | Stage 1 carry-out | Stage 2 carry-in | |
| `C3` | Stage 2 carry-out | Stage 3 carry-in | |
| `COUT` | Stage 3 carry-out | Top-level output | |

**Task 5 observations:**  
[Describe the direction of carry propagation and any differences between the HDL structure and the elaborated schematic.]

### Task 7 — FPGA Implementation (Switches and LEDs)

**Objective:** Use onboard switches for operand inputs and onboard LEDs for output display.

**Board identification**  
Board: ____________________  
FPGA device / part: ____________________  
Clock requirement (if any): ____________________

**Switch/LED mapping — fill from your actual XDC constraints**

| HDL signal | Physical control/indicator | FPGA package pin | I/O standard |
|---|---|---|---|
| `A[0]` | SW___ | | |
| `A[1]` | SW___ | | |
| `A[2]` | SW___ | | |
| `A[3]` | SW___ | | |
| `B[0]` | SW___ | | |
| `B[1]` | SW___ | | |
| `B[2]` | SW___ | | |
| `B[3]` | SW___ | | |
| `CIN` | SW___ | | |
| `SUM[0]` | LED___ | | |
| `SUM[1]` | LED___ | | |
| `SUM[2]` | LED___ | | |
| `SUM[3]` | LED___ | | |
| `COUT` | LED___ | | |

**XDC excerpt:**

```tcl
# Paste your actual XDC constraints here.
# Do not guess FPGA pin assignments.
```

**Implementation evidence**

| Step | Evidence / observation | Status |
|---|---|---|
| Run synthesis | Screenshot/report | |
| Run implementation | Screenshot/report | |
| Generate bitstream | Successful bitstream screenshot | |
| Program FPGA | Hardware Manager screenshot | |
| Test switches/LEDs | Observed LED patterns | |

**Hardware verification results**

| A (decimal) | B (decimal) | CIN | Expected `{COUT,SUM}` | Observed LED output | Pass/Fail |
|---:|---:|:---:|:---:|:---:|:---:|
| 0 | 0 | 0 | `00000` | | |
| 3 | 5 | 0 | `01000` | | |
| 7 | 8 | 1 | `10000` | | |
| 15 | 15 | 0 | `11110` | | |
| 15 | 15 | 1 | `11111` | | |

**Figure 4 — FPGA programmed in Hardware Manager:**  
[Insert screenshot.]

**Figure 5 — FPGA switch-and-LED test:**  
[Insert annotated photo showing switch positions and corresponding LEDs.]

**Task 7 observations:**  
[Describe whether the physical board behaved as predicted, including any issues with pin assignments or interpretation of the carry LED.]

### Overall Task Verification

| Task | Expected deliverable | Evidence supplied | Pass/Fail |
|---|---|---|---|
| 3 | Four-instance 4-bit ripple-carry adder | | |
| 4 | Hierarchy with four full-adder instances | | |
| 5 | RTL schematic with carry chain traced | | |
| 7 | FPGA implemented and switch/LED tested | | |

---

## 4. Discussion

Answer using **your actual results and screenshots**, not only theoretical descriptions.

1. Why is a 4-bit adder constructed using four full-adder instances rather than repeating the full Boolean equations in one module?
2. How does the carry signal travel from `CIN` through `C1`, `C2`, and `C3` to `COUT`?
3. How does Vivado's Sources/Hierarchy view demonstrate the reuse of an HDL module?
4. What evidence in the elaborated schematic confirms the ripple-carry architecture?
5. Why should `{COUT, SUM}` be treated as a **five-bit result** rather than only `SUM[3:0]`?
6. Which test vectors demonstrate carry propagation across multiple stages?
7. How did you map operand switches and result LEDs on the FPGA board?
8. Did physical FPGA results match the behavioral simulation? Support your answer with test data.
9. What errors can result from incorrect XDC mapping, missing carry connections, or an incorrectly selected top module?
10. How could the propagation delay of a ripple-carry adder change as its width increases?


