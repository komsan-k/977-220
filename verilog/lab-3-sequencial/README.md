# 🔬 Lab 3: Sequential Circuit Design in Verilog HDL

## 🧩 1. Objective
This lab focuses on **sequential logic systems**, which depend on both current inputs and past states.  
Students will learn to:
- Design sequential circuits using **D, JK, and T flip-flops**
- Implement **counters** and **shift registers**
- Understand **clocking, edge triggering, and reset behavior**
- Write **behavioral Verilog models** for sequential circuits
- Verify functionality through **simulation waveforms and testbenches**

---

## ⚙️ 2. Equipment and Tools
| Tool / Resource | Description |
|------------------|-------------|
| **Vivado / Quartus / ModelSim** | HDL simulation and synthesis |
| **Nexys A7 / Basys 3 FPGA** | Hardware verification |
| **Text Editor / IDE** | VS Code, Vivado, Quartus |
| **System Tasks** | `$display`, `$monitor`, `$dumpvars`, `$finish` |

---

## 🧠 3. Background Theory

Sequential circuits are **state-based systems** — their outputs depend on previous inputs.  
Common sequential components include:
- **Flip-Flops (storage elements)**
- **Counters**
- **Shift Registers**
- **Finite State Machines (FSMs)**

All sequential logic is **clock-driven** and typically described using the **behavioral modeling style** with `always @(posedge clk)` blocks.

---

### 3.1 D Flip-Flop

```verilog
module D_FF(input clk, rst, d, output reg q);
  always @(posedge clk or posedge rst)
    if (rst)
      q <= 0;
    else
      q <= d;
endmodule
```

**Testbench**
```verilog
module tb_D_FF;
  reg clk, rst, d;
  wire q;

  D_FF uut (.clk(clk), .rst(rst), .d(d), .q(q));

  initial clk = 0;
  always #5 clk = ~clk; // Clock generation

  initial begin
    $dumpfile("DFF.vcd");
    $dumpvars(0, tb_D_FF);
    rst = 1; d = 0;
    #10 rst = 0;
    #10 d = 1;
    #10 d = 0;
    #20 $finish;
  end
endmodule
```

---

### 3.2 JK Flip-Flop

```verilog
module JK_FF(input clk, rst, j, k, output reg q);
  always @(posedge clk or posedge rst)
    if (rst)
      q <= 0;
    else
      case ({j, k})
        2'b00: q <= q;       // Hold
        2'b01: q <= 0;       // Reset
        2'b10: q <= 1;       // Set
        2'b11: q <= ~q;      // Toggle
      endcase
endmodule
```

**Testbench**
```verilog
module tb_JK_FF;
  reg clk, rst, j, k;
  wire q;

  JK_FF uut (.clk(clk), .rst(rst), .j(j), .k(k), .q(q));

  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    rst = 1; j = 0; k = 0;
    #10 rst = 0;
    #10 j = 1; k = 0;  // Set
    #10 j = 0; k = 1;  // Reset
    #10 j = 1; k = 1;  // Toggle
    #30 $finish;
  end
endmodule
```

---

### 3.3 4-Bit Asynchronous Counter

```verilog
module AsyncCounter(input clk, rst, output reg [3:0] count);
  always @(posedge clk or posedge rst)
    if (rst)
      count <= 0;
    else
      count <= count + 1;
endmodule
```

**Testbench**
```verilog
module tb_AsyncCounter;
  reg clk, rst;
  wire [3:0] count;

  AsyncCounter uut (.clk(clk), .rst(rst), .count(count));

  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    rst = 1; #10 rst = 0;
    #100 $finish;
  end
endmodule
```

---

### 3.4 4-Bit Shift Register

```verilog
module ShiftRegister(input clk, rst, input si, output reg [3:0] q);
  always @(posedge clk or posedge rst)
    if (rst)
      q <= 4'b0000;
    else
      q <= {q[2:0], si};
endmodule
```

**Testbench**
```verilog
module tb_ShiftRegister;
  reg clk, rst, si;
  wire [3:0] q;

  ShiftRegister uut (.clk(clk), .rst(rst), .si(si), .q(q));

  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    rst = 1; si = 0; #10;
    rst = 0; si = 1; #10;
    si = 0; #20;
    si = 1; #30;
    $finish;
  end
endmodule
```

---

## 🧮 4. Experiment Procedure
1. Create a new Verilog project.
2. Implement: D Flip-Flop, JK Flip-Flop, Counter, and Shift Register.
3. Write testbenches for each module.
4. Run simulations and record output waveforms.
5. Compare simulation results with theoretical truth tables.
6. Modify clock frequency or reset conditions to observe timing changes.

---

## 📊 5. Observation Tables

### D Flip-Flop
| CLK | RST | D | Q(next) |
|:---:|:---:|:---:|:---:|
| ↑ | 1 | X | 0 |
| ↑ | 0 | 0 | 0 |
| ↑ | 0 | 1 | 1 |

### JK Flip-Flop
| J | K | Action |
|:---:|:---:|:---|
| 0 | 0 | Hold |
| 0 | 1 | Reset |
| 1 | 0 | Set |
| 1 | 1 | Toggle |

---

## 💡 6. Discussion Points
- Difference between **edge-triggered** and **level-sensitive** logic  
- Role of **asynchronous vs synchronous resets**  
- Effect of **clock frequency** on timing behavior  
- Design comparison between **serial** and **parallel** shift registers  

---

## 🧠 7. Post-Lab Exercises
1. Implement a **4-bit synchronous counter**.  
2. Modify the shift register into a **bidirectional (left/right)** register.  
3. Design a **T Flip-Flop** using a JK Flip-Flop.  
4. Implement a **sequence detector FSM** for pattern “101” using behavioral modeling.  

---

## 🧾 8. Outcome
Students will be able to:
- Design and verify **sequential circuits** using Verilog HDL.  
- Apply **behavioral modeling** for time-dependent systems.  
- Implement **counters** and **shift registers** with clock/reset control.  
- Analyze sequential circuit behavior through simulation waveforms.  

---

## 📘 9. Reference Materials
1. Samir Palnitkar, *Verilog HDL: A Guide to Digital Design and Synthesis*, Pearson  
2. Pong P. Chu, *FPGA Prototyping by Verilog Examples*, Wiley  
3. Xilinx, *Vivado Design Suite User Guide*  
4. IEEE 1364-2005, *Verilog Hardware Description Language*

---

**Author:** Dr. Komsan Kanjanasit  
**Publisher:** College of Computing, Prince of Songkla University, Thailand  
**Edition:** First Edition (2025)  
**License:** CC BY 4.0 — Free to use with attribution
