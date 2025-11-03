# 🔬 Lab 13: Reconfigurable Hardware System and Advanced Verification in Verilog HDL

## 🧩 1. Objective
This laboratory develops advanced FPGA design skills for **dynamic reconfiguration**, **hardware verification**, and **timing optimization**.  
Students will:
- Implement **partial reconfiguration** for hardware modules.  
- Create **self-checking testbenches** for functional validation.  
- Measure **timing performance and resource utilization**.  
- Understand **runtime hardware switching** between accelerators.  

---

## ⚙️ 2. Equipment and Tools
| Tool / Resource | Description |
|------------------|-------------|
| **Vivado Design Suite** | Supports Dynamic Partial Reconfiguration (DPR) |
| **ModelSim / Vivado Simulator** | Verification and waveform analysis |
| **Basys 3 / Nexys A7 FPGA Board** | Hardware validation |
| **Power Analyzer / Timing Report** | Performance evaluation |
| **Python/C Host Script** | Reconfiguration control |

---

## 🧠 3. Background Theory

### 3.1 Dynamic Partial Reconfiguration (DPR)
Partial reconfiguration allows an FPGA to **modify a specific hardware block at runtime** while the rest of the system continues to operate.

**Example:** Switch between two accelerators (e.g., Multiply–Accumulate vs FIR Filter) without resetting the SoC.

### 3.2 Verification Hierarchy
Verification ensures correctness at multiple levels:
| Level | Description |
|--------|--------------|
| **Unit level** | Tests individual modules (e.g., ALU, MAC) |
| **Integration level** | Verifies communication between subsystems |
| **System level** | Validates entire SoC with host software |

**Self-checking testbenches** enable automation, repeatability, and automatic pass/fail detection.

---

## ⚙️ 4. Verilog Implementations

### 4.1 Reconfigurable Accelerator Wrapper
```verilog
module Accelerator_Shell (
  input clk, rst,
  input [1:0] select,           // 00 = MAC, 01 = FIR
  input [7:0] A, B,
  output reg [15:0] result
);
  wire [15:0] mac_result, fir_result;

  MAC_Accelerator mac(.clk(clk), .rst(rst), .A(A), .B(B), .result(mac_result));
  FIR_Accelerator fir(.clk(clk), .rst(rst), .A(A), .result(fir_result));

  always @(*)
    case(select)
      2'b00: result = mac_result;
      2'b01: result = fir_result;
      default: result = 0;
    endcase
endmodule
```

---

### 4.2 FIR Filter Accelerator
```verilog
module FIR_Accelerator (
  input clk, rst,
  input [7:0] A,
  output reg [15:0] result
);
  parameter N = 4;
  reg [7:0] delay [0:N-1];
  reg [7:0] coeff [0:N-1];
  integer i;

  initial begin
    coeff[0]=1; coeff[1]=2; coeff[2]=2; coeff[3]=1;
  end

  always @(posedge clk or posedge rst)
    if (rst) begin
      for(i=0;i<N;i=i+1) delay[i]<=0;
      result<=0;
    end else begin
      delay[0]<=A;
      for(i=1;i<N;i=i+1) delay[i]<=delay[i-1];
      result <= (coeff[0]*delay[0]) + (coeff[1]*delay[1]) +
                (coeff[2]*delay[2]) + (coeff[3]*delay[3]);
    end
endmodule
```

---

### 4.3 Self-Checking Testbench
```verilog
module tb_Reconfigurable_Accelerator;
  reg clk, rst;
  reg [1:0] select;
  reg [7:0] A, B;
  wire [15:0] result;

  Accelerator_Shell uut (.clk(clk), .rst(rst), .select(select), .A(A), .B(B), .result(result));

  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    $dumpfile("Reconfigurable.vcd");
    $dumpvars(0, tb_Reconfigurable_Accelerator);
    rst=1; select=2'b00; A=0; B=0; #10;
    rst=0; A=10; B=5; #10;             // MAC mode
    if (result != 50) $display("❌ MAC Test Failed"); else $display("✅ MAC OK");

    select=2'b01; A=8; #20;            // FIR mode
    if (result == 0) $display("❌ FIR Test Failed"); else $display("✅ FIR OK");
    #20 $finish;
  end
endmodule
```

---

## 🧮 5. Experiment Procedure
1. Implement both **MAC** and **FIR** accelerators in the project.  
2. Configure **partial reconfigurable regions** in Vivado (PR Flow).  
3. Generate **bitstreams** for each configuration.  
4. Simulate using the provided **self-checking testbench**.  
5. Load different bitstreams dynamically to verify **runtime switching**.  

---

## 📊 6. Observation Table
| Mode | Accelerator | Input A | Input B | Output | Status |
|------|--------------|---------|---------|---------|---------|
| 00 | MAC | 10 | 5 | 50 | ✅ |
| 01 | FIR | 8 | – | 40 | ✅ |

---

## 💡 7. Discussion Points
- How does **partial reconfiguration** improve FPGA resource efficiency?  
- Why are **self-checking testbenches** crucial for design verification?  
- Discuss trade-offs between **static vs. reconfigurable** designs.  
- How can this technique benefit **AI inference or edge computing** systems?  

---

## 🧠 8. Post-Lab Exercises
1. Add a **Convolution Accelerator** as a third reconfigurable module.  
2. Extend the testbench for **automated multi-mode testing**.  
3. Implement **CRC verification** of partial bitstreams.  
4. Perform **timing and power analysis** for each configuration.  
5. Create a **Python GUI** to trigger FPGA reconfiguration via serial commands.  

---

## 🧾 9. Outcome
Students will be able to:
- Implement **dynamic reconfiguration** on FPGA.  
- Design and verify **reconfigurable accelerators** using Verilog HDL.  
- Automate **verification through self-checking testbenches**.  
- Analyze **resource, timing, and energy trade-offs** in adaptive SoCs.  

---

## 📘 10. References
1. Xilinx, *Partial Reconfiguration User Guide (UG909)*  
2. Pong P. Chu, *FPGA Prototyping by Verilog Examples*  
3. Samir Palnitkar, *Verilog HDL: A Guide to Digital Design and Synthesis*  
4. D. Harris & S. Harris, *Digital Design and Computer Architecture*  
5. IEEE Std 1800-2017, *SystemVerilog Language Reference Manual*  

---

**Author:** Dr. Komsan Kanjanasit  
**Publisher:** College of Computing, Prince of Songkla University, Thailand  
**Edition:** First Edition (2025)  
**License:** CC BY 4.0 — Free to use with attribution
