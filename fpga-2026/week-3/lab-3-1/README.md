# Hierarchical Simple Digital Design

---

# 📘 Overview

A hierarchical digital design means building a large system from smaller reusable modules.

Instead of writing one large HDL file, the design is divided into levels:

```text id="g80mgg"
System
 ├── Submodule
 │     ├── Smaller Module
 │     └── Smaller Module
 └── Submodule
```

This is the standard approach in:

* FPGA design
* ASIC design
* Verilog/SystemVerilog projects
* Vivado IP Integrator systems

---

# 🧩 Example: Hierarchical 4-Bit Adder

## Top-Level Concept

```text id="vxcf0y"
4-Bit Adder
   ├── Full Adder 0
   ├── Full Adder 1
   ├── Full Adder 2
   └── Full Adder 3
```

---

# 🔹 Step 1 — Full Adder Module

This is the smallest reusable block.

## Verilog Code

```verilog id="0h0w9q"
module full_adder(
    input a,
    input b,
    input cin,
    output sum,
    output cout
);

assign sum  = a ^ b ^ cin;
assign cout = (a & b) | (a & cin) | (b & cin);

endmodule
```

---

# 🔹 Step 2 — 4-Bit Adder (Top Module)

This module instantiates 4 full adders.

## Verilog Code

```verilog id="p0ku0u"
module adder4bit(
    input  [3:0] A,
    input  [3:0] B,
    input        Cin,
    output [3:0] Sum,
    output       Cout
);

wire c1, c2, c3;

full_adder FA0 (
    .a(A[0]),
    .b(B[0]),
    .cin(Cin),
    .sum(Sum[0]),
    .cout(c1)
);

full_adder FA1 (
    .a(A[1]),
    .b(B[1]),
    .cin(c1),
    .sum(Sum[1]),
    .cout(c2)
);

full_adder FA2 (
    .a(A[2]),
    .b(B[2]),
    .cin(c2),
    .sum(Sum[2]),
    .cout(c3)
);

full_adder FA3 (
    .a(A[3]),
    .b(B[3]),
    .cin(c3),
    .sum(Sum[3]),
    .cout(Cout)
);

endmodule
```

---

# 🏗️ Design Hierarchy

```text id="vax4x4"
adder4bit
   ├── FA0 : full_adder
   ├── FA1 : full_adder
   ├── FA2 : full_adder
   └── FA3 : full_adder
```

---

# 🔷 Advantages of Hierarchical Design

| Advantage        | Description                        |
| ---------------- | ---------------------------------- |
| Reusability      | Reuse modules                      |
| Easier debugging | Small modules easier to test       |
| Scalability      | Build large systems                |
| Readability      | Cleaner HDL code                   |
| Team design      | Multiple engineers work separately |

---

# 🔷 FPGA Relation

Hierarchical design is heavily used in:

* FPGA systems
* Vivado IP Integrator
* AXI architectures
* CPU systems
* CNN accelerators

---

# 🔷 Example FPGA Hierarchy

```text id="qkq8uq"
Top System
   ├── UART Module
   ├── GPIO Module
   ├── Memory Module
   └── Processor Module
```

---

# 🔷 Relation to Vivado

Vivado automatically shows hierarchy:

```text id="bqfjlwm"
Sources
 └── adder4bit
      ├── full_adder
      ├── full_adder
      ├── full_adder
      └── full_adder
```

---

# 🔷 Educational Learning Flow

```text id="zsyxlg"
Logic Gates
   ↓
Half Adder
   ↓
Full Adder
   ↓
4-Bit Adder
   ↓
ALU
```

---

# 🧪 Suggested Simple Lab

## Lab: Hierarchical 4-Bit Adder

### Tasks

1. Create full adder module
2. Create top-level 4-bit adder
3. Simulate in Vivado
4. Observe carry propagation

---

# 📊 Expected Simulation

| A    | B    | Sum          |
| ---- | ---- | ------------ |
| 0011 | 0101 | 1000         |
| 1111 | 0001 | 0000 + Carry |

---

# 🔷 Extension Ideas

You can extend this into:

* 8-bit adder
* ALU
* Multiplier
* CNN MAC unit
* DSP blocks

---

# 🎯 Learning Outcomes

Students will be able to:

* Understand hierarchical HDL design
* Create reusable Verilog modules
* Build larger FPGA systems
* Simulate hierarchical circuits in Vivado
* Develop scalable FPGA architectures

---

# 💻 Recommended Tools

| Tool                | Purpose                 |
| ------------------- | ----------------------- |
| Vivado Design Suite | FPGA design             |
| Verilog HDL         | Hardware description    |
| Nexys A7 FPGA       | Hardware implementation |

---

# 📘 Conclusion

Hierarchical digital design is a fundamental methodology in FPGA and ASIC development. By dividing systems into smaller reusable modules, engineers can create scalable, maintainable, and efficient hardware architectures.

The hierarchical 4-bit adder demonstrates how simple reusable blocks can be combined into larger digital systems.

---
