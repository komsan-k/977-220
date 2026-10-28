# Laboratory Report Template
## 977-220 — Week 3, Slot 11: Vivado-7 — Fixed-Point and Pipelined Multipliers

**Reference laboratory:** https://github.com/komsan-k/977-220/tree/main/fpga-2026/week-3/slot-11  
**Course:** 977-220 Electronics and Internet of Things

| Student information | Fill in |
|---|---|
| Name | |
| Student ID | |
| Section / Group | |
| Laboratory date | |
| Vivado version | |
| Target FPGA board / part | |
| Partner (if applicable) | |

> **Instructions:** Complete all four sections. Insert your own RTL snippets, calculations, Vivado screenshots, console output, waveform evidence, and measured reports. Do not replace measurements with expected values. The Nexys A7 hardware activity is optional in the reference laboratory.

---

## 1. Achievement

### 1.1 Learning outcomes

After this laboratory, I can:

- [ ] Interpret signed 8-bit **Q3.4** numbers (8 total bits, 4 fractional bits).
- [ ] Calculate full-width 8 × 8 products and rescale to Q3.4.
- [ ] Compare arithmetic-shift truncation and round-to-nearest (ties away from zero).
- [ ] Identify and handle output saturation.
- [ ] Implement and test a combinational fixed-point multiplier.
- [ ] Implement and test a pipelined multiplier with aligned `valid_in` / `valid_out`.
- [ ] Verify latency, throughput, bubbles, and synchronous reset.
- [ ] Analyze Vivado resource utilization and timing constraints.

**Achievement summary (4–6 sentences):**

[Describe what you implemented and verified, highlighting numerical behavior and pipeline timing.]

### 1.2 Design parameters

| Parameter | Lab value | Your configuration |
|---|---|---|
| Operand width, W | 8 bits, signed | |
| Fractional bits, F | 4 | |
| Number format | Q3.4 (1 sign + 3 integer + 4 fractional bits) | |
| Numeric range | -8 to 7.9375 | |
| Quantization step | 0.0625 | |
| Raw product width | 16 bits, signed | |
| Output width | 8 bits, signed | |
| Default quantizer | Nearest, ties away from zero | |
| Output limits | -128 to +127 (encoded) | |
| Clock period in simulation | 10 ns | |
| Acceptance-to-output latency | 2 clock periods (sample at edge k, output after edge k+2) | |
| Peak initiation interval | 1 cycle | |

---

## 2. Verilog/SystemVerilog Project URL (Shared)

**GitHub repository URL:** [Insert URL]  
**Vivado project name:** `topic11_fixed_point_multiplier` / [Your name]  
**Vivado project location or submission archive:** [Insert link or filename]  
**Optional demonstration video / hardware link:** [Insert link or N/A]

### 2.1 Project file checklist

- [ ] `fxp_quantize.sv` — quantization and saturation
- [ ] `fxp_multiplier_comb.sv` — combinational multiplication
- [ ] `fxp_multiplier_pipeline.sv` — pipelined multiplication
- [ ] `tb_fxp_multiplier.sv` — self-checking testbench
- [ ] Simulation console log and waveform screenshots
- [ ] Vivado utilization and timing reports
- [ ] `fixed_point_top.sv` and XDC (only if optional FPGA demonstration was performed)

**Project structure / notes:**

```text
topic11_fixed_point_multiplier/
├── rtl/
│   ├── fxp_quantize.sv
│   ├── fxp_multiplier_comb.sv
│   └── fxp_multiplier_pipeline.sv
├── sim/
│   └── tb_fxp_multiplier.sv
└── evidence/
    ├── simulation/
    └── vivado_reports/
```

[Adjust the tree to match your actual repository.]

---

## 3. Results

### 3.1 Experiment A — Signed Number Interpretation

**Objective:** Encode the specified real values as signed Q3.4 integers and 8-bit two's-complement patterns.

For Q3.4, use the conversion `X = x × 16` when the real value is exactly representable.

| Real value x | Encoded signed integer X | 8-bit binary (two's complement) | Your calculated value / verification | Pass/Fail |
|---:|---:|---|---|---|
| 1.5 | 24 | `00011000` | | |
| -2.25 | -36 | `11011100` | | |
| 0.5 | 8 | `00001000` | | |
| -8.0 | -128 | `10000000` | | |

**Show calculations for two examples:**

1. [Calculation]
2. [Calculation]

**Evidence:** [Insert screenshot, calculator log, or testbench output.]

**Short explanation:** Why does an 8-bit pattern have a different meaning when read as signed versus unsigned?  
[Your response]

### 3.2 Experiment B — Quantization and Saturation

**Objective:** Verify the fixed-point product, quantization error, rounding mode, and saturation behavior.

The signed 8 × 8 multiplication produces a **16-bit product with 8 fractional bits**. Divide the raw encoded product by 16 (using the selected rounding policy), then clamp to the signed 8-bit output range.

**Default policy:** round to nearest, with ties away from zero, followed by saturation.

| A (real) | B (real) | Exact real product | Simulated output (encoded signed) | Output real | Absolute error | Saturated (Y/N) | Pass/Fail |
|---:|---:|---:|---:|---:|---:|---|---|
| 1.5 | 2.0 | 3.0 | | | | | |
| -2.25 | 1.5 | -3.375 | | | | | |
| 0.0625 | 0.5 | 0.03125 | | | | | |
| -0.0625 | 0.0625 | -0.00390625 | | | | | |
| 4.0 | 4.0 | 16.0 | | | | | |

**Additional directed reference cases from the lab:**

| A encoded | B encoded | Raw product | Expected encoded output (nearest) | Expected saturation | Simulated output | Pass/Fail |
|---:|---:|---:|---:|---|---:|---|
| 24 | 32 | 768 | 48 | No | | |
| -36 | 24 | -864 | -54 | No | | |
| 1 | 8 | 8 | 1 | No | | |
| -1 | 8 | -8 | -1 | No | | |
| 64 | 64 | 4096 | 127 | Yes | | |
| -128 | 32 | -4096 | -128 | Yes | | |
| -128 | -128 | 16384 | 127 | Yes | | |

**Error calculation:** `absolute error = |simulated output real − exact real product|`.

**Repeat the experiment using arithmetic-shift truncation** (`ROUND_NEAREST = 0`) and a matching reference model.

| Case | Nearest output | Truncation output | Difference / observation |
|---|---|---|---|
| Small positive product | | | |
| Small negative product | | | |
| Positive half-step tie | | | |
| Negative half-step tie | | | |
| Saturated product | | | |

**Source code or parameter setting evidence:** [Insert relevant code / screenshot.]

**Waveform or console evidence:** [Insert figure with caption.]

**Interpretation:** [Discuss rounding bias, tie handling, and saturation versus wraparound. Distinguish quantization error from saturation error.]

### 3.3 Experiment C — Pipeline Verification

**Objective:** Verify that operands, products, output values, and validity signals move through the pipeline together.

**Reference edge convention:** a sample is captured at edge `k`; the full product is registered at `k+1`; the quantized result and `valid_out=1` appear just after `k+2`.

```text
valid_in, A, B → [operand registers] → [multiply/product register]
                                           ↓
                          [quantize/output register] → P, saturated, valid_out
```

**3.3.1 Consecutive valid samples**

| Input sample | A (encoded) | B (encoded) | Accepted at edge | Expected result edge | Observed result edge | Output P | Valid aligned? | Pass/Fail |
|---|---:|---:|---|---|---|---:|---|---|
| 1 | | | | | | | | |
| 2 | | | | | | | | |
| 3 | | | | | | | | |
| 4 | | | | | | | | |

**3.3.2 Pipeline events**

| Test | Expected observation | Your observation | Pass/Fail |
|---|---|---|---|
| Four consecutive valid samples | Outputs in order, after 2 clock periods | | |
| Bubble (`valid_in=0`) | Corresponding `valid_out=0` two periods later; pipeline does not stall | | |
| Reset while samples are in flight | In-flight valid flags cleared; pending results discarded | | |
| Continuous valid input | One valid result per cycle after filling | | |
| Output data vs. validity | Ignore output data and saturation flag when `valid_out=0` | | |

**3.3.3 EPWave / XSim evidence**

Insert clearly labeled waveform screenshots including:

- `clk`, `rst`, `valid_in`, `A`, `B`
- `a_reg`, `b_reg`, `product_reg`, `valid_product`
- `P`, `valid_out`, `saturated`

**Figure 1 — Consecutive valid samples:** [Insert waveform]

**Figure 2 — Bubble and invalid output slot:** [Insert waveform]

**Figure 3 — Reset with samples in flight:** [Insert waveform]

**Measured acceptance-to-output latency:** [ ] periods  
**Measured sustained initiation interval:** [ ] cycle(s)  
**Explanation of alignment:** [Your response]

### 3.4 Exhaustive Self-Checking Simulation

**Objective:** Run the supplied `tb_fxp_multiplier.sv` to check every signed 8-bit operand combination, including product values, saturation flags, and pipeline timing.

There are `256 × 256 = 65,536` input pairs from `-128` through `127` for each operand.

| Verification metric | Expected / requirement | Observed | Pass/Fail |
|---|---|---|---|
| Operand pairs tested | 65,536 | | |
| Self-checking assertion / mismatch | No mismatches | | |
| `valid_out` timing | Aligned with the input accepted two periods earlier | | |
| Saturation flag | Matches integer reference | | |
| Reset test | All in-flight validity cleared | | |
| Final simulation outcome | `PASS: exhaustive arithmetic and pipeline checks completed` | | |

**Simulation completion / elapsed simulated time:** [ ]  
**Console screenshot or copied final log:**

```text
[Paste actual XSim output here]
```

**Notes:** Do not report a test as passing unless simulation completed and the checker confirmed it. Directed samples completing before the reset may contribute to the testbench's total received counter; the exhaustive loop itself contains 65,536 pairs.

### 3.5 Experiment D — Vivado Resources and Timing

**Objective:** Record *measured* implementation results and interpret whether constraints are met.

**Device / board:** [ ]  
**Vivado version:** [ ]  
**Clock target period:** [ ] ns  
**Synthesis / implementation settings:** [ ]

| Metric | Pipelined core / wrapper | Registered comparison (optional) |
|---|---:|---:|
| LUTs | | |
| Flip-flops | | |
| DSP blocks | | |
| Target clock period (ns) | | |
| Worst setup slack (ns) | | |
| Worst hold slack (ns) | | |
| Acceptance-to-output latency (clock periods) | 2 (expected) | |
| Initiation interval (cycles) | 1 (expected) | |
| Timing constraints fully checked? | | |

**Figure 4 — Vivado utilization report:** [Insert screenshot]  
**Figure 5 — Vivado timing summary:** [Insert screenshot]  
**Figure 6 — Elaborated or synthesized datapath schematic (optional):** [Insert screenshot]

**Timing conclusion:** [Explain whether setup and hold constraints pass. A 10 ns target does not by itself establish actual 100 MHz timing closure.]

**Comparison conclusion:** [Explain measured resource/timing differences only if an equivalent registered comparison was implemented.]

### 3.6 Optional FPGA Demonstration — Nexys A7

Complete only if the hardware wrapper was used.

| Resource | Lab mapping | Observed result |
|---|---|---|
| `SW[7:0]` | Operand A, signed encoded | |
| `SW[15:8]` | Operand B, signed encoded | |
| `LED[7:0]` | Encoded product | |
| `LED[8]` | Saturation flag | |
| `LED[9]` | Output valid | |
| `BTNC` | Reset input | |
| `CLK100MHZ` | Board clock | |

**XDC pin / clock-constraint evidence:** [Insert screenshot or link]  
**Bitstream generation / programming:** [Pass / Fail / N/A]  
**Photograph or video evidence:** [Insert evidence]  
**Observation / limitation:** [Keep multi-bit switches steady before interpreting the results; note synchronization and any relevant asynchronous I/O constraints.]

### 3.7 Overall Results Summary

| Lab component | Required evidence | Status (Pass/Fail/Not done) |
|---|---|---|
| A — Signed number encoding | Binary and integer calculations | |
| B — Quantization and saturation | Simulation tables, errors, rounding/truncation comparison | |
| C — Pipeline verification | Timing, bubbles, reset, waveform evidence | |
| Exhaustive checking | 65,536-pair test and console PASS | |
| D — Resources and timing | Utilization, slack, device and constraints | |
| Optional Nexys A7 demo | XDC, bitstream, physical results | |

**Overall verification outcome:** [ ]  
**Most important observation:** [ ]  
**Unresolved issues:** [ ]

---

## 4. Discussion

Answer briefly, using your actual experiment results where relevant.

1. Why does multiplying two signed Q3.4 operands produce a raw product with eight fractional bits?
2. Why does the quantizer use a wider 17-bit signed intermediate?
3. Why is an arithmetic right shift not the same as rounding toward zero for negative values?
4. How do round-to-nearest (ties away from zero) and arithmetic-shift truncation differ in the measured outputs?
5. Why must saturation be applied **before** narrowing the result to eight bits?
6. What happens to quantization error when the correct real product lies outside the representable range?
7. Why is `valid_out` delayed along with the numerical result?
8. Why does a bubble move through the pipeline instead of stopping it?
9. What is the difference between **latency** and **throughput**? Did your results show one valid output each clock after filling?
10. Which combinational operations lie between each pair of pipeline registers?
11. What happens to samples that are in flight when synchronous reset is asserted?
12. Why is an unregistered combinational reference not directly comparable with a registered core using a register-to-register Fmax metric?
13. What do LUT, flip-flop, DSP, setup-slack, and hold-slack numbers indicate about the implemented design?
14. What changes would be needed to extend this multiplier into a **MAC** datapath? Propose an accumulator width and binary-point format.

**Proposed MAC accumulator design:**

| Design decision | Your proposal / justification |
|---|---|
| Number of products to accumulate, K | |
| Product format retained before accumulation | |
| Accumulator width (bits) | |
| Accumulator fractional bits | |
| Reset/enable behavior | |
| Overflow and rounding policy | |
| Valid/timing protocol | |

**Final reflection (one paragraph):**

[Summarize the key numerical, timing, and FPGA-implementation insights.]

---

## Submission Checklist

- [ ] All student/project information supplied.
- [ ] Source-code repository and Vivado version documented.
- [ ] Experiment A encoding table and calculations completed.
- [ ] Experiment B numerical results, errors, and saturation flags recorded.
- [ ] Truncation versus nearest rounding compared.
- [ ] Experiment C pipeline waveforms show edge alignment, bubble, reset, and throughput.
- [ ] Exhaustive 65,536-pair test completed with actual console evidence.
- [ ] Experiment D resource and timing measurements recorded.
- [ ] All discussion questions answered and MAC format proposed.
- [ ] Optional board results labeled N/A if not performed.

**Source:** https://github.com/komsan-k/977-220/tree/main/fpga-2026/week-3/slot-11
