# 🔬 Lab 5: Counters, Timers, and Clock Division in Verilog HDL

## 🧩 1. Objective
This laboratory exercise introduces **timing-controlled sequential circuits** using Verilog HDL.  
Students will learn to:
- Design and simulate **various counters** (up, down, and mod-N).  
- Implement **clock divider circuits** for timing control.  
- Design **time-based events** using behavioral modeling.  
- Integrate counter logic into **real-time clocking or LED blink control**.  

---

## ⚙️ 2. Equipment and Tools
| Tool / Resource | Description |
|------------------|-------------|
| **Vivado / Quartus / ModelSim** | HDL compiler and simulator |
| **FPGA Board (Basys 3 / Nexys A7)** | For hardware validation |
| **Text Editor / IDE** | VS Code, Vivado, Quartus |
| **Waveform Viewer** | For counter visualization |

---

## 🧠 3. Background Theory
A **counter** is a sequential circuit that progresses through a predefined sequence of states based on clock pulses.  
Counters form the foundation for **timing**, **event counting**, and **digital frequency division**.

### Common Types:
- **Asynchronous counter:** Ripple propagation through flip-flops.  
- **Synchronous counter:** All bits are clocked simultaneously.  
- **Up/Down counter:** Increment or decrement based on a control signal.  
- **Mod-N counter:** Resets after N counts (cyclic).  
- **Clock divider:** Reduces the clock frequency to generate slower timing signals.  

---

### 3.1 4-bit Synchronous Up Counter
```verilog
module SyncUpCounter(input clk, rst, output reg [3:0] count);
  always @(posedge clk or posedge rst)
    if (rst)
      count <= 0;
    else
      count <= count + 1;
endmodule
```

**Testbench**
```verilog
module tb_SyncUpCounter;
  reg clk, rst;
  wire [3:0] count;

  SyncUpCounter uut (.clk(clk), .rst(rst), .count(count));

  initial clk = 0;
  always #5 clk = ~clk;   // 100 MHz → 10 ns period

  initial begin
    $dumpfile("SyncUpCounter.vcd");
    $dumpvars(0, tb_SyncUpCounter);
    rst = 1; #10 rst = 0;
    #100 $finish;
  end
endmodule
```

---

### 3.2 4-bit Down Counter
```verilog
module DownCounter(input clk, rst, output reg [3:0] count);
  always @(posedge clk or posedge rst)
    if (rst)
      count <= 4'b1111;
    else
      count <= count - 1;
endmodule
```

---

### 3.3 Mod-10 (Decade) Counter
```verilog
module Mod10Counter(input clk, rst, output reg [3:0] count);
  always @(posedge clk or posedge rst)
    if (rst)
      count <= 0;
    else if (count == 9)
      count <= 0;
    else
      count <= count + 1;
endmodule
```

---

### 3.4 Clock Divider / Frequency Divider
Used to generate slower clocks from a fast FPGA oscillator (e.g., 100 MHz).

```verilog
module ClockDivider #(parameter DIV = 50000000)
  (input clk, rst, output reg slow_clk);
  reg [31:0] count;

  always @(posedge clk or posedge rst)
    if (rst) begin
      count <= 0;
      slow_clk <= 0;
    end else if (count == DIV-1) begin
      count <= 0;
      slow_clk <= ~slow_clk;
    end else
      count <= count + 1;
endmodule
```

**Testbench**
```verilog
module tb_ClockDivider;
  reg clk, rst;
  wire slow_clk;

  ClockDivider #(10) uut (.clk(clk), .rst(rst), .slow_clk(slow_clk));

  initial clk = 0;
  always #1 clk = ~clk;  // Simulated fast clock

  initial begin
    rst = 1; #5 rst = 0;
    #200 $finish;
  end
endmodule
```

---

### 3.5 Binary-to-Decimal Timer Display Example
```verilog
module Timer #(parameter MAX = 59)
  (input clk, rst, output reg [5:0] seconds);
  always @(posedge clk or posedge rst)
    if (rst)
      seconds <= 0;
    else if (seconds == MAX)
      seconds <= 0;
    else
      seconds <= seconds + 1;
endmodule
```

---

## 🧮 4. Experiment Procedure
1. **Create Project:** Open a new project in Vivado or Quartus.  
2. **Design Modules:** Implement Up Counter, Down Counter, Mod-10 Counter, and Clock Divider.  
3. **Write Testbenches:** Create and simulate Verilog testbenches for each module.  
4. **Simulate:** Observe timing waveforms and counter outputs.  
5. **Implement (Optional):** Download design to FPGA board and connect counter outputs to LEDs.  

---

## 📊 5. Observation Tables

### Example (Up Counter)
| Clock Cycle | Binary Count | Decimal Value |
|:-------------|:-------------|:--------------|
| 1 | 0001 | 1 |
| 2 | 0010 | 2 |
| 3 | 0011 | 3 |
| ... | ... | ... |

### Example (Mod-10 Counter)
| Cycle | Output | Reset? |
|:-------|:--------|:--------|
| 9 | 1001 | Yes |
| 10 | 0000 | Reset |

---

## 💡 6. Discussion Points
- Difference between **asynchronous** and **synchronous** counters.  
- Impact of **clock division** on real-time systems.  
- Role of **modulus counters** in timers and BCD displays.  
- Trade-off between **resolution and frequency** in clock dividers.  

---

## 🧠 7. Post-Lab Exercises
1. Design a **bidirectional up/down counter** using a control input.  
2. Implement a **Mod-6 counter** (sequence 0–5).  
3. Combine a **Clock Divider** and **Counter** to blink an LED every 1 second.  
4. Create a **multi-digit stopwatch** using two cascaded Mod-10 counters.  

---

## 🧾 8. Outcome
Students will be able to:
- Design **synchronous** and **mod-N counters** in Verilog.  
- Generate **clock division** for timing control.  
- Integrate **counters** into timer or display systems.  
- Analyze **timing relationships** through simulation waveforms.  

---

## 📘 9. References
1. Samir Palnitkar, *Verilog HDL: A Guide to Digital Design and Synthesis*, Pearson  
2. Pong P. Chu, *FPGA Prototyping by Verilog Examples*, Wiley  
3. Xilinx Vivado, *Synchronous Design Techniques*  
4. IEEE Std 1364-2005, *Verilog Hardware Description Language*  

---

**Author:** Dr. Komsan Kanjanasit  
**Publisher:** College of Computing, Prince of Songkla University, Thailand  
**Edition:** First Edition (2025)  
**License:** CC BY 4.0 — Free to use with attribution
