# 🔬 Lab 1: Fundamentals of Verilog HDL (Expanded)

## 🧩 1. Objective
This laboratory introduces the **core syntax, modeling styles, and simulation concepts** in Verilog HDL. Students will:
- Understand HDL structure and modular design.
- Implement digital logic using **gate-level, dataflow, and behavioral modeling**.
- Develop and simulate **testbenches**.
- Observe timing and event-driven simulation behavior.

---

## ⚙️ 2. Equipment and Tools
| Tool / Resource | Description |
|-----------------|--------------|
| **Vivado / Quartus / ModelSim** | HDL compiler and simulator |
| **Nexys A7 / Basys 3 FPGA** | For hardware implementation |
| **Text Editor** | VS Code, Vivado, or Quartus |
| **System Tasks** | `$display`, `$monitor`, `$dumpfile`, `$finish` |

---

## 🧠 3. Background Theory

### 3.1 Structure of a Verilog Module
A Verilog design is described in a **module**, which defines ports, internal signals, and logic behavior.

```verilog
module AND_gate(input a, b, output y);
  assign y = a & b;
endmodule
```

Each module can be **instantiated** within another design for hierarchy:
```verilog
AND_gate u1 (.a(x), .b(y), .y(z));
```

---

### 3.2 Modeling Styles in Verilog

#### (a) Gate-Level Modeling
Uses **logic primitives** such as `and`, `or`, `not`, etc.

```verilog
module logic_gates(input a, b, output y_and, y_or, y_not);
  and  (y_and, a, b);
  or   (y_or, a, b);
  not  (y_not, a);
endmodule
```

**Testbench:**
```verilog
module tb_logic_gates;
  reg a, b;
  wire y_and, y_or, y_not;

  logic_gates dut (.a(a), .b(b), .y_and(y_and), .y_or(y_or), .y_not(y_not));

  initial begin
    $dumpfile("logic_gates.vcd");
    $dumpvars(0, tb_logic_gates);
    a = 0; b = 0;
    #10 a = 1; b = 0;
    #10 b = 1;
    #10 a = 0;
    #10 $finish;
  end
endmodule
```

---

#### (b) Dataflow Modeling
Uses **continuous assignments** (`assign`) and Boolean expressions.

```verilog
module MUX_2to1(input a, b, sel, output y);
  assign y = sel ? b : a;
endmodule
```

**Testbench:**
```verilog
module tb_MUX_2to1;
  reg a, b, sel;
  wire y;

  MUX_2to1 uut (.a(a), .b(b), .sel(sel), .y(y));

  initial begin
    $monitor("time=%0t | a=%b b=%b sel=%b -> y=%b", $time, a, b, sel, y);
    a=0; b=1; sel=0;
    #10 sel=1;
    #10 a=1;
    #10 b=0; sel=0;
    #10 $finish;
  end
endmodule
```

---

#### (c) Behavioral Modeling
Uses **procedural blocks** such as `always` or `initial`.

```verilog
module D_FF(input clk, rst, d, output reg q);
  always @(posedge clk or posedge rst)
    if (rst)
      q <= 0;
    else
      q <= d;
endmodule
```

**Testbench:**
```verilog
module tb_D_FF;
  reg clk, rst, d;
  wire q;

  D_FF uut (.clk(clk), .rst(rst), .d(d), .q(q));

  initial begin
    clk = 0; forever #5 clk = ~clk; // clock generation
  end

  initial begin
    rst = 1; d = 0;
    #10 rst = 0;
    #10 d = 1;
    #10 d = 0;
    #20 $finish;
  end
endmodule
```

---

### 3.3 Parameterized Design Example
You can define reusable modules with **parameters**.

```verilog
module Nbit_Adder #(parameter N = 4)
  (input [N-1:0] a, b, output [N:0] sum);
  assign sum = a + b;
endmodule
```

**Testbench:**
```verilog
module tb_Nbit_Adder;
  reg [3:0] a, b;
  wire [4:0] sum;

  Nbit_Adder #(4) uut (.a(a), .b(b), .sum(sum));

  initial begin
    a=4'b0011; b=4'b0101;
    #10 a=4'b1111; b=4'b0001;
    #10 a=4'b1000; b=4'b0111;
    #10 $finish;
  end
endmodule
```

---

### 3.4 Sequential Logic Example: 3-bit Up Counter
```verilog
module counter_3bit(input clk, rst, output reg [2:0] count);
  always @(posedge clk or posedge rst)
    if (rst)
      count <= 3'b000;
    else
      count <= count + 1;
endmodule
```

**Testbench:**
```verilog
module tb_counter_3bit;
  reg clk, rst;
  wire [2:0] count;

  counter_3bit uut (.clk(clk), .rst(rst), .count(count));

  initial begin
    clk = 0; forever #5 clk = ~clk;
  end

  initial begin
    rst = 1; #10 rst = 0;
    #100 $finish;
  end
endmodule
```

---

## 🧮 4. Experiment Procedure
1. **Create project:** Start a new Verilog project in your chosen simulator.  
2. **Design modules:** Implement the codes for AND gate, MUX, D Flip-Flop, and Counter.  
3. **Develop testbenches:** Create and run corresponding testbenches.  
4. **Simulate and observe:** Record output waveforms.  
5. **Modify:** Add parameters, delays, and hierarchical instantiation.  

---

## 📊 5. Observation Table
| Time (ns) | a | b | sel | y (MUX) |
|------------|---|---|-----|---------|
| 0 | 0 | 1 | 0 | 0 |
| 10 | 0 | 1 | 1 | 1 |
| 20 | 1 | 0 | 0 | 1 |

---

## 💡 6. Discussion
- How does simulation time differ from synthesis time?  
- What are the effects of blocking (`=`) vs non-blocking (`<=`) assignments?  
- Why are delays (`#`) ignored during synthesis?  
- Discuss event-driven simulation behavior.  

---

## 🧠 7. Post-Lab Exercises
1. Modify the D Flip-Flop to a **T Flip-Flop**.  
2. Add a **parameterized width counter**.  
3. Implement a **4-to-1 multiplexer** using nested conditional statements.  
4. Write a **testbench that self-checks outputs** using `if` and `$display`.  

---

## 🧾 8. Outcome
Students will be able to:
- Write and simulate combinational and sequential circuits in Verilog.  
- Distinguish between structural, dataflow, and behavioral descriptions.  
- Use hierarchical instantiation and parameterization.  
- Apply testbenches for design verification.  

---

## 📘 9. Reference Materials
- IEEE 1364-2005: *Verilog HDL Standard*  
- Samir Palnitkar, *Verilog HDL: A Guide to Digital Design and Synthesis*  
- Pong P. Chu, *FPGA Prototyping by Verilog Examples*  
- Xilinx, *Vivado Design Suite User Guide*
