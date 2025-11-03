# 🔬 Lab 4: Finite State Machines (FSMs) in Verilog HDL

## 🧩 1. Objective
This laboratory focuses on the **design, simulation, and verification of Finite State Machines (FSMs)** using Verilog HDL.  
Students will learn to:
- Understand FSM fundamentals — states, transitions, and outputs  
- Design **Moore** and **Mealy** machines using behavioral modeling  
- Implement FSMs for **sequence detection** and **control applications**  
- Verify operation using simulation and waveform analysis  

---

## ⚙️ 2. Equipment and Tools
| Tool / Resource | Description |
|------------------|-------------|
| **Vivado / Quartus / ModelSim** | For coding, simulation, and waveform analysis |
| **FPGA Board (Basys 3 / Nexys A7)** | Optional hardware implementation |
| **Text Editor / IDE** | VS Code, Vivado Editor |
| **System Tasks** | `$monitor`, `$display`, `$dumpfile`, `$dumpvars` |

---

## 🧠 3. Background Theory
Finite State Machines (FSMs) are **sequential systems** that change their state depending on input conditions and clock signals.  

FSMs are categorized as:

| FSM Type | Output Depends On | Example |
|-----------|------------------|----------|
| **Moore Machine** | Present state only | Traffic light controller |
| **Mealy Machine** | Present state + inputs | Sequence detector |

FSMs are used in:
- Digital controllers  
- Communication interfaces  
- Vending machines  
- Sequence detectors  
- Data path controllers  

---

### 3.1 Moore FSM Example — 2-Bit Gray Code Generator

**State Diagram**

| State | Output (Q1 Q0) | Next State (Clock ↑) |
|:------|:----------------|:---------------------|
| S0 | 00 | S1 |
| S1 | 01 | S2 |
| S2 | 11 | S3 |
| S3 | 10 | S0 |

**Verilog Code**
```verilog
module GrayCounter(input clk, rst, output reg [1:0] gray);
  reg [1:0] state;
  parameter S0 = 2'b00, S1 = 2'b01, S2 = 2'b11, S3 = 2'b10;

  always @(posedge clk or posedge rst)
    if (rst)
      state <= S0;
    else
      case (state)
        S0: state <= S1;
        S1: state <= S2;
        S2: state <= S3;
        S3: state <= S0;
      endcase

  always @(*)
    gray = state;
endmodule
```

**Testbench**
```verilog
module tb_GrayCounter;
  reg clk, rst;
  wire [1:0] gray;

  GrayCounter uut (.clk(clk), .rst(rst), .gray(gray));

  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    $dumpfile("GrayCounter.vcd");
    $dumpvars(0, tb_GrayCounter);
    rst = 1; #10 rst = 0;
    #100 $finish;
  end
endmodule
```

---

### 3.2 Mealy FSM Example — Sequence Detector (“101”)

**Behavior:** Output `z = 1` when input sequence `101` is detected.

**State Diagram**

| State | Input=0 | Input=1 | Output |
|:------|:--------|:--------|:--------|
| S0 | S0 | S1 | 0 |
| S1 | S2 | S1 | 0 |
| S2 | S0 | S3 | 0 |
| S3 | S1 | S0 | 1 |

**Verilog Code**
```verilog
module SeqDetector_101(input clk, rst, x, output reg z);
  reg [1:0] state, next;
  parameter S0=2'b00, S1=2'b01, S2=2'b10, S3=2'b11;

  always @(posedge clk or posedge rst)
    if (rst) state <= S0;
    else     state <= next;

  always @(*) begin
    z = 0;
    case (state)
      S0: next = x ? S1 : S0;
      S1: next = x ? S1 : S2;
      S2: next = x ? S3 : S0;
      S3: begin
        z = 1;
        next = x ? S1 : S0;
      end
    endcase
  end
endmodule
```

**Testbench**
```verilog
module tb_SeqDetector_101;
  reg clk, rst, x;
  wire z;

  SeqDetector_101 uut (.clk(clk), .rst(rst), .x(x), .z(z));

  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    $dumpfile("SeqDetector_101.vcd");
    $dumpvars(0, tb_SeqDetector_101);
    rst = 1; #10 rst = 0;
    x = 0; #10;
    x = 1; #10;
    x = 0; #10;
    x = 1; #10;
    x = 1; #10;
    x = 0; #10;
    $finish;
  end
endmodule
```

---

## 🧮 4. Experiment Procedure
1. Create a new Verilog project.  
2. Write code for the **Moore Gray Counter** and **Mealy Sequence Detector**.  
3. Develop corresponding **testbenches**.  
4. Simulate and observe **state transitions** using waveform viewer.  
5. Compare results with theoretical **state diagrams**.  
6. Modify the sequence detector to detect **“1101”**.  

---

## 📊 5. Observation Table

### Gray Code Generator (Moore FSM)
| Clock | State (Q1Q0) | Output |
|:------|:--------------|:--------|
| 0 | 00 | 00 |
| 1 | 01 | 01 |
| 2 | 11 | 11 |
| 3 | 10 | 10 |

### Sequence Detector (Mealy FSM)
| Input (x) | State | Output (z) |
|:-----------|:------|:-----------|
| 1 | S1 | 0 |
| 0 | S2 | 0 |
| 1 | S3 | 1 |

---

## 💡 6. Discussion Points
- Difference between **Moore** and **Mealy** FSM outputs  
- Use of **parameter encoding** for states  
- How simulation timing reflects **state transitions**  
- Advantages of **FSM-based control logic** in FPGA design  

---

## 🧠 7. Post-Lab Exercises
1. Modify the sequence detector to detect **“1100”** pattern.  
2. Design a **traffic light controller FSM**.  
3. Implement a **vending machine controller** for coins (1, 2, 5).  
4. Use **one-hot encoding** for FSM states and compare resource usage.  

---

## 🧾 8. Outcome
Students will be able to:
- Model and simulate **Moore and Mealy FSMs** using Verilog HDL.  
- Interpret and construct **state diagrams** and **transition tables**.  
- Understand **state encoding** and **output dependencies**.  
- Apply FSM concepts to **real-world digital control problems**.  

---

## 📘 9. References
1. Samir Palnitkar, *Verilog HDL: A Guide to Digital Design and Synthesis*, Pearson  
2. Pong P. Chu, *FPGA Prototyping by Verilog Examples*, Wiley  
3. IEEE Std 1364-2005, *Verilog Hardware Description Language*  
4. Xilinx Vivado, *Finite State Machine Design Guide*  

---

**Author:** Dr. Komsan Kanjanasit  
**Publisher:** College of Computing, Prince of Songkla University, Thailand  
**Edition:** First Edition (2025)  
**License:** CC BY 4.0 — Free to use with attribution
