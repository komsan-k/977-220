# Laboratory Report Template
## 977-220 Electronics and IoT — Week 3, Slot 10: Multiplier Study Case

**Reference:** https://github.com/komsan-k/977-220/tree/main/fpga-2026/week-3/slot-10  
**Student name:** ____________________  
**Student ID:** ____________________  
**Date:** ____________________  
**Vivado version / target FPGA:** ____________________

> **Scope:** Complete Tasks **3–6**. Record results from your own implementation; do not replace experimental evidence with expected values.

---

## 1. Achievement

After completing this lab, I can:

- Construct four shifted partial-product rows for a **4 × 4-bit unsigned multiplier**.
- Explain how binary multiplication produces an **8-bit product**.
- Connect **three ripple-carry adders** to sum the partial-product rows.
- Implement an equivalent multiplier using the Verilog/SystemVerilog `*` operator.
- Build or run an **exhaustive testbench for 16 × 16 = 256 input pairs**.
- Compare the structural and multiplication-operator designs using simulation results.

**Achievement summary (4–6 sentences):**

[Describe what you implemented, tested, and learned.]

---

## 2. Verilog/SystemVerilog 

**GitHub repository URL:** [Insert link]  
**Vivado project / source files:** [Insert path or link]  
**Shared simulation results:** [Insert path or link]

**Project file checklist:**

- [ ] Full-adder / ripple-adder source modules
- [ ] Structural four-bit multiplier source module
- [ ] `*`-operator multiplier source module
- [ ] Exhaustive testbench source
- [ ] Simulation screenshots or log
- [ ] README describing how to reproduce the results

---

## 3. Results

### Task 3 — Four Shifted Partial-Product Rows

**Objective:** Construct the four partial-product rows and manually verify **11 × 5**.

For unsigned inputs `A[3:0]` and `B[3:0]`, the rows correspond to `A & {4{B[i]}}`, shifted left by `i` for `i = 0,1,2,3`. Use **8-bit alignment** in the report.

**Input operands:**

- `A = 11 = 4'b1011`
- `B = 5  = 4'b0101`

**Manual partial-product calculation:**

| Row | Multiplier bit | 4-bit partial product (before shifting) | 8-bit shifted row |
|---|---|---|---|
| `PP0` | `B[0] = 1` | `1011` | `00001011` |
| `PP1` | `B[1] = 0` | `0000` | `00000000` |
| `PP2` | `B[2] = 1` | `1011` | `00101100` |
| `PP3` | `B[3] = 0` | `0000` | `00000000` |
| **Sum** | | | **`00110111` = 55** |

**Handwritten calculation / annotated figure:**

[Insert your own working or screenshot showing the four aligned rows and the binary addition.]

**RTL used to generate partial products (if applicable):**

```systemverilog
// Paste the actual partial-product generation code here.
```

**Verification:** Expected product = `8'b00110111` = **55**.  
**Your simulated result:** ______________  
**Status:** [ ] PASS  [ ] FAIL

**Observation:** [Explain why PP1 and PP3 are zero and why PP2 is shifted by two positions.]

### Task 4 — Three Ripple Adders for the Structural Multiplier

**Objective:** Instantiate **three ripple-carry adders** to sum the four aligned partial-product rows.

**Hierarchy / architecture:**

```text
A[3:0], B[3:0]
       |
  Partial-product generation
       |
  PP0  PP1  PP2  PP3   (each zero-extended/shifted to 8 bits)
    \  /      |    |
   Ripple Adder 1   |
         |      |   |
    Ripple Adder 2  |
           |        |
      Ripple Adder 3
           |
        P[7:0]
```

**Design/source modules:**

```systemverilog
// Paste your ripple-adder module and structural multiplier top module.
// Identify all three ripple-adder instantiations.
```

**Hierarchy evidence:**

[Insert Vivado hierarchy or elaborated RTL screenshot, with the three ripple-adder instances labeled.]

**Intermediate arithmetic verification:**

| Stage | Operation | Expected 8-bit result | Simulated result | Pass/Fail |
|---|---|---|---|---|
| Adder 1 | `PP0 + PP1` | `00001011` | | |
| Adder 2 | `(PP0+PP1) + PP2` | `00110111` | | |
| Adder 3 | `previous + PP3` | `00110111` | | |

**Final structural product for 11 × 5:** ______________  
**Status:** [ ] PASS  [ ] FAIL

**Discussion of carry propagation:** [Identify which adder signals carry intermediate results, and explain how the final 8-bit product is formed.]

### Task 5 — Multiplication-Operator Version

**Objective:** Implement the equivalent unsigned 4 × 4 multiplier using `*`.

**RTL source:**

```systemverilog
// Paste your actual multiplier implementation using A * B.
// Show operand and product widths explicitly.
```

**Selected functional comparisons:**

| A (decimal) | B (decimal) | Expected product (decimal) | Structural result | `*` result | Both pass? |
|---:|---:|---:|---|---|---|
| 0 | 0 | 0 | | | |
| 1 | 15 | 15 | | | |
| 3 | 7 | 21 | | | |
| 5 | 11 | 55 | | | |
| 11 | 5 | 55 | | | |
| 15 | 15 | 225 | | | |

**Simulation waveform screenshot:**

[Insert screenshot showing A, B, structural product and operator product over several tests.]

**Comparison (3–5 sentences):**

[Discuss RTL complexity, readability, hierarchy, and functional equivalence. Do not claim resource/timing superiority without synthesis evidence.]

### Task 6 — Exhaustive Testbench: All 256 Operand Pairs

**Objective:** Test every unsigned four-bit pair: `A = 0…15`, `B = 0…15`.

**Testbench source:**

```systemverilog
// Paste the actual exhaustive testbench here.
// It should drive all 256 pairs, calculate the expected product,
// and compare BOTH multiplier implementations to the reference.
```

**Verification checklist:**

- [ ] All values of A from 0 to 15 tested
- [ ] All values of B from 0 to 15 tested for each A
- [ ] Total checked cases = 256
- [ ] Expected result computed with sufficient width (8 bits)
- [ ] Both structural and `*` results checked
- [ ] No unknown (`X`) or high-impedance (`Z`) products overlooked
- [ ] PASS/FAIL summary printed to the simulation console

**Simulation summary:**

| Verification metric | Reported value |
|---|---|
| Total input pairs executed | |
| Structural multiplier passes | |
| Structural multiplier failures | |
| `*` multiplier passes | |
| `*` multiplier failures | |
| Structural vs operator mismatches | |
| Final conclusion | PASS / FAIL |

**Simulation console screenshot:**

[Insert Vivado XSim console screenshot showing total number of tests and any failure count.]

**Waveform screenshot:**

[Insert waveform demonstrating representative boundary cases, e.g., 0×15, 11×5, and 15×15.]

**Failure details (only if applicable):**

| A | B | Expected | Structural | Operator | Suspected cause / fix |
|---|---|---|---|---|---|
| | | | | | |

### Overall Result Summary

| Task | Deliverable | Evidence included | PASS/FAIL |
|---|---|---|---|
| 3 | Four shifted rows; manual 11 × 5 | Calculation + check | |
| 4 | Three ripple-adder instances | HDL + hierarchy + intermediate checks | |
| 5 | Multiplication-operator multiplier | HDL + comparative simulation | |
| 6 | Exhaustive 256-pair verification | Testbench + log + waveform | |

**Overall lab result:** [ ] PASS  [ ] NEEDS CORRECTION  
**Summary of issues and corrections:** [Write here.]

---

## 4. Discussion

Answer with evidence from your implementation and simulation.

1. Why are **four** shifted partial-product rows required for a 4-bit multiplier?
2. Why does the unsigned product of two 4-bit operands require up to **8 bits**?
3. Show how `1011 × 0101` gives the result `00110111`.
4. Why are **three** adders sufficient to sum four partial-product rows in the chosen architecture?
5. What is the role of carry propagation in the ripple-carry adders?
6. How do the structural and `*`-operator multiplier descriptions differ?
7. Do both implementations generate identical outputs for **all 256 input pairs**? Cite the testbench report.
8. Why is exhaustive verification practical for this 4 × 4-bit design?
9. Which test cases are particularly useful for identifying width, shifting, or carry errors?
10. What would you change to extend this design to an 8 × 8-bit multiplier?

**Final reflection (4–6 sentences):**

[Summarize how structural arithmetic, hierarchy, and exhaustive simulation contribute to reliable FPGA design.]

---

## Submission Checklist

- [ ] Personal information and project links completed
- [ ] Task 3 manual partial-product calculation included
- [ ] Task 4 RTL and three ripple-adder instances documented
- [ ] Task 4 Vivado hierarchy screenshot included
- [ ] Task 5 `*`-operator RTL and comparison included
- [ ] Task 6 source testbench and 256-case summary included
- [ ] All required waveform / console screenshots included
- [ ] All tables filled with actual observations
- [ ] Discussion and final reflection completed

**Note:** Expected values above are reference calculations; write the *actual* values from your simulations in the blank columns. The GitHub page was not independently accessible while preparing this template; the task scope follows the four tasks supplied in the request.
