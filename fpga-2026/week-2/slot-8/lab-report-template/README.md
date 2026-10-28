# Laboratory Report Template
## 977-220 — Week 2, Slot 8: Sequential Circuits and FSM Design

**Reference:** [Week 2, Slot 8 GitHub laboratory](https://github.com/komsan-k/977-220/tree/main/fpga-2026/week-2/slot-8)  
**Selected activities:** Task 3 — 4-Bit Counter; Task 4 — Up/Down Counter; Task 5 — Traffic-Light FSM

| Student information | Details |
|---|---|
| Name | |
| Student ID | |
| Group / Section | |
| Date | |
| FPGA board / device (if used) | |
| Vivado version | |

---

## 1. Achievement

### 1.1 Learning outcomes

After completing this laboratory, students should be able to:

- Implement a synchronous 4-bit counter in Verilog/SystemVerilog.
- Extend a counter with direction-controlled up/down operation.
- Represent a three-state traffic-light controller using a state diagram and state table.
- Implement synchronous state transitions using clocked HDL logic.
- Develop testbenches and verify behavior with Vivado XSim waveforms.
- Compare expected and simulated results, documenting any discrepancies.

### 1.2 Achievement summary

**Summarize the circuits implemented, tests completed, and skills gained (approximately 60–100 words).**

> [Write your achievement summary here.]

---

## 2. Verilog/SystemVerilog 
  
**Project name:** [Insert project name]

### 2.1 Project file inventory

| File | Purpose | Included? |
|---|---|---|
| [counter4.sv / .v] | Task 3 — synchronous 4-bit counter | ☐ |
| [updown_counter4.sv / .v] | Task 4 — direction-controlled counter | ☐ |
| [traffic_light_fsm.sv / .v] | Task 5 — three-state FSM | ☐ |
| [tb_counter4.sv / .v] | Counter testbench | ☐ |
| [tb_updown_counter4.sv / .v] | Up/down testbench | ☐ |
| [tb_traffic_light.sv / .v] | FSM testbench | ☐ |
| [screenshots / waveforms] | Simulation evidence | ☐ |

**Note:** Use your actual filenames. Include source and testbench files sufficient for a reader to reproduce the simulations.

---

## 3. Results

### Task 3 — 4-Bit Counter

**Requirement:** Implement a synchronous 4-bit counter.

#### 3.1 Design specification

| Parameter | Student entry |
|---|---|
| Clock edge (rising / falling) | |
| Reset type and active level | |
| Counter width | 4 bits |
| Initial / reset value | |
| Count range | 0000 to 1111 |
| Wrap-around behavior | 1111 → 0000 |

#### 3.2 RTL source code

```systemverilog
// Paste your completed Task 3 module here.
```

#### 3.3 Testbench and simulation setup

```systemverilog
// Paste the Task 3 testbench or key stimulus here.
```

**Clock period:** ______ ns  
**Simulation duration:** ______ ns

#### 3.4 Count sequence verification

Record values **after the active clock edge**, allowing the simulation time needed for nonblocking assignments to update.

| Event / Edge | Expected Q[3:0] | Simulated Q[3:0] | Pass/Fail |
|---|---|---|---|
| Reset applied | 0000 | | |
| 1st count edge | 0001 | | |
| 2nd count edge | 0010 | | |
| 3rd count edge | 0011 | | |
| 4th count edge | 0100 | | |
| 15th count edge | 1111 | | |
| 16th count edge | 0000 | | |

**Figure 1 — Counter waveform:** [Insert XSim screenshot of `clk`, `reset`, and `count[3:0]`.]

**Verification summary:** [Describe counting, clock-edge behavior, and wrap-around.]

### Task 4 — Up/Down Counter

**Requirement:** Add direction control to the counter.

#### 3.5 Direction convention

Specify the direction convention **used in your HDL**:

| Direction input (`dir`) | Operation |
|---|---|
| [0 or 1] | Count up |
| [0 or 1] | Count down |

**Other controls (reset / enable, if implemented):** [Describe.]

#### 3.6 RTL source code

```systemverilog
// Paste your completed Task 4 module here.
```

#### 3.7 Testbench

```systemverilog
// Paste the testbench, including both direction modes.
```

#### 3.8 Direction verification

The following expected results assume **dir=1 means up, dir=0 means down**, counting modulo 16. Adjust the `dir` labels if your design uses the opposite convention.

| Initial Q | dir | Expected next Q | Simulated next Q | Pass/Fail |
|---|---|---|---|---|
| 0010 | 1 (up) | 0011 | | |
| 0111 | 1 (up) | 1000 | | |
| 1111 | 1 (up) | 0000 | | |
| 0101 | 0 (down) | 0100 | | |
| 0001 | 0 (down) | 0000 | | |
| 0000 | 0 (down) | 1111 | | |

**Figure 2 — Up/down counter waveform:** [Insert XSim screenshot of `clk`, `reset`, `dir`, and `count[3:0]`.]

**Verification summary:** [Explain the behavior when `dir` changes and how boundary wrap-around was checked.]

### Task 5 — Traffic-Light FSM

**Requirement:** Implement a three-state traffic-light controller.

#### 3.9 FSM description and state diagram

Use the states **RED, GREEN, and YELLOW**. Draw the transitions for the actual controller implemented. If using the simple cyclic controller, the sequence is:

`RED → GREEN → YELLOW → RED`

**Figure 3 — State diagram:** [Insert your three-state diagram; label the reset state and any transition conditions.]

#### 3.10 State table

For the simple cyclic **Moore FSM**, the expected state and outputs are:

| Current state | Next state (transition enabled) | Red | Yellow | Green |
|---|---|---|---|---|
| RED | GREEN | 1 | 0 | 0 |
| GREEN | YELLOW | 0 | 0 | 1 |
| YELLOW | RED | 0 | 1 | 0 |

**Transition condition / timing policy:** [Explain whether the FSM advances every clock cycle or uses a timer/enable signal, if implemented.]

#### 3.11 RTL implementation

```systemverilog
// Paste your Task 5 FSM module.
// Include state register, next-state logic, and output logic.
```

#### 3.12 Testbench

```systemverilog
// Paste your Task 5 testbench here.
```

#### 3.13 State-transition verification

| Test condition | Expected state | Expected {red,yellow,green} | Simulated state/output | Pass/Fail |
|---|---|---|---|---|
| Reset applied and sampled | RED | 100 | | |
| Next enabled transition | GREEN | 001 | | |
| Following transition | YELLOW | 010 | | |
| Following transition | RED | 100 | | |
| Additional full cycle | RED → GREEN → YELLOW → RED | 100 → 001 → 010 → 100 | | |

**Figure 4 — Traffic-light FSM waveform:** [Insert XSim screenshot of `clk`, `reset`, `state`, `next_state` (if visible), `red`, `yellow`, `green`.]

**Verification summary:** [Discuss reset behavior, transitions, and whether exactly one lamp is active in each valid state.]


---

## 4. Discussion

Answer in complete sentences and refer to your own RTL code, tables, and waveforms.

1. What makes the 4-bit counter a **synchronous sequential circuit**?
2. Why does a 4-bit counter wrap from `1111` to `0000`?
3. What is the role of the clock and reset in Task 3?
4. How does the `dir` signal change the behavior of the up/down counter?
5. What happens when a 4-bit up/down counter decrements from `0000`?
6. Why is it important to test both the middle of a counting sequence and its boundaries?
7. How does a finite-state machine differ from a binary counter?
8. What are the **state register**, **next-state logic**, and **output logic** in your traffic-light FSM?
9. Why is the three-state traffic-light design considered a **Moore FSM** when outputs depend only on state?
10. How did you confirm that the FSM reset and transitions occurred as intended?



