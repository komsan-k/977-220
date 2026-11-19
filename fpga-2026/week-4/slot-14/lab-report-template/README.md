# Topic-14: AI-FPGA — ANN for Smart Traffic Control

## Laboratory Worksheet and Report Template

**Course:** 977-220 FPGA  

**Student name:** __________________________________________  
**Student ID:** _____________________________________________  
**Date:** _____________________  


> **Instructions:** Complete the tables and questions as you perform the laboratory. Attach Verilog source files, simulation waveforms, Vivado reports, and FPGA demonstration evidence. Record *measured* results rather than assuming that expected results were observed. The source laboratory supplies an illustrative threshold-based ANN for FPGA **inference**; Python training is optional.

---

## 1. Learning Objectives

After completing the laboratory, students should be able to:

1. Explain a 2-input, 3-hidden-neuron, 2-output-neuron (2–3–2) ANN for traffic classification.
2. Calculate hidden-neuron thresholds and the resulting traffic class.
3. Implement hierarchical ANN inference and a green-time selection circuit in Verilog.
4. Verify the design using the `tb_smart_traffic_ai` testbench and Vivado XSim.
5. Deploy the design using FPGA switches and LEDs.
6. Record synthesis utilization and compare fixed-time versus adaptive green-time selection.
7. Distinguish a green-time **selection value** from an actual timed traffic-light FSM.

## 2. Equipment and Software

| Item | Purpose | Available? |
|---|---|:---:|
| FPGA board (Nexys A7 / Basys 3) | Hardware implementation | ☐ |
| USB cable and PC | Programming and development | ☐ |
| Vivado and XSim (or equivalent) | Design, simulation, synthesis | ☐ |
| Verilog HDL source files | ANN and timing selector | ☐ |
| FPGA switches and LEDs | Input and output demonstration | ☐ |
| 7-segment display (optional) | Display selected green time | ☐ |
| Python (optional) | Offline training and weight generation | ☐ |

## 3. Background: ANN-Based Traffic Classification

Two 4-bit inputs represent traffic levels on two roads:

- `road_a[3:0]` / `x1`: Road A traffic measurement (0–15).
- `road_b[3:0]` / `x2`: Road B traffic measurement (0–15).

The supplied design uses three hidden threshold neurons and a two-bit traffic-class output:

```mermaid
flowchart LR
    A["Road A: road_a[3:0]"] --> HL["ANN Hidden Layer: H1, H2, H3"]
    B["Road B: road_b[3:0]"] --> HL
    HL --> OL["ANN Output Layer"]
    OL --> C["traffic_class[1:0]"]
    C --> GT["Green-Time Controller"]
    GT --> T["green_time[5:0]"]
    C --> LED["LED1–LED0"]
```

**Figure 1.** System-level data path. The source's `green_time_controller` selects a numeric duration; it does not itself implement a countdown or red/yellow/green FSM.

### 3.1 Traffic-class encoding

| `traffic_class` | Traffic condition | Selected `green_time` |
|:---:|---|---:|
| `2'b00` | Low | 10 s |
| `2'b01` | Medium | 20 s |
| `2'b10` | High | 30 s |
| `2'b11` | Reserved; controller defaults to 10 | 10 s (fallback) |

### 3.2 Hidden-neuron equations

The supplied simplified model is:

$$
H_1=f(x_1+x_2-4),\qquad
H_2=f(x_1+x_2-8),\qquad
H_3=f(x_1+x_2-12)
$$

with the step activation:

$$
f(z)=\begin{cases}1,&z>0\,  0,&z\leq0.\end{cases}
$$

Thus, in the supplied Verilog, `H1` is 1 when the sum is at least 5, `H2` at least 9, and `H3` at least 13. The output layer assigns **High** if `H3` or `H2` is active, **Medium** if only `H1` is active, and **Low** otherwise.

**Question 1:** Why is the hidden layer described as a set of traffic-density thresholds?

**Answer:** __________________________________________________________________________

____________________________________________________________________________________

**Question 2:** What is the difference between ANN training and FPGA inference in this laboratory?

**Answer:** __________________________________________________________________________

____________________________________________________________________________________

---

## 4. Task 1 — Manual Calculation and ANN Simulation

### 4.1 Calculate the hidden-neuron states

For each test case, calculate `total = road_a + road_b`, the three hidden outputs, the two-bit class, and the selected green time. The five input pairs are taken from the source laboratory.

| Road A | Road B | Total | H1 | H2 | H3 | Expected class | Expected green time |
|---:|---:|---:|:---:|:---:|:---:|:---:|---:|
| 1 | 1 | 2 | | | | `00` | 10 |
| 3 | 3 | 6 | | | | `01` | 20 |
| 5 | 5 | 10 | | | | `10` | 30 |
| 7 | 7 | 14 | | | | `10` | 30 |
| 2 | 8 | 10 | | | | `10` | 30 |

**Worked example:** Select one case and show each weighted sum / threshold decision.

- Road A = ______, Road B = ______, Total = ______
- `z1 = total − 4 =` ______; `H1 =` ______
- `z2 = total − 8 =` ______; `H2 =` ______
- `z3 = total − 12 =` ______; `H3 =` ______
- `traffic_class =` ______; `green_time =` ______ seconds

### 4.2 Implement the hierarchical Verilog modules

| Module / file | Responsibility | Completed? |
|---|---|:---:|
| `traffic_hidden_layer.v` | Calculate H1, H2, H3 from the traffic inputs | ☐ |
| `traffic_output_layer.v` | Convert hidden states into `traffic_class` | ☐ |
| `traffic_ann.v` | Connect the hidden and output layers | ☐ |
| `green_time_controller.v` | Select 10, 20, or 30 seconds | ☐ |
| `smart_traffic_ai_top.v` | Integrate ANN and green-time selector | ☐ |
| `tb_smart_traffic_ai.v` | Apply traffic test cases | ☐ |

```mermaid
flowchart TD
    TOP["smart_traffic_ai_top"] --> ANN["traffic_ann"]
    TOP --> GTC["green_time_controller"]
    ANN --> H["traffic_hidden_layer"]
    ANN --> O["traffic_output_layer"]
    O -->|traffic_class| GTC
```

**Figure 2.** Verilog hierarchy from the source laboratory.

**Implementation checklist:**

- [ ] Input widths are 4 bits per road; the intermediate traffic sum is wide enough for 0–30.
- [ ] Hidden thresholds are `>= 5`, `>= 9`, and `>= 13` (equivalent to `f(z)` with `z > 0`).
- [ ] The output layer prioritizes High, then Medium, then Low.
- [ ] The `green_time_controller` implements `00 → 10`, `01 → 20`, `10 → 30`.
- [ ] The top module connects `road_a`, `road_b`, `traffic_class`, and `green_time` correctly.
- [ ] No elaboration or syntax errors are reported.

**Attach Figure 3:** Vivado hierarchy or RTL schematic screenshot.

**Figure 3.** [Insert screenshot here]

### 4.3 Run the testbench

Use `tb_smart_traffic_ai` from the source lab. Record the actual results, not only the expected values. The source testbench changes the inputs at 10 ns intervals.

| Road A | Road B | Observed class | Observed green time | Expected class | Expected time | Pass / Fail |
|---:|---:|:---:|---:|:---:|---:|:---:|
| 1 | 1 | | | `00` | 10 | |
| 3 | 3 | | | `01` | 20 | |
| 5 | 5 | | | `10` | 30 | |
| 7 | 7 | | | `10` | 30 | |
| 2 | 8 | | | `10` | 30 | |

**Attach Figure 4:** XSim waveform showing `road_a`, `road_b`, `traffic_class`, and `green_time`; show hidden states if available.

**Figure 4.** [Insert waveform screenshot here]

**Simulation result:** ☐ All cases pass ☐ Some cases fail

**If any case fails, explain the observed behavior:** _______________________________________

____________________________________________________________________________________

### 4.4 Boundary verification (additional analysis)

Test inputs around the decision boundaries. These are supplementary cases for examining the source's threshold behavior.

| Road A | Road B | Total | Expected class | Expected green time | Observed class | Pass / Fail |
|---:|---:|---:|:---:|---:|:---:|:---:|
| 2 | 2 | 4 | `00` | 10 | | |
| 2 | 3 | 5 | `01` | 20 | | |
| 4 | 4 | 8 | `01` | 20 | | |
| 4 | 5 | 9 | `10` | 30 | | |
| 6 | 6 | 12 | `10` | 30 | | |
| 6 | 7 | 13 | `10` | 30 | | |

**Question:** Why does the traffic class remain High when the sum changes from 12 to 13?

**Answer:** __________________________________________________________________________

---

## 5. Task 2 — FPGA Synthesis and Resource Analysis

Run synthesis for `smart_traffic_ai_top` and inspect the Vivado reports. Use the same board/part for all comparisons.

| FPGA resource / metric | Vivado reported result | Notes |
|---|---:|---|
| LUTs | | |
| Flip-flops | | |
| DSP slices | | |
| Block RAM | | |
| I/O pins | | |
| Estimated power (if available) | | |
| Timing / Fmax (only if meaningfully constrained) | | |

**Attach Figure 5:** Synthesis utilization report.

**Figure 5.** [Insert screenshot here]

**Question:** Why might this small threshold-based combinational ANN use LUTs without DSP slices?

**Answer:** __________________________________________________________________________

____________________________________________________________________________________

> **Timing note:** The supplied `smart_traffic_ai_top` is combinational and has no clock input. Do not report a clock-based Fmax for this unregistered top unless you add and document an appropriate clocked wrapper or timing measurement. Enter N/A when not applicable.

---

## 6. Task 3 — FPGA Hardware Testing

Use the board's **official master XDC** to assign input switches and output LEDs. The source provides logical resource assignments but not physical package-pin constraints.

| Verilog signal | FPGA resource | Purpose | Verified? |
|---|---|---|:---:|
| `road_a[3:0]` | SW3–SW0 | Road A traffic | ☐ |
| `road_b[3:0]` | SW7–SW4 | Road B traffic | ☐ |
| `traffic_class[0]` | LED0 | Class bit 0 | ☐ |
| `traffic_class[1]` | LED1 | Class bit 1 | ☐ |
| `green_time[5:0]` | Optional 7-segment interface | Display duration; requires additional display logic | ☐ |

**Hardware verification table**

| SW7–SW4 (Road B) | SW3–SW0 (Road A) | Expected class | LED1 LED0 observed | Pass / Fail |
|---|---|:---:|:---:|:---:|
| `0001` | `0001` | `00` | | |
| `0011` | `0011` | `01` | | |
| `0101` | `0101` | `10` | | |
| `0111` | `0111` | `10` | | |
| `1000` | `0010` | `10` | | |

**Attach Figure 6:** FPGA photograph or instructor-verified demonstration evidence.

**Figure 6.** [Insert FPGA demonstration photograph here]

**Hardware observations:** _____________________________________________________________

____________________________________________________________________________________

---

## 7. Task 4 — Adaptive Green-Time Selection

Verify the mapping implemented by `green_time_controller`.

| `traffic_class` | Expected `green_time` | Observed `green_time` | Pass / Fail |
|:---:|---:|---:|:---:|
| `00` | 10 | | |
| `01` | 20 | | |
| `10` | 30 | | |
| `11` (reserved/fallback) | 10 | | |

**Question 1:** What happens to the selected green time when the traffic class changes from Low to High?

**Answer:** __________________________________________________________________________

**Question 2:** Does the supplied design directly drive red, yellow, and green lamps for 10, 20, and 30 real seconds? Explain.

**Answer:** __________________________________________________________________________

____________________________________________________________________________________

**Extension idea (optional):** Add a clock divider/counter and a traffic-light FSM (`RED → GREEN → YELLOW → RED`) to turn the selected numeric duration into real timed control. This functionality is **not implemented** by the supplied combinational top module.

---

## 8. Task 5 — Fixed-Time vs ANN-Based Adaptive Controller

The source compares a fixed-time example of **20 seconds** with the ANN's class-dependent selection. Complete the table.

| Traffic condition | Fixed-time green selection | ANN green selection | Difference (ANN − Fixed) |
|---|---:|---:|---:|
| Low | 20 s | 10 s | |
| Medium | 20 s | 20 s | |
| High | 20 s | 30 s | |

**Question 1:** Which traffic condition receives a shorter green time under ANN-based selection?

**Answer:** __________________________________________________________________________

**Question 2:** What is a limitation of using only the **sum** of Road A and Road B traffic measurements?

**Answer:** __________________________________________________________________________

____________________________________________________________________________________

**Question 3:** Why is selecting one duration not sufficient for a complete two-road intersection controller?

**Answer:** __________________________________________________________________________

____________________________________________________________________________________

**Comparison summary:** _______________________________________________________________

____________________________________________________________________________________

---

## 9. Discussion Questions

Answer using your calculations, simulation results, and hardware evidence.

1. **Why is ANN training usually performed offline rather than on a small FPGA?**  
   Answer: ______________________________________________________________________

2. **What is the difference between ANN training and ANN inference?**  
   Answer: ______________________________________________________________________

3. **Why can integer/fixed-point arithmetic simplify an FPGA ANN?**  
   Answer: ______________________________________________________________________

4. **How could reducing weight precision affect ANN classification accuracy?**  
   Answer: ______________________________________________________________________

5. **What happens if the traffic measurements fall outside the training data or assumed operating range?**  
   Answer: ______________________________________________________________________

6. **How could cameras or physical traffic sensors replace the switches?**  
   Answer: ______________________________________________________________________

7. **What potential advantages does an FPGA offer for real-time neural-network inference?**  
   Answer: ______________________________________________________________________

8. **How could multiple intersections exchange traffic information?**  
   Answer: ______________________________________________________________________

---

## 10. Optional Extension 

- [ ] Implement four traffic classes: Very Low, Low, Medium, High.
- [ ] Add a third road input `X3` and revise the ANN.
- [ ] Train an ANN in Python and export weights and biases to Verilog.
- [ ] Compare 16-bit, 8-bit, and 4-bit quantized weights.
- [ ] Implement a timed `RED → GREEN → YELLOW → RED` FSM.
- [ ] Display `green_time` using a 7-segment display driver.
- [ ] Compare FPGA resource utilization between two implementations.
- [ ] Extend the controller to choose both the road and its green-light duration.

---

## 11. Conclusion

Summarize the 2–3–2 ANN architecture, threshold calculations, simulation outcome, FPGA implementation, green-time selection, and the main design limitation.

____________________________________________________________________________________

____________________________________________________________________________________

____________________________________________________________________________________


---

### Source and scope

This worksheet is adapted from **Topic-14: AI-FPGA — ANN for Smart Traffic Control**, `977-220/fpga-2026/week-4/slot-14/README.md`. The threshold equations, module names, five original test cases, traffic-class mapping, switch/LED mapping, and five laboratory tasks follow that source. Boundary tests, expanded observation tables, and the explicit distinction between duration selection and a timed FSM are supplementary reporting aids.
