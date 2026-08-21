# 🔬 Lab: Verilog/SystemVerilog-3 — Sequential Design

## Flip-Flops, Registers, and Counters Using EDA Playground

## 🧩 1. Objective

* Understand the fundamental concepts of **sequential digital circuits**.
* Learn how sequential logic differs from combinational logic.
* Understand the roles of **clock, reset, enable, and stored state**.
* Implement basic **D flip-flops** using Verilog/SystemVerilog.
* Design multi-bit **registers** with reset and enable control.
* Implement binary, up/down, and modulo counters.
* Create testbenches for clocked digital circuits.
* Observe sequential behavior using **EDA Playground and EPWave**.
* Practice proper use of **nonblocking assignments** in clocked HDL.
* Establish a foundation for finite-state machines, datapaths, processors, and FPGA systems.

---

## ⚙️ 2. Equipment and Tools

| Tool / Resource                                       | Description                                          |
| ----------------------------------------------------- | ---------------------------------------------------- |
| **EDA Playground**                                    | Online Verilog/SystemVerilog development environment |
| **Web Browser**                                       | Access to online HDL tools                           |
| **Verilog / SystemVerilog**                           | Hardware description languages                       |
| **Icarus Verilog / Verilator / Questa or equivalent** | Simulation engine                                    |
| **EPWave**                                            | Waveform visualization                               |
| **Testbench**                                         | Clock, reset, and stimulus generation                |

---

# 🧠 3. Background Theory

## 3.1 Sequential Logic

A **sequential circuit** produces outputs based on:

* current inputs, and
* previously stored information.

Mathematically,

$$
Y[n]=f(X[n],S[n])
$$

where

* (X[n]) is the current input,
* (S[n]) is the current state,
* (Y[n]) is the current output.

The next state is

$$
S[n+1]=g(X[n],S[n]).
$$

Therefore,

$$
\boxed{
\text{Sequential Logic}
=======================

\text{Current Inputs}
+
\text{Stored State}
}
$$

---

## 3.2 Combinational versus Sequential Logic

| Characteristic            | Combinational Logic   | Sequential Logic   |
| ------------------------- | --------------------- | ------------------ |
| Depends on current inputs | Yes                   | Yes                |
| Depends on previous state | No                    | Yes                |
| Memory                    | No                    | Yes                |
| Clock                     | Not normally required | Usually required   |
| Storage element           | None                  | Flip-flop/register |
| Example                   | Adder, MUX            | Register, counter  |

The key feature of sequential circuits is

$$
\boxed{\text{Memory}}
$$

---

# ⏱️ 4. Clock Signal

A clock is a periodic digital signal that synchronizes sequential circuits.

Example:

```text
      ┌─────┐     ┌─────┐     ┌─────┐
clk ──┘     └─────┘     └─────┘     └──
      ↑           ↑           ↑
   Rising      Rising      Rising
    Edge        Edge        Edge
```

A sequential block can respond to the rising edge using

```verilog
always @(posedge clk)
```

In SystemVerilog, the preferred equivalent is often

```systemverilog
always_ff @(posedge clk)
```

---

# 🕒 5. Clock Period and Frequency

The relationship between clock period and frequency is

$$
f=\frac{1}{T}.
$$

For example, if

$$
T=10~\text{ns},
$$

then

$$
f
=

# \frac{1}{10\times10^{-9}}

100~\text{MHz}.
$$

A testbench can generate a 100 MHz clock using

```systemverilog
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end
```

The clock changes every 5 ns, so the complete period is 10 ns.

---

# 🧱 6. Flip-Flops

A flip-flop stores one bit.

The most common type is the **D flip-flop**.

Its operation is

$$
Q[n+1]=D[n]
$$

at the active clock edge.

A conceptual representation is

```text
        ┌─────────┐
D ─────►│ D Flip  │────► Q
        │  Flop   │
clk ───►│ >       │
        └─────────┘
```

---

# 💻 7. Study Case 1 — D Flip-Flop

## 7.1 Verilog Implementation

```verilog
module dff(
    input  wire clk,
    input  wire D,
    output reg  Q
);

    always @(posedge clk) begin
        Q <= D;
    end

endmodule
```

The output `Q` changes only on a rising clock edge.

---

## 7.2 SystemVerilog Implementation

```systemverilog
module dff_sv(
    input  logic clk,
    input  logic D,
    output logic Q
);

    always_ff @(posedge clk) begin
        Q <= D;
    end

endmodule
```

`always_ff` clearly identifies the block as sequential logic.

---

# 🧠 8. Nonblocking Assignment

Sequential HDL normally uses

```text
<=
```

called a **nonblocking assignment**.

Example:

```systemverilog
Q <= D;
```

This is preferred over

```systemverilog
Q = D;
```

inside clocked logic.

The general design guideline is

$$
\boxed{
\text{Clocked Sequential Logic}
\rightarrow
\text{Nonblocking Assignment}
}
$$

while combinational logic commonly uses blocking assignments.

---

# 🧪 9. D Flip-Flop Testbench

```systemverilog
`timescale 1ns/1ps

module tb_dff;

    logic clk;
    logic D;
    logic Q;

    dff_sv dut (
        .clk(clk),
        .D(D),
        .Q(Q)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        $dumpfile("dump.vcd");
        $dumpvars(0, tb_dff);

        D = 0;

        #7;
        D = 1;

        #10;
        D = 0;

        #10;
        D = 1;

        #15;

        $finish;

    end

endmodule
```

The waveform should demonstrate that `Q` samples `D` only at each positive clock edge.

---

# 🔄 10. D Flip-Flop with Reset

A reset forces the stored value into a known state.

A synchronous reset is evaluated on the active clock edge.

```systemverilog
module dff_reset(
    input  logic clk,
    input  logic reset,
    input  logic D,
    output logic Q
);

    always_ff @(posedge clk) begin

        if (reset)
            Q <= 1'b0;

        else
            Q <= D;

    end

endmodule
```

When

$$
reset=1,
$$

the next active clock edge produces

$$
Q=0.
$$

---

# ⚡ 11. Asynchronous Reset

An asynchronous reset can affect the output without waiting for a clock edge.

```systemverilog
module dff_async_reset(
    input  logic clk,
    input  logic reset,
    input  logic D,
    output logic Q
);

    always_ff @(posedge clk or posedge reset) begin

        if (reset)
            Q <= 1'b0;

        else
            Q <= D;

    end

endmodule
```

The sensitivity list includes

```text
posedge reset
```

so reset can immediately clear the register.

---

# 🆚 12. Synchronous versus Asynchronous Reset

| Characteristic      | Synchronous Reset | Asynchronous Reset             |
| ------------------- | ----------------- | ------------------------------ |
| Requires clock edge | Yes               | No                             |
| Immediate response  | No                | Yes                            |
| Coding style        | `posedge clk`     | `posedge clk or posedge reset` |
| Timing handling     | Simpler           | Requires care                  |
| Common FPGA use     | Very common       | Also common                    |

The appropriate reset strategy depends on system architecture and implementation requirements.

---

# 📦 13. Registers

A register is a group of flip-flops used to store multiple bits.

For an (N)-bit register,

$$
Q[N-1:0]
\leftarrow
D[N-1:0].
$$

For example, a 4-bit register contains four storage bits.

```text
D[3:0]
   │
   ▼
┌────────────┐
│ 4-Bit      │
│ Register   │
└─────┬──────┘
      │
      ▼
Q[3:0]
```

---

# 💻 14. Study Case 2 — 4-Bit Register

```systemverilog
module register4(
    input  logic       clk,
    input  logic       reset,
    input  logic [3:0] D,
    output logic [3:0] Q
);

    always_ff @(posedge clk) begin

        if (reset)
            Q <= 4'b0000;

        else
            Q <= D;

    end

endmodule
```

---

# 🔘 15. Register with Enable

An enable input determines whether the register loads new data.

If

$$
EN=1,
$$

then

$$
Q\leftarrow D.
$$

If

$$
EN=0,
$$

then

$$
Q\leftarrow Q.
$$

---

## 15.1 SystemVerilog Implementation

```systemverilog
module register4_enable(
    input  logic       clk,
    input  logic       reset,
    input  logic       enable,
    input  logic [3:0] D,
    output logic [3:0] Q
);

    always_ff @(posedge clk) begin

        if (reset)
            Q <= 4'b0000;

        else if (enable)
            Q <= D;

    end

endmodule
```

No explicit `else` is required after `enable` because a flip-flop naturally retains its previous value.

---

# 🧪 16. Register Testbench

```systemverilog
`timescale 1ns/1ps

module tb_register4;

    logic clk;
    logic reset;
    logic enable;

    logic [3:0] D;
    logic [3:0] Q;

    register4_enable dut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .D(D),
        .Q(Q)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        $dumpfile("dump.vcd");
        $dumpvars(0, tb_register4);

        reset  = 1;
        enable = 0;
        D      = 4'b0000;

        #12;

        reset  = 0;
        enable = 1;
        D      = 4'b1010;

        #10;

        D = 4'b0101;

        #10;

        enable = 0;
        D      = 4'b1111;

        #20;

        $finish;

    end

endmodule
```

When `enable=0`, `Q` should retain its previous value.

---

# 🔢 17. Counters

A counter is a sequential circuit that changes its stored value according to a defined sequence.

A basic binary up-counter follows

$$
Q[n+1]=Q[n]+1.
$$

For a 4-bit counter,

$$
0\leq Q\leq15.
$$

The sequence is

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

---

# 💻 18. Study Case 3 — 4-Bit Up Counter

```systemverilog
module counter4(
    input  logic       clk,
    input  logic       reset,
    output logic [3:0] count
);

    always_ff @(posedge clk) begin

        if (reset)
            count <= 4'b0000;

        else
            count <= count + 1'b1;

    end

endmodule
```

---

# 🧪 19. Up-Counter Testbench

```systemverilog
`timescale 1ns/1ps

module tb_counter4;

    logic clk;
    logic reset;

    logic [3:0] count;

    counter4 dut (
        .clk(clk),
        .reset(reset),
        .count(count)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        $dumpfile("dump.vcd");
        $dumpvars(0, tb_counter4);

        reset = 1;

        #12;

        reset = 0;

        #180;

        $finish;

    end

endmodule
```

The waveform should show

```text
0 → 1 → 2 → 3 → ... → 15 → 0
```

---

# 📊 20. Expected Counter Results

| Rising Edge |  Count |
| ----------: | :----: |
|       Reset | `0000` |
|           1 | `0001` |
|           2 | `0010` |
|           3 | `0011` |
|           4 | `0100` |
|           5 | `0101` |
|         ... |   ...  |
|          15 | `1111` |
|          16 | `0000` |

The counter wraps automatically because only four bits are stored.

---

# 🔘 21. Counter with Enable

The counter can be modified so that counting occurs only when

$$
enable=1.
$$

```systemverilog
module counter4_enable(
    input  logic       clk,
    input  logic       reset,
    input  logic       enable,
    output logic [3:0] count
);

    always_ff @(posedge clk) begin

        if (reset)
            count <= 4'b0000;

        else if (enable)
            count <= count + 1'b1;

    end

endmodule
```

When `enable=0`, the current count is retained.

---

# 🔄 22. Study Case 4 — Up/Down Counter

An up/down counter changes direction according to a control signal.

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

## 22.1 SystemVerilog Implementation

```systemverilog
module updown_counter4(
    input  logic       clk,
    input  logic       reset,
    input  logic       enable,
    input  logic       dir,
    output logic [3:0] count
);

    always_ff @(posedge clk) begin

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

# 🧪 23. Up/Down Counter Testbench

```systemverilog
`timescale 1ns/1ps

module tb_updown_counter;

    logic clk;
    logic reset;
    logic enable;
    logic dir;

    logic [3:0] count;

    updown_counter4 dut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .dir(dir),
        .count(count)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        $dumpfile("dump.vcd");
        $dumpvars(0, tb_updown_counter);

        reset  = 1;
        enable = 0;
        dir    = 1;

        #12;

        reset  = 0;
        enable = 1;

        // Count up
        #60;

        // Count down
        dir = 0;

        #60;

        enable = 0;

        #20;

        $finish;

    end

endmodule
```

---

# 🔟 24. Study Case 5 — Modulo-10 Counter

A modulo-(N) counter counts from

$$
0
$$

to

$$
N-1
$$

and then returns to zero.

For a modulo-10 counter:

```text
0 → 1 → 2 → ... → 9 → 0
```

This is commonly called a **decade counter**.

---

## 24.1 SystemVerilog Implementation

```systemverilog
module counter_mod10(
    input  logic       clk,
    input  logic       reset,
    output logic [3:0] count
);

    always_ff @(posedge clk) begin

        if (reset)
            count <= 4'd0;

        else if (count == 4'd9)
            count <= 4'd0;

        else
            count <= count + 1'b1;

    end

endmodule
```

---

# 📊 25. Modulo-10 Sequence

| Clock | Count |
| ----: | ----: |
| Reset |     0 |
|     1 |     1 |
|     2 |     2 |
|     3 |     3 |
|   ... |   ... |
|     9 |     9 |
|    10 |     0 |
|    11 |     1 |

This type of counter is useful in:

* decimal displays,
* timers,
* clocks,
* event counting.

---

# 🔁 26. Study Case 6 — Shift Register

A shift register moves stored data by one position per clock.

For a 4-bit right-shift register,

$$
Q_3\leftarrow serial_in
$$

$$
Q_2\leftarrow Q_3
$$

$$
Q_1\leftarrow Q_2
$$

$$
Q_0\leftarrow Q_1.
$$

---

## 26.1 SystemVerilog Shift Register

```systemverilog
module shift_register4(
    input  logic       clk,
    input  logic       reset,
    input  logic       serial_in,
    output logic [3:0] Q
);

    always_ff @(posedge clk) begin

        if (reset)
            Q <= 4'b0000;

        else
            Q <= {serial_in, Q[3:1]};

    end

endmodule
```

---

# 🧠 27. Shift Register Applications

Shift registers are commonly used for:

* serial-to-parallel conversion,
* parallel-to-serial conversion,
* digital delays,
* communication interfaces,
* pseudo-random generators,
* LED patterns.

The data movement can be represented as

```text
Serial In
    │
    ▼
[FF3] → [FF2] → [FF1] → [FF0]
```

---

# 🔄 28. Ring Counter

A ring counter is a shift register where one output is fed back to the input.

Example sequence:

```text
0001
0010
0100
1000
0001
```

A 4-bit ring counter can be written as

```systemverilog
module ring_counter4(
    input  logic       clk,
    input  logic       reset,
    output logic [3:0] Q
);

    always_ff @(posedge clk) begin

        if (reset)
            Q <= 4'b0001;

        else
            Q <= {Q[2:0], Q[3]};

    end

endmodule
```

---

# 🔁 29. Johnson Counter

A Johnson counter feeds the inverted last bit back into the shift register.

For a 4-bit Johnson counter, the sequence can contain

$$
2N=8
$$

states.

Example:

```text
0000
0001
0011
0111
1111
1110
1100
1000
0000
```

This is useful for sequence generation and timing control.

---

# 💻 30. Johnson Counter Implementation

```systemverilog
module johnson_counter4(
    input  logic       clk,
    input  logic       reset,
    output logic [3:0] Q
);

    always_ff @(posedge clk) begin

        if (reset)
            Q <= 4'b0000;

        else
            Q <= {Q[2:0], ~Q[3]};

    end

endmodule
```

---

# 🧠 31. Sequential Circuit Structure

Most sequential circuits can be understood as

```text
                 ┌──────────────────┐
Input ──────────►│ Combinational    │
                 │ Next-State Logic │
                 └────────┬─────────┘
                          │
                          ▼
                    ┌─────────┐
Clock ─────────────►│ Register│
                    └────┬────┘
                         │
                         ▼
                       State
```

The register stores state while combinational logic determines the next value.

---

# 🔬 32. Counter as Next-State Logic

For a counter,

$$
Q_{next}=Q+1.
$$

The hardware architecture is

```text
      ┌─────────┐
Q ───►│ +1      │
      └────┬────┘
           │
           ▼
      ┌─────────┐
clk ─►│ Register│
      └────┬────┘
           │
           └────► Q
```

Therefore, a counter combines:

$$
\boxed{
\text{Adder}
+
\text{Register}
}
$$

---

# 🌐 33. Using EDA Playground

## Step 1 — Open EDA Playground

Create a new online project.

---

## Step 2 — Select SystemVerilog

Choose:

```text
SystemVerilog
```

This enables constructs such as

```systemverilog
logic
```

and

```systemverilog
always_ff
```

---

## Step 3 — Select Simulator

Choose an available simulator supporting SystemVerilog.

Examples may include:

```text
Icarus Verilog
Verilator
Questa
```

depending on current availability.

---

## Step 4 — Enter the Design

Place the sequential module in the design window.

---

## Step 5 — Enter the Testbench

Place clock, reset, and stimulus generation in the testbench window.

---

## Step 6 — Enable Waveforms

Include

```systemverilog
$dumpfile("dump.vcd");
$dumpvars(0, tb);
```

and enable EPWave if supported.

---

## Step 7 — Run Simulation

Click

```text
Run
```

and inspect both:

* console output,
* waveform behavior.

---

# 📈 34. Sequential Waveform Analysis

Consider a counter waveform:

```text
clk    _-_-_-_-_-_-_-_-_

reset  ----______________

count  0  0  1  2  3  4
             ↑  ↑  ↑  ↑
           Clock edges
```

The counter changes only at active clock edges.

This differs from combinational circuits where output may change whenever an input changes.

---

# ⏱️ 35. Reset Timing

For a synchronous reset,

```systemverilog
if (reset)
    count <= 0;
```

the counter clears only on a clock edge.

For an asynchronous reset,

```systemverilog
always_ff @(posedge clk or posedge reset)
```

the output can clear immediately when reset becomes active.

Students should compare these behaviors in simulation.

---

# ⚠️ 36. Common Sequential HDL Errors

## Error 1 — Using Blocking Assignment

Avoid:

```systemverilog
always_ff @(posedge clk)
    Q = D;
```

Prefer:

```systemverilog
always_ff @(posedge clk)
    Q <= D;
```

---

## Error 2 — Forgetting Reset Initialization

Without reset or initialization, some simulation signals may begin as

```text
X
```

meaning unknown.

---

## Error 3 — No Clock Generation

A sequential DUT will not change if the testbench does not generate clock edges.

---

## Error 4 — Simulation Too Short

A counter may need many cycles before expected behavior becomes visible.

---

## Error 5 — Changing Stimulus Exactly at a Clock Edge

Changing `D`, `enable`, or `dir` at the exact sampling edge may create ambiguous simulation scenarios.

For introductory testbenches, change stimulus between clock edges.

---

# 🧪 37. Self-Checking Counter Testbench

```systemverilog
module tb_counter_check;

    logic clk;
    logic reset;

    logic [3:0] count;

    logic [3:0] expected;

    counter4 dut (
        .clk(clk),
        .reset(reset),
        .count(count)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        reset = 1;
        expected = 0;

        #12;
        reset = 0;

        repeat (10) begin

            @(posedge clk);
            #1;

            expected = expected + 1'b1;

            if (count === expected)
                $display(
                    "PASS count=%0d",
                    count
                );

            else
                $display(
                    "FAIL count=%0d expected=%0d",
                    count,
                    expected
                );

        end

        $finish;

    end

endmodule
```

This introduces event-based verification using

```systemverilog
@(posedge clk);
```

---

# 🔍 38. `repeat` Statement

The testbench construct

```systemverilog
repeat (10)
```

runs the following statement or block ten times.

For example:

```systemverilog
repeat (10) begin
    @(posedge clk);
end
```

waits for ten rising clock edges.

This is useful for sequential verification.

---

# 🧠 39. Clock Enable versus Generated Clock

A common design requirement is to slow an operation.

Rather than creating another clock using ordinary logic, a preferred design can use a **clock-enable pulse**.

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
Sequential Circuit
```

Then:

```systemverilog
always_ff @(posedge clk) begin

    if (enable)
        count <= count + 1'b1;

end
```

This keeps the circuit in a single clock domain.

---

# 🔢 40. Parameterized Counter

A reusable counter can support different widths.

```systemverilog
module counter #(
    parameter N = 8
)(
    input  logic         clk,
    input  logic         reset,
    input  logic         enable,
    output logic [N-1:0] count
);

    always_ff @(posedge clk) begin

        if (reset)
            count <= '0;

        else if (enable)
            count <= count + 1'b1;

    end

endmodule
```

Changing

```text
N
```

changes the counter width.

For example:

$$
N=8
$$

provides

$$
2^8=256
$$

possible states.

---

# 📊 41. Counter Capacity

An (N)-bit binary counter has

$$
2^N
$$

possible values.

Examples:

| Number of Bits | Number of States | Range    |
| -------------: | ---------------: | -------- |
|              2 |                4 | 0–3      |
|              4 |               16 | 0–15     |
|              8 |              256 | 0–255    |
|             16 |           65,536 | 0–65,535 |

---

# 🧪 42. Lab Tasks

### Task 1 — D Flip-Flop

Implement and simulate a positive-edge-triggered D flip-flop.

### Task 2 — Add Reset

Create synchronous and asynchronous reset versions.

### Task 3 — 4-Bit Register

Implement a 4-bit data register.

### Task 4 — Register Enable

Add an enable signal and verify data retention.

### Task 5 — 4-Bit Up Counter

Implement a binary counter from `0000` to `1111`.

### Task 6 — Counter Enable

Pause and resume the counter using an enable input.

### Task 7 — Up/Down Counter

Implement direction-controlled counting.

### Task 8 — Modulo-10 Counter

Implement a decimal counter from 0 to 9.

### Task 9 — Shift Register

Implement a 4-bit serial-input shift register.

### Task 10 — Waveform Analysis

Use EPWave to examine clock, reset, inputs, and stored outputs.

---

# 📋 43. Experimental Results

| Circuit         | Input / Condition | Expected Result | Simulated Result | Pass/Fail |
| --------------- | ----------------- | --------------- | ---------------- | --------- |
| D Flip-Flop     | D=1 at clock edge | Q=1             |                  |           |
| D Flip-Flop     | D=0 at clock edge | Q=0             |                  |           |
| Register        | Enable=1          | Load D          |                  |           |
| Register        | Enable=0          | Hold Q          |                  |           |
| Up Counter      | Enable=1          | Increment       |                  |           |
| Up/Down Counter | DIR=1             | Count up        |                  |           |
| Up/Down Counter | DIR=0             | Count down      |                  |           |
| Mod-10 Counter  | Count=9           | Next=0          |                  |           |

---

# 📊 44. Counter Verification Table

| Clock Edge | Expected Count | Simulated Count |
| ---------: | :------------: | :-------------: |
|      Reset |     `0000`     |                 |
|          1 |     `0001`     |                 |
|          2 |     `0010`     |                 |
|          3 |     `0011`     |                 |
|          4 |     `0100`     |                 |
|          5 |     `0101`     |                 |
|          6 |     `0110`     |                 |
|          7 |     `0111`     |                 |

---

# 💬 45. Discussion Points

1. What is sequential logic?
2. How does sequential logic differ from combinational logic?
3. What is the purpose of a clock signal?
4. What is a D flip-flop?
5. Why does a register contain multiple flip-flops?
6. What is the purpose of reset?
7. What is the difference between synchronous and asynchronous reset?
8. Why should nonblocking assignment be used in sequential logic?
9. What does a register do when `enable=0`?
10. How does a binary counter work?
11. Why does a 4-bit counter wrap from 15 to 0?
12. What is a modulo counter?
13. What is the difference between an up counter and an up/down counter?
14. What is a shift register?
15. Why is waveform analysis especially important for clocked circuits?

---

# 🧠 46. Post-Lab Exercises

1. **8-Bit Register**
   Expand the register to eight bits.

2. **8-Bit Counter**
   Implement an 8-bit binary counter.

3. **Modulo-16 Counter**
   Verify the normal 4-bit wrap-around sequence.

4. **Modulo-6 Counter**
   Implement:

   ```text
   0 → 1 → 2 → 3 → 4 → 5 → 0
   ```

5. **Loadable Counter**
   Add a `load` input and a parallel data input.

6. **Ring Counter**
   Implement a 4-bit one-hot rotating pattern.

7. **Johnson Counter**
   Implement an 8-state Johnson sequence.

8. **Left/Right Shift Register**
   Add a direction control.

9. **Parallel-In Serial-Out Register**
   Implement PISO operation.

10. **Serial-In Parallel-Out Register**
    Implement SIPO operation.

---

# 🔬 47. Advanced Exercise — Universal Shift Register

Create a 4-bit universal shift register supporting:

| MODE | Operation     |
| :--: | ------------- |
| `00` | Hold          |
| `01` | Shift right   |
| `10` | Shift left    |
| `11` | Parallel load |

Example:

```systemverilog
module universal_shift_register(
    input  logic       clk,
    input  logic       reset,
    input  logic [1:0] mode,
    input  logic       serial_left,
    input  logic       serial_right,
    input  logic [3:0] parallel_in,
    output logic [3:0] Q
);

    always_ff @(posedge clk) begin

        if (reset)
            Q <= 4'b0000;

        else begin

            case (mode)

                2'b00:
                    Q <= Q;

                2'b01:
                    Q <= {serial_left, Q[3:1]};

                2'b10:
                    Q <= {Q[2:0], serial_right};

                2'b11:
                    Q <= parallel_in;

            endcase

        end

    end

endmodule
```

---

# 🚀 48. Advanced Exercise — Programmable Counter

Create a counter with:

* reset,
* enable,
* up/down direction,
* parallel load.

The behavior is

$$
COUNT_{next}
============

\begin{cases}
0,&reset=1\
DATA,&load=1\
COUNT+1,&enable=1,\ dir=1\
COUNT-1,&enable=1,\ dir=0\
COUNT,&\text{otherwise}.
\end{cases}
$$

This introduces **control priority** in sequential designs.

---

# 🧩 49. Sequential Datapath Concept

Registers and counters are key components of a datapath.

For example:

```text
Input
  │
  ▼
Register A
  │
  ▼
Adder
  │
  ▼
Register B
  │
  ▼
Output
```

Each register separates one processing stage from another.

This concept is the basis of:

* pipelines,
* processors,
* DSP systems,
* ANN accelerators,
* CNN accelerators.

---

# 🔄 50. Recommended EDA Workflow

```text
Sequential Function
       │
       ▼
Write SystemVerilog
       │
       ▼
Create Clocked Testbench
       │
       ▼
Generate Clock + Reset
       │
       ▼
Run Simulation
       │
       ▼
Inspect EPWave
       │
       ▼
Check State at Clock Edges
       │
       ├── Incorrect → Debug HDL
       │
       └── Correct
               │
               ▼
        Complete Design
```

---

# 🧾 51. Expected Learning Outcomes

After completing this laboratory, students will be able to:

* Explain sequential digital logic.
* Explain the function of clocks and state storage.
* Implement D flip-flops using Verilog/SystemVerilog.
* Distinguish synchronous and asynchronous reset.
* Use `always_ff` and nonblocking assignments.
* Design multi-bit registers.
* Add enable and reset functions to registers.
* Implement binary and modulo counters.
* Design up/down counters.
* Implement basic shift registers.
* Generate clock signals in a testbench.
* Analyze sequential waveforms using EPWave.
* Create self-checking sequential testbenches.
* Apply registers and counters to larger digital systems.

---

# 📘 52. References

1. M. M. Mano and M. D. Ciletti, *Digital Design*, Pearson.
2. S. Brown and Z. Vranesic, *Fundamentals of Digital Logic with Verilog Design*, McGraw-Hill.
3. M. D. Ciletti, *Advanced Digital Design with the Verilog HDL*, Pearson.
4. D. M. Harris and S. L. Harris, *Digital Design and Computer Architecture*, Morgan Kaufmann.
5. IEEE Std 1364-2005, *IEEE Standard for Verilog Hardware Description Language*.
6. IEEE Std 1800, *SystemVerilog—Unified Hardware Design, Specification, and Verification Language*.

---

## 🔑 Key Concept

The central concept of sequential design is

$$
\boxed{
\text{Clock}
+
\text{Storage}
+
\text{Next-State Logic}
}
$$

For a register,

$$
\boxed{
D
\xrightarrow{\text{Clock}}
Q
}
$$

and for a counter,

$$
\boxed{
Q_{next}=Q+1
}
$$

The complete learning progression is

$$
\boxed{
\text{Flip-Flop}
\rightarrow
\text{Register}
\rightarrow
\text{Counter}
\rightarrow
\text{FSM}
\rightarrow
\text{Digital System}
}
$$

This laboratory provides the foundation for subsequent work involving **finite-state machines, timing controllers, datapaths, processors, UART controllers, FPGA systems, MAC engines, and AI-FPGA architectures**.
