# Laboratory Report Template
## Verilog/SystemVerilog-3 — Sequential Design
### Week 1, Slot 3: Counters and Waveform Analysis

**Course:** 977-220 Electronics and IoT  
**Student Name:** ____________________  
**Student ID:** ____________________  
**Section / Group:** ____________________  
**Date:** ____________________  
**Reference:** https://github.com/komsan-k/977-220/tree/main/fpga-2026/week-1/slot-3

---

## 1. Achievement

**Learning objectives:**
- Implement a synchronous 4-bit binary up counter (`0000` to `1111`).
- Control counting using an `enable` signal and verify the hold condition.
- Implement a direction-controlled up/down counter.
- Build a modulo-10 (decade) counter that wraps from 9 to 0.
- Use EDA Playground and EPWave to inspect `clk`, `reset`, `enable`, `dir`, and `count` waveforms.
- Apply `always_ff` and nonblocking (`<=`) assignments in sequential HDL.

**Achievement summary:**  
[Summarize the circuits implemented, testbenches completed, and important findings in 4–6 sentences.]

## 2. Verilog/SystemVerilog Project URL (Shared)

**GitHub repository / project URL:** [Insert URL]  
**EDA Playground shared URL:** [Insert URL]  

**Repository contents:** HDL design modules, testbench files, waveforms or screenshots, and a short README explaining how to reproduce the results.

## 3. Results

### Task 5 — 4-Bit Up Counter

**Objective:** Implement a rising-edge-triggered binary counter from `0000` to `1111`, then wrap to `0000`.

**HDL implementation:**  
[Insert source code or link to the module.]

**Testbench and stimulus:**  
[Describe clock period, reset assertion/deassertion, simulation duration, and how many rising edges are observed.]

| Event | Expected count | Simulated count | Pass / Fail |
|---|:---:|:---:|:---:|
| Reset sampled at rising edge | `0000` | | |
| 1st rising edge after reset | `0001` | | |
| 2nd rising edge | `0010` | | |
| 3rd rising edge | `0011` | | |
| 4th rising edge | `0100` | | |
| 15th rising edge | `1111` | | |
| 16th rising edge | `0000` | | |

**EPWave evidence:** [Insert screenshot showing `clk`, `reset`, and `count`, including wrap-around.]  
**Verification summary:** [Describe whether the counter increments once per rising edge and wraps after 15.]

### Task 6 — Counter Enable

**Objective:** Pause and resume a 4-bit up counter using an `enable` input.

**HDL implementation:**  
[Insert source code or link to the module.]

**Testbench and stimulus:**  
[Describe when enable is high/low, with input changes placed away from sampling edges.]

| Condition at rising edge | Expected behavior | Simulated count / behavior | Pass / Fail |
|---|---|---|---|
| `reset=1` | Clear to `0000` | | |
| `reset=0`, `enable=1` | Count + 1 | | |
| `reset=0`, `enable=0` | Hold previous count | | |
| `enable=0` for 3 edges | Remain unchanged | | |
| `enable` changes 0 → 1 | Resume from held count | | |

**EPWave evidence:** [Insert screenshot showing `clk`, `reset`, `enable`, and `count` across pause/resume.]  
**Verification summary:** [Explain what happens while enable is low.]

### Task 7 — Up/Down Counter

**Objective:** Implement a 4-bit counter with `dir=1` for counting up and `dir=0` for counting down; use `enable` to control operation.

**HDL implementation:**  
[Insert source code or link to the module.]

**Testbench and stimulus:**  
[Describe direction changes, enabling/disabling, and reset.]

| Condition at rising edge | Example current count | Expected next count | Simulated count | Pass / Fail |
|---|:---:|:---:|:---:|:---:|
| `reset=1` | Any | `0000` | | |
| `enable=1`, `dir=1` | `0010` | `0011` | | |
| `enable=1`, `dir=0` | `0011` | `0010` | | |
| `enable=0` | `0010` | `0010` | | |
| `enable=1`, `dir=0` | `0000` | `1111` | | |
| `enable=1`, `dir=1` | `1111` | `0000` | | |

**EPWave evidence:** [Insert screenshot showing `clk`, `reset`, `enable`, `dir`, and `count`.]  
**Verification summary:** [Discuss direction control, hold behavior, and wrap-around.]

### Task 8 — Modulo-10 Counter

**Objective:** Implement a decade counter that follows `0 → 1 → … → 9 → 0`.

**HDL implementation:**  
[Insert source code or link to the module.]

**Testbench and stimulus:**  
[Describe clock, reset, and a simulation long enough to observe at least one complete decade.]

| Event | Expected decimal count | Simulated count | Pass / Fail |
|---|:---:|:---:|:---:|
| Reset sampled at rising edge | 0 | | |
| 1st rising edge after reset | 1 | | |
| 2nd rising edge | 2 | | |
| 8th rising edge | 8 | | |
| 9th rising edge | 9 | | |
| 10th rising edge | 0 | | |
| 11th rising edge | 1 | | |

**EPWave evidence:** [Insert screenshot showing `clk`, `reset`, and `count`, especially `9 → 0`.]  
**Verification summary:** [Explain why a modulo-10 counter resets at 9 rather than wrapping at 15.]

### Task 10 — Waveform Analysis

**Objective:** Use EPWave to examine clock, reset, control inputs, and stored outputs in all four counter designs.

**Waveform capture details:**  
**Simulator:** ____________________  
**Clock period:** __________ ns  
**Reset type used:** Synchronous / Asynchronous (circle one for each design)  
**Simulation duration:** __________ ns  

| Circuit | Signals to display | Key observation at clock edges | Screenshot / Figure No. |
|---|---|---|---|
| 4-bit up counter | `clk`, `reset`, `count` | Increment and `15 → 0` wrap | |
| Counter with enable | `clk`, `reset`, `enable`, `count` | Hold while `enable=0` | |
| Up/down counter | `clk`, `reset`, `enable`, `dir`, `count` | Direction reversal | |
| Modulo-10 counter | `clk`, `reset`, `count` | `9 → 0` transition | |

**Waveform screenshots and annotations:**  
[Insert labeled screenshots. Mark at least one rising edge, reset event, pause interval, direction change, and wrap-around event.]

**Waveform interpretation:**  
[Explain why stored outputs update on the selected clock edge, and how this differs from combinational circuits.]

### Overall Verification Summary

| Task | Circuit / analysis | Completed? | Pass / Fail | Evidence reference |
|---|---|:---:|:---:|---|
| 5 | 4-bit up counter | | | |
| 6 | Counter enable | | | |
| 7 | Up/down counter | | | |
| 8 | Modulo-10 counter | | | |
| 10 | EPWave waveform analysis | | | |

**Overall results:** [Report number of tests passed/failed and any implementation limitations.]

## 4. Discussion

1. Why does a 4-bit up counter have 16 states, and what causes wrap-around from 15 to 0?
2. What is the difference between a rising-edge-triggered counter and combinational logic?
3. How does `enable=0` preserve the current count without an explicit self-assignment?
4. What happens when `enable` returns to 1?
5. How is the direction selected in the up/down counter?
6. What happens when an up/down counter decrements from `0000`?
7. How is a modulo-10 counter different from an ordinary 4-bit binary counter?
8. Why is reset required for predictable startup behavior?
9. Why is a nonblocking assignment (`<=`) recommended inside `always_ff`?
10. How does EPWave help confirm timing behavior and identify logic errors?
11. Why should testbench inputs normally change away from the active clock edge?
12. What problems did you encounter and how did you resolve them?

**Final reflection:**  
[Write a short paragraph explaining how counters and state storage support timers, control systems, FSMs, and FPGA datapaths.]

---

## Submission Checklist

- [ ] Student information and shared project links completed.
- [ ] All four HDL counter implementations included.
- [ ] Testbenches and relevant stimulus descriptions provided.
- [ ] Truth/verification tables completed with actual simulation results.
- [ ] EPWave screenshots for each task included and labeled.
- [ ] Hold, direction change, and wrap-around behaviors demonstrated.
- [ ] Discussion and final reflection completed.
