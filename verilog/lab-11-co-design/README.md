# 🔬 Lab 11: Hardware–Software Co-Design and FPGA System Integration

## 🧩 1. Objective
This laboratory introduces **hardware/software partitioning** in embedded FPGA systems.  
Students will:
- Integrate **Verilog modules** with a software controller (C or Python host).  
- Design and simulate an **AXI-Lite-style interface** for hardware control.  
- Perform **register-level communication** between CPU and FPGA logic.  
- Explore how **firmware commands configure or monitor** FPGA subsystems.  

---

## ⚙️ 2. Equipment and Tools
| Tool / Resource | Description |
|------------------|-------------|
| **Vivado / Quartus + ModelSim** | HDL synthesis and simulation |
| **Verilator or Co-simulation tool** | Software ↔ hardware interface |
| **C compiler / Python host** | Control software development |
| **FPGA board (Basys 3 / Nexys A7)** | Hardware testing |
| **UART terminal / USB JTAG** | Communication with host |

---

## 🧠 3. Background Theory

### 3.1 Hardware/Software Co-Design
**Co-design** divides the system into two complementary domains:

| Domain | Description |
|:--------|:-------------|
| **Hardware (FPGA)** | Executes high-speed, parallel logic (ALU, PWM, DMA, etc.) |
| **Software (Processor / PC)** | Handles control, configuration, and visualization |

**Communication methods:**
- Memory-mapped registers  
- UART commands  
- AXI-Lite bus transactions  

### 3.2 Typical Architecture
```
      ┌───────────────────────────┐
      │          HOST PC          │
      │  C/Python Control Program │
      │   e.g., send UART cmds    │
      └────────────┬──────────────┘
                   │  Serial/AXI
      ┌────────────▼──────────────┐
      │         FPGA SoC          │
      │  ┌──────────────┐         │
      │  │ AXI-Lite IF │◄────────┤
      │  ├──────────────┤         │
      │  │ Custom IP (ALU, PWM) │ │
      │  ├──────────────┤         │
      │  │ GPIO / UART │          │
      └───────────────────────────┘
```

---

## ⚙️ 4. Verilog Implementation

### 4.1 Memory-Mapped Register Interface
```verilog
module HW_Interface (
  input  clk, rst,
  input  [7:0] addr,
  input  [7:0] din,
  output reg [7:0] dout,
  input  we, re
);
  reg [7:0] regA, regB, result;

  always @(posedge clk or posedge rst)
    if (rst)
      {regA, regB, result} <= 0;
    else if (we) begin
      case (addr)
        8'h00: regA <= din;
        8'h01: regB <= din;
        8'h02: result <= regA + regB;
      endcase
    end

  always @(*) begin
    case (addr)
      8'h00: dout = regA;
      8'h01: dout = regB;
      8'h02: dout = result;
      default: dout = 8'h00;
    endcase
  end
endmodule
```

---

### 4.2 UART Command Parser (Controller)
```verilog
module UART_Command (
  input clk, rst,
  input rx,
  output tx,
  output [7:0] gpio
);
  reg [7:0] rx_data;
  wire [7:0] tx_data;
  reg tx_start, we, re;
  reg [7:0] addr, din;
  wire [7:0] dout;

  UART_RX #(50000000,9600) RX1 (.clk(clk), .rst(rst), .rx(rx), .data_out(rx_data));
  UART_TX #(50000000,9600) TX1 (.clk(clk), .rst(rst), .tx_start(tx_start), .data_in(tx_data), .tx(tx));

  HW_Interface core (.clk(clk), .rst(rst), .addr(addr), .din(din), .dout(dout), .we(we), .re(re));

  assign gpio = dout;

  always @(posedge clk) begin
    // simple protocol: upper nibble = addr, lower nibble = data
    addr <= rx_data[7:4];
    din  <= {4'b0000, rx_data[3:0]};
    we   <= 1;
    tx_start <= 1;
  end
endmodule
```

---

### 4.3 Host-Side Control (Simplified C Program)
```c
#include <stdio.h>
#include "serial.h"

int main() {
    init_serial("/dev/ttyUSB0", 9600);
    printf("Writing to FPGA register...\n");
    send_byte(0x01);   // Write to regB
    send_byte(0x20);   // Write to regA
    send_byte(0x30);   // Trigger addition
    printf("Result fetched from FPGA.\n");
}
```

---

## 🧮 5. Experiment Procedure
1. Create a new FPGA project with **HW_Interface** and **UART_Command** modules.  
2. Simulate UART transactions in ModelSim or Vivado.  
3. Connect FPGA via USB and test using C or Python host commands.  
4. Observe **LED or 7-segment display outputs**.  
5. Validate communication between **software and hardware**.  

---

## 📊 6. Observation Table
| Operation | Sent Byte | FPGA Register Action | Observed Output |
|:-----------|:----------|:--------------------|:----------------|
| Write RegA | 0x10 | regA ← 0x0 | Stored value |
| Write RegB | 0x11 | regB ← 0x1 | Stored value |
| Execute ADD | 0x30 | result ← regA + regB | Sum displayed |

---

## 💡 7. Discussion Points
- How does **software communicate** with Verilog logic?  
- Why are **memory-mapped registers** effective for hardware control?  
- How do **handshake signals** (e.g., `tx_busy`, `rx_ready`) prevent data loss?  
- Compare **software polling** vs **interrupt-driven** communication.  

---

## 🧠 8. Post-Lab Exercises
1. Add **multiply/divide** operations in hardware.  
2. Implement a **PWM peripheral** controlled by register values.  
3. Extend the **UART protocol** to include readback capability.  
4. Replace UART with **AXI-Lite bus** for soft CPU (MicroBlaze/Nios II).  
5. Develop a **Python GUI** to visualize FPGA registers in real time.  

---

## 🧾 9. Outcome
Students will be able to:
- Integrate **hardware and software** modules in a co-design environment.  
- Design a **custom hardware accelerator** accessible from host software.  
- Simulate and test **register-level transactions** via serial or AXI interface.  
- Understand **system-level verification** for FPGA SoC integration.  

---

## 📘 10. References
1. Samir Palnitkar, *Verilog HDL: A Guide to Digital Design and Synthesis*, Pearson  
2. Pong P. Chu, *FPGA Prototyping by Verilog Examples*, Wiley  
3. Xilinx, *AXI4-Lite Interface Specification*  
4. Intel FPGA, *Hardware/Software Co-Design Using Nios II*  
5. B. Karam, *FPGA-Based System Design Methodology*  

---

**Author:** Dr. Komsan Kanjanasit  
**Publisher:** College of Computing, Prince of Songkla University, Thailand  
**Edition:** First Edition (2025)  
**License:** CC BY 4.0 — Free to use with attribution
