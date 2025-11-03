# 🔬 Lab 20: Distributed FPGA Intelligence and Multi-Agent Coordination

## 🧩 1. Objective

This laboratory explores **multi-agent intelligence using interconnected FPGA nodes**.  
Students will:

- Implement agent logic on each FPGA node with sensing, communication, and decision-making.  
- Exchange data through **UART/SPI/Ethernet** links for cooperative behavior.  
- Apply **consensus or swarm algorithms** in hardware.  
- Evaluate **latency, convergence, and resilience** in distributed FPGA systems.

---

## ⚙️ 2. Equipment and Tools

| Tool / Resource | Description |
|-----------------|--------------|
| **2–4 FPGA Boards** (Basys-3 / Nexys A7 / PYNQ-Z2) | Multi-agent hardware network |
| **Vivado / Quartus / Vitis HLS** | HDL and HLS design tools |
| **UART or Ethernet links** | Agent communication |
| **Python (for monitoring)** | Data visualization |
| **LEDs / Sensors** | Local state indicators |

---

## 🧠 3. Background Theory

### 3.1 Multi-Agent FPGA Systems
Each FPGA node functions as an **autonomous agent**, performing:
- Local sensing and computation  
- Data exchange with neighboring nodes  
- Consensus or learning updates  
- Cooperative control output  

This architecture enables **distributed decision-making** without a centralized controller.

### 3.2 Consensus Algorithm
A fundamental average-consensus update rule:

\[
x_i(t+1) = x_i(t) + \alpha \sum_{j \in N_i} (x_j(t) - x_i(t))
\]

Where:
- \( x_i \) = local state value  
- \( N_i \) = set of neighbors  
- \( \alpha \) = learning rate  

---

## ⚙️ 4. Verilog Implementation

### 4.1 Agent Core
```verilog
module Agent_Node (
  input clk, rst,
  input [7:0] neighbor_val,
  output reg [7:0] local_val
);
  parameter ALPHA = 1;
  reg [7:0] x_i;

  always @(posedge clk or posedge rst)
    if (rst) x_i <= 8'd50;
    else x_i <= x_i + ((neighbor_val - x_i) >>> ALPHA);  // consensus update

  always @(*) local_val = x_i;
endmodule
```

### 4.2 Communication Link (UART)
```verilog
module Agent_UART_Link (
  input clk, rst,
  input rx,
  output tx,
  output [7:0] neighbor_val
);
  reg [7:0] rx_data;
  wire rx_ready;

  UART_RX #(50000000, 9600) RX (.clk(clk), .rst(rst), .rx(rx),
                                 .data_out(rx_data), .rx_ready(rx_ready));
  UART_TX #(50000000, 9600) TX (.clk(clk), .rst(rst), .tx(tx));

  assign neighbor_val = rx_data;
endmodule
```

### 4.3 Top-Level Multi-Agent Network (2 FPGA Example)
```verilog
module TwoAgent_System (
  input clk, rst,
  input rxA, rxB,
  output txA, txB,
  output [7:0] valA, valB
);
  wire [7:0] neighborA, neighborB;

  Agent_UART_Link linkA (.clk(clk), .rst(rst), .rx(rxB), .tx(txA), .neighbor_val(neighborA));
  Agent_UART_Link linkB (.clk(clk), .rst(rst), .rx(rxA), .tx(txB), .neighbor_val(neighborB));

  Agent_Node A (.clk(clk), .rst(rst), .neighbor_val(neighborA), .local_val(valA));
  Agent_Node B (.clk(clk), .rst(rst), .neighbor_val(neighborB), .local_val(valB));
endmodule
```

### 4.4 Behavior Example
If **Node A** starts with 40 and **Node B** with 60, after several iterations both converge near 50 — achieving **consensus**.

---

## 🧩 5. Python Visualization (Serial Monitoring)
```python
import serial, time

serA = serial.Serial('COM4', 9600)
serB = serial.Serial('COM5', 9600)

for _ in range(50):
    a = int(serA.readline().strip())
    b = int(serB.readline().strip())
    print(f"NodeA={a}, NodeB={b}")
    time.sleep(0.5)
```

---

## 🧮 6. Experiment Procedure

1. Program both FPGAs with `Agent_Node` and `Agent_UART_Link`.  
2. Cross-connect **TX ↔ RX** between the boards.  
3. Initialize nodes with distinct values (e.g., 30 and 70).  
4. Observe serial output for convergence.  
5. Record latency, update rate, and convergence error.

---

## 📊 7. Observation Table

| Iteration | Node A | Node B | Average | Δ Error | Status |
|------------|--------|--------|----------|----------|---------|
| 0 | 30 | 70 | 50 | 40 | Start |
| 5 | 40 | 60 | 50 | 20 | Converging |
| 10 | 45 | 55 | 50 | 10 | Stable |
| 20 | 49 | 51 | 50 | 2 | Consensus |

---

## 💡 8. Discussion Points

- How does **learning rate (α)** influence convergence?  
- What is the effect of **communication delay** on synchronization?  
- Can agents tolerate **packet loss or jitter**?  
- How can this design scale to **10 + FPGA nodes**?

---

## 🧠 9. Post-Lab Exercises

- Extend to **3+ FPGA nodes** (ring or star topology).  
- Implement **leader election** (highest-value node becomes master).  
- Integrate a **reinforcement-learning (RL)** module per node.  
- Add **neighbor weighting** to the consensus rule.  
- Visualize convergence in **Node-RED** or a Python GUI.

---

## 🧾 10. Outcome

Students will be able to:

- Implement **distributed consensus protocols** in Verilog.  
- Network multiple FPGAs for **cooperative computation**.  
- Analyze **stability, convergence, and fault tolerance**.  
- Relate hardware multi-agent systems to **distributed AI and CPS** frameworks.

---

## 📘 11. References

- Olfati-Saber, R. *Consensus and Cooperation in Networked Multi-Agent Systems*. IEEE, 2007.  
- Xilinx. *AXI Stream Interconnect for Multi-FPGA Communication*.  
- Mittal, S. *Survey of FPGA Accelerators for AI and Multi-Agent Learning*.  
- Lee & Seshia. *Embedded Systems: A Cyber-Physical Systems Approach*.  
- Chu, P. *FPGA Prototyping by Verilog Examples*.

---

✅ **Author:** Dr. Komsan Kanjanasit  
**Publisher:** College of Computing, Prince of Songkla University, Thailand  
**Edition:** 1st Edition (2025)  
**License:** CC BY-NC 4.0  
