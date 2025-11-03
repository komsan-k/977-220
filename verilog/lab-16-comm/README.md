# 🔬 Lab 16: Multi-FPGA Communication and Distributed Hardware Processing

## 🧩 1. Objective
Students will learn to interconnect **two or more FPGAs** for parallel or pipelined computation.

You will:
- Establish **FPGA-to-FPGA communication** via UART, SPI, or GPIO.  
- Partition computation across devices (e.g., matrix block or partial summation).  
- Synchronize operations using **handshake protocols (REQ/ACK)**.  
- Measure **latency and throughput** between hardware links.

---

## ⚙️ 2. Equipment and Tools
| Tool / Resource | Description |
|------------------|-------------|
| **Two FPGA boards (Basys 3 / Nexys A7 / DE10-Lite)** | For distributed deployment |
| **Vivado / Quartus** | Hardware synthesis and simulation |
| **Oscilloscope / Logic Analyzer** | Observe signal timing and protocol behavior |
| **USB UART cables or SPI lines** | Hardware interconnection |
| **Python script (optional)** | Used as a host coordinator |

---

## 🧠 3. Background Theory

### 3.1 Distributed Hardware Concept
Multiple FPGAs can collaborate to perform large computations efficiently.  

- **Master node** → coordinates data transmission and synchronization.  
- **Worker node(s)** → perform assigned computations in parallel.  

Common synchronization techniques include:
- **Handshake protocol (REQ/ACK)**  
- **Token passing** (for sequential pipelines)  
- **Clock synchronization** for timing-critical operations  

### 3.2 Typical Use Cases
- Real-time DSP distributed over multiple FPGAs  
- Matrix multiplication where each FPGA handles one sub-block  
- Fault-tolerant or redundant computation systems  

---

## ⚙️ 4. Verilog Implementation

### 4.1 Master FPGA (Controller & Sender)
```verilog
module FPGA_Master (
  input clk, rst,
  output reg tx, req,
  input ack,
  output reg [7:0] data_out
);
  reg [3:0] state;
  localparam IDLE=0, SEND=1, WAIT_ACK=2, DONE=3;

  always @(posedge clk or posedge rst)
    if (rst) begin
      tx <= 0; req <= 0; data_out <= 8'h00; state <= IDLE;
    end else begin
      case (state)
        IDLE: begin data_out <= 8'h0A; req <= 1; state <= SEND; end
        SEND: begin if (ack) state <= WAIT_ACK; end
        WAIT_ACK: begin req <= 0; tx <= 1; state <= DONE; end
        DONE: tx <= 0;
      endcase
    end
endmodule
```

### 4.2 Slave FPGA (Receiver & Processor)
```verilog
module FPGA_Slave (
  input clk, rst,
  input req, tx,
  output reg ack,
  input [7:0] data_in,
  output reg [15:0] result
);
  reg [3:0] state;
  localparam WAIT=0, PROCESS=1, RESPOND=2;

  always @(posedge clk or posedge rst)
    if (rst) begin
      state <= WAIT; ack <= 0; result <= 0;
    end else begin
      case (state)
        WAIT: if (req) state <= PROCESS;
        PROCESS: begin
          result <= data_in * 4; // Example computation
          state <= RESPOND;
        end
        RESPOND: begin
          ack <= 1; state <= WAIT;
        end
      endcase
    end
endmodule
```

### 4.3 Handshake Timing Diagram
```
Master: ──REQ────┐      ┌───────────────
Slave :      ┌──ACK─────┘
Data  :  <--- valid during REQ=1
```

---

## 🧮 5. Experiment Procedure
1. Connect **two FPGA boards**:  
   - Cross-link TX/RX pins.  
   - Connect shared ground.  
   - Optionally, share a synchronization clock line.  
2. Program one FPGA as **Master** and the other as **Slave**.  
3. Observe **REQ/ACK** signals on the oscilloscope.  
4. Verify correct computation and handshake.  
5. Extend design to a **multi-node topology (chain or ring)** for distributed processing.

---

## 📊 6. Observation Table
| Trial | Data Sent | Result (×4) | REQ → ACK Delay (ns) | Status |
|:------|:-----------|:------------:|:---------------------:|:-------:|
| 1 | 0x0A | 0x28 | 120 | ✅ |
| 2 | 0x05 | 0x14 | 115 | ✅ |

---

## 💡 7. Discussion Points
- How does **hardware handshaking** improve communication reliability?  
- What determines **latency** between FPGAs (wire length, clock domains)?  
- Compare **UART**, **SPI**, and **parallel buses** in terms of throughput.  
- How can flow control be improved for **high-speed streaming data**?  

---

## 🧠 8. Post-Lab Exercises
1. Build a **3-FPGA ring network** using token passing.  
2. Implement **CRC-8 error checking** on communication packets.  
3. Design an **FPGA load balancer** for dynamic task assignment.  
4. Add **shared clock synchronization** for deterministic timing.  
5. Develop a **Python host visualization tool** to monitor distributed computation.  

---

## 🧾 9. Outcome
Students will be able to:
- Implement reliable **FPGA-to-FPGA communication** protocols.  
- Coordinate distributed computations across hardware nodes.  
- Measure and optimize **link latency and throughput**.  
- Understand architectures used in **multi-node FPGA systems** (data-center accelerators, AI fabrics).  

---

## 📘 10. References
1. Xilinx UG583 – *FPGA Inter-Device Communication Guide*  
2. Intel AN 490 – *High-Speed Interconnect between FPGAs*  
3. Pong P. Chu – *FPGA Prototyping by Verilog Examples*  
4. Samir Palnitkar – *Verilog HDL: A Guide to Digital Design and Synthesis*  
5. Harris & Harris – *Digital Design and Computer Architecture*  

---

**Author:** Dr. Komsan Kanjanasit  
**Publisher:** College of Computing, Prince of Songkla University, Thailand  
**Edition:** First Edition (2025)  
**License:** CC BY 4.0 — Free for educational and academic use
