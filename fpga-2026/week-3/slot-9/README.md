# 🔬 Lab: Vivado Hierarchy — Adder Study Case

## 🧩 1. Objective

* Understand the concept of **hierarchical digital design** in Vivado.
* Design a complex circuit by combining smaller reusable Verilog modules.
* Implement **half adder**, **full adder**, and **multi-bit ripple-carry adder** modules.
* Learn how to instantiate lower-level modules inside higher-level modules.
* Simulate and verify each hierarchy level.
* Synthesize the complete hierarchical design in Vivado.
* Deploy the adder on an FPGA such as the **Basys 3 or Nexys A7**.

---

## ⚙️ 2. Equipment and Tools

| Tool / Resource                     | Description                                           |
| ----------------------------------- | ----------------------------------------------------- |
| **Vivado Design Suite**             | HDL design, simulation, synthesis, and implementation |
| **FPGA Board (Basys 3 / Nexys A7)** | Hardware implementation                               |
| **Verilog HDL**                     | Hierarchical circuit design                           |
| **Vivado Simulator**                | Functional simulation                                 |
| **RTL Schematic Viewer**            | Visualization of module hierarchy                     |
| **Switches**                        | Binary adder inputs                                   |
| **LEDs**                            | Sum and carry outputs                                 |

---

# 🧠 3. Background Theory

## 3.1 Hierarchical Digital Design

A large digital circuit can be divided into smaller functional modules.

Instead of writing one large Verilog module, the circuit can be constructed using a hierarchy such as

```text
Top Module
    │
    ├── Submodule 1
    │
    ├── Submodule 2
    │
    └── Submodule 3
```

Each lower-level module performs a specific function.

Hierarchical design provides several advantages:

* improved readability,
* easier debugging,
* module reuse,
* simpler verification,
* easier maintenance,
* better scalability.

In this laboratory, an adder is used as a study case for hierarchical FPGA design.

---

# ➕ 4. Adder Design Hierarchy

The design is constructed in stages:

```text
Half Adder
    │
    ▼
Full Adder
    │
    ▼
4-Bit Ripple-Carry Adder
    │
    ▼
FPGA Top Module
```

The complete hierarchy is

```text
adder_top
    │
    └── ripple_adder_4bit
            │
            ├── full_adder FA0
            ├── full_adder FA1
            ├── full_adder FA2
            └── full_adder FA3
                    │
                    ├── half_adder HA1
                    └── half_adder HA2
```

This illustrates how complex circuits are constructed from simpler reusable blocks.

---

# 🧮 5. Half Adder

## 5.1 Function

A half adder adds two binary inputs:

$$
A+B.
$$

It produces:

* Sum (S)
* Carry (C)

The Boolean equations are

$$
S=A\oplus B
$$

and

$$
C=A\cdot B.
$$

---

## 5.2 Truth Table

|  A  |  B  | Sum | Carry |
| :-: | :-: | :-: | :---: |
|  0  |  0  |  0  |   0   |
|  0  |  1  |  1  |   0   |
|  1  |  0  |  1  |   0   |
|  1  |  1  |  0  |   1   |

---

# 💻 6. Half Adder Verilog Module

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

This module forms the lowest level of the design hierarchy.

---

# 🧪 7. Half Adder Testbench

```verilog
`timescale 1ns / 1ps

module tb_half_adder;

    reg A;
    reg B;

    wire SUM;
    wire CARRY;

    half_adder uut (
        .A(A),
        .B(B),
        .SUM(SUM),
        .CARRY(CARRY)
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

The expected results are

|  A  |  B  | SUM | CARRY |
| :-: | :-: | :-: | :---: |
|  0  |  0  |  0  |   0   |
|  0  |  1  |  1  |   0   |
|  1  |  0  |  1  |   0   |
|  1  |  1  |  0  |   1   |

---

# ➕ 8. Full Adder

## 8.1 Function

A full adder adds three binary inputs:

$$
A+B+C_{in}.
$$

The outputs are

* Sum (S)
* Carry-out (C_{out})

The Boolean equations are

$$
S=A\oplus B\oplus C_{in}
$$

and

$$
C_{out}=AB+C_{in}(A\oplus B).
$$

---

## 8.2 Full Adder Truth Table

|  A  |  B  | (C_{in}) | Sum | (C_{out}) |
| :-: | :-: | :------: | :-: | :-------: |
|  0  |  0  |     0    |  0  |     0     |
|  0  |  0  |     1    |  1  |     0     |
|  0  |  1  |     0    |  1  |     0     |
|  0  |  1  |     1    |  0  |     1     |
|  1  |  0  |     0    |  1  |     0     |
|  1  |  0  |     1    |  0  |     1     |
|  1  |  1  |     0    |  0  |     1     |
|  1  |  1  |     1    |  1  |     1     |

---

# 🏗️ 9. Full Adder Using Half Adders

A full adder can be constructed hierarchically using two half adders.

```text
              ┌────────────┐
A ───────────►│ Half Adder │
B ───────────►│    HA1     │
              └─────┬──────┘
                    │
                   S1
                    │
              ┌─────▼──────┐
Cin ─────────►│ Half Adder │
              │    HA2     │
              └─────┬──────┘
                    │
                   SUM

Carry1 ──┐
         ├── OR ───► Cout
Carry2 ──┘
```

Mathematically,

$$
S_1=A\oplus B
$$

$$
C_1=AB
$$

$$
S=S_1\oplus C_{in}
$$

$$
C_2=S_1C_{in}
$$

$$
C_{out}=C_1+C_2.
$$

---

# 💻 10. Full Adder Verilog Module

```verilog
module full_adder(
    input  wire A,
    input  wire B,
    input  wire CIN,
    output wire SUM,
    output wire COUT
);

    wire sum1;
    wire carry1;
    wire carry2;

    half_adder HA1 (
        .A(A),
        .B(B),
        .SUM(sum1),
        .CARRY(carry1)
    );

    half_adder HA2 (
        .A(sum1),
        .B(CIN),
        .SUM(SUM),
        .CARRY(carry2)
    );

    assign COUT = carry1 | carry2;

endmodule
```

This module demonstrates **module instantiation**.

The `full_adder` module contains two instances of the `half_adder` module.

---

# 🧪 11. Full Adder Testbench

```verilog
`timescale 1ns / 1ps

module tb_full_adder;

    reg A;
    reg B;
    reg CIN;

    wire SUM;
    wire COUT;

    full_adder uut (
        .A(A),
        .B(B),
        .CIN(CIN),
        .SUM(SUM),
        .COUT(COUT)
    );

    integer i;

    initial begin

        for (i = 0; i < 8; i = i + 1) begin
            {A, B, CIN} = i;
            #10;
        end

        $finish;

    end

endmodule
```

---

# 🔢 12. Four-Bit Binary Addition

A four-bit adder performs

$$
A+B+C_{in}
$$

where

$$
A=[A_3A_2A_1A_0]
$$

and

$$
B=[B_3B_2B_1B_0].
$$

The result is

$$
S=[S_3S_2S_1S_0]
$$

with carry output

$$
C_{out}.
$$

Thus,

$$
{C_{out},S}=A+B+C_{in}.
$$

---

# 🏗️ 13. Ripple-Carry Adder Architecture

A 4-bit ripple-carry adder uses four full adders connected in sequence.

```text
      A0 B0
       │ │
       ▼ ▼
Cin ─► FA0 ───► C1
       │
       ▼
      S0

      A1 B1
       │ │
       ▼ ▼
C1 ──► FA1 ───► C2
       │
       ▼
      S1

      A2 B2
       │ │
       ▼ ▼
C2 ──► FA2 ───► C3
       │
       ▼
      S2

      A3 B3
       │ │
       ▼ ▼
C3 ──► FA3 ───► Cout
       │
       ▼
      S3
```

The carry propagates from the least significant bit toward the most significant bit.

This is why the architecture is called a **ripple-carry adder**.

---

# 💻 14. Four-Bit Ripple-Carry Adder

```verilog
module ripple_adder_4bit(
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire       CIN,
    output wire [3:0] SUM,
    output wire       COUT
);

    wire c1;
    wire c2;
    wire c3;

    full_adder FA0 (
        .A(A[0]),
        .B(B[0]),
        .CIN(CIN),
        .SUM(SUM[0]),
        .COUT(c1)
    );

    full_adder FA1 (
        .A(A[1]),
        .B(B[1]),
        .CIN(c1),
        .SUM(SUM[1]),
        .COUT(c2)
    );

    full_adder FA2 (
        .A(A[2]),
        .B(B[2]),
        .CIN(c2),
        .SUM(SUM[2]),
        .COUT(c3)
    );

    full_adder FA3 (
        .A(A[3]),
        .B(B[3]),
        .CIN(c3),
        .SUM(SUM[3]),
        .COUT(COUT)
    );

endmodule
```

The module hierarchy is now

```text
ripple_adder_4bit
      │
      ├── FA0
      ├── FA1
      ├── FA2
      └── FA3
```

where each `FA` is itself composed of two half adders.

---

# 🧪 15. Four-Bit Adder Testbench

```verilog
`timescale 1ns / 1ps

module tb_ripple_adder_4bit;

    reg  [3:0] A;
    reg  [3:0] B;
    reg        CIN;

    wire [3:0] SUM;
    wire       COUT;

    ripple_adder_4bit uut (
        .A(A),
        .B(B),
        .CIN(CIN),
        .SUM(SUM),
        .COUT(COUT)
    );

    initial begin

        A = 4'd0;
        B = 4'd0;
        CIN = 0;
        #10;

        A = 4'd3;
        B = 4'd2;
        CIN = 0;
        #10;

        A = 4'd7;
        B = 4'd5;
        CIN = 0;
        #10;

        A = 4'd9;
        B = 4'd6;
        CIN = 1;
        #10;

        A = 4'd15;
        B = 4'd15;
        CIN = 0;
        #10;

        $finish;

    end

endmodule
```

---

# 📊 16. Expected Simulation Results

|  A |  B | (C_{in}) | Decimal Result |   SUM  | (C_{out}) |
| -: | -: | :------: | -------------: | :----: | :-------: |
|  0 |  0 |     0    |              0 | `0000` |     0     |
|  3 |  2 |     0    |              5 | `0101` |     0     |
|  7 |  5 |     0    |             12 | `1100` |     0     |
|  9 |  6 |     1    |             16 | `0000` |     1     |
| 15 | 15 |     0    |             30 | `1110` |     1     |

For example,

$$
9+6+1=16.
$$

In binary,

$$
1001+0110+1=10000.
$$

Therefore,

$$
SUM=0000
$$

and

$$
C_{out}=1.
$$

---

# 🔗 17. FPGA Top-Level Module

A top-level wrapper can be created for FPGA implementation.

```verilog
module adder_top(
    input  wire [3:0] SW_A,
    input  wire [3:0] SW_B,
    input  wire       SW_CIN,

    output wire [3:0] LED_SUM,
    output wire       LED_COUT
);

    ripple_adder_4bit ADDER (
        .A(SW_A),
        .B(SW_B),
        .CIN(SW_CIN),
        .SUM(LED_SUM),
        .COUT(LED_COUT)
    );

endmodule
```

The hierarchy becomes

```text
adder_top
    │
    ▼
ripple_adder_4bit
    │
    ├── full_adder
    │      ├── half_adder
    │      └── half_adder
    │
    ├── full_adder
    │
    ├── full_adder
    │
    └── full_adder
```

---

# ⚡ 18. FPGA I/O Mapping

A suggested mapping is

| Signal         | FPGA Resource | Description  |
| -------------- | ------------- | ------------ |
| `SW_A[3:0]`    | SW3–SW0       | Operand A    |
| `SW_B[3:0]`    | SW7–SW4       | Operand B    |
| `SW_CIN`       | SW8           | Carry input  |
| `LED_SUM[3:0]` | LED3–LED0     | Sum          |
| `LED_COUT`     | LED4          | Carry output |

For example,

```text
SW7 SW6 SW5 SW4    SW3 SW2 SW1 SW0
 B3  B2  B1  B0     A3  A2  A1  A0
```

The result is displayed as

```text
LED4 LED3 LED2 LED1 LED0
COUT   S3   S2   S1   S0
```

---

# 🛠️ 19. Vivado Project Procedure

## Step 1 — Create a New Project

Open Vivado and select

```text
Create Project
```

Choose an RTL project and select the appropriate FPGA board or device.

---

## Step 2 — Add Verilog Sources

Create the following design files:

```text
half_adder.v
full_adder.v
ripple_adder_4bit.v
adder_top.v
```

The dependency hierarchy is

```text
adder_top.v
    │
    └── ripple_adder_4bit.v
             │
             └── full_adder.v
                    │
                    └── half_adder.v
```

---

## Step 3 — Set Top Module

In the Sources window, right-click

```text
adder_top
```

and select

```text
Set as Top
```

---

## Step 4 — Check Design Hierarchy

Vivado should display a hierarchical structure similar to

```text
adder_top
 └── ADDER : ripple_adder_4bit
      ├── FA0 : full_adder
      │    ├── HA1 : half_adder
      │    └── HA2 : half_adder
      │
      ├── FA1 : full_adder
      ├── FA2 : full_adder
      └── FA3 : full_adder
```

This confirms that module instances are correctly connected.

---

# 🔍 20. RTL Analysis in Vivado

Select

```text
RTL Analysis
    ↓
Open Elaborated Design
```

Then choose

```text
Schematic
```

Vivado should display the hierarchical circuit.

Students should identify:

* `adder_top`
* `ripple_adder_4bit`
* four full adders
* half-adder instances
* carry-chain connections

This visualizes the relationship between HDL hierarchy and synthesized hardware structure.

---

# 🧪 21. Simulation Procedure

Create a simulation source

```text
tb_ripple_adder_4bit.v
```

Then select

```text
Run Simulation
    ↓
Run Behavioral Simulation
```

Observe:

* `A`
* `B`
* `CIN`
* `SUM`
* `COUT`

in the waveform viewer.

Students should verify

$$
{COUT,SUM}=A+B+CIN.
$$

---

# 🧮 22. Manual Verification

Consider

$$
A=1011_2=11
$$

and

$$
B=0101_2=5.
$$

With

$$
C_{in}=0,
$$

the expected result is

$$
11+5=16.
$$

Therefore,

$$
1011+0101=10000.
$$

The FPGA output should be

```text
COUT = 1
SUM  = 0000
```

---

# 🏗️ 23. Structural versus Behavioral Design

The ripple-carry adder in this laboratory is a **structural design** because lower-level modules are explicitly instantiated.

Example:

```verilog
full_adder FA0 (...);
full_adder FA1 (...);
```

However, the same 4-bit adder could be described behaviorally as

```verilog
assign {COUT, SUM} = A + B + CIN;
```

Both may produce functionally equivalent hardware after synthesis.

The hierarchical version is particularly useful for learning:

* digital architecture,
* module reuse,
* component interconnection,
* carry propagation,
* structural HDL design.

---

# 🆚 24. Hierarchical versus Flat Design

| Characteristic                 | Hierarchical Design | Flat Design             |
| ------------------------------ | ------------------- | ----------------------- |
| Structure                      | Multiple modules    | One large module        |
| Readability                    | High                | Lower for large designs |
| Reusability                    | High                | Limited                 |
| Debugging                      | Easier              | More difficult          |
| Module testing                 | Independent         | Less convenient         |
| Scalability                    | Good                | Poorer                  |
| Learning hardware architecture | Excellent           | Limited                 |

Hierarchical design becomes increasingly important for large systems such as:

* processors,
* ALUs,
* memories,
* communication controllers,
* FPGA accelerators,
* AI hardware.

---

# ⏱️ 25. Ripple-Carry Delay

The disadvantage of a ripple-carry adder is carry propagation delay.

The carry must propagate through

```text
FA0 → FA1 → FA2 → FA3
```

before the final result is stable.

For an (N)-bit ripple-carry adder, the worst-case carry delay approximately grows with

$$
T_{RCA}\propto N.
$$

For larger word lengths, this can reduce maximum operating frequency.

More advanced architectures include:

* carry-lookahead adder,
* carry-select adder,
* carry-skip adder,
* parallel-prefix adder.

Modern FPGAs also provide dedicated fast carry-chain resources.

---

# 📈 26. Synthesis Analysis

After simulation, select

```text
Run Synthesis
```

and inspect:

* LUT utilization,
* flip-flop utilization,
* I/O utilization,
* logic hierarchy.

Students should record the results.

| Resource   | Utilization |
| ---------- | ----------: |
| LUTs       |             |
| Flip-Flops |             |
| I/O        |             |
| DSPs       |             |
| BRAM       |             |

Because the adder is combinational, very few or no flip-flops should be required unless Vivado inserts or preserves registers elsewhere in the design.

---

# ⏱️ 27. Timing Analysis

After implementation, inspect the timing report.

Useful parameters include:

| Parameter         | Result |
| ----------------- | -----: |
| Critical Path     |        |
| Logic Delay       |        |
| Routing Delay     |        |
| Maximum Frequency |        |

The critical path is expected to involve carry propagation through the adder.

Students should investigate whether Vivado maps the design onto dedicated FPGA carry-chain resources.

---

# 🧪 28. Lab Tasks

### Task 1 — Half Adder

Implement and simulate a half adder.

Verify

$$
S=A\oplus B
$$

and

$$
C=AB.
$$

### Task 2 — Full Adder

Create a full adder using **two half-adder instances**.

Verify all eight input combinations.

### Task 3 — Four-Bit Adder

Create a 4-bit ripple-carry adder using **four full-adder instances**.

### Task 4 — Hierarchy Verification

Open the Vivado hierarchy and identify each module instance.

### Task 5 — RTL Schematic

Open the elaborated RTL schematic and trace the carry signal

$$
CIN\rightarrow C_1\rightarrow C_2\rightarrow C_3\rightarrow COUT.
$$

### Task 6 — Simulation

Verify at least five different addition cases.

### Task 7 — FPGA Implementation

Use switches as operands and LEDs as outputs.

### Task 8 — Resource Analysis

Record LUT, register, and I/O utilization.

---

# 💬 29. Discussion Points

1. What is hierarchical design?
2. Why is hierarchical design useful in FPGA projects?
3. What is the difference between a half adder and a full adder?
4. Why does a full adder require a carry input?
5. How can two half adders form a full adder?
6. Why is the 4-bit circuit called a ripple-carry adder?
7. What determines the critical path of a ripple-carry adder?
8. What is the difference between structural and behavioral Verilog?
9. Can Vivado optimize away some hierarchy during synthesis?
10. Why are reusable modules important in large FPGA projects?

---

# 🧠 30. Post-Lab Exercises

1. **Eight-Bit Ripple-Carry Adder**
   Extend the design from 4 bits to 8 bits.

2. **Sixteen-Bit Adder**
   Create a 16-bit adder using four 4-bit modules.

3. **Adder/Subtractor**
   Add a control input that selects

   $$
   A+B
   $$

   or

   $$
   A-B.
   $$

4. **Overflow Detection**
   Add an overflow flag for signed arithmetic.

5. **Behavioral Comparison**
   Replace the hierarchical adder with

   ```verilog
   assign {COUT, SUM} = A + B + CIN;
   ```

   and compare the synthesized hardware.

6. **Carry-Lookahead Adder**
   Design a 4-bit carry-lookahead adder.

7. **Timing Comparison**
   Compare ripple-carry and carry-lookahead timing.

8. **Parameterized Adder**
   Create a parameterized (N)-bit adder.

---

# 🔬 31. Advanced Exercise — Parameterized Ripple-Carry Adder

Instead of manually instantiating each full adder, a parameterized design can use a `generate` statement.

```verilog
module ripple_adder #(
    parameter N = 8
)(
    input  wire [N-1:0] A,
    input  wire [N-1:0] B,
    input  wire         CIN,
    output wire [N-1:0] SUM,
    output wire         COUT
);

    wire [N:0] carry;

    assign carry[0] = CIN;
    assign COUT = carry[N];

    genvar i;

    generate
        for (i = 0; i < N; i = i + 1) begin : ADDER_STAGE

            full_adder FA (
                .A(A[i]),
                .B(B[i]),
                .CIN(carry[i]),
                .SUM(SUM[i]),
                .COUT(carry[i+1])
            );

        end
    endgenerate

endmodule
```

This illustrates how hierarchy can be combined with **parameterization and hardware generation**.

---

# 🧱 32. Advanced Hierarchy

A larger architecture can be developed as

```text
16-bit Adder
    │
    ├── 4-bit Adder Block 0
    │      ├── FA
    │      ├── FA
    │      ├── FA
    │      └── FA
    │
    ├── 4-bit Adder Block 1
    ├── 4-bit Adder Block 2
    └── 4-bit Adder Block 3
```

This demonstrates multi-level hierarchy:

$$
\boxed{
\text{Half Adder}
\rightarrow
\text{Full Adder}
\rightarrow
\text{4-bit Adder}
\rightarrow
\text{16-bit Adder}
}
$$

The same design methodology is used for much larger digital systems.

---

# 🧾 33. Expected Learning Outcomes

After completing this laboratory, students will be able to:

* Explain hierarchical digital design.
* Design and simulate a half adder.
* Construct a full adder from half adders.
* Construct a multi-bit adder from full adders.
* Instantiate Verilog modules correctly.
* Understand parent-child relationships between HDL modules.
* Navigate the Vivado hierarchy view.
* Analyze RTL schematics.
* Verify hierarchical designs using simulation.
* Deploy a hierarchical circuit to an FPGA.
* Compare structural and behavioral Verilog.
* Analyze carry propagation and timing.
* Apply hierarchical design principles to larger FPGA systems.

---

# 📘 34. References

1. M. D. Ciletti, *Advanced Digital Design with the Verilog HDL*, Pearson.
2. S. Brown and Z. Vranesic, *Fundamentals of Digital Logic with Verilog Design*, McGraw-Hill.
3. M. M. Mano and M. D. Ciletti, *Digital Design*, Pearson.
4. AMD Xilinx, *Vivado Design Suite User Guide: Synthesis*.
5. AMD Xilinx, *Vivado Design Suite User Guide: Design Analysis and Closure Techniques*.
6. IEEE Std 1364-2005, *IEEE Standard for Verilog Hardware Description Language*.

---

## 🔑 Key Concept

The central concept of this laboratory is

$$
\boxed{
\text{Simple Module}
\rightarrow
\text{Reusable Submodule}
\rightarrow
\text{Hierarchical System}
}
$$

For the adder study case,

$$
\boxed{
\text{Half Adder}
\rightarrow
\text{Full Adder}
\rightarrow
\text{Ripple-Carry Adder}
\rightarrow
\text{FPGA Top Module}
}
$$

This laboratory provides the foundation for hierarchical design of more advanced FPGA systems such as **ALUs, processors, finite-state machines, communication controllers, DSP blocks, systolic arrays, and AI accelerators**.
