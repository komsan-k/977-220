# 🔬 Lab: Vivado-4 — Sequential and FSM Design

## Implementing Sequential and Finite-State Machine Circuits Using Vivado

## 🧩 1. Objective

* Understand the basic principles of **sequential logic circuits**.
* Understand the role of **clock, reset, registers, and state**.
* Implement registers, counters, and simple state-based circuits using **Verilog HDL**.
* Understand the architecture of a **Finite-State Machine (FSM)**.
* Design and implement Moore- and Mealy-style FSM concepts.
* Simulate sequential and FSM circuits using Vivado.
* Synthesize and implement the circuits on FPGA hardware.
* Use FPGA switches and push buttons as inputs and LEDs as outputs.
* Analyze timing, state transitions, and FPGA resource utilization.

---

## ⚙️ 2. Equipment and Tools

| Tool / Resource                     | Description                                           |
| ----------------------------------- | ----------------------------------------------------- |
| **Vivado Design Suite**             | HDL design, simulation, synthesis, and implementation |
| **FPGA Board (Basys 3 / Nexys A7)** | Hardware implementation                               |
| **Verilog HDL**                     | Sequential and FSM design                             |
| **Vivado Simulator**                | Behavioral verification                               |
| **Onboard Clock**                   | Sequential circuit timing source                      |
| **Push Buttons / Switches**         | Reset and control inputs                              |
| **LEDs**                            | State and output visualization                        |
| **XDC Constraint File**             | FPGA pin and clock assignments                        |

---

# 🧠 3. Background Theory

## 3.1 Sequential Logic

A sequential circuit is a digital circuit whose output depends on both:

* current inputs,
* previous internal state.

Mathematically,

$$
Y[n]=f(X[n],S[n])
$$

and the next state is

$$
S[n+1]=g(X[n],S[n]).
$$

Therefore,

$$
\boxed{
\text{Sequential Logic}
=======================

\text{Current Input}
+
\text{Previous State}
}
$$

Typical sequential circuits include:

* registers,
* counters,
* shift registers,
* timers,
* finite-state machines.

---

## 3.2 Combinational versus Sequential Logic

| Characteristic            | Combinational | Sequential         |
| ------------------------- | ------------- | ------------------ |
| Depends on present input  | Yes           | Yes                |
| Depends on previous state | No            | Yes                |
| Memory                    | No            | Yes                |
| Clock                     | Not required  | Usually required   |
| Example                   | Adder, MUX    | Counter, FSM       |
| Storage element           | None          | Flip-flop/register |

The key additional concept is

$$
\boxed{\text{State}}
$$

---

# ⏱️ 4. Clocked Operation

Sequential circuits usually update on a clock edge.

For example,

```verilog
always @(posedge clk)
```

means that the statements inside the block execute on each rising edge of the clock.

A waveform is

```text
clk
     ┌─────┐     ┌─────┐     ┌─────┐
─────┘     └─────┘     └─────┘     └──
     ↑           ↑           ↑
   Update      Update      Update
```

At each rising edge,

$$
Q[n+1]=D[n].
$$

---

# 🧱 5. D Flip-Flop

A D flip-flop is one of the fundamental memory elements.

Its next-state equation is

$$
Q[n+1]=D[n].
$$

At the active clock edge, the value of (D) is stored in (Q).

---

## 5.1 Verilog D Flip-Flop

```verilog
module dff(
    input  wire clk,
    input  wire reset,
    input  wire D,
    output reg  Q
);

    always @(posedge clk) begin

        if (reset)
            Q <= 1'b0;
        else
            Q <= D;

    end

endmodule
```

---

# 🧠 6. Nonblocking Assignment

Sequential circuits normally use

```verilog
<=
```

rather than

```verilog
=
```

inside clocked `always` blocks.

For example,

```verilog
Q <= D;
```

is a nonblocking assignment.

This models simultaneous register updates more accurately.

Therefore,

$$
\boxed{
\text{Sequential Logic}
\rightarrow
\text{Nonblocking Assignment}
}
$$

---

# 🧪 7. D Flip-Flop Testbench

```verilog
`timescale 1ns / 1ps

module tb_dff;

    reg clk;
    reg reset;
    reg D;

    wire Q;

    dff uut (
        .clk(clk),
        .reset(reset),
        .D(D),
        .Q(Q)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        reset = 1;
        D = 0;

        #12;
        reset = 0;

        D = 1;
        #10;

        D = 0;
        #10;

        D = 1;
        #10;

        $finish;

    end

endmodule
```

The output (Q) changes only on rising clock edges.

---

# 🔢 8. Study Case 1 — 4-Bit Register

A register stores multiple bits.

For a 4-bit register,

$$
Q[3:0]\leftarrow D[3:0]
$$

on every active clock edge.

---

## 8.1 Verilog Register Module

```verilog
module register4(
    input  wire       clk,
    input  wire       reset,
    input  wire       enable,
    input  wire [3:0] D,
    output reg  [3:0] Q
);

    always @(posedge clk) begin

        if (reset)
            Q <= 4'b0000;

        else if (enable)
            Q <= D;

    end

endmodule
```

If `enable = 0`, the register keeps its previous value.

---

# 🔢 9. Study Case 2 — 4-Bit Counter

A binary counter increments once per clock cycle.

The next-state equation is

$$
Q[n+1]=Q[n]+1.
$$

For a 4-bit counter,

$$
Q\in[0,15].
$$

After 15, it wraps to 0.

---

## 9.1 Counter Verilog Module

```verilog
module counter4(
    input  wire       clk,
    input  wire       reset,
    input  wire       enable,
    output reg  [3:0] count
);

    always @(posedge clk) begin

        if (reset)
            count <= 4'b0000;

        else if (enable)
            count <= count + 1'b1;

    end

endmodule
```

---

# 📊 10. Counter Sequence

The expected sequence is

```text
0000
0001
0010
0011
0100
...
1111
0000
```

Therefore,

$$
\boxed{
\text{Counter}
==============

\text{Register}
+
\text{Increment Logic}
}
$$

---

# 🧪 11. Counter Testbench

```verilog
`timescale 1ns / 1ps

module tb_counter4;

    reg clk;
    reg reset;
    reg enable;

    wire [3:0] count;

    counter4 uut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .count(count)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        reset = 1;
        enable = 0;

        #12;

        reset = 0;
        enable = 1;

        #100;

        enable = 0;

        #20;

        $finish;

    end

endmodule
```

---

# 🔄 12. Study Case 3 — Up/Down Counter

A more advanced counter can count in both directions.

If

$$
DIR=1,
$$

then

$$
COUNT\leftarrow COUNT+1.
$$

If

$$
DIR=0,
$$

then

$$
COUNT\leftarrow COUNT-1.
$$

---

## 12.1 Verilog Up/Down Counter

```verilog
module updown_counter4(
    input  wire       clk,
    input  wire       reset,
    input  wire       enable,
    input  wire       dir,
    output reg  [3:0] count
);

    always @(posedge clk) begin

        if (reset)
            count <= 4'b0000;

        else if (enable) begin

            if (dir)
                count <= count + 1'b1;
            else
                count <= count - 1'b1;

        end

    end

endmodule
```

---

# 🧠 13. Finite-State Machine

A **Finite-State Machine (FSM)** is a sequential circuit whose behavior is described by a finite number of states.

The fundamental structure is

```text
Current State
     │
     ▼
Next-State Logic
     │
     ▼
State Register
     │
     ▼
Output Logic
```

A complete FSM contains three parts:

1. State register
2. Next-state logic
3. Output logic

---

# 🔄 14. FSM Mathematical Model

The next state is

$$
S_{next}=f(S_{current},X).
$$

The output depends on the state and possibly the input.

For a Moore machine,

$$
Y=g(S).
$$

For a Mealy machine,

$$
Y=g(S,X).
$$

---

# 🆚 15. Moore versus Mealy FSM

| Characteristic    | Moore FSM                  | Mealy FSM               |
| ----------------- | -------------------------- | ----------------------- |
| Output depends on | State                      | State + Input           |
| Output changes    | Usually after state update | Can respond immediately |
| Complexity        | Simpler                    | More compact            |
| Output stability  | High                       | May react faster        |
| Typical use       | Controllers                | Protocol logic          |

---

# 🚦 16. Study Case 4 — Traffic-Light FSM

A simple traffic-light controller uses three states:

* RED
* GREEN
* YELLOW

The state sequence is

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

This is a simple Moore FSM.

---

# 🧩 17. State Encoding

Three states require at least two bits.

Define

```text
RED    = 00
GREEN  = 01
YELLOW = 10
```

The remaining state

```text
11
```

is unused.

In Verilog:

```verilog
localparam RED    = 2'b00;
localparam GREEN  = 2'b01;
localparam YELLOW = 2'b10;
```

---

# 📊 18. Traffic-Light State Table

| Current State | Next State | Red | Yellow | Green |
| ------------- | ---------- | :-: | :----: | :---: |
| RED           | GREEN      |  1  |    0   |   0   |
| GREEN         | YELLOW     |  0  |    0   |   1   |
| YELLOW        | RED        |  0  |    1   |   0   |

---

# 💻 19. Traffic-Light FSM Verilog

```verilog
module traffic_fsm(
    input  wire clk,
    input  wire reset,

    output reg red,
    output reg yellow,
    output reg green
);

    localparam RED    = 2'b00;
    localparam GREEN  = 2'b01;
    localparam YELLOW = 2'b10;

    reg [1:0] state;
    reg [1:0] next_state;

    // State register
    always @(posedge clk) begin

        if (reset)
            state <= RED;
        else
            state <= next_state;

    end

    // Next-state logic
    always @(*) begin

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
    always @(*) begin

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

        endcase

    end

endmodule
```

---

# 🧪 20. Traffic-Light FSM Testbench

```verilog
`timescale 1ns / 1ps

module tb_traffic_fsm;

    reg clk;
    reg reset;

    wire red;
    wire yellow;
    wire green;

    traffic_fsm uut (
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

        reset = 1;

        #12;

        reset = 0;

        #80;

        $finish;

    end

endmodule
```

---

# 📊 21. Expected FSM Sequence

After reset,

```text
RED
```

is active.

At each clock edge, the states progress as

```text
RED → GREEN → YELLOW → RED → ...
```

Expected outputs:

| State  | Red | Yellow | Green |
| ------ | :-: | :----: | :---: |
| RED    |  1  |    0   |   0   |
| GREEN  |  0  |    0   |   1   |
| YELLOW |  0  |    1   |   0   |

---

# ⏱️ 22. Slowing the FSM for FPGA Observation

If the FSM changes state at 100 MHz, the LEDs change too quickly to observe.

Therefore, the state transitions should be driven by a slower enable signal.

For example,

```text
100 MHz Clock
     │
     ▼
Counter
     │
     ▼
1 Hz Enable
     │
     ▼
Traffic FSM
```

This allows humans to observe state transitions.

---

# 💻 23. Clock-Enable Generator

```verilog
module tick_generator(
    input  wire clk,
    input  wire reset,
    output reg  tick
);

    parameter MAX_COUNT = 100_000_000 - 1;

    reg [26:0] count;

    always @(posedge clk) begin

        if (reset) begin

            count <= 27'd0;
            tick  <= 1'b0;

        end

        else if (count == MAX_COUNT) begin

            count <= 27'd0;
            tick  <= 1'b1;

        end

        else begin

            count <= count + 1'b1;
            tick  <= 1'b0;

        end

    end

endmodule
```

This generates a one-clock-cycle pulse periodically.

---

# 🚦 24. FSM with Clock Enable

The traffic FSM can be modified to update only when `tick = 1`.

```verilog
always @(posedge clk) begin

    if (reset)
        state <= RED;

    else if (tick)
        state <= next_state;

end
```

This keeps the design in a single clock domain.

---

# 🧠 25. Study Case 5 — Sequence Detector FSM

Consider a circuit that detects the bit sequence

```text
101
```

from a serial input stream.

The FSM must remember previous input bits.

Possible states are:

* (S_0): no match
* (S_1): received `1`
* (S_2): received `10`

When the next input is `1`, the sequence `101` is detected.

---

# 🔄 26. Sequence Detector State Diagram

```text
          1
      ┌────────► S1
      │          │
      │          │0
      │          ▼
      │         S2
      │          │
      │          │1 / detect
      │          ▼
     S0 ◄────────┘
```

A more complete implementation may allow overlapping sequences.

---

# 💻 27. Sequence Detector Verilog

```verilog
module seq101_detector(
    input  wire clk,
    input  wire reset,
    input  wire x,
    output reg  detect
);

    localparam S0 = 2'b00;
    localparam S1 = 2'b01;
    localparam S2 = 2'b10;

    reg [1:0] state;
    reg [1:0] next_state;

    always @(posedge clk) begin

        if (reset)
            state <= S0;

        else
            state <= next_state;

    end

    always @(*) begin

        case (state)

            S0:
                if (x)
                    next_state = S1;
                else
                    next_state = S0;

            S1:
                if (x)
                    next_state = S1;
                else
                    next_state = S2;

            S2:
                if (x)
                    next_state = S1;
                else
                    next_state = S0;

            default:
                next_state = S0;

        endcase

    end

    always @(*) begin

        detect = 1'b0;

        if ((state == S2) && x)
            detect = 1'b1;

    end

endmodule
```

This behaves as a Mealy-style detector because the output depends on both state and input.

---

# 🧪 28. Sequence Detector Testbench

```verilog
`timescale 1ns / 1ps

module tb_seq101_detector;

    reg clk;
    reg reset;
    reg x;

    wire detect;

    seq101_detector uut (
        .clk(clk),
        .reset(reset),
        .x(x),
        .detect(detect)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        reset = 1;
        x = 0;

        #12;

        reset = 0;

        // Input sequence: 1 0 1
        x = 1; #10;
        x = 0; #10;
        x = 1; #10;

        // Additional sequence
        x = 1; #10;
        x = 0; #10;
        x = 1; #10;

        $finish;

    end

endmodule
```

---

# 🔍 29. Three-Process FSM Style

A clean FSM implementation often uses three blocks:

```text
Block 1 → State Register
Block 2 → Next-State Logic
Block 3 → Output Logic
```

The structure is

```verilog
always @(posedge clk)
    state <= next_state;
```

```verilog
always @(*)
    next_state = ...;
```

```verilog
always @(*)
    outputs = ...;
```

This style improves readability and reduces design errors.

---

# 🧠 30. Two-Process FSM Style

Another common implementation combines next-state and output logic into one block.

```text
Block 1 → State Register
Block 2 → Next State + Output Logic
```

Both methods are valid.

The three-process style is often easier for introductory learning.

---

# ⚠️ 31. Default Assignments in FSM Logic

Combinational FSM blocks should assign defaults.

For example,

```verilog
always @(*) begin

    next_state = state;

    case (state)
        ...
    endcase

end
```

This helps prevent unintended latch inference.

Similarly, output logic should initialize outputs before the `case` statement.

---

# 🚨 32. Illegal-State Recovery

FSMs should handle invalid states.

For example,

```verilog
default:
    next_state = RED;
```

This causes the FSM to return to a known state if an unexpected state occurs.

Thus,

$$
\boxed{
\text{Default State}
\rightarrow
\text{Safe Recovery}
}
$$

---

# 🔢 33. State-Encoding Methods

FSM states can be encoded in different ways.

### Binary Encoding

Three states may use:

```text
00
01
10
```

### One-Hot Encoding

Three states may use:

```text
001
010
100
```

### Gray Encoding

State transitions attempt to change only one bit at a time.

Vivado may optimize or re-encode states during synthesis depending on settings.

---

# 🆚 34. Binary versus One-Hot Encoding

| Characteristic     | Binary       | One-Hot         |
| ------------------ | ------------ | --------------- |
| State bits         | Few          | One per state   |
| Flip-flops         | Low          | Higher          |
| Decode logic       | More         | Often simpler   |
| FPGA suitability   | Good         | Very good       |
| Speed              | Moderate     | Often high      |
| Resource trade-off | FF-efficient | Logic-efficient |

---

# 🛠️ 35. Vivado Project Procedure

## Step 1 — Create Project

Open Vivado and choose

```text
Create Project
```

Select

```text
RTL Project
```

and choose the target FPGA board.

---

## Step 2 — Add Design Source

Create a file such as

```text
traffic_fsm.v
```

or

```text
counter4.v
```

---

## Step 3 — Add Simulation Source

Create

```text
tb_traffic_fsm.v
```

or another testbench.

---

# ▶️ 36. Run Behavioral Simulation

Select

```text
Run Simulation
    ↓
Run Behavioral Simulation
```

Observe:

* clock,
* reset,
* state,
* next state,
* outputs.

For FSM debugging, it is often useful to add `state` and `next_state` to the waveform.

---

# 🔍 37. Inspecting the State Signal

In the waveform viewer, a binary state may appear as

```text
00
01
10
00
...
```

To improve readability, students can correlate each value with its symbolic state:

```text
00 → RED
01 → GREEN
10 → YELLOW
```

---

# 🔬 38. RTL Schematic

Open

```text
RTL Analysis
    ↓
Open Elaborated Design
    ↓
Schematic
```

The FSM architecture should show:

```text
         ┌───────────────┐
Inputs ─►│ Next-State    │
         │ Logic         │
         └──────┬────────┘
                │
                ▼
         ┌───────────────┐
         │ State Register│
         └──────┬────────┘
                │
                ▼
         ┌───────────────┐
         │ Output Logic  │
         └──────┬────────┘
                │
                ▼
             Outputs
```

---

# 🔨 39. Synthesis

Run

```text
Run Synthesis
```

and inspect:

* LUTs,
* flip-flops,
* inferred FSM,
* clock resources.

Vivado synthesis may report recognized FSMs in the synthesis report.

---

# 📊 40. Resource Utilization

Record:

| Circuit           | LUTs | Flip-Flops | I/O |
| ----------------- | ---: | ---------: | --: |
| D Flip-Flop       |      |            |     |
| 4-Bit Register    |      |            |     |
| 4-Bit Counter     |      |            |     |
| Traffic FSM       |      |            |     |
| Sequence Detector |      |            |     |

Sequential circuits require flip-flops because state information must be stored.

---

# 🧷 41. FPGA I/O Mapping

For a traffic-light FSM:

| Signal   | FPGA Resource |
| -------- | ------------- |
| `clk`    | Onboard clock |
| `reset`  | BTN0          |
| `red`    | LED0          |
| `yellow` | LED1          |
| `green`  | LED2          |

The exact package pins must be taken from the board's official XDC file.

---

# 📌 42. Example XDC Structure

```tcl
set_property PACKAGE_PIN <CLK_PIN> [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

set_property PACKAGE_PIN <BTN_PIN> [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

set_property PACKAGE_PIN <LED0_PIN> [get_ports red]
set_property IOSTANDARD LVCMOS33 [get_ports red]
```

Repeat for the yellow and green LEDs.

---

# 📦 43. Generate Bitstream

After successful synthesis and implementation:

```text
Generate Bitstream
```

Then open:

```text
Hardware Manager
```

and program the FPGA.

---

# 🚦 44. Expected Hardware Behavior

For the traffic-light FSM, the LEDs should cycle as

```text
RED
 ↓
GREEN
 ↓
YELLOW
 ↓
RED
```

If a 1-second clock-enable interval is used, each state is visible for approximately one second.

---

# 🔘 45. Push-Button Considerations

Mechanical push buttons can generate several rapid transitions when pressed.

This effect is called

$$
\boxed{\text{Switch Bounce}}
$$

A raw button may appear as

```text
0 → 1 → 0 → 1 → 1
```

instead of one clean transition.

For reliable FSM control, a **debounce circuit** may be required.

---

# 🧠 46. Button Synchronization

External buttons are asynchronous relative to the FPGA clock.

A simple synchronization structure uses two flip-flops:

```text
Button
  │
  ▼
FF1
  │
  ▼
FF2
  │
  ▼
Synchronized Signal
```

This reduces metastability risk.

---

# ⚠️ 47. Clock versus Clock Enable

Avoid using ordinary logic signals as clocks when possible.

Preferred:

```text
System Clock
    │
    ▼
Counter
    │
    ▼
Enable Pulse
    │
    ▼
FSM
```

Rather than:

```text
Counter Output
    │
    ▼
New Clock
    │
    ▼
FSM
```

Using a clock enable keeps the design in one clock domain and simplifies timing analysis.

---

# 🧪 48. Lab Tasks

### Task 1 — D Flip-Flop

Implement and simulate a D flip-flop.

### Task 2 — 4-Bit Register

Implement a register with reset and enable.

### Task 3 — 4-Bit Counter

Implement a synchronous counter.

### Task 4 — Up/Down Counter

Add direction control.

### Task 5 — Traffic-Light FSM

Implement the three-state traffic-light controller.

### Task 6 — Slow State Transition

Use a counter-based clock-enable signal so the FSM can be observed on LEDs.

### Task 7 — Sequence Detector

Implement an FSM that detects `101`.

### Task 8 — Simulation

Verify all state transitions using Vivado waveforms.

### Task 9 — FPGA Implementation

Map state outputs to LEDs.

### Task 10 — Resource Analysis

Compare LUT and flip-flop usage for the sequential circuits.

---

# 📋 49. Experimental Results

Complete the table.

| Experiment        | Expected Behavior        | Measured Behavior | Pass/Fail |
| ----------------- | ------------------------ | ----------------- | --------- |
| D Flip-Flop       | Stores D at rising edge  |                   |           |
| Register          | Loads input when enabled |                   |           |
| Counter           | Counts 0–15              |                   |           |
| Up/Down Counter   | Counts both directions   |                   |           |
| Traffic FSM       | RED→GREEN→YELLOW         |                   |           |
| Sequence Detector | Detects `101`            |                   |           |

---

# 📊 50. FSM State Observation

For the traffic-light FSM:

| Clock Event | State  | Red | Yellow | Green |
| ----------: | ------ | :-: | :----: | :---: |
|       Reset | RED    |  1  |    0   |   0   |
|           1 | GREEN  |  0  |    0   |   1   |
|           2 | YELLOW |  0  |    1   |   0   |
|           3 | RED    |  1  |    0   |   0   |
|           4 | GREEN  |  0  |    0   |   1   |

Students should compare the expected table with the waveform and FPGA LEDs.

---

# ⏱️ 51. Timing Analysis

Sequential timing includes:

* setup time,
* hold time,
* clock-to-Q delay,
* combinational delay.

Conceptually,

```text
Register
   │
   ▼
Combinational Logic
   │
   ▼
Register
```

For reliable operation,

$$
T_{clk}
\geq
T_{cq}
+
T_{logic}
+
T_{setup}.
$$

---

# 📈 52. Maximum Clock Frequency

If the critical-path delay is

$$
T_{critical},
$$

then the approximate maximum clock frequency is

$$
f_{max}
\approx
\frac{1}{T_{critical}}.
$$

Vivado performs static timing analysis to verify whether the selected clock frequency is valid.

---

# 💬 53. Discussion Points

1. What is sequential logic?
2. What is the difference between combinational and sequential circuits?
3. Why do sequential circuits need storage elements?
4. What is the purpose of a clock?
5. What is the purpose of reset?
6. Why are nonblocking assignments recommended in sequential logic?
7. What is a state?
8. What are the three main parts of an FSM?
9. What is the difference between Moore and Mealy FSMs?
10. Why should default assignments be used in FSM logic?
11. Why is illegal-state recovery important?
12. What is state encoding?
13. Why is a clock enable preferable to creating a new fabric clock?
14. Why might a push button require debouncing?

---

# 🧠 54. Post-Lab Exercises

1. **8-Bit Counter**
   Expand the 4-bit counter to 8 bits.

2. **Modulo-10 Counter**
   Implement a decimal counter from 0 to 9.

3. **Ring Counter**
   Generate the sequence

   ```text
   0001 → 0010 → 0100 → 1000
   ```

4. **Johnson Counter**
   Implement a 4-bit Johnson counter.

5. **Pedestrian Traffic Light**
   Add a pedestrian request input.

6. **Four-State Traffic FSM**
   Add an `ALL_RED` state.

7. **Sequence Detector `1101`**
   Design an FSM to detect a different sequence.

8. **Overlapping Sequence Detection**
   Modify the `101` detector to support overlapping patterns.

9. **Moore Sequence Detector**
   Rewrite the detector as a Moore FSM.

10. **Debounced Button FSM**
    Use a push button to step manually through FSM states.

---

# 🔬 55. Advanced Exercise — Pedestrian Traffic Controller

Extend the traffic FSM to include a pedestrian request.

States may include:

```text
CAR_GREEN
    │
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

Inputs:

* pedestrian request,
* timer done.

Outputs:

* car red,
* car yellow,
* car green,
* pedestrian red,
* pedestrian green.

This introduces a more realistic event-driven FSM.

---

# 🚀 56. Advanced Exercise — FSM-Controlled Datapath

An FSM can control a datapath.

For example:

```text
                ┌───────────┐
Inputs ────────►│ Datapath  │
                └─────┬─────┘
                      ▲
                      │ Control
                ┌─────┴─────┐
                │    FSM    │
                └───────────┘
```

The FSM can control:

* register loading,
* counter reset,
* arithmetic enable,
* result capture.

This architecture is widely used in:

* processors,
* communication systems,
* MAC units,
* AI accelerators.

---

# 🧾 57. Expected Learning Outcomes

After completing this laboratory, students will be able to:

* Explain sequential logic and state storage.
* Implement D flip-flops and registers.
* Implement synchronous counters.
* Use clock, reset, and enable signals correctly.
* Explain finite-state machine concepts.
* Design state diagrams and state tables.
* Implement Moore and Mealy FSM concepts.
* Write state-register, next-state, and output logic.
* Simulate state transitions in Vivado.
* Analyze FSM behavior in RTL schematics.
* Implement FSMs on FPGA hardware.
* Use LEDs to visualize state outputs.
* Understand state encoding, timing, synchronization, and debouncing.
* Apply FSM concepts to more advanced FPGA systems.

---

# 📘 58. References

1. M. M. Mano and M. D. Ciletti, *Digital Design*, Pearson.
2. S. Brown and Z. Vranesic, *Fundamentals of Digital Logic with Verilog Design*, McGraw-Hill.
3. M. D. Ciletti, *Advanced Digital Design with the Verilog HDL*, Pearson.
4. AMD Xilinx, *Vivado Design Suite User Guide: Synthesis*.
5. AMD Xilinx, *Vivado Design Suite User Guide: Logic Simulation*.
6. AMD Xilinx, *Vivado Design Suite User Guide: Design Analysis and Closure Techniques*.
7. IEEE Std 1364-2005, *IEEE Standard for Verilog Hardware Description Language*.

---

## 🔑 Key Concept

The central idea of sequential design is

$$
\boxed{
\text{Current State}
+
\text{Input}
\rightarrow
\text{Next State}
}
$$

The basic FSM architecture is

$$
\boxed{
\text{State Register}
+
\text{Next-State Logic}
+
\text{Output Logic}
}
$$

and the recommended FPGA workflow is

$$
\boxed{
\text{State Diagram}
\rightarrow
\text{Verilog FSM}
\rightarrow
\text{Simulation}
\rightarrow
\text{Synthesis}
\rightarrow
\text{FPGA}
}
$$

This laboratory provides the foundation for later work involving **timers, protocol controllers, traffic systems, UART controllers, processor control units, MAC controllers, custom AXI peripherals, and AI-FPGA control architectures**.
