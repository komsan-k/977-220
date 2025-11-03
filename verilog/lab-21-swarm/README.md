# 🔬 Lab 21: Self-Organizing FPGA Network and Swarm Intelligence Optimization

## 🧩 1. Objective

This laboratory develops a **swarm-based FPGA system** that performs **collective optimization through bio-inspired algorithms**.  
Students will:  

- Implement **Particle Swarm Optimization (PSO)** directly in Verilog HDL.  
- Enable **distributed communication** among FPGA agents.  
- Evaluate **collective convergence** toward a global optimum.  
- Visualize swarm dynamics in real time using **Python Matplotlib** or **Node-RED dashboards**.  

---

## ⚙️ 2. Equipment and Tools

| Tool / Resource | Description |
|:----------------|:-------------|
| **2–4 FPGA Boards** (Basys 3 / Nexys A7 / PYNQ-Z2) | Multi-agent swarm network |
| **Vivado / Quartus / Vitis HLS** | HDL synthesis and analysis tools |
| **UART / SPI / Ethernet** | Inter-FPGA communication links |
| **Python + Matplotlib / Node-RED** | Real-time visualization environment |
| **Sensors / Actuators (optional)** | Environmental interaction inputs |

---

## 🧠 3. Background Theory

### 3.1 Swarm Intelligence

Swarm algorithms rely on **decentralized coordination** among agents that follow simple local rules, leading to emergent global optimization.  

**Particle Swarm Optimization (PSO)** update rule:  

\[
v_i(t+1)=w\,v_i(t)+c_1r_1(p_i-x_i)+c_2r_2(g-x_i)
\]  
\[
x_i(t+1)=x_i(t)+v_i(t+1)
\]  

where:  
- \(p_i\): best position found by particle _i_  
- \(g\): global best position  
- \(w,c_1,c_2\): inertia and learning coefficients  
- \(r_1,r_2\): random numbers ∈ [0,1]  

### 3.2 FPGA Implementation Concept

Each FPGA node acts as a particle:  
- Maintains local position and velocity.  
- Evaluates its own fitness function.  
- Shares fitness data with neighbors through UART or Ethernet.  
- Executes PSO updates in hardware for **deterministic low-latency optimization**.  

---

## ⚙️ 4. Verilog Implementation

### 4.1 Particle Update Logic
```verilog
module Particle_Update (
  input clk, rst,
  input signed [15:0] p_best, g_best,
  input signed [15:0] x, v,
  output reg signed [15:0] x_next, v_next
);
  parameter W = 1, C1 = 1, C2 = 1;
  wire signed [15:0] r1 = 3;  // pseudo-random constants
  wire signed [15:0] r2 = 2;

  always @(posedge clk or posedge rst)
    if (rst) begin
      x_next <= 0; v_next <= 0;
    end else begin
      v_next <= (W*v) + (C1*r1*(p_best - x)) + (C2*r2*(g_best - x));
      x_next <= x + v_next;
    end
endmodule
```

### 4.2 Local Fitness Evaluation
```verilog
module Fitness_Eval (
  input [15:0] x,
  output reg [15:0] fitness
);
  always @(*)
    fitness = (x > 0) ? (x * x) : (-x * x); // minimize f(x)=x^2
endmodule
```

### 4.3 Global Best Sharing (2-FPGA Example)
```verilog
module Swarm_Link (
  input clk, rst,
  input [15:0] local_fitness,
  output reg [15:0] g_best
);
  reg [15:0] neighbor_fitness;
  wire [7:0] rx_data;
  wire rx_ready;

  UART_RX #(50000000, 9600) RX (.clk(clk), .rst(rst), .rx(rx),
                                .data_out(rx_data), .rx_ready(rx_ready));
  UART_TX #(50000000, 9600) TX (.clk(clk), .rst(rst), .tx(tx));

  always @(posedge clk) begin
    if (rx_ready) neighbor_fitness <= rx_data;
    g_best <= (local_fitness < neighbor_fitness) ? local_fitness : neighbor_fitness;
  end
endmodule
```

### 4.4 Swarm Node (Top-Level)
```verilog
module Swarm_Node (
  input clk, rst,
  output [15:0] pos, vel, best_fit
);
  wire [15:0] f, g_best;
  reg [15:0] x, v, p_best;

  Fitness_Eval F(.x(x), .fitness(f));
  Swarm_Link  L(.clk(clk), .rst(rst), .local_fitness(f), .g_best(g_best));
  Particle_Update P(.clk(clk), .rst(rst),
                    .p_best(p_best), .g_best(g_best),
                    .x(x), .v(v), .x_next(x), .v_next(v));

  always @(posedge clk or posedge rst)
    if (rst) p_best <= 16'h7FFF;
    else if (f < p_best) p_best <= f;
endmodule
```

---

## 🧩 5. Python Visualization
```python
import serial, time, matplotlib.pyplot as plt

serA = serial.Serial('COM4', 9600)
serB = serial.Serial('COM5', 9600)
histA, histB = [], []

for t in range(50):
    xA = int(serA.readline().strip())
    xB = int(serB.readline().strip())
    histA.append(xA)
    histB.append(xB)
    print(f"t={t}: NodeA={xA}, NodeB={xB}")

plt.plot(histA, label="Node A")
plt.plot(histB, label="Node B")
plt.xlabel("Iteration")
plt.ylabel("Position")
plt.legend()
plt.show()
```

---

## 🧮 6. Experiment Procedure

1. Program two FPGA boards with `Swarm_Node`.  
2. Initialize each node with random position and velocity.  
3. Cross-connect **UART TX ↔ RX** for communication.  
4. Observe position updates and fitness convergence.  
5. Visualize global convergence via Python or Node-RED.  

---

## 📊 7. Observation Table

| Iteration | Node A (x) | Node B (x) | Global Best | Fitness | Status |
|:-----------|:-----------|:-----------|:-------------|:-----------|:-----------|
| 0 | 80 | -40 | -40 | 1600 | Init |
| 5 | 60 | -20 | -20 | 400 | Converging |
| 10 | 25 | -10 | -10 | 100 | Converged |
| 20 | 5 | -5 | -5 | 25 | Optimal |

---

## 💡 8. Discussion Points

- How do swarm parameters (w, c1, c2) affect convergence speed?  
- Which communication method (UART, SPI, Ethernet) minimizes latency?  
- Compare **FPGA-based PSO** vs **CPU-based PSO** in performance and determinism.  
- How could partial reconfiguration enable “mutation” behavior in hardware swarms?  

---

## 🧠 9. Post-Lab Exercises

- Implement 3+ FPGA swarm nodes with full mesh communication.  
- Replace UART with Ethernet broadcast.  
- Extend to a 2-D fitness function f(x,y) for pathfinding.  
- Integrate real sensors (light, temperature) as fitness inputs.  
- Apply FPGA swarm for autonomous decision-making in CPS.  

---

## 🧾 10. Outcome

Students will be able to:  
- Design and implement **swarm intelligence algorithms** in Verilog.  
- Build **distributed FPGA networks** for shared optimization.  
- Evaluate **convergence, latency, and learning behavior**.  
- Apply **bio-inspired coordination** to reconfigurable hardware systems.  

---

## 📘 11. References

- Kennedy & Eberhart, *Particle Swarm Optimization*, IEEE, 1995.  
- Xilinx, *AXI Streaming for Multi-FPGA Systems*.  
- S. Mittal, *FPGA Architectures for Bio-Inspired Algorithms*, IEEE Access, 2020.  
- Lee & Seshia, *Introduction to Embedded Systems: CPS Approach*.  
- Chu, *FPGA Prototyping by Verilog Examples*.  

---

✅ **Author:** Dr. Komsan Kanjanasit  
**Publisher:** College of Computing, Prince of Songkla University, Thailand  
**Edition:** 1st Edition (2025)  
**License:** CC BY-NC 4.0  
