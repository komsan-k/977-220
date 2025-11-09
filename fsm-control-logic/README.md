# 🧠 Finite State Machines and Control Logic

## 📘 Introduction to Finite State Machines (FSMs)

A **Finite State Machine (FSM)** is a computational model used to design
**control logic**. It consists of a finite set of states, transitions
between these states based on input signals, and outputs determined by
the current state and possibly the input. FSMs are widely used in
hardware design to manage control flow, protocols, sequencing
operations, and user interfaces.

------------------------------------------------------------------------

## 🧩 Types of FSMs

### 🔹 Moore Machine

In a **Moore machine**, the output is determined solely by the current
state. This model is simple and ensures that outputs change only on
state transitions.

### 🔹 Mealy Machine

In a **Mealy machine**, the output depends on both the current state and
the current input. This model reacts more quickly to input changes but
may lead to complex timing.

### 🔸 Comparison

  FSM Type    Output Depends On       Characteristics
  ----------- ----------------------- ---------------------------------
  **Moore**   Current State only      Stable output, simpler design
  **Mealy**   Current State + Input   Faster response, compact states

------------------------------------------------------------------------

## ⚙️ FSM Design Process

1.  Define the problem or control sequence.\
2.  Identify the number of states.\
3.  Draw the state diagram with transitions.\
4.  Assign binary codes to the states.\
5.  Write the transition and output logic.\
6.  Implement in Verilog.\
7.  Simulate and test.

------------------------------------------------------------------------

## 🎯 State Diagrams and Transition Tables

State diagrams use **circles** (states) and **arrows** (transitions) to
represent behavior. Each transition is labeled with input conditions and
possibly output actions.

### Example: Sequence Detector

Detects a specific bit pattern (e.g., `1011`) in an input stream.

------------------------------------------------------------------------

## 💡 State Encoding Techniques

### Binary Encoding

Uses the minimal number of bits but may lead to complex logic.

### One-Hot Encoding

Each state is assigned a bit. Only one bit is high at a time. Preferred
in **FPGAs** for speed.

### Gray Encoding

Minimizes bit changes between adjacent states --- useful for error
minimization.

------------------------------------------------------------------------

## 💻 FSM Implementation in Verilog

### 🔸 State Declaration

``` verilog
parameter IDLE = 2'b00, LOAD = 2'b01, DONE = 2'b10;
```

### 🔸 State Register

``` verilog
always @(posedge clk or posedge rst)
  if (rst) state <= IDLE;
  else state <= next_state;
```

### 🔸 Next State Logic

``` verilog
always @(*) begin
  case (state)
    IDLE: next_state = start ? LOAD : IDLE;
    LOAD: next_state = ready ? DONE : LOAD;
    DONE: next_state = IDLE;
    default: next_state = IDLE;
  endcase
end
```

### 🔸 Output Logic

**Moore-style:**

``` verilog
assign output = (state == DONE);
```

**Mealy-style:**

``` verilog
assign output = (state == LOAD) && input_ready;
```

------------------------------------------------------------------------

## ⚡ Example: Serial Data Receiver FSM

Detects **start** and **stop bits** and assembles serial data into a
byte.

### FSM States

-   IDLE\
-   START\
-   RECEIVE\
-   STOP

### Implementation Steps

1.  Draw state diagram.\
2.  Write Verilog code.\
3.  Simulate and verify functionality.

------------------------------------------------------------------------

## 🧱 Hierarchical FSM Design

FSMs can be modularized for complexity management: - Each sub-FSM
handles a part of the control logic.\
- Common in **protocol controllers** and **CPU subsystems**.

------------------------------------------------------------------------

## ⚙️ FSM as a Control Unit

FSMs manage datapath operations such as: - Instruction decoding in CPUs\
- Step control in ALUs\
- Packet parsing in network interfaces

------------------------------------------------------------------------

## 🧪 Simulation and Verification

Use **testbenches** with input stimuli to verify all transitions.

``` verilog
initial begin
  clk = 0;
  rst = 1;
  #10 rst = 0;
  input = 1;
  #20 input = 0;
end
```

------------------------------------------------------------------------

## 🧰 Debugging FSMs

-   Monitor **state transitions** using waveform viewers.\
-   Add **one-hot debug outputs**.\
-   Use **Integrated Logic Analyzer (ILA)** cores on FPGA for real-time
    monitoring.

------------------------------------------------------------------------

## ⚠️ Common Design Mistakes

-   Incomplete state transition definitions.\
-   Missing default branches.\
-   Using blocking assignments instead of non-blocking.\
-   Mixing Moore and Mealy logic incorrectly.

------------------------------------------------------------------------

## 🚀 Advanced FSM Topics

### FSM with Wait States

Used to delay transitions until a condition (e.g., signal ready) is met.

### FSM with Priority Arbitration

Used to resolve contention between multiple requesters.

### FSM with Timeout Counters

Used for communication protocols and error recovery.

------------------------------------------------------------------------

## 📘 Summary

Finite State Machines are powerful tools for designing control logic in
digital systems. Verilog provides flexible constructs to model FSMs
efficiently. A well-designed FSM improves **modularity**,
**testability**, and **maintainability**.

------------------------------------------------------------------------

## 🧩 Exercises

1.  Design a **3-state FSM** for a vending machine (IDLE, COIN,
    DISPENSE).\
2.  Create a **Mealy FSM** for detecting `1101` in a serial bit stream.\
3.  Modify a **Moore FSM** to include a resettable state.\
4.  Simulate a **UART receiver FSM** with start, data, and stop bits.\
5.  Design a **hierarchical FSM** for a simplified CPU control unit.

------------------------------------------------------------------------


