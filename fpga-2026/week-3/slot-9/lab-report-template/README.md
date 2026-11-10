# Laboratory Report Template
## 977-220 Electronics and IoT — Week 3, Slot 9
### Hierarchical Four-Bit Ripple-Carry Adder (Vivado / Nexys A7) — Tasks 3–8

**Student name:** ____________________  
**Student ID:** ____________________  
**Date:** ____________________  

**Laboratory reference:** https://github.com/komsan-k/977-220/tree/main/fpga-2026/week-3/slot-9

> Complete **Tasks 3, 4, 5, 6, 7, and 8**. Insert your own HDL source files, simulation results, Vivado screenshots, resource reports, hardware test data, and observations. Do not mark an item **PASS** without supporting evidence. Use the actual board master XDC and implemented constraints for pin assignments; do not guess package pins. Record measured utilization rather than expected or invented values.

---

## 1. Achievement

**Learning objectives**

- Build a 4-bit ripple-carry adder hierarchically from **four full-adder instances**.
- Recognize the top-level module and its submodules in Vivado's hierarchy view.
- Trace `CIN → C1 → C2 → C3 → COUT` in the elaborated RTL schematic.
- Verify **at least five distinct addition cases** in Vivado behavioral simulation.
- Implement and test an FPGA design in which **switches supply the operands and LEDs display outputs**.
- Record and interpret **LUT, register/flip-flop, and I/O utilization** from Vivado synthesis reports.

**Achievement summary (5–8 sentences):**  
[Summarize Tasks 3–8: hierarchical construction, module hierarchy, RTL carry chain, simulation results, FPGA switch/LED testing, and synthesis resource utilization. Cite your figures and tables.]

---

## 2. Verilog/SystemVerilog

**Project checklist:**

- [ ] Task 3: `half_adder`, `full_adder`, `ripple_adder_4bit`, and any FPGA top-level HDL used
- [ ] Task 4: Vivado hierarchy screenshot identifying the four full-adder instances
- [ ] Task 5: Elaborated RTL schematic and carry-chain trace
- [ ] Task 6: Testbench, waveform screenshot, and results for at least five addition cases
- [ ] Task 7: Actual XDC constraints, implementation/bitstream evidence, and FPGA switch/LED tests
- [ ] Task 8: Vivado utilization report screenshot and LUT/register/I/O resource table

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

**Structural design checks**

- [ ] Four `full_adder` instances are connected in the correct bit order.
- [ ] `CIN` enters the least significant stage (bit 0).
- [ ] Intermediate carries connect stage 0 → 1 → 2 → 3.
- [ ] `{COUT, SUM}` provides the five-bit unsigned result.
- [ ] The HDL elaborates without missing-module or port-connection errors.

**Task 3 verification summary:**  
[Describe the hierarchical implementation, name the four instances, and explain the carry connections. Functional simulation results are recorded separately in Task 6.]

### Task 4 — Hierarchy Verification

**Objective:** Open the Vivado hierarchy and identify each full-adder instance.

**Figure 1 — Vivado hierarchy:**  
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

**Figure 2 — Elaborated RTL schematic:**  
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

### Task 6 — Behavioral Simulation (At Least Five Addition Cases)

**Objective:** Simulate the hierarchical 4-bit ripple-carry adder in Vivado and verify at least five distinct additions. The expected **five-bit unsigned result** is

$$
\{COUT,SUM\}=A+B+CIN.
$$

**Simulation setup**  
Testbench file: ____________________  
Design under test (DUT): ____________________  
Simulation tool / Vivado version: ____________________  
Simulation duration: ____________________  

**Testbench source code:**

```systemverilog
// Paste your behavioral testbench here.
// Apply at least five different {A, B, CIN} input combinations.
// Record or check the resulting {COUT, SUM} values.
```

**Simulation results — record the observed outputs**

| Test | A (decimal) | B (decimal) | CIN | Expected decimal result | Expected `{COUT,SUM}` (5 bits) | Simulated `{COUT,SUM}` | Pass/Fail |
|---:|---:|---:|:---:|---:|:---:|:---:|:---:|
| 1 | 0 | 0 | 0 | 0 | `00000` | | |
| 2 | 3 | 2 | 0 | 5 | `00101` | | |
| 3 | 7 | 5 | 0 | 12 | `01100` | | |
| 4 | 9 | 6 | 1 | 16 | `10000` | | |
| 5 | 15 | 15 | 0 | 30 | `11110` | | |
| 6 (optional) | 15 | 15 | 1 | 31 | `11111` | | |
| 7 (custom) | | | | | | | |

**Figure 3 — Vivado behavioral simulation waveform:**  
[Insert a screenshot showing `A`, `B`, `CIN`, `SUM`, `COUT`, and time markers for at least five test cases. Include intermediate carry nets if available.]

**Simulation evidence checklist**

- [ ] Testbench compiled and simulation completed.
- [ ] At least five distinct test cases are visible in the waveform or test log.
- [ ] Each observed five-bit result was compared against `A + B + CIN`.
- [ ] A case producing `COUT = 1` was included.
- [ ] Any mismatch was documented and investigated.

**Task 6 observations:**  
[Explain which test vectors verify ordinary addition, carry propagation, and final carry-out. Report mismatches if any; do not claim PASS without evidence.]

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

### Task 8 — FPGA Resource Analysis

**Objective:** Record and interpret FPGA resource utilization after running Vivado synthesis, especially **LUT, register/flip-flop, and I/O utilization**, as required by the laboratory instructions.

**Report identification**  
Vivado report name / location: ____________________  
FPGA device / part: ____________________  
Synthesis top module: ____________________  
Synthesis run status: ____________________  

**Resource utilization — transcribe values from the actual Vivado report**

| Resource | Used | Available (if reported) | Utilization (%) (if reported) | Evidence / report row |
|---|---:|---:|---:|---|
| LUTs | | | | |
| Registers / flip-flops | | | | |
| I/O ports or I/O buffers | | | | |
| BRAM (if reported) | | | | |
| DSP slices (if reported) | | | | |

**Figure 6 — Vivado synthesis utilization report:**  
[Insert a screenshot of the *Report Utilization* or synthesis summary showing LUT, register, and I/O usage. Make sure the device name and top-level design are identifiable.]

**Resource interpretation**

| Question | Student observation / explanation |
|---|---|
| How many LUTs were used? | |
| How many registers/flip-flops were used? | |
| How many I/O resources were used? | |
| Is the design combinational or sequential? How does this affect register use? | |
| Did synthesis preserve the HDL hierarchy or optimize/flatten some modules? | |
| What FPGA logic resources appear to implement carry propagation? (If visible) | |

**Optional timing observation (only if a meaningful timing report is available):**  
Critical path / delay: ____________________  
Report and constraint assumptions: ____________________  

> **Reporting note:** This ripple-carry adder is a combinational circuit, so register utilization may be zero. Record what Vivado actually reports. Do not infer a maximum clock frequency from an unconstrained combinational path; if timing is discussed, identify the constraints and report used.

**Task 8 observations:**  
[Explain the observed LUT, register, and I/O usage, the effect of hierarchy/synthesis optimization, and any unexpected resource counts. Cite Figure 6.]

---

## 4. Discussion

Answer using **your actual results and screenshots**, not only theoretical descriptions.

1. Why is a 4-bit adder constructed using four full-adder instances rather than repeating the full Boolean equations in one module?
2. How does the carry signal travel from `CIN` through `C1`, `C2`, and `C3` to `COUT`?
3. How does Vivado's Sources/Hierarchy view demonstrate the reuse of an HDL module?
4. What evidence in the elaborated schematic confirms the ripple-carry architecture?
5. Why should `{COUT, SUM}` be treated as a **five-bit result** rather than only `SUM[3:0]`?
6. Which five or more Task 6 test vectors demonstrate ordinary addition, carry propagation, and final carry-out?
7. How did you map operand switches and result LEDs on the FPGA board?
8. Did physical FPGA results match the behavioral simulation? Support your answer with test data.
9. What errors can result from incorrect XDC mapping, missing carry connections, or an incorrectly selected top module?
10. How could the propagation delay of a ripple-carry adder change as its width increases?
11. What LUT, register, and I/O utilization did Vivado report for your design (Task 8)?
12. Why might the synthesized circuit use no flip-flops, even though the HDL hierarchy contains many modules?
13. Can synthesis optimization change the displayed module hierarchy without changing the adder's function? Explain using your report.


