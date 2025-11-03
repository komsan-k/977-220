# 🔬 Lab 2: Combinational Circuit Design in Verilog HDL

## 🧩 1. Objective
This lab builds upon the fundamentals learned in Lab 1 and focuses on:
- Designing combinational logic circuits (**Adders, Multiplexers, Decoders, Comparators**)
- Using **dataflow** and **behavioral** modeling styles
- Writing and executing **testbenches** to verify functionality
- Understanding **truth table verification** and **simulation waveform analysis**

---

## ⚙️ 2. Equipment and Tools
| Tool / Resource | Description |
|------------------|-------------|
| **Vivado / Quartus / ModelSim** | HDL simulator and synthesizer |
| **FPGA Board (Basys 3 / Nexys A7)** | For implementation and hardware verification |
| **Text Editor / IDE** | VS Code, Vivado, or Quartus |
| **Waveform Viewer** | For simulation result verification |

---

## 🧠 3. Background Theory

Combinational circuits generate outputs purely as a function of current inputs, with **no memory** of past states.

Common modeling styles:
- **Dataflow modeling:** continuous assignments using `assign`
- **Behavioral modeling:** procedural blocks using `always @(*)`

Typical components:
- Half Adder / Full Adder  
- Multiplexer  
- Decoder  
- Comparator  

---

### 3.1 Half Adder (Dataflow Model)

```verilog
module HalfAdder(input a, b, output sum, carry);
  assign sum   = a ^ b;
  assign carry = a & b;
endmodule
```

**Testbench**
```verilog
module tb_HalfAdder;
  reg a, b;
  wire sum, carry;

  HalfAdder uut (.a(a), .b(b), .sum(sum), .carry(carry));

  initial begin
    $monitor("t=%0t | a=%b b=%b -> sum=%b carry=%b", $time, a, b, sum, carry);
    a=0; b=0; #10;
    a=0; b=1; #10;
    a=1; b=0; #10;
    a=1; b=1; #10;
    $finish;
  end
endmodule
```

---

### 3.2 Full Adder (Behavioral Model)

```verilog
module FullAdder(input a, b, cin, output reg sum, output reg cout);
  always @(*) begin
    {cout, sum} = a + b + cin;
  end
endmodule
```

**Testbench**
```verilog
module tb_FullAdder;
  reg a, b, cin;
  wire sum, cout;

  FullAdder uut (.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

  initial begin
    $display("A B Cin | Sum Cout");
    for (integer i = 0; i < 8; i = i + 1) begin
      {a,b,cin} = i;
      #10;
      $display("%b %b  %b  |  %b   %b", a,b,cin,sum,cout);
    end
    $finish;
  end
endmodule
```

---

### 3.3 4-to-1 Multiplexer (Dataflow)

```verilog
module MUX4to1(input [3:0] d, input [1:0] sel, output y);
  assign y = d[sel];
endmodule
```

---

### 3.4 2-to-4 Decoder (Behavioral)

```verilog
module Decoder2to4(input [1:0] in, output reg [3:0] out);
  always @(*) begin
    case (in)
      2'b00: out = 4'b0001;
      2'b01: out = 4'b0010;
      2'b10: out = 4'b0100;
      2'b11: out = 4'b1000;
      default: out = 4'b0000;
    endcase
  end
endmodule
```

---

### 3.5 2-bit Comparator (Dataflow)

```verilog
module Comparator2bit(input [1:0] a, b, output eq, gt, lt);
  assign eq = (a == b);
  assign gt = (a >  b);
  assign lt = (a <  b);
endmodule
```

---

## 🧮 4. Experiment Procedure
1. **Create Project:** Start a new Verilog project in your HDL tool.  
2. **Design Modules:** Implement `HalfAdder`, `FullAdder`, `MUX4to1`, `Decoder2to4`, and `Comparator2bit`.  
3. **Simulate:** Write and run testbenches for each module.  
4. **Observe Outputs:** Compare simulation results to the truth tables.  
5. **Export Waveforms:** Save `.vcd` or `.wlf` files for verification.  
6. **Synthesize (Optional):** Implement the verified design on an FPGA board.

---

## 📊 5. Observation Tables

### Half Adder
| A | B | Sum | Carry |
|:-:|:-:|:-:|:-:|
| 0 | 0 | 0 | 0 |
| 0 | 1 | 1 | 0 |
| 1 | 0 | 1 | 0 |
| 1 | 1 | 0 | 1 |

### Full Adder
| A | B | Cin | Sum | Cout |
|:-:|:-:|:-:|:-:|:-:|
| 0 | 0 | 0 | 0 | 0 |
| 0 | 1 | 0 | 1 | 0 |
| 1 | 1 | 1 | 1 | 1 |

---

## 💡 6. Discussion Points
- Differences between **dataflow** and **behavioral** styles  
- Use of **procedural vs continuous** assignments  
- Role of **MUX** and **Decoder** in forming larger logic systems  
- Synthesis implications of **case statements** and conditional modeling  

---

## 🧠 7. Post-Lab Exercises
1. Design a **4-bit ripple-carry adder** using Full Adder modules.  
2. Implement a **4-to-2 priority encoder** in behavioral model.  
3. Create a **7-segment display decoder** for binary input.  
4. Write a **self-checking testbench** for the comparator module.  

---

## 🧾 8. Outcome
Students will be able to:
- Implement and verify combinational logic in Verilog  
- Differentiate between dataflow and behavioral representations  
- Build **parameterized and hierarchical** designs  
- Perform synthesis and deployment on FPGA hardware  

---

## 📘 9. References
1. Samir Palnitkar, *Verilog HDL: A Guide to Digital Design and Synthesis*, Pearson  
2. Pong P. Chu, *FPGA Prototyping by Verilog Examples*, Wiley  
3. Xilinx, *Vivado User Guide for Simulation*  
4. IEEE Std 1364-2005, *Verilog Hardware Description Language*

---

**Author:** Dr. Komsan Kanjanasit  
**Publisher:** College of Computing, Prince of Songkla University, Thailand  
**Edition:** First Edition (2025)  
**License:** CC BY 4.0 — Free to use with attribution

