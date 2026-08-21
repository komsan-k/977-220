# 🔬 Lab: Verilog/SystemVerilog-4 — FSM Design

## Moore/Mealy FSM and Traffic Light FSM Using EDA Playground

## 🧩 1. Objective

* Understand the fundamental concept of a **Finite-State Machine (FSM)**.
* Distinguish between **Moore** and **Mealy** FSM architectures.
* Learn how to represent an FSM using a **state diagram** and **state table**.
* Implement FSMs using **Verilog/SystemVerilog**.
* Use `always_ff` for state storage and `always_comb` for next-state/output logic.
* Simulate FSM behavior using **EDA Playground and EPWave**.
* Implement a simple **traffic-light controller**.
* Verify state transitions, outputs, and reset behavior.
* Build a foundation for protocol controllers, digital control systems, processors, and FPGA applications.

---

## ⚙️ 2. Equipment and Tools

| Tool / Resource                                       | Description                                 |
| ----------------------------------------------------- | ------------------------------------------- |
| **EDA Playground**                                    | Online HDL design and simulation            |
| **Web Browser**                                       | Access to EDA Playground                    |
| **Verilog / SystemVerilog**                           | FSM design languages                        |
| **Icarus Verilog / Verilator / Questa or equivalent** | Simulation engine                           |
| **EPWave**                                            | Waveform visualization                      |
| **Testbench**                                         | Clock, reset, and input stimulus generation |

---

# 🧠 3. Background Theory

## 3.1 What Is a Finite-State Machine?

A Finite-State Machine is a sequential digital circuit whose behavior is described by a finite number of states.

At any time, the FSM is in one current state.

The next state depends on:

* the current state,
* input conditions.

Mathematically,

$$
S_{next}=f(S_{current},X).
$$

The output is determined by the state and, depending on the FSM type, possibly the input.

Thus,

$$
\boxed{
\text{Current State}
+
\text{Input}
\rightarrow
\text{Next State}
}
$$

---

## 3.2 Basic FSM Structure

A typical FSM contains three functional blocks:

```text
              Inputs
                │
                ▼
        ┌────────────────┐
        │ Next-State     │
        │ Logic          │
        └───────┬────────┘
                │
                ▼
        ┌────────────────┐
Clock ─►│ State Register │
Reset ─►│                │
        └───────┬────────┘
                │
                ▼
          Current State
                │
                ▼
        ┌────────────────┐
        │ Output Logic   │
        └───────┬────────┘
                │
                ▼
              Outputs
```

Therefore,

$$
\boxed{
\text{FSM}
==========

\text{State Register}
+
\text{Next-State Logic}
+
\text{Output Logic}
}
$$

---

# 🆚 4. Moore and Mealy FSMs

## 4.1 Moore FSM

In a Moore FSM, the output depends only on the current state.

$$
Y=g(S).
$$

The architecture is

```text
Input
  │
  ▼
Next-State Logic
  │
  ▼
State Register
  │
  ├────► Output Logic ───► Output
  │
  ▼
State
```

The output changes when the state changes.

---

## 4.2 Mealy FSM

In a Mealy FSM, the output depends on both the state and current input.

$$
Y=g(S,X).
$$

The architecture is

```text
Input ───────────────┐
  │                  │
  ▼                  ▼
Next-State Logic  Output Logic
  │                  ▲
  ▼                  │
State Register ───────┘
```

The output may change immediately when the input changes.

---

## 4.3 Comparison

| Characteristic      | Moore FSM                  | Mealy FSM                   |
| ------------------- | -------------------------- | --------------------------- |
| Output depends on   | Current state              | Current state + input       |
| Output response     | Usually after state update | Can respond immediately     |
| Output stability    | Generally high             | More input-sensitive        |
| Number of states    | Sometimes more             | Sometimes fewer             |
| Design simplicity   | Often simpler              | Slightly more complex       |
| Typical application | Controllers                | Protocol/sequence detection |

---

# 🔢 5. FSM State Representation

A state can be represented by binary values.

For three states:

```text
S0 = 00
S1 = 01
S2 = 10
```

In SystemVerilog, symbolic state names are preferred.

For example:

```systemverilog
typedef enum logic [1:0] {
    S0 = 2'b00,
    S1 = 2'b01,
    S2 = 2'b10
} state_t;
```

This improves code readability.

---

# 🧠 6. Three-Part FSM Coding Style

A clean FSM implementation commonly uses three blocks.

### Block 1 — State Register

```systemverilog
always_ff @(posedge clk) begin
    if (reset)
        state <= S0;
    else
        state <= next_state;
end
```

### Block 2 — Next-State Logic

```systemverilog
always_comb begin
    next_state = state;

    case (state)
        ...
    endcase
end
```

### Block 3 — Output Logic

```systemverilog
always_comb begin
    output_signal = 1'b0;

    case (state)
        ...
    endcase
end
```

---

# 🚦 7. Study Case 1 — Moore Traffic Light FSM

Consider a simple traffic light with three states:

* RED
* GREEN
* YELLOW

The transition sequence is

```text
RED
 │
 ▼
GREEN
 │
 ▼
YELLOW
 │
 └────► RED
```

This is a Moore FSM because the lamp outputs depend only on the current state.

---

# 🧩 8. State Definition

Use:

```text
RED    = 00
GREEN  = 01
YELLOW = 10
```

In SystemVerilog:

```systemverilog
typedef enum logic [1:0] {
    RED    = 2'b00,
    GREEN  = 2'b01,
    YELLOW = 2'b10
} state_t;
```

---

# 📊 9. Traffic-Light State Table

| Current State | Next State | Red | Yellow | Green |
| ------------- | ---------- | :-: | :----: | :---: |
| RED           | GREEN      |  1  |    0   |   0   |
| GREEN         | YELLOW     |  0  |    0   |   1   |
| YELLOW        | RED        |  0  |    1   |   0   |

---

# 💻 10. Moore Traffic-Light FSM in SystemVerilog

```systemverilog
module traffic_light_moore(
    input  logic clk,
    input  logic reset,

    output logic red,
    output logic yellow,
    output logic green
);

    typedef enum logic [1:0] {
        RED    = 2'b00,
        GREEN  = 2'b01,
        YELLOW = 2'b10
    } state_t;

    state_t state;
    state_t next_state;

    // State register
    always_ff @(posedge clk) begin

        if (reset)
            state <= RED;
        else
            state <= next_state;

    end

    // Next-state logic
    always_comb begin

        next_state = state;

        case (state)

            RED:
                next_state = GREEN;

            GREEN:
                next_state = YELLOW;

            YELLOW:
                next_state = RED;

            default:
                next_state = RED;

        endcase

    end

    // Output logic
    always_comb begin

        red    = 1'b0;
        yellow = 1'b0;
        green  = 1'b0;

        case (state)

            RED:
                red = 1'b1;

            GREEN:
                green = 1'b1;

            YELLOW:
                yellow = 1'b1;

            default:
                red = 1'b1;

        endcase

    end

endmodule
```

---

# 🧪 11. Moore FSM Testbench

```systemverilog
`timescale 1ns/1ps

module tb_traffic_light_moore;

    logic clk;
    logic reset;

    logic red;
    logic yellow;
    logic green;

    traffic_light_moore dut (
        .clk(clk),
        .reset(reset),
        .red(red),
        .yellow(yellow),
        .green(green)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        $dumpfile("dump.vcd");
        $dumpvars(0, tb_traffic_light_moore);

        reset = 1;

        #12;

        reset = 0;

        #80;

        $finish;

    end

endmodule
```

---

# 📊 12. Expected Moore FSM Sequence

After reset:

```text
RED
```

Then:

```text
RED → GREEN → YELLOW → RED → ...
```

Expected outputs are:

| State  | Red | Yellow | Green |
| ------ | :-: | :----: | :---: |
| RED    |  1  |    0   |   0   |
| GREEN  |  0  |    0   |   1   |
| YELLOW |  0  |    1   |   0   |

---

# 🔍 13. Expected Waveform

The simulation may resemble:

```text
clk      _-_-_-_-_-_-_-_-_-_

reset    ----________________

red      ----____--------____

green    ____----________----

yellow   ________----________
```

The state changes only on a clock edge.

---

# 🧠 14. State Diagram Interpretation

For the basic traffic light:

```text
         ┌─────────┐
         │   RED   │
         └────┬────┘
              │
              ▼
         ┌─────────┐
         │  GREEN  │
         └────┬────┘
              │
              ▼
         ┌─────────┐
         │ YELLOW  │
         └────┬────┘
              │
              └────────► RED
```

Since transitions are unconditional, each state automatically advances to the next one.

---

# ⏱️ 15. Adding State Duration

A practical traffic light should not change every system clock cycle.

Instead, each state should remain active for a defined duration.

For example:

| State  | Duration |
| ------ | -------: |
| RED    |  5 units |
| GREEN  |  8 units |
| YELLOW |  2 units |

A timer or counter can be used to generate a `timer_done` input.

---

# 🏗️ 16. Timed Traffic FSM Architecture

```text
System Clock
     │
     ├──────────────┐
     ▼              ▼
   Timer           FSM
     │              │
     └─timer_done──►│
                    ▼
              Traffic Lights
```

The timer determines when the FSM is allowed to move to the next state.

---

# 💻 17. Moore FSM with Timer Input

```systemverilog
module traffic_light_timed(
    input  logic clk,
    input  logic reset,
    input  logic timer_done,

    output logic red,
    output logic yellow,
    output logic green
);

    typedef enum logic [1:0] {
        RED    = 2'b00,
        GREEN  = 2'b01,
        YELLOW = 2'b10
    } state_t;

    state_t state, next_state;

    always_ff @(posedge clk) begin

        if (reset)
            state <= RED;
        else
            state <= next_state;

    end

    always_comb begin

        next_state = state;

        case (state)

            RED:
                if (timer_done)
                    next_state = GREEN;

            GREEN:
                if (timer_done)
                    next_state = YELLOW;

            YELLOW:
                if (timer_done)
                    next_state = RED;

            default:
                next_state = RED;

        endcase

    end

    always_comb begin

        red    = 1'b0;
        yellow = 1'b0;
        green  = 1'b0;

        case (state)

            RED:
                red = 1'b1;

            GREEN:
                green = 1'b1;

            YELLOW:
                yellow = 1'b1;

            default:
                red = 1'b1;

        endcase

    end

endmodule
```

---

# 🧪 18. Testbench with Timer Pulse

```systemverilog
`timescale 1ns/1ps

module tb_traffic_timed;

    logic clk;
    logic reset;
    logic timer_done;

    logic red;
    logic yellow;
    logic green;

    traffic_light_timed dut (
        .clk(clk),
        .reset(reset),
        .timer_done(timer_done),
        .red(red),
        .yellow(yellow),
        .green(green)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        $dumpfile("dump.vcd");
        $dumpvars(0, tb_traffic_timed);

        reset = 1;
        timer_done = 0;

        #12;
        reset = 0;

        #18;
        timer_done = 1;

        #10;
        timer_done = 0;

        #30;
        timer_done = 1;

        #10;
        timer_done = 0;

        #20;
        timer_done = 1;

        #10;
        timer_done = 0;

        #20;

        $finish;

    end

endmodule
```

---

# 🧠 19. Study Case 2 — Mealy Sequence Detector

A simple Mealy FSM can detect the input sequence

```text
101
```

The output becomes `1` when the sequence is completed.

The states can represent:

* `S0`: no useful match
* `S1`: received `1`
* `S2`: received `10`

When in `S2` and the input is `1`, the sequence `101` is detected.

---

# 🔄 20. Mealy Sequence Detector State Diagram

```text
            x=1
       ┌────────────┐
       ▼            │
      S1 ──x=0──► S2
       ▲            │
       │            │ x=1 / detect=1
       │            ▼
      S0 ◄──────────┘
```

The output depends on both:

* current state,
* current input.

Thus, it is a Mealy FSM.

---

# 📊 21. Sequence Detector State Table

| Current State | Input x | Next State | Detect |
| ------------- | :-----: | ---------- | :----: |
| S0            |    0    | S0         |    0   |
| S0            |    1    | S1         |    0   |
| S1            |    0    | S2         |    0   |
| S1            |    1    | S1         |    0   |
| S2            |    0    | S0         |    0   |
| S2            |    1    | S1         |    1   |

---

# 💻 22. Mealy Sequence Detector

```systemverilog
module mealy_101_detector(
    input  logic clk,
    input  logic reset,
    input  logic x,
    output logic detect
);

    typedef enum logic [1:0] {
        S0 = 2'b00,
        S1 = 2'b01,
        S2 = 2'b10
    } state_t;

    state_t state;
    state_t next_state;

    always_ff @(posedge clk) begin

        if (reset)
            state <= S0;
        else
            state <= next_state;

    end

    always_comb begin

        next_state = state;
        detect = 1'b0;

        case (state)

            S0: begin

                if (x)
                    next_state = S1;
                else
                    next_state = S0;

            end

            S1: begin

                if (x)
                    next_state = S1;
                else
                    next_state = S2;

            end

            S2: begin

                if (x) begin
                    next_state = S1;
                    detect = 1'b1;
                end

                else begin
                    next_state = S0;
                end

            end

            default: begin
                next_state = S0;
                detect = 1'b0;
            end

        endcase

    end

endmodule
```

---

# 🧪 23. Mealy Sequence Detector Testbench

```systemverilog
`timescale 1ns/1ps

module tb_mealy_101;

    logic clk;
    logic reset;
    logic x;
    logic detect;

    mealy_101_detector dut (
        .clk(clk),
        .reset(reset),
        .x(x),
        .detect(detect)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task send_bit(input logic b);
    begin
        @(negedge clk);
        x = b;
    end
    endtask

    initial begin

        $dumpfile("dump.vcd");
        $dumpvars(0, tb_mealy_101);

        reset = 1;
        x = 0;

        #12;
        reset = 0;

        send_bit(1);
        send_bit(0);
        send_bit(1);

        send_bit(1);
        send_bit(0);
        send_bit(1);

        send_bit(0);

        #20;

        $finish;

    end

endmodule
```

---

# 🔍 24. Why Change Input on the Negative Edge?

In the testbench:

```systemverilog
@(negedge clk);
x = b;
```

changes the input halfway between positive clock edges.

This avoids changing the input exactly when the FSM samples it.

That makes waveform interpretation more reliable.

---

# 🆚 25. Moore versus Mealy Sequence Detection

Suppose the sequence is `101`.

A Mealy detector may assert the output on the same cycle that the final `1` arrives.

A Moore detector generally moves to a dedicated detection state first.

Therefore:

```text
Mealy:
Input completes sequence
        │
        ▼
Output may assert immediately

Moore:
Input completes sequence
        │
        ▼
Enter detect state
        │
        ▼
Output asserts from state
```

---

# 🧠 26. Safe Default Assignments

Combinational FSM logic should include default values.

Example:

```systemverilog
always_comb begin

    next_state = state;
    detect = 1'b0;

    case (state)
        ...
    endcase

end
```

This avoids incomplete assignments and unintended latches.

---

# 🚨 27. Illegal-State Recovery

An FSM should include a safe default state.

For example:

```systemverilog
default:
    next_state = S0;
```

For the traffic light:

```systemverilog
default:
    next_state = RED;
```

This gives the FSM a recovery path if it enters an invalid state.

---

# 🔢 28. State-Encoding Methods

Common encoding methods include:

### Binary Encoding

For four states:

```text
00
01
10
11
```

### One-Hot Encoding

For four states:

```text
0001
0010
0100
1000
```

### Gray Encoding

Adjacent states are encoded to reduce the number of changing bits.

Vivado and synthesis tools may optimize state encoding automatically.

---

# 🆚 29. Binary versus One-Hot Encoding

| Characteristic     | Binary           | One-Hot         |
| ------------------ | ---------------- | --------------- |
| Flip-flops         | Fewer            | More            |
| Decode logic       | Potentially more | Often simpler   |
| State visibility   | Compact          | Very clear      |
| FPGA suitability   | Good             | Often excellent |
| Speed              | Good             | Often high      |
| Resource trade-off | FF-efficient     | Logic-efficient |

---

# 🌐 30. Using EDA Playground

## Step 1 — Open EDA Playground

Create a new project.

## Step 2 — Select SystemVerilog

Choose:

```text
SystemVerilog
```

## Step 3 — Select Simulator

Choose an available simulator that supports SystemVerilog.

## Step 4 — Enter the FSM Design

Place the DUT in the design window.

## Step 5 — Enter the Testbench

Generate:

* clock,
* reset,
* FSM inputs.

## Step 6 — Enable Waveforms

Add:

```systemverilog
$dumpfile("dump.vcd");
$dumpvars(0, tb);
```

## Step 7 — Run

Click:

```text
Run
```

and inspect EPWave.

---

# 📈 31. Waveform Signals to Observe

For a traffic FSM, observe:

```text
clk
reset
state
next_state
red
yellow
green
```

For a Mealy detector, observe:

```text
clk
reset
x
state
next_state
detect
```

The state transition should occur on the active clock edge.

---

# 🧪 32. Self-Checking Traffic FSM Concept

A self-checking testbench can verify the outputs automatically.

For example:

```systemverilog
if (red !== 1'b1)
    $display("ERROR: Expected RED state");
```

or

```systemverilog
if ({red, yellow, green} !== 3'b100)
    $display("FAIL");
else
    $display("PASS");
```

This reduces reliance on visual waveform inspection.

---

# ✅ 33. Example Output Check

```systemverilog
task check_lights(
    input logic exp_red,
    input logic exp_yellow,
    input logic exp_green
);

begin

    #1;

    if ({red, yellow, green}
        ===
        {exp_red, exp_yellow, exp_green})

        $display("PASS");

    else

        $display(
            "FAIL R=%b Y=%b G=%b",
            red, yellow, green
        );

end

endtask
```

This illustrates reusable testbench tasks.

---

# 🚦 34. Advanced Traffic-Light FSM

A more realistic controller may use four states:

```text
RED
 │
 ▼
GREEN
 │
 ▼
YELLOW
 │
 ▼
ALL_RED
 │
 └────► RED
```

The extra `ALL_RED` state can improve safety during transitions.

---

# 🚶 35. Pedestrian Request Extension

Add an input:

```text
ped_request
```

The FSM can then include states such as:

```text
CAR_GREEN
CAR_YELLOW
ALL_RED
PED_GREEN
```

A possible sequence is:

```text
CAR_GREEN
     │
ped_request
     ▼
CAR_YELLOW
     │
     ▼
ALL_RED
     │
     ▼
PED_GREEN
     │
     ▼
ALL_RED
     │
     └────► CAR_GREEN
```

---

# 💻 36. Pedestrian FSM Concept

The next-state logic might contain:

```systemverilog
CAR_GREEN: begin

    if (ped_request)
        next_state = CAR_YELLOW;

end
```

This demonstrates event-driven state transitions.

---

# ⏱️ 37. FSM and Timer Integration

A timed controller can use:

```text
FSM
 │
 ├──► State duration selection
 │
 ▼
Timer
 │
 └──► timer_done
      │
      ▼
     FSM
```

For example:

$$
T_{RED}=5
$$

$$
T_{GREEN}=8
$$

$$
T_{YELLOW}=2.
$$

The timer produces `timer_done`, which causes the next transition.

---

# 🧩 38. FSM-Controlled Datapath

FSMs are often used to control a datapath.

```text
              ┌───────────┐
Inputs ──────►│ Datapath  │────► Result
              └─────▲─────┘
                    │
                 Control
                    │
              ┌─────┴─────┐
              │    FSM    │
              └───────────┘
```

The FSM may control:

* register enable,
* counter reset,
* ALU operation,
* MAC start,
* memory read/write.

---

# 🧠 39. Why FSMs Are Important

FSMs are widely used in:

* traffic controllers,
* vending machines,
* elevators,
* communication protocols,
* UART controllers,
* SPI controllers,
* CPU control units,
* memory controllers,
* FPGA accelerators,
* robotics,
* embedded systems.

They provide a systematic way to describe time-dependent control behavior.

---

# 🧪 40. Lab Tasks

### Task 1 — Moore FSM Concept

Draw a three-state Moore FSM.

### Task 2 — Traffic Light FSM

Implement:

```text
RED → GREEN → YELLOW → RED
```

### Task 3 — State Table

Create the complete state/output table.

### Task 4 — Behavioral Simulation

Verify all state transitions using EPWave.

### Task 5 — Add Timer Input

Modify the traffic FSM so that transitions occur only when `timer_done=1`.

### Task 6 — Mealy Sequence Detector

Implement a `101` detector.

### Task 7 — Compare Moore and Mealy

Explain the difference in output timing.

### Task 8 — Illegal-State Recovery

Add a safe default state.

### Task 9 — Self-Checking Testbench

Automatically verify traffic-light outputs.

### Task 10 — State Encoding

Compare binary and one-hot state representations.

---

# 📋 41. Experimental Results

| Experiment        | Expected Behavior       | Simulated Behavior | Pass/Fail |
| ----------------- | ----------------------- | ------------------ | --------- |
| Reset             | State = RED             |                    |           |
| RED transition    | RED → GREEN             |                    |           |
| GREEN transition  | GREEN → YELLOW          |                    |           |
| YELLOW transition | YELLOW → RED            |                    |           |
| Timer hold        | State remains unchanged |                    |           |
| Sequence `101`    | Detect = 1              |                    |           |
| Illegal state     | Recover safely          |                    |           |

---

# 📊 42. Traffic FSM Verification Table

| Clock Event | Expected State | Red | Yellow | Green |
| ----------: | -------------- | :-: | :----: | :---: |
|       Reset | RED            |  1  |    0   |   0   |
|           1 | GREEN          |  0  |    0   |   1   |
|           2 | YELLOW         |  0  |    1   |   0   |
|           3 | RED            |  1  |    0   |   0   |
|           4 | GREEN          |  0  |    0   |   1   |

Students should fill in the simulated results.

---

# 📊 43. Mealy Detector Verification Table

Test the input stream:

```text
1 0 1 1 0 1 0
```

| Input Bit | Expected Detect |
| :-------: | :-------------: |
|     1     |        0        |
|     0     |        0        |
|     1     |        1        |
|     1     |        0        |
|     0     |        0        |
|     1     |        1        |
|     0     |        0        |

---

# 💬 44. Discussion Points

1. What is a finite-state machine?
2. What are the three basic blocks of an FSM?
3. What is the purpose of the state register?
4. What is next-state logic?
5. What is output logic?
6. What is the difference between Moore and Mealy FSMs?
7. Why does a Moore output depend only on state?
8. Why can a Mealy output react faster?
9. Why should default assignments be included?
10. Why is illegal-state recovery important?
11. What is state encoding?
12. What is the advantage of symbolic state names?
13. Why should the FSM state update occur with `always_ff`?
14. Why is `always_comb` useful for next-state logic?
15. How can a timer be integrated with an FSM?

---

# 🧠 45. Post-Lab Exercises

1. **Four-State Traffic Light**
   Add an `ALL_RED` state.

2. **Pedestrian Request**
   Add a pedestrian button input.

3. **Emergency Mode**
   Add an emergency input that forces the traffic light to RED.

4. **Manual Step Mode**
   Use an input pulse to advance the state manually.

5. **Moore `101` Detector**
   Rewrite the Mealy detector as a Moore FSM.

6. **Sequence `1101` Detector**
   Implement a new detector.

7. **Overlapping Sequence Detection**
   Support overlapping patterns.

8. **One-Hot Encoding**
   Rewrite the traffic FSM using one-hot states.

9. **Vending Machine FSM**
   Implement a simple vending controller.

10. **Elevator FSM**
    Design states such as IDLE, UP, DOWN, and DOOR_OPEN.

---

# 🔬 46. Advanced Exercise — Traffic Light with Pedestrian Mode

Create the states:

```text
CAR_GREEN
CAR_YELLOW
ALL_RED_1
PED_GREEN
ALL_RED_2
```

Inputs:

* `timer_done`
* `ped_request`

Outputs:

* `car_red`
* `car_yellow`
* `car_green`
* `ped_red`
* `ped_green`

The state sequence may be:

```text
CAR_GREEN
    │
ped_request
    ▼
CAR_YELLOW
    │
timer_done
    ▼
ALL_RED_1
    │
    ▼
PED_GREEN
    │
timer_done
    ▼
ALL_RED_2
    │
    ▼
CAR_GREEN
```

---

# 🚀 47. Advanced Exercise — FSM-Controlled MAC

An FSM can control a sequential MAC engine.

Example states:

```text
IDLE
 │
 ▼
LOAD
 │
 ▼
MULTIPLY
 │
 ▼
ACCUMULATE
 │
 ▼
DONE
 │
 └────► IDLE
```

This introduces the architecture

$$
\boxed{
\text{FSM Control}
+
\text{Arithmetic Datapath}
}
$$

used in many FPGA accelerators.

---

# 🤖 48. Extension to AI-FPGA

An AI accelerator may use an FSM to control:

```text
IDLE
  │
  ▼
LOAD_INPUT
  │
  ▼
LOAD_WEIGHT
  │
  ▼
MAC
  │
  ▼
ACTIVATION
  │
  ▼
OUTPUT
  │
  └────► IDLE
```

The FSM coordinates the computational datapath.

Therefore,

$$
\boxed{
\text{FSM}
\rightarrow
\text{Control Flow}
}
$$

while

$$
\boxed{
\text{MAC / ANN / CNN}
\rightarrow
\text{Data Processing}
}
$$

---

# 🔄 49. Recommended EDA Playground Workflow

```text
State Diagram
     │
     ▼
State Table
     │
     ▼
Define State Encoding
     │
     ▼
Write State Register
     │
     ▼
Write Next-State Logic
     │
     ▼
Write Output Logic
     │
     ▼
Create Testbench
     │
     ▼
Run Simulation
     │
     ▼
Inspect EPWave
     │
     ├── Incorrect → Modify FSM
     │
     └── Correct
             │
             ▼
        Complete Design
```

---

# 🧾 50. Expected Learning Outcomes

After completing this laboratory, students will be able to:

* Explain the concept of a finite-state machine.
* Distinguish Moore and Mealy FSMs.
* Create FSM state diagrams and state tables.
* Define symbolic states using SystemVerilog.
* Implement FSM state registers using `always_ff`.
* Implement next-state and output logic using `always_comb`.
* Design and simulate a traffic-light FSM.
* Implement a Mealy sequence detector.
* Integrate timer and event inputs into an FSM.
* Create safe default transitions.
* Analyze FSM waveforms using EPWave.
* Develop a foundation for larger digital control systems.

---

# 📘 51. References

1. M. M. Mano and M. D. Ciletti, *Digital Design*, Pearson.
2. S. Brown and Z. Vranesic, *Fundamentals of Digital Logic with Verilog Design*, McGraw-Hill.
3. M. D. Ciletti, *Advanced Digital Design with the Verilog HDL*, Pearson.
4. D. M. Harris and S. L. Harris, *Digital Design and Computer Architecture*, Morgan Kaufmann.
5. IEEE Std 1364-2005, *IEEE Standard for Verilog Hardware Description Language*.
6. IEEE Std 1800, *SystemVerilog—Unified Hardware Design, Specification, and Verification Language*.

---

## 🔑 Key Concept

The fundamental FSM relationship is

$$
\boxed{
S_{next}
========

f(S_{current},X)
}
$$

For a Moore FSM,

$$
\boxed{
Y=g(S)
}
$$

while for a Mealy FSM,

$$
\boxed{
Y=g(S,X)
}
$$

The complete FSM design flow is

$$
\boxed{
\text{State Diagram}
\rightarrow
\text{State Table}
\rightarrow
\text{SystemVerilog FSM}
\rightarrow
\text{Testbench}
\rightarrow
\text{Simulation}
\rightarrow
\text{Verification}
}
$$

This laboratory provides the foundation for subsequent work involving **timers, UART controllers, protocol FSMs, processor control units, traffic systems, datapath controllers, MAC engines, and AI-FPGA accelerators**.
