# 🔬 Lab 17: FPGA Network Interface and Remote Hardware Virtualization

## 🧩 1. Objective
This laboratory focuses on connecting **FPGA hardware** to a **network stack** and exposing its computational resources remotely through **TCP/IP or UDP** communication.

Students will learn to:
- Implement **Ethernet MAC/UDP/TCP** communication on FPGA.
- Design a **hardware virtualization layer** for remote command execution.
- Invoke FPGA computation from a host PC or cloud client.
- Analyze **latency, throughput, and network overhead**.

---

## ⚙️ 2. Equipment and Tools
| Tool / Resource | Description |
|------------------|-------------|
| **FPGA board with Ethernet port (Nexys A7 / PYNQ-Z2 / Zybo Z7)** | Hardware platform for testing |
| **Vivado / Quartus / LiteX / Vitis HLS** | FPGA synthesis and design tools |
| **Python (socket, struct, time)** | Host communication scripts |
| **Wireshark / Logic Analyzer** | Network monitoring tools |
| **Ethernet crossover or LAN** | Physical connection for data transfer |

---

## 🧠 3. Background Theory

### 3.1 FPGA Network Communication
Modern FPGAs include **Ethernet PHY/MAC blocks** that enable direct network communication through lightweight IP cores (LWIP).  

Protocols:
- **UDP (User Datagram Protocol)** → fast, low-latency communication.  
- **TCP (Transmission Control Protocol)** → reliable and ordered data transfer.

### 3.2 Hardware Virtualization
FPGA virtualization abstracts hardware functions so that **remote clients** can issue API-like commands.  
Example: Sending `"MUL 15 4"` → FPGA computes `60` → returns result.

**System Architecture:**

```
+--------------------+
| Cloud / Host PC    |
|  Python TCP Client |
+---------▲----------+
          │ Ethernet
+---------▼----------+
| FPGA Node          |
| ┌────────────────┐ |
| │ UDP/TCP Server │ |
| │ Hardware Logic │ |
| └────────────────┘ |
+--------------------+
```

---

## ⚙️ 4. Verilog Implementation

### 4.1 Compute Core (Multiply-Accumulate Example)
```verilog
module ComputeCore (
  input clk, rst,
  input [7:0] A, B,
  input start,
  output reg [15:0] result,
  output reg done
);
  always @(posedge clk or posedge rst)
    if (rst) begin result <= 0; done <= 0; end
    else if (start) begin
      result <= A * B + result;
      done <= 1;
    end else
      done <= 0;
endmodule
```

### 4.2 UDP Command Decoder (Simplified)
```verilog
module UDP_Command_IF (
  input clk, rst,
  input [7:0] rx_data,
  input rx_valid,
  output reg [7:0] tx_data,
  output reg tx_valid,
  output reg [15:0] result
);
  reg [7:0] A, B;
  reg start;
  wire done;
  wire [15:0] mac_result;

  ComputeCore core (.clk(clk), .rst(rst), .A(A), .B(B), .start(start), .result(mac_result), .done(done));

  always @(posedge clk) begin
    if (rx_valid) begin
      if (rx_data == "M") start <= 1;
      else if (rx_data == "A") A <= 8'd15;
      else if (rx_data == "B") B <= 8'd4;
    end
    if (done) begin
      tx_data <= mac_result[7:0];
      tx_valid <= 1;
    end else
      tx_valid <= 0;
  end
endmodule
```

---

## 🧩 5. Python Network Client
```python
import socket, time

server_ip = "192.168.1.50"
server_port = 5005

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
msg = b"M"  # Trigger computation
sock.sendto(msg, (server_ip, server_port))
data, _ = sock.recvfrom(1024)
print("Received from FPGA:", data)
sock.close()
```

---

## 🧮 6. Experiment Procedure
1. Configure Ethernet IP and PHY in Vivado using the **IP core wizard**.  
2. Instantiate `UDP_Command_IF` and `ComputeCore` modules.  
3. Assign a static IP address (e.g., `192.168.1.50`).  
4. Run the **Python UDP client** and observe the responses.  
5. Use **Wireshark** to monitor the packet exchange.  
6. Measure **round-trip latency** and packet loss.

---

## 📊 7. Observation Table
| Packet | Sent Command | Result | FPGA Response Time (µs) | Status |
|:-------|:--------------|:--------:|:------------------------:|:-------:|
| 1 | MUL 15 4 | 60 | 83 | ✅ |
| 2 | MUL 5 8 | 40 | 80 | ✅ |
| 3 | MUL 10 2 | 20 | 82 | ✅ |

---

## 💡 8. Discussion Points
- Why is **UDP** preferred for real-time FPGA communication?  
- Compare **network latency** vs. UART/SPI connections.  
- What are the design challenges for **packet reordering/loss**?  
- Discuss FPGA virtualization and **FPGA-as-a-Service (FaaS)**.  

---

## 🧠 9. Post-Lab Exercises
1. Add **TCP** support for reliable transfer.  
2. Implement **ADD, SUB, and MUL** commands.  
3. Extend protocol with **status codes** (`DONE`, `BUSY`, `ERROR`).  
4. Integrate **AXI-Ethernet Lite IP** and measure throughput.  
5. Develop a **Node.js dashboard** for real-time visualization.  

---

## 🧾 10. Outcome
Students will be able to:
- Interface FPGA with **standard network protocols (UDP/TCP)**.  
- Design lightweight FPGA-based **network servers**.  
- Implement **remote access to FPGA accelerators**.  
- Understand **FPGA virtualization and cloud integration** concepts.  

---

## 📘 11. References
1. Xilinx – *AXI Ethernet Lite IP Product Guide (PG135)*  
2. Intel – *Ethernet IP Cores User Guide*  
3. Xilinx Vitis – *lwIP and TCP/IP Stack Example Designs*  
4. Pong P. Chu – *FPGA Prototyping by Verilog Examples*  
5. D. Harris & S. Harris – *Digital Design and Computer Architecture*  

---

**Author:** Dr. Komsan Kanjanasit  
**Publisher:** College of Computing, Prince of Songkla University, Thailand  
**Edition:** First Edition (2025)  
**License:** CC BY 4.0 – Free for educational and research use.
