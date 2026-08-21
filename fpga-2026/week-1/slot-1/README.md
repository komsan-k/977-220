# 🔬 Lab: Verilog/SystemVerilog-1 — Digital Logic Fundamentals

## Logic Gates, Boolean Algebra, and Combinational Logic Using EDA Playground

## 🧩 1. Objective

* Understand the fundamental concepts of **digital logic**.
* Review basic **logic gates** and Boolean algebra.
* Learn the difference between **Verilog** and **SystemVerilog** for simple digital designs.
* Implement basic combinational circuits using HDL.
* Create simple testbenches to verify circuit behavior.
* Use **EDA Playground** as an online HDL simulation environment.
* Observe simulation results through console output and waveforms.
* Build a foundation for later work in combinational, sequential, FSM, FPGA, and AI-hardware design.

---

## ⚙️ 2. Equipment and Tools

| Tool / Resource                                                 | Description                                  |
| --------------------------------------------------------------- | -------------------------------------------- |
| **EDA Playground**                                              | Online HDL coding and simulation environment |
| **Web Browser**                                                 | Access to the online simulator               |
| **Verilog / SystemVerilog**                                     | Hardware description languages               |
| **Icarus Verilog / Verilator / Questa or equivalent simulator** | HDL simulation backend                       |
| **EPWave**                                                      | Online waveform viewer                       |
| **Text Editor in EDA Playground**                               | Design and testbench development             |

---

# 🧠 3. Background Theory

## 3.1 Digital Logic

Digital systems represent information using two logic levels:

$$
0
$$

and

$$
1.
$$

These values may represent:

* OFF / ON,
* FALSE / TRUE,
* LOW / HIGH.

A digital circuit processes binary inputs and generates binary outputs.

The basic model is

```text
Binary Inputs
     │
     ▼
 Digital Logic
     │
     ▼
Binary Outputs
```

---

## 3.2 Logic Gates

Logic gates are the fundamental building blocks of digital circuits.

The main gates are:

* AND
* OR
* NOT
* NAND
* NOR
* XOR
* XNOR

Each gate implements a Boolean function.

---

# 🔢 4. AND Gate

The AND operation is

$$
Y=A\cdot B.
$$

The output is `1` only when both inputs are `1`.

|  A  |  B  |  Y  |
| :-: | :-: | :-: |
|  0  |  0  |  0  |
|  0  |  1  |  0  |
|  1  |  0  |  0  |
|  1  |  1  |  1  |

In Verilog:

```verilog
assign Y = A & B;
```

---

# 🔢 5. OR Gate

The OR operation is

$$
Y=A+B.
$$

The output is `1` when at least one input is `1`.

|  A  |  B  |  Y  |
| :-: | :-: | :-: |
|  0  |  0  |  0  |
|  0  |  1  |  1  |
|  1  |  0  |  1  |
|  1  |  1  |  1  |

In Verilog:

```verilog
assign Y = A | B;
```

---

# 🔢 6. NOT Gate

The NOT operation complements the input.

$$
Y=\overline{A}.
$$

|  A  |  Y  |
| :-: | :-: |
|  0  |  1  |
|  1  |  0  |

In Verilog:

```verilog
assign Y = ~A;
```

---

# 🔢 7. XOR Gate

The XOR operation is

$$
Y=A\oplus B.
$$

The output is `1` when the inputs are different.

|  A  |  B  |  Y  |
| :-: | :-: | :-: |
|  0  |  0  |  0  |
|  0  |  1  |  1  |
|  1  |  0  |  1  |
|  1  |  1  |  0  |

In Verilog:

```verilog
assign Y = A ^ B;
```

---

# 🔢 8. NAND, NOR, and XNOR

### NAND

$$
Y=\overline{AB}
$$

```verilog
assign Y = ~(A & B);
```

### NOR

$$
Y=\overline{A+B}
$$

```verilog
assign Y = ~(A | B);
```

### XNOR

$$
Y=\overline{A\oplus B}
$$

```verilog
assign Y = ~(A ^ B);
```

---

# 📊 9. Combined Logic-Gate Truth Table

|  A  |  B  | AND |  OR | NAND | NOR | XOR | XNOR |
| :-: | :-: | :-: | :-: | :--: | :-: | :-: | :--: |
|  0  |  0  |  0  |  0  |   1  |  1  |  0  |   1  |
|  0  |  1  |  0  |  1  |   1  |  0  |  1  |   0  |
|  1  |  0  |  0  |  1  |   1  |  0  |  1  |   0  |
|  1  |  1  |  1  |  1  |   0  |  0  |  0  |   1  |

---

# 🧮 10. Boolean Algebra

Boolean algebra is used to describe and simplify digital logic expressions.

Some important identities are:

### Identity Laws

$$
A+0=A
$$

$$
A\cdot1=A
$$

### Null Laws

$$
A+1=1
$$

$$
A\cdot0=0
$$

### Idempotent Laws

$$
A+A=A
$$

$$
A\cdot A=A
$$

### Complement Laws

$$
A+\overline{A}=1
$$

$$
A\overline{A}=0
$$

---

# 🔄 11. De Morgan's Theorems

Two important Boolean identities are

$$
\overline{AB}
=============

\overline{A}+\overline{B}
$$

and

$$
\overline{A+B}
==============

\overline{A},\overline{B}.
$$

These identities are important in digital circuit simplification.

For example,

```verilog
assign Y1 = ~(A & B);
assign Y2 = (~A) | (~B);
```

should produce identical outputs.

---

# 🧠 12. What Is Combinational Logic?

A combinational circuit produces outputs based only on current input values.

Mathematically,

$$
Y=f(X_1,X_2,\ldots,X_n).
$$

No previous state is stored.

Typical combinational circuits include:

* logic gates,
* multiplexers,
* decoders,
* encoders,
* adders,
* comparators.

Thus,

$$
\boxed{
\text{Current Input}
\rightarrow
\text{Current Output}
}
$$

---

# 💻 13. First Verilog Design — Basic Gates

Create the following design:

```verilog
module basic_gates(
    input  wire A,
    input  wire B,

    output wire y_and,
    output wire y_or,
    output wire y_not_a,
    output wire y_xor
);

    assign y_and   = A & B;
    assign y_or    = A | B;
    assign y_not_a = ~A;
    assign y_xor   = A ^ B;

endmodule
```

This module implements four logic functions in parallel.

---

# 🧪 14. Verilog Testbench

```verilog
`timescale 1ns/1ps

module tb_basic_gates;

    reg A;
    reg B;

    wire y_and;
    wire y_or;
    wire y_not_a;
    wire y_xor;

    basic_gates uut (
        .A(A),
        .B(B),
        .y_and(y_and),
        .y_or(y_or),
        .y_not_a(y_not_a),
        .y_xor(y_xor)
    );

    initial begin

        $display("A B | AND OR NOT_A XOR");
        $display("----------------------");

        A = 0; B = 0; #10;
        A = 0; B = 1; #10;
        A = 1; B = 0; #10;
        A = 1; B = 1; #10;

        $finish;

    end

    initial begin

        $monitor(
            "%b %b |  %b   %b    %b     %b",
            A, B,
            y_and,
            y_or,
            y_not_a,
            y_xor
        );

    end

endmodule
```

---

# 📊 15. Expected Simulation Results

|  A  |  B  | AND |  OR | NOT A | XOR |
| :-: | :-: | :-: | :-: | :---: | :-: |
|  0  |  0  |  0  |  0  |   1   |  0  |
|  0  |  1  |  0  |  1  |   1   |  1  |
|  1  |  0  |  0  |  1  |   0   |  1  |
|  1  |  1  |  1  |  1  |   0   |  0  |

The console output should match the truth table.

---

# 🌐 16. Using EDA Playground

## Step 1 — Open EDA Playground

Open the EDA Playground website in a web browser.

The workspace typically contains:

```text
Design
Testbench
Simulator Options
Run Button
Output Console
```

---

## Step 2 — Select Language

Choose

```text
Verilog
```

or

```text
SystemVerilog
```

depending on the lab exercise.

---

## Step 3 — Select a Simulator

Choose a supported simulator such as:

```text
Icarus Verilog
```

or another available simulator.

The exact list may vary.

---

## Step 4 — Enter Design Code

Place the DUT code in the **Design** window.

For example:

```verilog
module and_gate(
    input A,
    input B,
    output Y
);

    assign Y = A & B;

endmodule
```

---

## Step 5 — Enter the Testbench

Place the testbench in the **Testbench** window.

```verilog
module tb;

    reg A;
    reg B;
    wire Y;

    and_gate dut (
        .A(A),
        .B(B),
        .Y(Y)
    );

    initial begin

        A=0; B=0; #10;
        A=0; B=1; #10;
        A=1; B=0; #10;
        A=1; B=1; #10;

        $finish;

    end

endmodule
```

---

## Step 6 — Run Simulation

Click

```text
Run
```

The simulator compiles and executes the HDL code.

Any compiler errors or simulation messages appear in the output console.

---

# 📈 17. Viewing Waveforms with EPWave

To view waveforms, add:

```verilog
initial begin

    $dumpfile("dump.vcd");
    $dumpvars(0, tb);

end
```

to the testbench.

Then enable

```text
Open EPWave after run
```

if available.

The waveform viewer may show:

```text
A
B
Y
```

over simulation time.

---

# 💻 18. Complete EDA Playground Example

### Design

```verilog
module and_gate(
    input  wire A,
    input  wire B,
    output wire Y
);

    assign Y = A & B;

endmodule
```

### Testbench

```verilog
`timescale 1ns/1ps

module tb;

    reg A;
    reg B;

    wire Y;

    and_gate dut (
        .A(A),
        .B(B),
        .Y(Y)
    );

    initial begin

        $dumpfile("dump.vcd");
        $dumpvars(0, tb);

        A = 0; B = 0; #10;
        A = 0; B = 1; #10;
        A = 1; B = 0; #10;
        A = 1; B = 1; #10;

        $finish;

    end

    initial begin

        $monitor(
            "time=%0t A=%b B=%b Y=%b",
            $time, A, B, Y
        );

    end

endmodule
```

---

# 🧩 19. Study Case 1 — Boolean Function

Consider

$$
Y=AB+\overline{A}C.
$$

The Verilog implementation is

```verilog
module boolean_function(
    input  wire A,
    input  wire B,
    input  wire C,
    output wire Y
);

    assign Y = (A & B) | ((~A) & C);

endmodule
```

---

# 📊 20. Boolean Function Truth Table

|  A  |  B  |  C  |  Y  |
| :-: | :-: | :-: | :-: |
|  0  |  0  |  0  |  0  |
|  0  |  0  |  1  |  1  |
|  0  |  1  |  0  |  0  |
|  0  |  1  |  1  |  1  |
|  1  |  0  |  0  |  0  |
|  1  |  0  |  1  |  0  |
|  1  |  1  |  0  |  1  |
|  1  |  1  |  1  |  1  |

---

# 🧪 21. Exhaustive Testbench

Instead of manually writing every combination:

```verilog
module tb_boolean_function;

    reg A;
    reg B;
    reg C;

    wire Y;

    integer i;

    boolean_function dut (
        .A(A),
        .B(B),
        .C(C),
        .Y(Y)
    );

    initial begin

        $dumpfile("dump.vcd");
        $dumpvars(0, tb_boolean_function);

        for (i = 0; i < 8; i = i + 1) begin

            {A, B, C} = i;

            #10;

        end

        $finish;

    end

endmodule
```

The loop automatically generates all

$$
2^3=8
$$

input combinations.

---

# ✅ 22. Self-Checking Testbench

A self-checking testbench can automatically compare the DUT output with the expected result.

```verilog
module tb_check;

    reg A;
    reg B;
    reg C;

    wire Y;

    reg expected;

    integer i;

    boolean_function dut (
        .A(A),
        .B(B),
        .C(C),
        .Y(Y)
    );

    initial begin

        for (i = 0; i < 8; i = i + 1) begin

            {A, B, C} = i;

            #1;

            expected =
                (A & B) |
                ((~A) & C);

            if (Y === expected)
                $display(
                    "PASS: %b%b%b -> %b",
                    A, B, C, Y
                );

            else
                $display(
                    "FAIL: %b%b%b -> %b Expected=%b",
                    A, B, C, Y, expected
                );

            #9;

        end

        $finish;

    end

endmodule
```

---

# 🔀 23. Study Case 2 — 2-to-1 Multiplexer

A multiplexer selects one of two inputs.

$$
Y=
\begin{cases}
D_0,&S=0\
D_1,&S=1.
\end{cases}
$$

Verilog implementation:

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

# 📊 24. Multiplexer Truth Table

|  S  |  D0 |  D1 |  Y  |
| :-: | :-: | :-: | :-: |
|  0  |  0  |  X  |  0  |
|  0  |  1  |  X  |  1  |
|  1  |  X  |  0  |  0  |
|  1  |  X  |  1  |  1  |

Here, `X` represents a don't-care condition.

---

# ➕ 25. Study Case 3 — Half Adder

A half adder computes

$$
SUM=A\oplus B
$$

and

$$
CARRY=AB.
$$

Verilog:

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

# 📊 26. Half-Adder Truth Table

|  A  |  B  | SUM | CARRY |
| :-: | :-: | :-: | :---: |
|  0  |  0  |  0  |   0   |
|  0  |  1  |  1  |   0   |
|  1  |  0  |  1  |   0   |
|  1  |  1  |  0  |   1   |

---

# 💻 27. SystemVerilog Version

SystemVerilog can use the `logic` data type.

```systemverilog
module basic_logic_sv(
    input  logic A,
    input  logic B,

    output logic Y
);

    assign Y = A ^ B;

endmodule
```

For simple combinational logic, Verilog and SystemVerilog may look very similar.

---

# 🧠 28. Verilog versus SystemVerilog

| Feature                      | Verilog | SystemVerilog  |
| ---------------------------- | ------- | -------------- |
| Basic HDL support            | Yes     | Yes            |
| `wire` / `reg`               | Common  | Supported      |
| `logic` type                 | No      | Yes            |
| `always_comb`                | No      | Yes            |
| Advanced testbench features  | Limited | Extensive      |
| Assertions                   | Limited | Strong support |
| Object-oriented verification | No      | Yes            |

SystemVerilog extends Verilog with more powerful design and verification features.

---

# 💻 29. Using `always_comb`

A SystemVerilog multiplexer can be written as

```systemverilog
module mux_sv(
    input  logic D0,
    input  logic D1,
    input  logic S,
    output logic Y
);

    always_comb begin

        if (S)
            Y = D1;
        else
            Y = D0;

    end

endmodule
```

`always_comb` clearly indicates that the block represents combinational logic.

---

# ⚠️ 30. Avoiding Incomplete Assignments

Incorrect:

```systemverilog
always_comb begin

    if (A)
        Y = B;

end
```

When `A=0`, `Y` has no assignment.

Correct:

```systemverilog
always_comb begin

    if (A)
        Y = B;
    else
        Y = 1'b0;

end
```

Every output should be assigned in every possible branch.

---

# 🧠 31. Continuous Assignment versus Procedural Assignment

### Continuous Assignment

```verilog
assign Y = A & B;
```

is suitable for simple Boolean expressions.

### Procedural Combinational Assignment

```systemverilog
always_comb begin
    Y = A & B;
end
```

is useful for more complex logic structures.

Both can represent combinational hardware.

---

# 🔍 32. Operator Summary

| Operation    | Verilog/SystemVerilog Operator |   |
| ------------ | :----------------------------: | - |
| AND          |               `&`              |   |
| OR           |                `               | ` |
| XOR          |               `^`              |   |
| NOT          |               `~`              |   |
| Equality     |              `==`              |   |
| Greater than |               `>`              |   |
| Less than    |               `<`              |   |
| Conditional  |              `?:`              |   |

Be careful not to confuse bitwise operators with logical operators such as:

```text
&&
||
!
```

---

# 🧪 33. Logic Error Exercise

Suppose the intended function is

$$
Y=A\oplus B.
$$

Incorrect implementation:

```verilog
assign Y = A | B;
```

Run the testbench and identify which input combination fails.

For

$$
A=1,\quad B=1,
$$

OR produces

$$
1,
$$

but XOR should produce

$$
0.
$$

This demonstrates the value of simulation.

---

# 🔬 34. De Morgan Verification Exercise

Implement:

```verilog
assign Y1 = ~(A & B);
assign Y2 = (~A) | (~B);
```

Test all combinations.

The outputs should satisfy

$$
Y_1=Y_2
$$

for every input combination.

Similarly, verify

```verilog
assign Y3 = ~(A | B);
assign Y4 = (~A) & (~B);
```

---

# 🧪 35. Lab Tasks

### Task 1 — AND Gate

Implement and simulate an AND gate.

### Task 2 — Basic Gates

Implement:

* AND
* OR
* NOT
* XOR
* NAND
* NOR
* XNOR

### Task 3 — Truth-Table Verification

Compare simulation results with the expected truth table.

### Task 4 — Boolean Function

Implement

$$
Y=AB+\overline{A}C.
$$

### Task 5 — De Morgan's Theorem

Verify both De Morgan identities using simulation.

### Task 6 — Multiplexer

Implement a 2-to-1 multiplexer.

### Task 7 — Half Adder

Implement and verify a half adder.

### Task 8 — SystemVerilog

Rewrite one design using `logic` and `always_comb`.

### Task 9 — Waveform Analysis

Open EPWave and inspect all input/output signals.

### Task 10 — Self-Checking Verification

Create a testbench that automatically reports PASS or FAIL.

---

# 📋 36. Experimental Results

Complete the following table.

| Test             | Input | Expected Output | Simulated Output | Pass/Fail |
| ---------------- | ----- | --------------- | ---------------- | --------- |
| AND              |       |                 |                  |           |
| OR               |       |                 |                  |           |
| XOR              |       |                 |                  |           |
| NAND             |       |                 |                  |           |
| Boolean Function |       |                 |                  |           |
| Multiplexer      |       |                 |                  |           |
| Half Adder       |       |                 |                  |           |

---

# 📊 37. Logic-Gate Verification Table

|  A  |  B  | AND |  OR | XOR | NAND | NOR | XNOR |
| :-: | :-: | :-: | :-: | :-: | :--: | :-: | :--: |
|  0  |  0  |     |     |     |      |     |      |
|  0  |  1  |     |     |     |      |     |      |
|  1  |  0  |     |     |     |      |     |      |
|  1  |  1  |     |     |     |      |     |      |

Students should fill the table using simulation results.

---

# 💬 38. Discussion Points

1. What is digital logic?
2. What is the difference between logic `0` and logic `1`?
3. What is a truth table?
4. What is Boolean algebra?
5. What is the difference between AND, OR, and XOR?
6. What is the purpose of De Morgan's theorem?
7. What is combinational logic?
8. Why does combinational logic not require memory?
9. What is the purpose of a testbench?
10. Why is simulation useful before FPGA implementation?
11. What is the difference between Verilog and SystemVerilog?
12. What is the role of `assign`?
13. When is `always_comb` useful?
14. What is EPWave used for?

---

# 🧠 39. Post-Lab Exercises

1. **3-Input AND Gate**
   Implement

   $$
   Y=ABC.
   $$

2. **3-Input Majority Gate**
   Implement

   $$
   Y=AB+AC+BC.
   $$

3. **4-to-1 Multiplexer**
   Design a 4-input MUX.

4. **2-to-4 Decoder**
   Implement a one-hot decoder.

5. **2-Bit Comparator**
   Generate:

   * (A>B),
   * (A=B),
   * (A<B).

6. **Full Adder**
   Extend the half adder by adding `Cin`.

7. **Parity Generator**
   Generate even parity for four input bits.

8. **Boolean Simplification**
   Simplify a Boolean expression and compare both versions by simulation.

9. **SystemVerilog Rewrite**
   Rewrite all modules using `logic` and `always_comb`.

10. **Automatic Exhaustive Test**
    Use loops to generate all possible input combinations.

---

# 🔬 40. Advanced Exercise — Full Adder

A full adder performs

$$
A+B+C_{in}.
$$

The outputs are

$$
SUM=A\oplus B\oplus C_{in}
$$

and

$$
C_{out}=AB+C_{in}(A\oplus B).
$$

Example:

```verilog
module full_adder(
    input  wire A,
    input  wire B,
    input  wire Cin,

    output wire Sum,
    output wire Cout
);

    assign Sum =
        A ^ B ^ Cin;

    assign Cout =
        (A & B) |
        (Cin & (A ^ B));

endmodule
```

Verify all

$$
2^3=8
$$

input combinations.

---

# 🚀 41. Advanced Exercise — Simple 2-Bit ALU

Implement a simple combinational ALU.

Inputs:

$$
A[1:0],\quad B[1:0].
$$

Use a 2-bit control input:

|  OP  | Function |
| :--: | -------- |
| `00` | AND      |
| `01` | OR       |
| `10` | XOR      |
| `11` | ADD      |

A SystemVerilog implementation may use:

```systemverilog
module alu2(
    input  logic [1:0] A,
    input  logic [1:0] B,
    input  logic [1:0] OP,
    output logic [2:0] Y
);

    always_comb begin

        case (OP)

            2'b00:
                Y = {1'b0, A & B};

            2'b01:
                Y = {1'b0, A | B};

            2'b10:
                Y = {1'b0, A ^ B};

            2'b11:
                Y = A + B;

            default:
                Y = 3'b000;

        endcase

    end

endmodule
```

This introduces students to a basic processor datapath concept.

---

# 🔄 42. Recommended EDA Playground Workflow

The recommended process is

```text
Boolean Equation
      │
      ▼
Write Verilog/SystemVerilog
      │
      ▼
Create Testbench
      │
      ▼
Run Online Simulation
      │
      ▼
Check Console Output
      │
      ▼
Open EPWave
      │
      ▼
Compare with Truth Table
      │
      ├── Incorrect → Modify Code
      │
      └── Correct
              │
              ▼
          Complete Lab
```

---

# 🧾 43. Expected Learning Outcomes

After completing this laboratory, students will be able to:

* Explain basic digital logic concepts.
* Describe the operation of common logic gates.
* Use Boolean algebra to represent digital circuits.
* Apply De Morgan's theorems.
* Create truth tables.
* Write basic Verilog modules.
* Write simple SystemVerilog combinational modules.
* Create HDL testbenches.
* Run simulations using EDA Playground.
* Interpret console and waveform results.
* Implement multiplexers, adders, and Boolean functions.
* Build a foundation for more advanced digital-system design.

---

# 📘 44. References

1. M. M. Mano and M. D. Ciletti, *Digital Design*, Pearson.
2. S. Brown and Z. Vranesic, *Fundamentals of Digital Logic with Verilog Design*, McGraw-Hill.
3. M. D. Ciletti, *Advanced Digital Design with the Verilog HDL*, Pearson.
4. D. M. Harris and S. L. Harris, *Digital Design and Computer Architecture*, Morgan Kaufmann.
5. IEEE Std 1364-2005, *IEEE Standard for Verilog Hardware Description Language*.
6. IEEE Std 1800, *SystemVerilog—Unified Hardware Design, Specification, and Verification Language*.

---

## 🔑 Key Concept

The central concept of this laboratory is

$$
\boxed{
\text{Boolean Logic}
\rightarrow
\text{Verilog/SystemVerilog}
\rightarrow
\text{Simulation}
\rightarrow
\text{Verification}
}
$$

For combinational circuits,

$$
\boxed{
\text{Current Inputs}
\rightarrow
\text{Logic Function}
\rightarrow
\text{Current Outputs}
}
$$

and the EDA Playground workflow is

$$
\boxed{
\text{Write HDL}
\rightarrow
\text{Write Testbench}
\rightarrow
\text{Run Simulation}
\rightarrow
\text{Inspect EPWave}
}
$$

This laboratory provides the foundation for subsequent work involving **combinational logic, adders, multiplexers, sequential logic, finite-state machines, Vivado FPGA implementation, processor design, and AI-FPGA hardware**.
