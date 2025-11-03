# 🔬 Lab 9: Finite Datapath and Control Unit Integration — Mini CPU Design in Verilog HDL

## 🧩 1. Objective
This laboratory introduces the integration of **datapath and control logic** to form a minimal CPU system.  
Students will:
- Design a **datapath** containing registers, ALU, and memory.  
- Implement a **control unit (FSM)** to sequence operations.  
- Understand **instruction execution flow** (fetch → decode → execute → store).  
- Verify CPU operation via **simulation and waveform observation**.  

---

## ⚙️ 2. Equipment and Tools
| Tool / Resource | Description |
|------------------|-------------|
| **Vivado / Quartus / ModelSim** | HDL compiler and simulator |
| **FPGA Board (Basys 3 / Nexys A7)** | Optional hardware testing |
| **Text Editor / IDE** | VS Code or Vivado |
| **System Tasks** | `$display`, `$monitor`, `$dumpfile`, `$dumpvars` |

---

## 🧠 3. Background Theory
A **CPU (Central Processing Unit)** consists of two major subsystems:

| Component | Description |
|------------|-------------|
| **Datapath** | Performs operations (ALU, registers, multiplexers, buses). |
| **Control Unit** | Generates control signals for the datapath (FSM-driven). |

A typical single-cycle CPU performs operations in several stages:
1. **Fetch** — Load instruction from memory.  
2. **Decode** — Interpret opcode and operands.  
3. **Execute** — Perform ALU or memory operation.  
4. **Writeback** — Store result to register or memory.  

---

## 🧩 4. Datapath Design

### 4.1 ALU (From Lab 6, Reused)
```verilog
module ALU_8bit (
  input [7:0] A, B,
  input [3:0] ALU_Sel,
  output reg [7:0] ALU_Out
);
  always @(*) begin
    case(ALU_Sel)
      4'b0000: ALU_Out = A + B;  // ADD
      4'b0001: ALU_Out = A - B;  // SUB
      4'b0010: ALU_Out = A & B;  // AND
      4'b0011: ALU_Out = A | B;  // OR
      4'b0100: ALU_Out = A ^ B;  // XOR
      default: ALU_Out = 8'h00;
    endcase
  end
endmodule
```

---

### 4.2 Register File (2 Registers)
```verilog
module RegFile_2x8(
  input clk, rst, we,
  input [7:0] data_in,
  input sel,                // 0 for R0, 1 for R1
  output reg [7:0] R0, R1
);
  always @(posedge clk or posedge rst)
    if (rst)
      {R0, R1} <= 16'b0;
    else if (we)
      if (sel) R1 <= data_in;
      else     R0 <= data_in;
endmodule
```

---

### 4.3 Simple Instruction Memory (ROM)
```verilog
module InstrROM(
  input [3:0] addr,
  output reg [7:0] instr
);
  always @(*)
    case (addr)
      4'b0000: instr = 8'b00000001; // LOAD R0, 1
      4'b0001: instr = 8'b00010010; // LOAD R1, 2
      4'b0010: instr = 8'b00100000; // ADD R0, R1
      4'b0011: instr = 8'b01000000; // OUT R0
      default: instr = 8'b00000000;
    endcase
endmodule
```

---

## ⚙️ 5. Control Unit (FSM)
```verilog
module ControlUnit(
  input clk, rst,
  output reg [1:0] state
);
  parameter FETCH=2'b00, DECODE=2'b01, EXECUTE=2'b10, WRITEBACK=2'b11;

  always @(posedge clk or posedge rst)
    if (rst)
      state <= FETCH;
    else
      case(state)
        FETCH:    state <= DECODE;
        DECODE:   state <= EXECUTE;
        EXECUTE:  state <= WRITEBACK;
        WRITEBACK:state <= FETCH;
      endcase
endmodule
```

---

## ⚙️ 6. Top-Level CPU Integration
```verilog
module MiniCPU(input clk, rst);
  wire [7:0] instr, alu_out;
  wire [1:0] state;
  reg [3:0] pc;
  reg [7:0] R0, R1;

  InstrROM rom (.addr(pc), .instr(instr));
  ALU_8bit alu (.A(R0), .B(R1), .ALU_Sel(instr[3:0]), .ALU_Out(alu_out));
  ControlUnit cu (.clk(clk), .rst(rst), .state(state));

  always @(posedge clk or posedge rst) begin
    if (rst) pc <= 0;
    else pc <= pc + 1;
  end

  always @(posedge clk)
    if (state == 2'b10) // EXECUTE
      R0 <= alu_out;
endmodule
```

**Testbench**
```verilog
module tb_MiniCPU;
  reg clk, rst;
  MiniCPU uut (.clk(clk), .rst(rst));

  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    $dumpfile("MiniCPU.vcd");
    $dumpvars(0, tb_MiniCPU);
    rst = 1; #10; rst = 0;
    #200 $finish;
  end
endmodule
```

---

## 🧮 7. Experiment Procedure
1. Create a new project in your HDL tool.  
2. Implement **ALU**, **Register File**, **ROM**, **Control Unit**, and **Top-Level CPU**.  
3. Connect datapath and control signals.  
4. Simulate and analyze instruction flow using waveform viewer.  
5. Verify program execution through `$display` outputs.  

---

## 📊 8. Observation Table
| Cycle | State | PC | Instruction | R0 | R1 | ALU_Out | Operation |
|:------|:------|:--:|:------------|:--:|:--:|:--------:|:-----------|
| 1 | FETCH | 0 | LOAD R0, 1 | 0 | 0 | - | - |
| 2 | DECODE | 1 | LOAD R1, 2 | 1 | 0 | - | - |
| 3 | EXECUTE | 2 | ADD R0, R1 | 1 | 2 | 3 | ADD |
| 4 | WRITEBACK | 3 | OUT R0 | 3 | 2 | - | Output |

---

## 💡 9. Discussion Points
- How do FSM states synchronize datapath operations?  
- Explain the interaction between **ROM**, **ALU**, and **registers**.  
- How does this resemble a **single-cycle CPU** architecture?  
- What are the limitations of this simplified design?  

---

## 🧠 10. Post-Lab Exercises
1. Add **SUB** and **AND** instructions to the instruction set.  
2. Implement a **memory load/store stage** using RAM.  
3. Extend the **program counter** to 8 bits for larger programs.  
4. Design a **two-stage pipeline** (Fetch + Execute).  
5. Visualize CPU execution using simulation waveforms.  

---

## 🧾 11. Outcome
Students will be able to:
- Integrate **datapath and control logic** using Verilog HDL.  
- Simulate **instruction execution** and timing behavior.  
- Understand the **fetch–decode–execute** cycle.  
- Implement a functional **Mini CPU** suitable for FPGA demonstration.  

---

## 📘 12. References
1. Samir Palnitkar, *Verilog HDL: A Guide to Digital Design and Synthesis*, Pearson  
2. Pong P. Chu, *FPGA Prototyping by Verilog Examples*, Wiley  
3. David Harris & Sarah Harris, *Digital Design and Computer Architecture*, Morgan Kaufmann  
4. IEEE Std 1364-2005, *Verilog Hardware Description Language*  

---

**Author:** Dr. Komsan Kanjanasit  
**Publisher:** College of Computing, Prince of Songkla University, Thailand  
**Edition:** First Edition (2025)  
**License:** CC BY 4.0 — Free to use with attribution
