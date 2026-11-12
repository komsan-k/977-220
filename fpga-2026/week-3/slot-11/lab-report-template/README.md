# Laboratory Report Template
## 977-220 Electronics and IoT — Topic 11: Vivado-7
### Fixed-Point Multipliers — Combinational Verilog and FPGA Implementation (Nexys A7)

**Student name:** ______________________________  
**Student ID:** ______________________________   
**Date:** ______________________________  


**Laboratory reference:** *Topic 11: Vivado-7 — Fixed-Point Multipliers* (revised, non-pipelined laboratory).

> **Required work:** Complete **Tasks 1–8, including Task 7 — FPGA Implementation**. Use your own calculations, Verilog files, Vivado screenshots, board photos, and measured results. Do not mark PASS without evidence. This is a **combinational** multiplier: no pipeline, clock, reset, or valid signals are used in the datapath. Obtain exact package pins from the **official master XDC for your actual board**; do not guess pin numbers.

---

## 1. Achievement

**Learning objectives**

- Encode signed 8-bit **Q3.4** numbers (1 sign bit, 3 non-sign integer bits, 4 fractional bits).
- Design a signed 8 × 8 multiplier with a **16-bit signed raw product**.
- Rescale the raw product using **arithmetic right shift `>>> 4`**.
- Clamp the result to the signed 8-bit range using **saturation**.
- Verify the combinational circuit using Vivado simulation and an RTL schematic.
- Implement the design on **Nexys A7**, using switches for both operands and LEDs for the product and saturation flag.
- Record and interpret Vivado synthesis resource utilization.

**Achievement summary (5–8 sentences):**  
[Summarize the Verilog design, Q3.4 calculations, simulation, FPGA programming, observed LED outputs, and synthesis results.]

---

## 2. Verilog and FPGA Project

### 2.1 Project information

| Item | Student entry |
|---|---|
| Vivado project name | |
| Vivado version | |
| Board and FPGA part | |
| Simulation top module | `tb_fixed_point_multiplier` |
| FPGA synthesis top module | `fixed_point_top` |
| Design files | `signed_multiplier.v`, `fixed_point_multiplier.v`, `fixed_point_top.v` |
| Simulation file | `tb_fixed_point_multiplier.v` |
| Constraint file | [Actual board XDC filename] |

**Source / evidence checklist**

- [ ] `signed_multiplier.v` — basic signed multiplication
- [ ] `fixed_point_multiplier.v` — arithmetic shift and saturation
- [ ] `tb_fixed_point_multiplier.v` — behavioral simulation
- [ ] `fixed_point_top.v` — switches and LEDs wrapper
- [ ] Official board XDC adapted to the actual top-level port names
- [ ] Simulation waveform and test results
- [ ] Elaborated RTL schematic
- [ ] Synthesis and implementation reports
- [ ] Generated bitstream and programmed FPGA
- [ ] Hardware test photographs / observations

### 2.2 Design interface

| Module | Input | Output | Purpose |
|---|---|---|---|
| `signed_multiplier` | `A[7:0]`, `B[7:0]` signed | `PRODUCT[15:0]` signed | Full raw product |
| `fixed_point_multiplier` | `A[7:0]`, `B[7:0]` signed | `P[7:0]` signed, `SATURATED` | Q3.4 output with saturation |
| `fixed_point_top` | `SW[15:0]` | `LED[8:0]` | FPGA switches and LEDs |

### 2.3 Source code — signed multiplier

```verilog
// Paste your signed_multiplier.v here.
```

### 2.4 Source code — fixed-point multiplier

```verilog
// Paste your fixed_point_multiplier.v here.
// Include the 16-bit signed raw product, >>> 4, and saturation.
```

### 2.5 Source code — FPGA top-level wrapper

```verilog
// Paste your fixed_point_top.v here.
// SW[7:0] = A; SW[15:8] = B;
// LED[7:0] = P; LED[8] = SATURATED.
```

### 2.6 Source code — testbench

```verilog
// Paste your tb_fixed_point_multiplier.v here.
```

---

## 3. Results

### Task 1 — Signed Fixed-Point Encoding (Q3.4)

**Objective:** Encode real numbers as signed 8-bit integers with four fractional bits.

\[
X=16x,\qquad x=X/16,\qquad -8\le x\le7.9375.
\]

| Real value | Expected encoded integer | Expected binary | Student calculation / verification |
|---:|---:|---|---|
| 1.5 | 24 | `00011000` | |
| -2.25 | -36 | `11011100` | |
| 0.5 | 8 | `00001000` | |
| -8.0 | -128 | `10000000` | |
| [custom] | | | |

**Task 1 observations:**  
[Explain the sign bit, two's-complement representation, and the 0.0625 resolution.]

### Task 2 — Basic Signed Multiplication

**Objective:** Verify that an 8 × 8 signed multiplication produces a full 16-bit signed product.

| A (encoded) | B (encoded) | Expected raw product (decimal) | Simulated raw product | Pass/Fail |
|---:|---:|---:|---:|---|
| 24 | 32 | 768 | | |
| -36 | 24 | -864 | | |
| 0 | 32 | 0 | | |
| -128 | -128 | 16384 | | |
| [custom] | [custom] | | | |

**Figure 1 — Signed multiplier simulation:**  
[Insert a waveform or simulation-console screenshot showing signed inputs and the 16-bit raw product.]

**Task 2 observations:**  
[Explain why the raw product needs 16 bits and why the operands must be declared signed.]

### Task 3 — Fixed-Point Product Scaling

**Objective:** Convert the signed 16-bit raw product from eight fractional bits to a Q3.4-scaled integer using `>>> 4`.

\[
P_{\mathrm{raw}}=A\times B,\qquad P_{\mathrm{scaled}}=P_{\mathrm{raw}}\mathbin{\texttt{>>>}}4.
\]

| A | B | Raw product | Expected scaled integer | Simulated scaled integer | Pass/Fail |
|---:|---:|---:|---:|---:|---|
| 24 | 32 | 768 | 48 | | |
| -36 | 24 | -864 | -54 | | |
| 1 | 8 | 8 | 0 | | |
| -1 | 8 | -8 | -1 | | |
| -1 | 1 | -1 | -1 | | |

**Task 3 observations:**  
[Explain arithmetic right shift and why a small negative raw product may scale to -1 instead of 0.]

### Task 4 — Saturation

**Objective:** Verify clamping to the signed 8-bit range of -128 through 127.

| A | B | Scaled integer | Expected `P` (decimal) | Expected `SATURATED` | Simulated `P` | Simulated flag | Pass/Fail |
|---:|---:|---:|---:|:---:|---:|:---:|---|
| 24 | 32 | 48 | 48 | 0 | | | |
| 64 | 64 | 256 | 127 | 1 | | | |
| -128 | 32 | -256 | -128 | 1 | | | |
| -128 | -128 | 1024 | 127 | 1 | | | |
| [custom] | [custom] | | | | | | |

**Task 4 observations:**  
[Explain why saturation is needed and how it differs from keeping only the low eight bits.]

### Task 5 — Behavioral Simulation

**Objective:** Test at least five cases, including positive, negative, small-magnitude, and saturated results. The revised laboratory provides nine reference cases.

| # | A (encoded) | B (encoded) | Expected `P` | Expected SAT | Simulated `P` | Simulated SAT | Pass/Fail |
|---:|---:|---:|---:|:---:|---:|:---:|---|
| 1 | 24 | 32 | 48 | 0 | | | |
| 2 | -36 | 24 | -54 | 0 | | | |
| 3 | 1 | 8 | 0 | 0 | | | |
| 4 | -1 | 8 | -1 | 0 | | | |
| 5 | 1 | 1 | 0 | 0 | | | |
| 6 | -1 | 1 | -1 | 0 | | | |
| 7 | 64 | 64 | 127 | 1 | | | |
| 8 | -128 | 32 | -128 | 1 | | | |
| 9 | -128 | -128 | 127 | 1 | | | |

**Figure 2 — Behavioral simulation waveform:**  
[Insert a readable Vivado waveform screenshot showing `A`, `B`, `P`, and `SATURATED`.]

**Simulation run duration:** __________ ns  
**Simulation top:** __________________________  
**Number of passing cases:** ______ / ______

**Task 5 observations:**  
[Describe mismatches, if any. Explain that the combinational output is observed after input changes settle; there is no clock-cycle pipeline latency.]

### Task 6 — RTL Schematic Verification

**Objective:** Open **RTL Analysis → Open Elaborated Design → Schematic** and inspect the combinational datapath.

| RTL component / operation | Identified in schematic? | Screenshot annotation / observation |
|---|---|---|
| Signed 8 × 8 multiplication | [ ] Yes / [ ] No | |
| Arithmetic right shift by 4 | [ ] Yes / [ ] No | |
| Upper saturation comparison (> 127) | [ ] Yes / [ ] No | |
| Lower saturation comparison (< -128) | [ ] Yes / [ ] No | |
| Final output selection / mux logic | [ ] Yes / [ ] No | |
| No clocked pipeline registers | [ ] Yes / [ ] No | |

**Figure 3 — Elaborated RTL schematic:**  
[Insert screenshot and label the multiplication, scaling, saturation, and output stages.]

**Task 6 observations:**  
[Explain how the RTL corresponds to the source code. Note that Vivado may simplify or optimize combinational logic.]

### Task 7 — FPGA Implementation (Required)

**Objective:** Implement the combinational fixed-point multiplier on a Nexys A7 board using 16 switches as the two signed operands and nine LEDs as outputs.

#### 7.1 Board and tool information

**Board / variant:** __________________________  
**FPGA part:** __________________________  
**Vivado version:** __________________________  
**Master XDC source / version:** __________________________  
**FPGA synthesis top:** `fixed_point_top`  
**Clock used by multiplier?** **No** — the design is combinational.

#### 7.2 Switch and LED interpretation

| FPGA resource | HDL signal | Meaning |
|---|---|---|
| SW0–SW7 | `SW[7:0]` | Signed encoded operand A |
| SW8–SW15 | `SW[15:8]` | Signed encoded operand B |
| LED0–LED7 | `LED[7:0]` | Signed encoded result P |
| LED8 | `LED[8]` | Saturation flag |

**Important:** Negative values must be entered in 8-bit two's-complement form. LED0 is the least significant bit. Interpret the eight result LEDs as a signed Q3.4 encoding, not an unsigned decimal display.

#### 7.3 XDC pin mapping — complete from the actual board constraints

| HDL port | Physical device | FPGA package pin | I/O standard |
|---|---|---|---|
| `SW[0]` | SW0 | | |
| `SW[1]` | SW1 | | |
| `SW[2]` | SW2 | | |
| `SW[3]` | SW3 | | |
| `SW[4]` | SW4 | | |
| `SW[5]` | SW5 | | |
| `SW[6]` | SW6 | | |
| `SW[7]` | SW7 | | |
| `SW[8]` | SW8 | | |
| `SW[9]` | SW9 | | |
| `SW[10]` | SW10 | | |
| `SW[11]` | SW11 | | |
| `SW[12]` | SW12 | | |
| `SW[13]` | SW13 | | |
| `SW[14]` | SW14 | | |
| `SW[15]` | SW15 | | |
| `LED[0]` | LED0 | | |
| `LED[1]` | LED1 | | |
| `LED[2]` | LED2 | | |
| `LED[3]` | LED3 | | |
| `LED[4]` | LED4 | | |
| `LED[5]` | LED5 | | |
| `LED[6]` | LED6 | | |
| `LED[7]` | LED7 | | |
| `LED[8]` | LED8 | | |

**XDC excerpt:**

```tcl
# Paste the actual get_ports, PACKAGE_PIN, and IOSTANDARD constraints here.
# Use the official XDC for the specific board variant.
# Do not invent package pins.
```

#### 7.4 Implementation and programming evidence

| Step | Evidence / report / screenshot | Status |
|---|---|---|
| Set `fixed_point_top` as synthesis top | Sources hierarchy screenshot | |
| Validate all XDC assignments | Constraints / I/O Ports screenshot | |
| Run synthesis | Synthesis completion screenshot | |
| Run implementation | Implementation completion screenshot | |
| Generate bitstream | Successful bitstream generation screenshot | |
| Program FPGA via Hardware Manager | Program Device screenshot | |
| Verify hardware outputs | LED photographs and test table below | |

**Figure 4 — Vivado synthesis / implementation completion:**  
[Insert screenshot.]

**Figure 5 — Hardware Manager / programmed FPGA:**  
[Insert screenshot.]

#### 7.5 FPGA switch and LED test cases

For each row, set the switches, wait for the outputs to settle, read LED0–LED8, and compare with the expected result. The binary strings below are written **MSB to LSB**.

| # | A decimal / SW7–SW0 | B decimal / SW15–SW8 | Expected P decimal / LED7–LED0 | Expected LED8 | Observed LED7–LED0 | Observed LED8 | Pass/Fail |
|---:|---|---|---|:---:|---|:---:|---|
| 1 | 24 / `00011000` | 32 / `00100000` | 48 / `00110000` | 0 | | | |
| 2 | -36 / `11011100` | 24 / `00011000` | -54 / `11001010` | 0 | | | |
| 3 | 1 / `00000001` | 8 / `00001000` | 0 / `00000000` | 0 | | | |
| 4 | -1 / `11111111` | 8 / `00001000` | -1 / `11111111` | 0 | | | |
| 5 | 64 / `01000000` | 64 / `01000000` | 127 / `01111111` | 1 | | | |
| 6 | -128 / `10000000` | 32 / `00100000` | -128 / `10000000` | 1 | | | |
| 7 | -128 / `10000000` | -128 / `10000000` | 127 / `01111111` | 1 | | | |
| 8 | [custom] | [custom] | | | | | |

**Figure 6 — FPGA hardware test (non-saturated):**  
[Insert a labeled photograph showing switch positions and LED states for case 1.]

**Figure 7 — FPGA hardware test (saturated):**  
[Insert a labeled photograph showing switch positions and LED states for case 5, 6, or 7.]

**Task 7 verification summary:**  
[State how many test cases matched. Discuss any incorrect switch mapping, LED interpretation, missing constraints, or unstable intermediate patterns while switches were being changed.]

### Task 8 — FPGA Resource Analysis

**Objective:** Report **actual** synthesis utilization for `fixed_point_top` on the selected device. Do not estimate or invent resource counts.

**Vivado report:** Run Synthesis → Open Synthesized Design → Report Utilization.

| Resource | Observed used | Device available (if reported) | Utilization (%) | Comments |
|---|---:|---:|---:|---|
| LUTs | | | | |
| Flip-flops / registers | | | | Combinational multiplier does not require registers |
| DSP blocks | | | | Mapping depends on synthesis settings |
| I/O ports / I/O buffers | | | | Wrapper has 16 inputs and 9 outputs |
| BRAM | | | | No memory required by design |

**Figure 8 — Vivado utilization report:**  
[Insert screenshot showing LUT, FF, DSP, I/O, and BRAM counts.]

**Figure 9 — Synthesized schematic (optional):**  
[Insert screenshot if useful for identifying multiplier implementation.]

**Timing interpretation:**  
[Explain that a purely combinational top has **no register-to-register clock path**, so an unconstrained Fmax cannot be claimed. If reporting delay, specify input-to-output constraints or clearly identify the report as an unconstrained path estimate.]

**Task 8 observations:**  
[Discuss LUT versus DSP use, why no pipeline registers are needed, and whether the observed resources agree with the design structure.]


---

## 4. Discussion

Answer using your **actual calculations, Verilog code, Vivado reports, and FPGA evidence**.

1. How does signed Q3.4 encoding represent a fractional real number? What is its resolution and range?
2. Why is a full signed 8 × 8 multiplication represented using a 16-bit raw product?
3. Why must the raw product be shifted by four bits before producing an 8-bit Q3.4 result?
4. What is the difference between `>>>` and `>>` when the left operand is signed and negative?
5. Why can `-1 × 1` (encoded values) produce `-1` after arithmetic-shift truncation?
6. What is the difference between saturation and wraparound? Which test cases demonstrate it?
7. How did you map SW0–SW15 to the two signed operands and LED0–LED8 to the outputs?
8. Did the FPGA hardware match the behavioral simulation for all tested cases? Cite the relevant test rows and photographs.
9. What were the actual LUT, FF, DSP, I/O, and BRAM counts? Why might Vivado use a DSP block or LUT logic for multiplication?
10. Why does this circuit need neither a clock nor a pipeline? How would a future MAC design add an accumulator register?


