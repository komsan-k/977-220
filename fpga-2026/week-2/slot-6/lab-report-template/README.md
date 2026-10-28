# Laboratory Report Template — Vivado FPGA LED Blinker

**Course:** 977-220 Electronics and IoT  
**Laboratory:** Week 2, Slot 6 — LED Blinker: Simulation to FPGA Implementation  
**Reference:** https://github.com/komsan-k/977-220/tree/main/fpga-2026/week-2/slot-6  
**Student name:** ____________________  
**Student ID:** ____________________  
**Lab date:** ____________________  
**FPGA board / device:** ____________________  
**Vivado version:** ____________________

> **Scope:** Complete Tasks 2–10. Insert your own screenshots, measured values, code, and verification results. Do not report an implementation as PASS without supporting evidence. The GitHub page could not be retrieved when this template was prepared; task descriptions are based on the supplied assignment.

---

## 1. Achievement

After completing this laboratory, I can:

- [ ] Implement a counter-based LED blinking circuit in Verilog/SystemVerilog.
- [ ] Simulate an accelerated blinker and verify LED transitions.
- [ ] Apply the board clock and LED pin constraints in an XDC file.
- [ ] Identify the counter and output logic in an elaborated RTL schematic.
- [ ] Interpret synthesis utilization and implementation timing results.
- [ ] Generate a bitstream, program the FPGA, and observe blinking on the board.

**Achievement summary (60–100 words):**  
[Describe the completed design flow and the major outcome of each stage.]

---

## 2. Verilog/SystemVerilog 


**Files included:**

- [ ] RTL source (`.v` / `.sv`)
- [ ] Testbench source
- [ ] XDC constraints
- [ ] Simulation screenshots / logs
- [ ] RTL schematic screenshot
- [ ] Synthesis utilization report
- [ ] Implementation timing report
- [ ] Bitstream generation evidence
- [ ] Hardware Manager / board verification evidence

> Avoid uploading large automatically generated Vivado folders unnecessarily. Provide the reproducible source files and evidence needed by your instructor.

---

## 3. Results

### Task 2 — Implement LED Blinker

**Objective:** Write a counter-based LED blinking module.

**Design parameters**

| Parameter | Design value | Notes |
|---|---|---|
| FPGA board | | |
| Clock frequency, `f_clk` (Hz) | | From board clock specification |
| Counter width (bits) | | |
| Counter terminal value / limit | | |
| LED toggle interval (s) | | |
| Expected full LED period (s) | | |
| Expected blink frequency (Hz) | | |
| Reset type and polarity | | If implemented |

**Design equation / reasoning:**  
For a design that toggles the LED once every `N` clock cycles:

- Toggle interval: `T_toggle = N / f_clk`
- Full ON–OFF period: `T_LED = 2N / f_clk`
- Blink frequency: `f_LED = f_clk / (2N)`

Explain your exact RTL terminal-count convention (for example, counting `0` through `N−1`) and calculate the expected blinking frequency:  
[Your calculation]

**RTL implementation:**

```systemverilog
// Paste the implemented LED blinker module here.
```

**Explanation:** [Describe the counter increment, threshold comparison, reset, and LED toggle behavior.]

### Task 3 — Behavioral Simulation

**Objective:** Use a reduced counter width or terminal count to observe LED toggling quickly in simulation.

**Simulation settings**

| Item | Value |
|---|---|
| Testbench clock period | |
| Reduced counter width / terminal count | |
| Expected cycles per LED toggle | |
| Expected time per LED toggle | |
| Total simulated duration | |
| Simulator | Vivado XSim |

**Testbench:**

```systemverilog
// Paste the testbench used to generate clock and verify LED transitions.
```

**Waveform evidence:**  
[Insert screenshot showing `clk`, `counter` (if accessible), and `led` with a readable time axis.]

**Verification table**

| Event / interval | Expected LED | Observed LED | Time or cycle | Pass/Fail |
|---|---|---|---|---|
| After initialization / reset | | | | |
| First toggle | | | | |
| Second toggle | | | | |
| Third toggle | | | | |

**Interpretation:** [Explain whether the observed toggle interval agrees with the expected count.]

### Task 4 — Add XDC Constraints

**Objective:** Assign the onboard clock and onboard LED to the correct FPGA pins.

**XDC excerpt:**

```tcl
# Paste the actual board-specific clock and LED constraint lines.
# Include clock pin, IOSTANDARD, LED pin, and create_clock where required.
```

| Signal / port | Package pin | I/O standard | Clock period, if relevant | Verified source |
|---|---|---|---|---|
| `clk` | | | | |
| `led` | | | N/A | |

**Evidence:** [Insert screenshot of active constraints and/or I/O Ports view.]

**Check:** The top-module port names must match the XDC port references exactly. Use the correct master XDC for the actual FPGA board; do not assume pin assignments.

### Task 5 — RTL Analysis

**Objective:** Open the elaborated schematic and identify the counter and LED control logic.

**RTL schematic screenshot:**  
[Insert elaborated-design schematic, with relevant blocks highlighted.]

| Component | Observed RTL element / signal | Role |
|---|---|---|
| Counter register | | Stores count |
| Increment logic | | Updates count |
| Terminal-count comparator | | Detects toggle condition |
| LED register / logic | | Updates output |
| Clock / reset | | Controls sequential elements |

**Explanation:** [Trace the logic path from clock to counter to LED output.]

### Task 6 — Synthesis

**Objective:** Run synthesis and inspect FPGA utilization.

**Evidence:** [Insert screenshot of synthesis completion and utilization report.]

| Resource / metric | Used | Available | Utilization (%) |
|---|---:|---:|---:|
| LUTs | | | |
| Flip-flops (FFs) | | | |
| I/O pins | | | |
| BUFG / clock buffers | | | |
| Other relevant resources | | | |

**Observations:** [Identify the major logic resources and explain why the counter consumes flip-flops and combinational logic.]

### Task 7 — Implementation

**Objective:** Run placement and routing and check timing.

**Evidence:** [Insert implemented-design screenshot and timing summary.]

| Metric | Reported value | Interpretation |
|---|---|---|
| Clock period constraint | | |
| Worst Negative Slack (WNS) | | |
| Total Negative Slack (TNS) | | |
| Timing status / violations | | |
| Placement-and-route status | | |

**Timing conclusion:** [State whether the reported timing requirements were met. Quote the actual report rather than assuming success.]

### Task 8 — Generate Bitstream

**Objective:** Generate the FPGA programming bitstream.

| Item | Result |
|---|---|
| Bitstream generation status | |
| Output `.bit` filename / location | |
| Errors or critical warnings | |

**Evidence:** [Insert screenshot of successful bitstream generation and/or `.bit` output location.]

### Task 9 — Program FPGA

**Objective:** Program the FPGA using Hardware Manager.

**Programming record**

| Item | Observation |
|---|---|
| Hardware connection detected | |
| FPGA device recognized | |
| Bitstream selected | |
| Programming status | |
| Errors / troubleshooting | |

**Evidence:** [Insert Hardware Manager screenshot showing the recognized device and programming outcome.]

### Task 10 — Verify LED

**Objective:** Confirm that the onboard LED blinks continuously on the programmed FPGA.

| Observation | Expected | Measured / observed | Pass/Fail |
|---|---|---|---|
| LED toggles ON and OFF | Yes | | |
| Blinking continues without intervention | Yes | | |
| Observed full ON–OFF period | Design expectation | | |
| Observed blink frequency (if measured) | Design expectation | | |

**Photo or video evidence:** [Insert a link to a short video or time-stamped photographs showing the LED behavior.]

**Analysis:** [Compare observed blinking with the design calculation. Note that a static photograph alone cannot establish a blinking rate.]

### Overall Verification Summary

| Task | Evidence supplied | Result (Pass/Fail/Not tested) | Notes |
|---|---|---|---|
| 2 — LED Blinker RTL | | | |
| 3 — Behavioral Simulation | | | |
| 4 — XDC Constraints | | | |
| 5 — RTL Analysis | | | |
| 6 — Synthesis | | | |
| 7 — Implementation / Timing | | | |
| 8 — Bitstream | | | |
| 9 — FPGA Programming | | | |
| 10 — Physical LED Verification | | | |

**Overall conclusion:** [Summarize whether the complete RTL-to-hardware workflow was verified, and identify any incomplete stages.]

---

## 4. Discussion

Answer each question with reference to your own source code, simulation output, and Vivado reports.

1. How does a clock-driven counter produce a visible LED blink?
2. How are counter width and terminal count related to the toggle interval?
3. Why is a reduced counter limit useful for behavioral simulation?
4. How do you distinguish an LED toggle interval from a complete ON–OFF period?
5. Why are an FPGA clock constraint and accurate I/O pin constraints necessary?
6. What is the difference between the elaborated RTL schematic and the synthesized design?
7. Which hardware resources are used by the LED blinker, and why?
8. What do WNS and TNS indicate about implementation timing?
9. What is the difference between synthesis, implementation, and bitstream generation?
10. What does Hardware Manager do when programming an FPGA?


