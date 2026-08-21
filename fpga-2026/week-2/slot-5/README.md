# 🔬 Lab: Vivado-1 — Simulation & Testbench

## Behavioral Simulation Using Vivado

## 🧩 1. Objective

* Understand the purpose of **simulation** in digital-system design.
* Learn the difference between **design source** and **testbench source**.
* Create a simple combinational Verilog circuit.
* Write a Verilog testbench to generate input stimulus automatically.
* Run **Behavioral Simulation** using Vivado Simulator.
* Observe signals using the Vivado waveform viewer.
* Verify a design before FPGA synthesis and hardware implementation.
* Learn how to detect functional errors using simulation.

---

## ⚙️ 2. Equipment and Tools

| Tool / Resource             | Description                            |
| --------------------------- | -------------------------------------- |
| **Vivado Design Suite**     | HDL design and behavioral simulation   |
| **Vivado Simulator (XSim)** | Built-in simulator                     |
| **Verilog HDL**             | Design and testbench language          |
| **Waveform Viewer**         | Signal visualization                   |
| **FPGA Board (optional)**   | Not required for behavioral simulation |
| **PC / Workstation**        | Vivado development environment         |

---

## 🧠 3. Background Theory

### 3.1 What Is Digital Simulation?

Simulation is the process of testing a digital design using software before implementing it on FPGA hardware.

A simulation allows the designer to apply input signals and observe the resulting outputs.

The basic process is

```text
Input Stimulus
     │
     ▼
Design Under Test
     │
     ▼
Output Response
     │
     ▼
Waveform Analysis
```

The main goal is to verify that

$$
\boxed{\text{Actual Output}=\text{Expected Output}}
$$

before synthesis.

---

### 3.2 Why Simulation Is Important

Simulation helps detect problems such as:

* incorrect Boolean logic,
* wrong signal connections,
* timing sequence errors,
* reset problems,
* state-machine errors,
* arithmetic mistakes,
* unexpected output conditions.

Without simulation, these problems may only be discovered after FPGA programming.

Therefore,

$$
\boxed{\text{Simulation First} \rightarrow \text{Hardware Later}}
$$

is an important FPGA design practice.

---

## 🧩 4. Design Source and Testbench Source

A Vivado simulation project normally contains at least two types of HDL files.

### Design Source

The design source describes the hardware circuit.

For example:

```verilog
module and_gate(
    input  wire A,
    input  wire B,
    output wire Y
);

    assign Y = A & B;

endmodule
```

### Testbench Source

The testbench generates simulation inputs and observes the output.

For example:

```verilog
module tb_and_gate;

    reg A;
    reg B;

    wire Y;

    and_gate uut (
        .A(A),
        .B(B),
        .Y(Y)
    );

endmodule
```

The testbench is used only for simulation.

It is generally **not synthesized into FPGA hardware**.

---

# 🧠 5. Device Under Test

The circuit being tested is often called:

* DUT — Device Under Test
* UUT — Unit Under Test

For example,

```verilog
and_gate uut (
    .A(A),
    .B(B),
    .Y(Y)
);
```

means that the `and_gate` module is instantiated inside the testbench.

The simulation structure is

```text
Testbench
    │
    ├── Generates A
    ├── Generates B
    │
    ▼
   UUT
    │
    ▼
    Y
```

---

# 🔬 6. Study Case — Basic Logic Circuit

For this laboratory, use the function

$$
Y=(A\land B)\lor C.
$$

The corresponding Boolean equation is

$$
Y=AB+C.
$$

The circuit can be represented as

```text
A ─────┐
       AND ───┐
B ─────┘      │
              OR ───► Y
C ────────────┘
```

---

# 📊 7. Truth Table

The complete truth table is

|  A  |  B  |  C  | (A \land B) |  Y  |
| :-: | :-: | :-: | :---------: | :-: |
|  0  |  0  |  0  |      0      |  0  |
|  0  |  0  |  1  |      0      |  1  |
|  0  |  1  |  0  |      0      |  0  |
|  0  |  1  |  1  |      0      |  1  |
|  1  |  0  |  0  |      0      |  0  |
|  1  |  0  |  1  |      0      |  1  |
|  1  |  1  |  0  |      1      |  1  |
|  1  |  1  |  1  |      1      |  1  |

This table will be used to verify the simulation results.

---

# 💻 8. Verilog Design Module

Create the design file

```text
logic_circuit.v
```

with the following code:

```verilog
module logic_circuit(
    input  wire A,
    input  wire B,
    input  wire C,
    output wire Y
);

    assign Y = (A & B) | C;

endmodule
```

This is a combinational circuit.

No clock is required.

---

# 🧪 9. Basic Testbench

Create a simulation source

```text
tb_logic_circuit.v
```

with the following code:

```verilog
`timescale 1ns / 1ps

module tb_logic_circuit;

    reg A;
    reg B;
    reg C;

    wire Y;

    logic_circuit uut (
        .A(A),
        .B(B),
        .C(C),
        .Y(Y)
    );

    initial begin

        A = 0;
        B = 0;
        C = 0;
        #10;

        A = 0;
        B = 0;
        C = 1;
        #10;

        A = 0;
        B = 1;
        C = 0;
        #10;

        A = 0;
        B = 1;
        C = 1;
        #10;

        A = 1;
        B = 0;
        C = 0;
        #10;

        A = 1;
        B = 0;
        C = 1;
        #10;

        A = 1;
        B = 1;
        C = 0;
        #10;

        A = 1;
        B = 1;
        C = 1;
        #10;

        $finish;

    end

endmodule
```

---

# ⏱️ 10. Understanding `#10`

The statement

```verilog
#10;
```

creates a simulation delay.

With

```verilog
`timescale 1ns / 1ps
```

the value

```text
#10
```

means

$$
10~\text{ns}.
$$

Therefore, each input condition remains active for 10 ns before the next condition is applied.

The timeline is approximately

```text
0 ns   → 000
10 ns  → 001
20 ns  → 010
30 ns  → 011
40 ns  → 100
50 ns  → 101
60 ns  → 110
70 ns  → 111
80 ns  → Simulation ends
```

---

# 🧠 11. Meaning of `reg` and `wire` in Testbench

In a basic Verilog testbench:

* inputs driven by the testbench are usually declared as `reg`,
* outputs driven by the DUT are usually declared as `wire`.

For example,

```verilog
reg A;
reg B;
reg C;

wire Y;
```

The testbench assigns values to `A`, `B`, and `C`.

The circuit produces `Y`.

---

# 🔍 12. Using `$display`

The simulation can print information to the console.

For example:

```verilog
initial begin
    $display("A B C | Y");
end
```

The console may display

```text
A B C | Y
```

This is useful for readable simulation output.

---

# 🔄 13. Using `$monitor`

`$monitor` automatically prints a line when one of its listed signals changes.

Add:

```verilog
initial begin
    $monitor(
        "time=%0t A=%b B=%b C=%b Y=%b",
        $time, A, B, C, Y
    );
end
```

Example output:

```text
time=0  A=0 B=0 C=0 Y=0
time=10 A=0 B=0 C=1 Y=1
time=20 A=0 B=1 C=0 Y=0
```

This makes functional verification easier.

---

# 💻 14. Complete Testbench with Monitor

```verilog
`timescale 1ns / 1ps

module tb_logic_circuit;

    reg A;
    reg B;
    reg C;

    wire Y;

    logic_circuit uut (
        .A(A),
        .B(B),
        .C(C),
        .Y(Y)
    );

    initial begin

        $display("A B C | Y");
        $display("---------");

        A = 0; B = 0; C = 0; #10;
        A = 0; B = 0; C = 1; #10;
        A = 0; B = 1; C = 0; #10;
        A = 0; B = 1; C = 1; #10;
        A = 1; B = 0; C = 0; #10;
        A = 1; B = 0; C = 1; #10;
        A = 1; B = 1; C = 0; #10;
        A = 1; B = 1; C = 1; #10;

        $finish;

    end

    initial begin

        $monitor(
            "%b %b %b | %b",
            A, B, C, Y
        );

    end

endmodule
```

---

# 📊 15. Expected Simulation Output

The expected result is

| Time (ns) |  A  |  B  |  C  |  Y  |
| --------: | :-: | :-: | :-: | :-: |
|         0 |  0  |  0  |  0  |  0  |
|        10 |  0  |  0  |  1  |  1  |
|        20 |  0  |  1  |  0  |  0  |
|        30 |  0  |  1  |  1  |  1  |
|        40 |  1  |  0  |  0  |  0  |
|        50 |  1  |  0  |  1  |  1  |
|        60 |  1  |  1  |  0  |  1  |
|        70 |  1  |  1  |  1  |  1  |

The waveform should match the truth table.

---

# 🛠️ 16. Create a Vivado Project

## Step 1 — Start Vivado

Open Vivado and select

```text
Create Project
```

Choose a project name such as

```text
Vivado_Simulation_Lab
```

---

## Step 2 — Select RTL Project

Choose

```text
RTL Project
```

For behavioral simulation, an FPGA board is not strictly required to test functionality, but selecting the intended target device is good practice.

---

# 📁 17. Add Design Source

Select

```text
Add Sources
    ↓
Add or Create Design Sources
```

Create

```text
logic_circuit.v
```

and enter the Verilog design.

The Sources window should display

```text
Design Sources
    └── logic_circuit
```

---

# 📁 18. Add Simulation Source

Select

```text
Add Sources
    ↓
Add or Create Simulation Sources
```

Create

```text
tb_logic_circuit.v
```

Enter the testbench code.

The project structure becomes

```text
Design Sources
    └── logic_circuit

Simulation Sources
    └── tb_logic_circuit
```

---

# 🔝 19. Set Simulation Top

Vivado normally detects the testbench automatically.

If necessary, right-click

```text
tb_logic_circuit
```

and select

```text
Set as Top
```

for the simulation source set.

The testbench should be the top module for simulation because it instantiates the design under test.

---

# ▶️ 20. Run Behavioral Simulation

Select

```text
Flow Navigator
    ↓
Simulation
    ↓
Run Simulation
    ↓
Run Behavioral Simulation
```

Vivado will:

1. compile the HDL,
2. elaborate the design,
3. start XSim,
4. open the waveform window.

---

# 📈 21. Vivado Simulation Window

The simulator normally includes:

* **Scopes**
* **Objects**
* **Waveform**
* **Tcl Console**
* **Simulation controls**

The waveform may contain

```text
A
B
C
Y
```

as digital signals.

Students should inspect the waveform and compare it with the expected truth table.

---

# 🔎 22. Reading a Waveform

A waveform represents logic levels over time.

Example:

```text
A  ____----____----
B  __--__--__--__--
C  _-_-_-_-_-_-_-_-
Y  _-_-_---_-_-_---
```

A high signal represents

$$
1,
$$

while a low signal represents

$$
0.
$$

The horizontal axis represents simulation time.

---

# 🔍 23. Zoom and Cursor Functions

Useful Vivado waveform tools include:

* Zoom In
* Zoom Out
* Zoom Fit
* Cursor
* Run All
* Restart
* Run For

A timing cursor can be placed at a specific point to inspect signal values.

For example, at

$$
t=60~\text{ns}
$$

the signals should be

```text
A = 1
B = 1
C = 0
Y = 1
```

---

# 🔁 24. Restarting Simulation

To rerun the simulation from time zero:

```text
Restart
```

Then choose

```text
Run All
```

or specify a simulation duration such as

```text
Run For 100 ns
```

This is useful after modifying waveform settings.

---

# 🧪 25. Compact Testbench Using a Loop

Instead of manually writing eight input combinations, use a loop.

```verilog
`timescale 1ns / 1ps

module tb_logic_circuit_loop;

    reg A;
    reg B;
    reg C;

    wire Y;

    integer i;

    logic_circuit uut (
        .A(A),
        .B(B),
        .C(C),
        .Y(Y)
    );

    initial begin

        for (i = 0; i < 8; i = i + 1) begin

            {A, B, C} = i;

            #10;

        end

        $finish;

    end

endmodule
```

The statement

```verilog
{A, B, C} = i;
```

automatically generates

```text
000
001
010
011
100
101
110
111
```

---

# ✅ 26. Self-Checking Testbench

A stronger testbench automatically determines whether the DUT output is correct.

For

$$
Y=(A\land B)\lor C,
$$

the expected output can be calculated in the testbench.

```verilog
`timescale 1ns / 1ps

module tb_logic_circuit_check;

    reg A;
    reg B;
    reg C;

    wire Y;

    reg expected;

    integer i;

    logic_circuit uut (
        .A(A),
        .B(B),
        .C(C),
        .Y(Y)
    );

    initial begin

        for (i = 0; i < 8; i = i + 1) begin

            {A, B, C} = i;

            #1;

            expected = (A & B) | C;

            if (Y == expected)

                $display(
                    "PASS: A=%b B=%b C=%b Y=%b",
                    A, B, C, Y
                );

            else

                $display(
                    "FAIL: A=%b B=%b C=%b Y=%b Expected=%b",
                    A, B, C, Y, expected
                );

            #9;

        end

        $finish;

    end

endmodule
```

---

# 🧠 27. Why Self-Checking Testbenches Are Useful

A visual waveform is useful for learning, but large systems may contain thousands of test cases.

A self-checking testbench can automatically report

```text
PASS
```

or

```text
FAIL
```

for each case.

Therefore,

$$
\boxed{
\text{Automatic Verification}

>

\text{Manual Inspection}
}
$$

for larger digital systems.

---

# 🐞 28. Intentional Error Study

Change the circuit temporarily from

```verilog
assign Y = (A & B) | C;
```

to

```verilog
assign Y = (A | B) | C;
```

Run the simulation again.

Some output combinations will become incorrect.

Students should use the waveform and self-checking testbench to identify the failure cases.

This exercise demonstrates how simulation helps detect design bugs.

---

# 🧪 29. Study Case 2 — Two-Bit Adder

A second simulation exercise uses a small arithmetic circuit.

Create

```verilog
module adder2(
    input  wire [1:0] A,
    input  wire [1:0] B,
    output wire [2:0] SUM
);

    assign SUM = A + B;

endmodule
```

Since the largest value is

$$
3+3=6,
$$

the output requires three bits.

---

# 🧪 30. Two-Bit Adder Testbench

```verilog
`timescale 1ns / 1ps

module tb_adder2;

    reg [1:0] A;
    reg [1:0] B;

    wire [2:0] SUM;

    adder2 uut (
        .A(A),
        .B(B),
        .SUM(SUM)
    );

    initial begin

        A = 0; B = 0; #10;
        A = 1; B = 2; #10;
        A = 2; B = 2; #10;
        A = 3; B = 1; #10;
        A = 3; B = 3; #10;

        $finish;

    end

endmodule
```

Expected results:

|  A |  B | SUM |
| -: | -: | --: |
|  0 |  0 |   0 |
|  1 |  2 |   3 |
|  2 |  2 |   4 |
|  3 |  1 |   4 |
|  3 |  3 |   6 |

---

# 🔢 31. Waveform Radix

Vivado can display buses in different number formats.

Possible radix options include:

* Binary
* Hexadecimal
* Unsigned Decimal
* Signed Decimal

For example, the 2-bit input

```text
11
```

may be displayed as

```text
Binary  → 11
Decimal → 3
Hex     → 3
```

Changing radix often makes arithmetic simulation easier to interpret.

---

# 🕒 32. Clock Generation in Testbenches

Sequential circuits require a clock.

A common clock generator is

```verilog
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end
```

The clock changes every 5 ns.

Therefore, the complete period is

$$
T=10~\text{ns}.
$$

The simulated clock frequency is

$$
f=\frac{1}{10~\text{ns}}
=100~\text{MHz}.
$$

---

# 🔄 33. Example Clock Waveform

```text
clk
     ┌─────┐     ┌─────┐
─────┘     └─────┘     └─────
     5 ns  5 ns
```

The full period is

$$
5+5=10~\text{ns}.
$$

This clock generator will be useful in later Vivado laboratories involving:

* counters,
* registers,
* FSMs,
* MAC units,
* processors.

---

# 🧩 34. Behavioral Simulation versus Synthesis

Behavioral simulation checks the HDL behavior before physical implementation.

The design flow is

```text
Verilog Design
     │
     ▼
Behavioral Simulation
     │
     ▼
Synthesis
     │
     ▼
Implementation
     │
     ▼
Bitstream
     │
     ▼
FPGA
```

Simulation does not create FPGA hardware.

Instead, it verifies the logical behavior of the HDL design.

---

# 🆚 35. Simulation versus FPGA Testing

| Characteristic           | Behavioral Simulation   | FPGA Testing          |
| ------------------------ | ----------------------- | --------------------- |
| Hardware board required  | No                      | Yes                   |
| Input generation         | Testbench               | Switches/sensors      |
| Output observation       | Waveforms               | LEDs/instruments      |
| Internal signals visible | Yes                     | Limited               |
| Debugging                | Easy                    | More difficult        |
| Speed                    | Software simulation     | Real-time hardware    |
| Main purpose             | Functional verification | Physical verification |

A good workflow uses both.

---

# 🧱 36. Simulation Hierarchy

A typical simulation hierarchy is

```text
tb_logic_circuit
       │
       └── uut : logic_circuit
```

The testbench is the simulation top.

The hardware module is a child instance.

This is different from the FPGA synthesis hierarchy, where the actual hardware module is generally the top-level design.

---

# ⚠️ 37. Common Testbench Errors

### Error 1 — No Delay Between Inputs

Incorrect:

```verilog
A = 0;
A = 1;
A = 0;
```

All assignments may occur at essentially the same simulation time.

Use:

```verilog
A = 0; #10;
A = 1; #10;
A = 0; #10;
```

---

### Error 2 — Incorrect DUT Port Names

Example:

```verilog
logic_circuit uut (
    .A(A),
    .B(B),
    .Y(Y)
);
```

If the DUT also requires `C`, the connection is incomplete.

---

### Error 3 — Testbench Selected as Design Source

A testbench should normally be placed under

```text
Simulation Sources
```

rather than being synthesized as normal FPGA hardware.

---

### Error 4 — Wrong Simulation Top

If Vivado runs the wrong top module, expected testbench stimulus may not appear.

---

### Error 5 — Simulation Ends Too Early

If `$finish` is called before all test vectors have been applied, the waveform is incomplete.

---

# 🔍 38. Unknown and High-Impedance Values

Simulation may show:

```text
X
```

or

```text
Z
```

### `X`

Means an unknown logic value.

Possible causes:

* signal not initialized,
* conflicting drivers,
* incomplete assignment.

### `Z`

Means high impedance.

This often occurs with:

* tri-state signals,
* disconnected buses,
* undriven nets.

Students should not assume `X` means logic 0.

---

# 🧪 39. Lab Tasks

### Task 1 — Create Vivado Project

Create a new Vivado RTL project.

### Task 2 — Design Basic Logic Circuit

Implement

$$
Y=(A\land B)\lor C.
$$

### Task 3 — Create Testbench

Generate all eight input combinations.

### Task 4 — Run Behavioral Simulation

Launch Vivado XSim and observe the waveform.

### Task 5 — Verify Truth Table

Compare simulation results with the expected truth table.

### Task 6 — Add `$monitor`

Display signal values in the simulation console.

### Task 7 — Use a Loop

Replace manual stimulus generation with a `for` loop.

### Task 8 — Self-Checking Testbench

Automatically report `PASS` and `FAIL`.

### Task 9 — Introduce an Error

Modify the logic intentionally and identify incorrect test cases.

### Task 10 — Two-Bit Adder

Simulate a 2-bit adder and verify arithmetic results.

---

# 📋 40. Experimental Results

Complete the table after simulation.

| Test |  A  |  B  |  C  | Expected Y | Simulated Y | Pass/Fail |
| ---: | :-: | :-: | :-: | :--------: | :---------: | :-------: |
|    1 |  0  |  0  |  0  |      0     |             |           |
|    2 |  0  |  0  |  1  |      1     |             |           |
|    3 |  0  |  1  |  0  |      0     |             |           |
|    4 |  0  |  1  |  1  |      1     |             |           |
|    5 |  1  |  0  |  0  |      0     |             |           |
|    6 |  1  |  0  |  1  |      1     |             |           |
|    7 |  1  |  1  |  0  |      1     |             |           |
|    8 |  1  |  1  |  1  |      1     |             |           |

---

# 📊 41. Simulation Report

Students should record:

| Item                 | Result |
| -------------------- | ------ |
| Vivado Version       |        |
| Design Module        |        |
| Testbench Module     |        |
| Simulation Duration  |        |
| Number of Test Cases |        |
| Number Passed        |        |
| Number Failed        |        |

---

# 💬 42. Discussion Points

1. What is behavioral simulation?
2. Why should simulation be performed before synthesis?
3. What is the difference between a design source and a testbench?
4. What is a DUT or UUT?
5. Why are testbench inputs commonly declared as `reg`?
6. Why are DUT outputs commonly declared as `wire`?
7. What does `#10` mean?
8. What is the purpose of `` `timescale ``?
9. What is the difference between `$display` and `$monitor`?
10. What does an `X` value mean in a waveform?
11. Why is a self-checking testbench useful?
12. Why is an FPGA board unnecessary for behavioral simulation?

---

# 🧠 43. Post-Lab Exercises

1. **NAND Gate Simulation**
   Implement and verify

   $$
   Y=\overline{AB}.
   $$

2. **XOR Gate Simulation**
   Implement

   $$
   Y=A\oplus B.
   $$

3. **Three-Input Majority Circuit**
   Implement

   $$
   Y=AB+AC+BC.
   $$

4. **4-to-1 Multiplexer**
   Create a testbench that verifies every input and select combination.

5. **2-Bit Comparator**
   Generate outputs:

   * (A>B)
   * (A=B)
   * (A<B)

6. **4-Bit Adder**
   Simulate several arithmetic combinations.

7. **Clocked Register**
   Generate a 100 MHz simulation clock.

8. **Counter Simulation**
   Simulate a 4-bit synchronous counter.

9. **Automated Test Vector Generation**
   Use nested loops to test all input combinations.

10. **Error Injection**
    Add an intentional HDL error and identify it through simulation.

---

# 🔬 44. Advanced Exercise — Automatic Exhaustive Verification

For a 4-input combinational circuit, there are

$$
2^4=16
$$

possible input combinations.

A testbench can automatically generate every case:

```verilog
integer i;

initial begin

    for (i = 0; i < 16; i = i + 1) begin

        {A, B, C, D} = i;

        #10;

    end

    $finish;

end
```

For (N) binary inputs, exhaustive simulation requires

$$
2^N
$$

test vectors.

This method is practical for small combinational circuits.

---

# 🚀 45. Advanced Exercise — Testbench for Sequential Logic

Create a D flip-flop:

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

Then generate:

* clock,
* reset,
* data input

in the testbench.

This extends the laboratory from **combinational simulation** to **sequential simulation**.

---

# 🔄 46. Recommended Vivado Verification Flow

The recommended workflow is

```text
Write Verilog
     │
     ▼
Check Syntax
     │
     ▼
Create Testbench
     │
     ▼
Behavioral Simulation
     │
     ▼
Compare Expected Results
     │
     ├── Incorrect ──► Modify HDL
     │
     └── Correct
             │
             ▼
          Synthesis
             │
             ▼
       Implementation
             │
             ▼
          FPGA Test
```

This iterative process reduces hardware debugging time.

---

# 🧾 47. Expected Learning Outcomes

After completing this laboratory, students will be able to:

* Explain the purpose of behavioral simulation.
* Create Verilog design sources in Vivado.
* Create Verilog simulation sources.
* Instantiate a DUT inside a testbench.
* Generate test stimulus using `initial` blocks.
* Use simulation delays.
* Run behavioral simulation using Vivado XSim.
* Observe and interpret digital waveforms.
* Use `$display` and `$monitor`.
* Generate exhaustive test vectors using loops.
* Create simple self-checking testbenches.
* Identify functional HDL errors before synthesis.
* Apply simulation techniques to later combinational and sequential FPGA laboratories.

---

# 📘 48. References

1. AMD Xilinx, *Vivado Design Suite User Guide: Logic Simulation*.
2. AMD Xilinx, *Vivado Design Suite User Guide: Using the Vivado IDE*.
3. M. D. Ciletti, *Advanced Digital Design with the Verilog HDL*, Pearson.
4. S. Brown and Z. Vranesic, *Fundamentals of Digital Logic with Verilog Design*, McGraw-Hill.
5. M. M. Mano and M. D. Ciletti, *Digital Design*, Pearson.
6. IEEE Std 1364-2005, *IEEE Standard for Verilog Hardware Description Language*.

---

## 🔑 Key Concept

The central concept of this laboratory is

$$
\boxed{
\text{Testbench}
\rightarrow
\text{Input Stimulus}
\rightarrow
\text{Design Under Test}
\rightarrow
\text{Waveform}
\rightarrow
\text{Verification}
}
$$

The recommended FPGA development approach is

$$
\boxed{
\text{Design}
\rightarrow
\text{Behavioral Simulation}
\rightarrow
\text{Debug}
\rightarrow
\text{Synthesis}
\rightarrow
\text{FPGA}
}
$$

This laboratory provides the foundation for later Vivado work involving **combinational logic, counters, registers, FSMs, hierarchical design, MAC units, AXI peripherals, MicroBlaze systems, and AI-FPGA accelerators**.
