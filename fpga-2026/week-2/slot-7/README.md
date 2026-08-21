# 🔬 Lab: Vivado-3 — FPGA Combinational Design

## Implementing Combinational Circuits Using Vivado

## 🧩 1. Objective

* Understand the concept of **combinational logic circuits**.
* Implement basic combinational circuits using **Verilog HDL**.
* Design and verify logic functions using Boolean equations and truth tables.
* Use Vivado to create, simulate, synthesize, and implement combinational FPGA designs.
* Learn how FPGA **LUTs** realize Boolean logic.
* Interface FPGA switches as inputs and LEDs as outputs.
* Compare different coding styles for combinational logic.
* Deploy and test combinational circuits on a **Basys 3 / Nexys A7 FPGA**.

---

## ⚙️ 2. Equipment and Tools

| Tool / Resource                     | Description                                           |
| ----------------------------------- | ----------------------------------------------------- |
| **Vivado Design Suite**             | HDL design, simulation, synthesis, and implementation |
| **FPGA Board (Basys 3 / Nexys A7)** | Hardware implementation                               |
| **Verilog HDL**                     | Combinational circuit description                     |
| **Vivado Simulator**                | Behavioral verification                               |
| **FPGA Switches**                   | Input signals                                         |
| **FPGA LEDs**                       | Output signals                                        |
| **XDC Constraint File**             | Physical FPGA pin assignments                         |
| **RTL Schematic Viewer**            | Visualization of synthesized logic                    |

---

# 🧠 3. Background Theory

## 3.1 What Is a Combinational Circuit?

A **combinational circuit** is a digital circuit whose outputs depend only on the current input values.

Mathematically,

$$
Y=f(X_1,X_2,\ldots,X_n).
$$

There is no memory of previous input values.

Examples include:

* logic gates,
* multiplexers,
* decoders,
* encoders,
* comparators,
* adders,
* subtractors.

A simple representation is

```text
Inputs
   │
   ▼
Combinational Logic
   │
   ▼
Outputs
```

---

## 3.2 Combinational versus Sequential Logic

| Characteristic    | Combinational Logic | Sequential Logic                |
| ----------------- | ------------------- | ------------------------------- |
| Output depends on | Current inputs      | Current inputs + previous state |
| Memory            | No                  | Yes                             |
| Clock required    | No                  | Usually yes                     |
| Example           | Adder, MUX          | Counter, register, FSM          |
| Storage elements  | None                | Flip-flops/registers            |

Thus,

$$
\boxed{
\text{Combinational Logic}
==========================

\text{Present Input}
\rightarrow
\text{Present Output}
}
$$

---

# 🔢 4. Basic Logic Gates

The fundamental Boolean operations are:

### AND

$$
Y=A\cdot B
$$

### OR

$$
Y=A+B
$$

### NOT

$$
Y=\overline{A}
$$

### XOR

$$
Y=A\oplus B
$$

These operations can be implemented directly in Verilog.

---

# 💻 5. Basic Logic-Gate Module

```verilog
module basic_logic(
    input  wire A,
    input  wire B,

    output wire Y_AND,
    output wire Y_OR,
    output wire Y_XOR,
    output wire Y_NAND
);

    assign Y_AND  = A & B;
    assign Y_OR   = A | B;
    assign Y_XOR  = A ^ B;
    assign Y_NAND = ~(A & B);

endmodule
```

---

# 📊 6. Truth Table

|  A  |  B  | AND |  OR | XOR | NAND |
| :-: | :-: | :-: | :-: | :-: | :--: |
|  0  |  0  |  0  |  0  |  0  |   1  |
|  0  |  1  |  0  |  1  |  1  |   1  |
|  1  |  0  |  0  |  1  |  1  |   1  |
|  1  |  1  |  1  |  1  |  0  |   0  |

---

# 🧪 7. Testbench for Basic Logic

```verilog
`timescale 1ns / 1ps

module tb_basic_logic;

    reg A;
    reg B;

    wire Y_AND;
    wire Y_OR;
    wire Y_XOR;
    wire Y_NAND;

    basic_logic uut (
        .A(A),
        .B(B),
        .Y_AND(Y_AND),
        .Y_OR(Y_OR),
        .Y_XOR(Y_XOR),
        .Y_NAND(Y_NAND)
    );

    initial begin

        A = 0; B = 0; #10;
        A = 0; B = 1; #10;
        A = 1; B = 0; #10;
        A = 1; B = 1; #10;

        $finish;

    end

endmodule
```

---

# 🧮 8. Study Case 1 — Boolean Function

Consider

$$
Y=(A\land B)\lor C.
$$

Equivalent Boolean notation:

$$
Y=AB+C.
$$

The corresponding hardware is

```text
A ─────┐
       AND ───┐
B ─────┘      │
              OR ───► Y
C ────────────┘
```

---

# 💻 9. Verilog Implementation

```verilog
module logic_function(
    input  wire A,
    input  wire B,
    input  wire C,
    output wire Y
);

    assign Y = (A & B) | C;

endmodule
```

This is called **dataflow modeling** because the output is described using a Boolean expression.

---

# 📊 10. Truth Table for the Logic Function

|  A  |  B  |  C  |  Y  |
| :-: | :-: | :-: | :-: |
|  0  |  0  |  0  |  0  |
|  0  |  0  |  1  |  1  |
|  0  |  1  |  0  |  0  |
|  0  |  1  |  1  |  1  |
|  1  |  0  |  0  |  0  |
|  1  |  0  |  1  |  1  |
|  1  |  1  |  0  |  1  |
|  1  |  1  |  1  |  1  |

The simulation should match this table.

---

# 🔀 11. Study Case 2 — 2-to-1 Multiplexer

A multiplexer selects one of several inputs.

For a 2-to-1 multiplexer,

$$
Y=
\begin{cases}
D_0,&S=0\
D_1,&S=1.
\end{cases}
$$

The Boolean equation is

$$
Y=\overline{S}D_0+SD_1.
$$

---

# 💻 12. Multiplexer Verilog Module

```verilog
module mux2to1(
    input  wire D0,
    input  wire D1,
    input  wire S,
    output wire Y
);

    assign Y = S ? D1 : D0;

endmodule
```

---

# 📊 13. Multiplexer Truth Table

|  S  |  D0 |  D1 |  Y  |
| :-: | :-: | :-: | :-: |
|  0  |  0  |  X  |  0  |
|  0  |  1  |  X  |  1  |
|  1  |  X  |  0  |  0  |
|  1  |  X  |  1  |  1  |

Here, `X` means the value does not affect the output.

---

# 🔢 14. Study Case 3 — 2-to-4 Decoder

A decoder converts an (n)-bit input into one of (2^n) active outputs.

For a 2-bit input,

$$
A=[A_1A_0],
$$

the decoder produces four outputs.

---

## 14.1 Decoder Truth Table

| (A_1) | (A_0) |  Y3 |  Y2 |  Y1 |  Y0 |
| :---: | :---: | :-: | :-: | :-: | :-: |
|   0   |   0   |  0  |  0  |  0  |  1  |
|   0   |   1   |  0  |  0  |  1  |  0  |
|   1   |   0   |  0  |  1  |  0  |  0  |
|   1   |   1   |  1  |  0  |  0  |  0  |

---

# 💻 15. Decoder Verilog Module

```verilog
module decoder2to4(
    input  wire [1:0] A,
    output reg  [3:0] Y
);

    always @(*) begin

        case (A)

            2'b00: Y = 4'b0001;
            2'b01: Y = 4'b0010;
            2'b10: Y = 4'b0100;
            2'b11: Y = 4'b1000;

        endcase

    end

endmodule
```

This example introduces the **behavioral coding style** for combinational logic.

---

# ⚖️ 16. Study Case 4 — 2-Bit Comparator

A magnitude comparator determines whether

$$
A>B,
$$

$$
A=B,
$$

or

$$
A<B.
$$

For two 2-bit numbers,

$$
A=[A_1A_0]
$$

and

$$
B=[B_1B_0].
$$

---

# 💻 17. Comparator Verilog Module

```verilog
module comparator2(
    input  wire [1:0] A,
    input  wire [1:0] B,

    output wire GT,
    output wire EQ,
    output wire LT
);

    assign GT = (A > B);
    assign EQ = (A == B);
    assign LT = (A < B);

endmodule
```

---

# ➕ 18. Study Case 5 — Half Adder

A half adder adds two single-bit inputs.

The outputs are

$$
SUM=A\oplus B
$$

and

$$
CARRY=AB.
$$

---

# 💻 19. Half-Adder Module

```verilog
module half_adder(
    input  wire A,
    input  wire B,

    output wire SUM,
    output wire CARRY
);

    assign SUM   = A ^ B;
    assign CARRY = A & B;

endmodule
```

---

# 📊 20. Half-Adder Truth Table

|  A  |  B  | SUM | CARRY |
| :-: | :-: | :-: | :---: |
|  0  |  0  |  0  |   0   |
|  0  |  1  |  1  |   0   |
|  1  |  0  |  1  |   0   |
|  1  |  1  |  0  |   1   |

---

# ➕ 21. Study Case 6 — 4-Bit Adder

A 4-bit combinational adder performs

$$
SUM=A+B.
$$

For

$$
A,B\in[0,15],
$$

the maximum result is

$$
15+15=30.
$$

Therefore, the output requires five bits.

---

# 💻 22. Four-Bit Adder Module

```verilog
module adder4(
    input  wire [3:0] A,
    input  wire [3:0] B,
    output wire [4:0] SUM
);

    assign SUM = A + B;

endmodule
```

---

# 🧪 23. Four-Bit Adder Testbench

```verilog
`timescale 1ns / 1ps

module tb_adder4;

    reg  [3:0] A;
    reg  [3:0] B;

    wire [4:0] SUM;

    adder4 uut (
        .A(A),
        .B(B),
        .SUM(SUM)
    );

    initial begin

        A = 4'd0;
        B = 4'd0;
        #10;

        A = 4'd3;
        B = 4'd5;
        #10;

        A = 4'd7;
        B = 4'd8;
        #10;

        A = 4'd15;
        B = 4'd15;
        #10;

        $finish;

    end

endmodule
```

Expected results:

|  A |  B | SUM |
| -: | -: | --: |
|  0 |  0 |   0 |
|  3 |  5 |   8 |
|  7 |  8 |  15 |
| 15 | 15 |  30 |

---

# 🧠 24. Combinational Coding Styles

Verilog supports several coding styles.

## 24.1 Dataflow Modeling

```verilog
assign Y = (A & B) | C;
```

This style is concise and suitable for Boolean equations.

---

## 24.2 Behavioral Modeling

```verilog
always @(*) begin

    if (S)
        Y = D1;
    else
        Y = D0;

end
```

This style is useful for:

* multiplexers,
* decoders,
* priority logic,
* larger decision structures.

---

## 24.3 Structural Modeling

A design can also instantiate smaller modules.

```verilog
and_gate G1(...);
or_gate  G2(...);
```

This is useful for hierarchical design.

---

# ⚠️ 25. Avoiding Latches

In a combinational `always @(*)` block, every output should be assigned for every possible input condition.

Incorrect:

```verilog
always @(*) begin

    if (A)
        Y = B;

end
```

When `A=0`, `Y` is not assigned.

This may cause Vivado to infer a latch.

A correct form is

```verilog
always @(*) begin

    if (A)
        Y = B;
    else
        Y = 1'b0;

end
```

or

```verilog
always @(*) begin

    Y = 1'b0;

    if (A)
        Y = B;

end
```

---

# 🧠 26. FPGA LUT Implementation

Combinational logic is primarily mapped into FPGA **Lookup Tables (LUTs)**.

Conceptually,

```text
Inputs
   │
   ▼
 FPGA LUT
   │
   ▼
Output
```

A LUT stores the truth table of a Boolean function.

For example, if

$$
Y=A\oplus B,
$$

the LUT stores

|  A  |  B  |  Y  |
| :-: | :-: | :-: |
|  0  |  0  |  0  |
|  0  |  1  |  1  |
|  1  |  0  |  1  |
|  1  |  1  |  0  |

Thus,

$$
\boxed{
\text{Boolean Function}
\rightarrow
\text{LUT Configuration}
}
$$

---

# 🛠️ 27. Vivado Project Procedure

## Step 1 — Create a New Project

Open Vivado and select

```text
Create Project
```

Choose a project name such as

```text
Vivado_Combinational_Lab
```

Select

```text
RTL Project
```

and choose the target FPGA board.

---

## Step 2 — Add Design Source

Select

```text
Add Sources
    ↓
Add or Create Design Sources
```

Create a module such as

```text
logic_function.v
```

or

```text
adder4.v
```

---

## Step 3 — Add Simulation Source

Select

```text
Add Sources
    ↓
Add or Create Simulation Sources
```

Create a testbench such as

```text
tb_logic_function.v
```

---

# ▶️ 28. Run Behavioral Simulation

Select

```text
Run Simulation
    ↓
Run Behavioral Simulation
```

Observe:

* inputs,
* outputs,
* expected truth-table behavior.

The simulation should be completed before FPGA synthesis.

---

# 🔍 29. Open RTL Schematic

Select

```text
RTL Analysis
    ↓
Open Elaborated Design
    ↓
Schematic
```

The schematic shows how Vivado interprets the Verilog design.

For example, a multiplexer may appear conceptually as

```text
D0 ─────┐
        │
        MUX ───► Y
        │
D1 ─────┘
        ▲
        │
        S
```

---

# 🔨 30. Run Synthesis

Select

```text
Run Synthesis
```

Vivado converts the HDL into FPGA resources.

Students should inspect:

* LUT count,
* I/O count,
* optimized schematic.

---

# 📊 31. Resource Utilization

Record the synthesis results.

| Resource   | Utilization |
| ---------- | ----------: |
| LUTs       |             |
| Flip-Flops |             |
| I/O        |             |
| DSP        |             |
| BRAM       |             |

For a purely combinational design, the number of flip-flops should normally be zero or very small.

---

# 🧷 32. FPGA I/O Mapping

A simple 4-bit adder can use eight switches.

Suggested mapping:

| Signal   | FPGA Resource |
| -------- | ------------- |
| `A[0]`   | SW0           |
| `A[1]`   | SW1           |
| `A[2]`   | SW2           |
| `A[3]`   | SW3           |
| `B[0]`   | SW4           |
| `B[1]`   | SW5           |
| `B[2]`   | SW6           |
| `B[3]`   | SW7           |
| `SUM[0]` | LED0          |
| `SUM[1]` | LED1          |
| `SUM[2]` | LED2          |
| `SUM[3]` | LED3          |
| `SUM[4]` | LED4          |

Use the correct XDC file for the selected board.

---

# 📌 33. Example XDC Structure

```tcl
set_property PACKAGE_PIN <SW0_PIN> [get_ports {A[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {A[0]}]

set_property PACKAGE_PIN <LED0_PIN> [get_ports {SUM[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SUM[0]}]
```

Repeat the assignments for all required switches and LEDs.

The actual package pins must come from the board's official master XDC file.

---

# 🏗️ 34. Run Implementation

After synthesis, select

```text
Run Implementation
```

Vivado performs:

* placement,
* routing,
* design-rule checks.

Then verify that the design meets implementation requirements.

---

# 📦 35. Generate Bitstream

Select

```text
Generate Bitstream
```

The bitstream configures the FPGA LUTs and routing resources to implement the combinational circuit.

---

# 🔌 36. Program the FPGA

Open

```text
Hardware Manager
```

then select

```text
Open Target
    ↓
Auto Connect
```

and

```text
Program Device
```

After configuration, changes in switch inputs should immediately affect the LED outputs.

No clock is required for a purely combinational circuit.

---

# 🔢 37. FPGA Demonstration — 4-Bit Adder

Suppose

```text
A = 0011 = 3
B = 0101 = 5
```

Then

$$
A+B=8.
$$

Therefore,

```text
SUM = 01000
```

The corresponding LEDs should display

```text
LED4 LED3 LED2 LED1 LED0
  0    1    0    0    0
```

---

# 🔄 38. Propagation Delay

Although a combinational circuit does not require a clock, its output does not change instantaneously.

Every logic element introduces a small propagation delay.

Conceptually,

$$
T_{pd}
======

T_{\text{logic}}
+
T_{\text{routing}}.
$$

For FPGA logic,

```text
Input Change
    │
    ▼
LUT Processing
    │
    ▼
Routing
    │
    ▼
Output Change
```

These delays are usually on the order of nanoseconds.

---

# ⏱️ 39. Critical Path

The **critical path** is the longest combinational delay from input to output.

For example,

```text
A
 │
 ▼
AND
 │
 ▼
XOR
 │
 ▼
MUX
 │
 ▼
Y
```

The total path delay determines the maximum speed at which the logic could safely operate if it were placed between registers.

---

# 🆚 40. Boolean Equation versus Verilog

Consider

$$
Y=\overline{A}B+AC.
$$

The corresponding Verilog is

```verilog
assign Y = (~A & B) | (A & C);
```

Vivado can optimize the expression and map it into one or more LUTs.

This illustrates the relationship

$$
\boxed{
\text{Boolean Algebra}
\rightarrow
\text{Verilog}
\rightarrow
\text{FPGA LUT}
}
$$

---

# 🧪 41. Self-Checking Testbench

A self-checking testbench can automatically detect errors.

Example:

```verilog
`timescale 1ns / 1ps

module tb_logic_check;

    reg A;
    reg B;
    reg C;

    wire Y;

    reg expected;

    integer i;

    logic_function uut (
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
                    "PASS: %b%b%b -> %b",
                    A, B, C, Y
                );

            else

                $display(
                    "FAIL: %b%b%b -> %b expected %b",
                    A, B, C, Y, expected
                );

            #9;

        end

        $finish;

    end

endmodule
```

---

# 🧪 42. Lab Tasks

### Task 1 — Basic Logic Gates

Implement:

* AND,
* OR,
* XOR,
* NAND.

Verify all input combinations.

### Task 2 — Boolean Function

Implement

$$
Y=(A\land B)\lor C.
$$

### Task 3 — Multiplexer

Implement a 2-to-1 multiplexer.

### Task 4 — Decoder

Implement a 2-to-4 decoder using a `case` statement.

### Task 5 — Comparator

Implement a 2-bit magnitude comparator.

### Task 6 — Half Adder

Implement and simulate a half adder.

### Task 7 — Four-Bit Adder

Implement

$$
SUM=A+B
$$

for two 4-bit operands.

### Task 8 — Synthesis

Run synthesis and compare resource utilization for the different circuits.

### Task 9 — FPGA Deployment

Map switches to inputs and LEDs to outputs.

### Task 10 — Hardware Verification

Compare measured FPGA behavior with simulation results.

---

# 📋 43. Experimental Results

Complete the following table for the selected combinational circuit.

| Test | Input A | Input B | Expected Output | FPGA Output | Pass/Fail |
| ---: | ------- | ------- | --------------- | ----------- | --------- |
|    1 |         |         |                 |             |           |
|    2 |         |         |                 |             |           |
|    3 |         |         |                 |             |           |
|    4 |         |         |                 |             |           |
|    5 |         |         |                 |             |           |

---

# 📊 44. Resource Comparison

Students should record:

| Circuit          | LUTs | FFs | I/O |
| ---------------- | ---: | --: | --: |
| Logic gates      |      |     |     |
| 2-to-1 MUX       |      |     |     |
| 2-to-4 Decoder   |      |     |     |
| 2-bit Comparator |      |     |     |
| Half Adder       |      |     |     |
| 4-bit Adder      |      |     |     |

Discuss why different combinational functions require different LUT resources.

---

# 💬 45. Discussion Points

1. What is a combinational circuit?
2. How does combinational logic differ from sequential logic?
3. Why does combinational logic normally not require a clock?
4. What is a truth table?
5. What is the role of an FPGA LUT?
6. What is the difference between dataflow and behavioral Verilog?
7. Why must every output be assigned in a combinational `always @(*)` block?
8. What causes unintended latch inference?
9. What is propagation delay?
10. What is a critical path?
11. Why can Vivado optimize a Boolean expression?
12. Why should simulation be performed before FPGA programming?

---

# 🧠 46. Post-Lab Exercises

1. **3-to-8 Decoder**
   Extend the decoder from 2 inputs to 3 inputs.

2. **4-to-1 Multiplexer**
   Implement four data inputs and two select inputs.

3. **Priority Encoder**
   Implement a 4-to-2 priority encoder.

4. **4-Bit Comparator**
   Expand the magnitude comparator from 2 bits to 4 bits.

5. **Full Adder**
   Add a carry input to the half-adder design.

6. **4-Bit Adder/Subtractor**
   Implement

   $$
   A+B
   $$

   and

   $$
   A-B.
   $$

7. **Parity Generator**
   Generate even parity for a 4-bit input.

8. **Majority Circuit**
   Implement

   $$
   Y=AB+AC+BC.
   $$

9. **One-Hot Decoder**
   Implement an 8-output decoder.

10. **ALU Introduction**
    Create a simple ALU supporting AND, OR, XOR, and ADD.

---

# 🔬 47. Advanced Exercise — Simple 4-Bit ALU

Create a combinational ALU with

$$
A[3:0],
$$

$$
B[3:0],
$$

and a 2-bit operation selector.

Use

|  OP  | Operation   |
| :--: | ----------- |
| `00` | (A+B)       |
| `01` | (A-B)       |
| `10` | (A\land B)  |
| `11` | (A\oplus B) |

Example Verilog:

```verilog
module alu4(
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire [1:0] OP,
    output reg  [4:0] Y
);

    always @(*) begin

        case (OP)

            2'b00:
                Y = A + B;

            2'b01:
                Y = A - B;

            2'b10:
                Y = {1'b0, A & B};

            2'b11:
                Y = {1'b0, A ^ B};

            default:
                Y = 5'd0;

        endcase

    end

endmodule
```

This introduces the basic datapath concept used in processors.

---

# 🚀 48. Advanced Exercise — Hierarchical Combinational Design

Construct a larger circuit from reusable modules:

```text
                    Top Module
                        │
          ┌─────────────┼─────────────┐
          ▼             ▼             ▼
      Comparator      Adder         MUX
          │             │             │
          └─────────────┼─────────────┘
                        ▼
                      Output
```

This introduces hierarchical design while remaining completely combinational.

---

# 🔄 49. Recommended Vivado Flow

The recommended process is

```text
Boolean Equation / Truth Table
          │
          ▼
      Write Verilog
          │
          ▼
    Create Testbench
          │
          ▼
 Behavioral Simulation
          │
          ▼
     RTL Analysis
          │
          ▼
       Synthesis
          │
          ▼
    Add Constraints
          │
          ▼
    Implementation
          │
          ▼
  Generate Bitstream
          │
          ▼
     Program FPGA
          │
          ▼
   Hardware Verification
```

---

# 🧾 50. Expected Learning Outcomes

After completing this laboratory, students will be able to:

* Explain the principles of combinational logic.
* Convert truth tables and Boolean equations into Verilog HDL.
* Implement logic gates, multiplexers, decoders, comparators, and adders.
* Use dataflow and behavioral modeling styles.
* Avoid unintended latch inference.
* Create and run combinational testbenches.
* Use Vivado behavioral simulation.
* Inspect RTL schematics.
* Understand how FPGA LUTs implement combinational logic.
* Synthesize and implement a combinational circuit.
* Assign switches and LEDs using XDC constraints.
* Program and verify combinational logic on FPGA hardware.

---

# 📘 51. References

1. M. M. Mano and M. D. Ciletti, *Digital Design*, Pearson.
2. S. Brown and Z. Vranesic, *Fundamentals of Digital Logic with Verilog Design*, McGraw-Hill.
3. M. D. Ciletti, *Advanced Digital Design with the Verilog HDL*, Pearson.
4. AMD Xilinx, *Vivado Design Suite User Guide: Synthesis*.
5. AMD Xilinx, *Vivado Design Suite User Guide: Using the Vivado IDE*.
6. IEEE Std 1364-2005, *IEEE Standard for Verilog Hardware Description Language*.

---

## 🔑 Key Concept

The central idea of this laboratory is

$$
\boxed{
\text{Input}
\rightarrow
\text{Boolean Logic}
\rightarrow
\text{Output}
}
$$

with no internal memory.

The FPGA implementation flow is

$$
\boxed{
\text{Truth Table}
\rightarrow
\text{Verilog HDL}
\rightarrow
\text{LUT Mapping}
\rightarrow
\text{FPGA Hardware}
}
$$

This laboratory provides the foundation for subsequent work involving **sequential circuits, counters, registers, finite-state machines, hierarchical design, arithmetic datapaths, MAC units, processors, and AI-FPGA accelerators**.
