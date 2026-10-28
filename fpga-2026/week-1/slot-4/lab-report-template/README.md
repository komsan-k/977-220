# Laboratory Report Template
## 977-220 Electronics and IoT — Week 1, Slot 4
### Verilog/SystemVerilog-4: Finite-State Machine (FSM) Design
**Focus:** Moore FSM, state tables, behavioral simulation, timer-controlled transitions, and Moore–Mealy comparison  
**Reference:** https://github.com/komsan-k/977-220/tree/main/fpga-2026/week-1/slot-4

**Student Name:** ____________________________________  
**Student ID:** ______________________________________  
**Lab Date:** ________________________________________


> **Instructions:** Complete **Tasks 1, 3, 4, 5, and 7** only. Insert your *own* diagrams, HDL code, simulation screenshots, and observations. State whether each test passes or fails. The example states and expected transitions follow the Slot 4 traffic-light FSM exercise: **RED → GREEN → YELLOW → RED**. Actual observations must be obtained from your simulations.

---

## 1. Achievement

### 1.1 Intended learning outcomes

After completing this laboratory, I can:
- Draw and explain a three-state **Moore FSM** for a traffic-light controller.
- Construct a complete **state-transition and output table**.
- Implement and simulate an FSM with `always_ff` and `always_comb`.
- Verify **reset**, state transitions, and lamp outputs using **EDA Playground / EPWave**.
- Add `timer_done` so the FSM advances only on the active clock edge when the timer condition is asserted.
- Compare **Moore** and **Mealy** output behavior and timing.

### 1.2 Achievement summary

[In 60–100 words, describe what you implemented, verified, and learned. Mention any unfinished or failed tests.]

---

## 2. Verilog/SystemVerilog Project URL (Shared)
 
**EDA Playground shared URL:** [Paste link]  
**Simulator and language/version:** [e.g., SystemVerilog; simulator used]  


**Shared-project checklist:**
- [ ] FSM source code included
- [ ] Testbench source code included
- [ ] EPWave screenshots or VCD evidence included
- [ ] Project link publicly viewable or shared with the instructor

---

## 3. Results

### Task 1 — Moore FSM Concept
**Objective:** Draw a three-state Moore FSM.

**State names and outputs:**

| State | Meaning | Red | Yellow | Green |
|---|---|:---:|:---:|:---:|
| RED | Red lamp active | 1 | 0 | 0 |
| GREEN | Green lamp active | 0 | 0 | 1 |
| YELLOW | Yellow lamp active | 0 | 1 | 0 |

**3.1 State diagram**

[Insert your drawn state diagram here. Show **RED → GREEN → YELLOW → RED**, arrows, and the reset/initial state. Label each state with its output values.]

**Figure 1.** Three-state Moore traffic-light FSM.

**3.2 Explanation**  
[Explain why this is a Moore FSM and how state determines lamp outputs.]

**Verification checkpoint:** [ ] Diagram contains all states, transitions, outputs, and reset state.

### Task 3 — State Table
**Objective:** Create the complete state/output table.

**3.3 Basic FSM state table (unconditional transition)**

| Current state | Next state | Red | Yellow | Green |
|---|---|:---:|:---:|:---:|
| RED | GREEN | 1 | 0 | 0 |
| GREEN | YELLOW | 0 | 0 | 1 |
| YELLOW | RED | 0 | 1 | 0 |

**3.4 State encoding**

| State | Assigned binary code |
|---|---|
| RED | `00` |
| GREEN | `01` |
| YELLOW | `10` |

**3.5 State-table analysis**  
[Explain the meaning of current state, next state, and output columns. Discuss what should happen after reset.]

### Task 4 — Behavioral Simulation
**Objective:** Verify all state transitions using EPWave.

**3.6 FSM design code**

```systemverilog
// Insert the SystemVerilog FSM source code here.
// Include the state register, next-state logic, and output logic.
```

**3.7 Testbench code**

```systemverilog
// Insert the testbench here.
// Include clock generation, reset, VCD dumping, and simulation duration.
```

**3.8 Expected versus simulated behavior**

| Checkpoint | Expected state | Expected (Red, Yellow, Green) | Observed state | Observed outputs | Pass/Fail |
|---|---|---|---|---|---|
| Reset sampled | RED | `(1,0,0)` | | | |
| 1st rising edge after reset release | GREEN | `(0,0,1)` | | | |
| 2nd rising edge | YELLOW | `(0,1,0)` | | | |
| 3rd rising edge | RED | `(1,0,0)` | | | |
| 4th rising edge | GREEN | `(0,0,1)` | | | |

**3.9 Waveform screenshot**

[Insert EPWave screenshot showing `clk`, `reset`, `state`, `next_state` (if accessible), `red`, `yellow`, and `green`. Mark representative rising edges.]

**Figure 2.** EPWave verification of Moore FSM state transitions and outputs.

**3.10 Verification summary**  
[Describe whether the state changed only at rising clock edges and whether lamp outputs matched each state. Record any failures.]

### Task 5 — Add Timer Input
**Objective:** Modify the traffic FSM so transitions occur only when `timer_done = 1` at a rising clock edge.

**3.11 Design changes**

[Describe how `timer_done` is added to the FSM and used in the next-state logic.]

```systemverilog
// Insert modified timer-controlled FSM source code here.
```

**3.12 Timer-enabled transition table**

| Current state | `timer_done` | Expected next state | Expected outputs (R,Y,G) | Simulated next state | Pass/Fail |
|---|:---:|---|---|---|---|
| RED | 0 | RED | `(1,0,0)` | | |
| RED | 1 | GREEN | `(1,0,0)` before edge; `(0,0,1)` after edge | | |
| GREEN | 0 | GREEN | `(0,0,1)` | | |
| GREEN | 1 | YELLOW | `(0,0,1)` before edge; `(0,1,0)` after edge | | |
| YELLOW | 0 | YELLOW | `(0,1,0)` | | |
| YELLOW | 1 | RED | `(0,1,0)` before edge; `(1,0,0)` after edge | | |

> **Timing note:** `timer_done` is an input to combinational next-state logic. In this synchronous implementation, asserting it does **not** immediately change the stored state; the state advances at the next active clock edge.

**3.13 Testbench and stimulus**

```systemverilog
// Insert testbench including timer_done pulses and hold intervals.
// Drive timer_done away from the clock sampling edge.
```

**3.14 EPWave screenshot**

[Insert a screenshot showing `clk`, `reset`, `timer_done`, `state`, and lamp outputs. Highlight a hold period and a timer-enabled transition.]

**Figure 3.** EPWave verification of timer-controlled state hold and transition.

**3.15 Verification summary**  
[Explain how the FSM behaves with `timer_done = 0` and `timer_done = 1`.]

### Task 7 — Compare Moore and Mealy
**Objective:** Explain the difference in output timing.

**3.16 Comparison table**

| Characteristic | Moore FSM | Mealy FSM |
|---|---|---|
| Output depends on | Current state | Current state and current input |
| Output expression | `Y = g(state)` | `Y = g(state, input)` |
| Response to changing input between clock edges | Output usually remains unchanged until the state updates | Output may change immediately through combinational logic |
| Output sensitivity | Less directly sensitive to input glitches | Can be sensitive to input glitches |
| Example in Slot 4 | Traffic-light controller | `101` sequence detector |

**3.17 Conceptual timing comparison**

[Draw or insert timing sketches for a Moore output and a Mealy output relative to changing input and the clock edge. Clearly label whether the output is registered or combinational.]

**Figure 4.** Moore-versus-Mealy output timing comparison.

**3.18 Explanation**  
[In 100–150 words, explain why the Moore FSM output is based on the stored state while Mealy output also depends on the current input. Relate your answer to the traffic-light FSM and the `101` detector described in the lesson.]

### 3.19 Overall verification summary

| Selected task | Expected evidence | Result / status | Remarks |
|---|---|---|---|
| Task 1 — Moore FSM concept | State diagram | | |
| Task 3 — State table | State/output table | | |
| Task 4 — Behavioral simulation | Code, table, EPWave | | |
| Task 5 — Timer input | Modified code, hold/advance evidence | | |
| Task 7 — Moore vs Mealy | Comparison and timing diagram | | |

**Overall observations and limitations:**  
[Summarize successful tests, failed tests, debugging steps, and remaining limitations.]

---

## 4. Discussion

Answer the following using **your own results**.

1. What three functional blocks make up a typical FSM?
2. Why is the traffic-light controller in this laboratory considered a Moore FSM?
3. Which state does the traffic-light controller enter after reset? How is this confirmed in EPWave?
4. Why are `always_ff` and `always_comb` used for different parts of an FSM?
5. Which signal or event causes the FSM to move between states in Task 4?
6. What happens when `timer_done = 0` in Task 5?
7. Why must `timer_done = 1` be sampled at the active clock edge before the stored state changes?
8. How do lamp outputs reflect the current state in the timer-controlled FSM?
9. What is the difference between a Moore output and a Mealy output when an input changes between clock edges?
10. How might a Mealy output become sensitive to glitches on its input?


