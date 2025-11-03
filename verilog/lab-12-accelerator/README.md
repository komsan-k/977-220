# 🔬 Lab 12: Hardware Accelerator Design and Integration with SoC

## 🧩 1. Objective
Students will learn to design, implement, and integrate a **hardware accelerator** into an existing SoC using Verilog HDL.  
They will:
- Create a **custom processing module** (e.g., multiply–accumulate unit).  
- Interface it through a **memory-mapped register interface**.  
- Control and monitor the accelerator from **software (C or Python)**.  
- Validate **performance improvement** over pure software execution.  

---

## ⚙️ 2. Equipment and Tools
| Tool / Resource | Description |
|------------------|-------------|
| **Vivado / Quartus / ModelSim** | HDL simulation & synthesis |
| **FPGA board (Basys 3 / Nexys A7)** | Hardware prototyping |
| **UART / AXI-Lite Interface** | Host communication |
| **C / Python host script** | Accelerator control |
| **Waveform viewer** | Timing verification |

---

## 🧠 3. Background Theory
A **hardware accelerator** performs specific computational tasks faster than software by exploiting FPGA parallelism.

### Typical Accelerator Examples
- Multiply–Accumulate (MAC)  
- FIR or IIR digital filters  
- Matrix–vector multipliers  
- Neural-network layers (dot product)

### System Flow
```
Software (C/Python)
   │
   ▼
Command/Registers (AXI-Lite / UART)
   │
   ▼
FPGA Accelerator (Verilog)
   ├── Input Buffers
   ├── Compute Engine
   └── Output Registers
```

---

## ⚙️ 4. Verilog Implementation

### 4.1 Accelerator Core – Multiply–Accumulate Unit
```verilog
module MAC_Accelerator (
  input clk, rst, start,
  input [7:0] A, B,
  output reg [15:0] result,
  output reg done
);
  reg [15:0] acc;

  always @(posedge clk or posedge rst)
    if (rst) begin
      acc <= 0;
      done <= 0;
    end else if (start) begin
      acc <= acc + (A * B);
      done <= 1;
    end else
      done <= 0;

  always @(*) result = acc;
endmodule
```

---

### 4.2 Memory-Mapped Interface for Accelerator
```verilog
module MAC_Interface (
  input clk, rst,
  input [7:0] addr,
  input [7:0] din,
  output reg [15:0] dout,
  input we, re
);
  reg [7:0] A, B;
  reg start;
  wire done;
  wire [15:0] result;

  MAC_Accelerator mac (.clk(clk), .rst(rst), .start(start),
                       .A(A), .B(B), .result(result), .done(done));

  always @(posedge clk or posedge rst)
    if (rst)
      {A, B, start} <= 0;
    else if (we) begin
      case(addr)
        8'h00: A <= din;
        8'h01: B <= din;
        8'h02: start <= 1'b1;
        default: start <= 1'b0;
      endcase
    end

  always @(*) begin
    case(addr)
      8'h10: dout = result;
      default: dout = 0;
    endcase
  end
endmodule
```

---

### 4.3 Top-Level SoC Integration
```verilog
module SoC_with_MAC (
  input clk, rst,
  input [7:0] addr, din,
  input we, re,
  output [15:0] dout
);
  wire sel_mac;
  assign sel_mac = (addr[7:4] == 4'h3); // 0x30–0x3F reserved for MAC

  MAC_Interface mac_if (.clk(clk), .rst(rst), .addr(addr),
                        .din(din), .we(we & sel_mac), .re(re),
                        .dout(dout));
endmodule
```

---

### 4.4 Software Control (Python Example)
```python
import serial, time
ser = serial.Serial('COM3', 9600)

def write(addr, val):
    ser.write(bytes([addr, val]))

def read(addr):
    ser.write(bytes([addr | 0x80]))  # Read flag
    return int.from_bytes(ser.read(2), 'little')

# Example: Multiply 15 × 5 and accumulate
write(0x30, 15)  # A
write(0x31, 5)   # B
write(0x32, 1)   # Start
time.sleep(0.1)
res = read(0x40) # Result register
print("Result =", res)
```

---

## 🧮 5. Experiment Procedure
1. Create a new project and include `MAC_Accelerator`, `MAC_Interface`, and top-level `SoC_with_MAC`.  
2. Write a testbench to verify multiply–accumulate behavior.  
3. Simulate waveforms for **start**, **done**, and **result** signals.  
4. Program the FPGA and connect via **UART/Python** script.  
5. Compare **hardware vs. software computation time**.  

---

## 📊 6. Observation Table
| Cycle | A | B | Start | Result | Done | Comment |
|:------|:-:|:-:|:------:|:-------:|:-----:|:----------|
| 1 | 15 | 5 | 1 | 75 | 1 | MAC executed |
| 2 | 2 | 3 | 1 | 81 | 1 | Accumulated |
| 3 | 0 | 0 | 0 | 81 | 0 | Idle |

---

## 💡 7. Discussion Points
- Why is the **hardware multiplier** faster than software loops?  
- How does the **start/done handshake** synchronize CPU and accelerator?  
- How can **pipelining** improve throughput?  
- What **FPGA resources** (DSP slices, LUTs) are used for multiplication?  

---

## 🧠 8. Post-Lab Exercises
1. Add **pipelined multiplication** with ready/valid signals.  
2. Expand MAC to support **vector dot products**.  
3. Implement a **fixed-point FIR filter** using the accelerator.  
4. Replace UART with an **AXI4-Lite interface** for MicroBlaze/Nios II integration.  
5. Measure **latency improvement** compared to software-only computation.  

---

## 🧾 9. Outcome
Students will be able to:
- Design and integrate a **custom FPGA accelerator**.  
- Interface hardware logic through **memory-mapped registers**.  
- Perform **host-controlled computation** via UART or AXI bus.  
- Evaluate **hardware acceleration performance** in SoC environments.  

---

## 📘 10. References
1. Pong P. Chu, *FPGA Prototyping by Verilog Examples*  
2. Samir Palnitkar, *Verilog HDL: A Guide to Digital Design and Synthesis*  
3. Xilinx Docs: *Vivado Designing Custom AXI IP Accelerators*  
4. Harris & Harris, *Digital Design and Computer Architecture*  

---

**Author:** Dr. Komsan Kanjanasit  
**Publisher:** College of Computing, Prince of Songkla University, Thailand  
**Edition:** First Edition (2025)  
**License:** CC BY 4.0 — Free to use with attribution
