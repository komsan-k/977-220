# 🔬 Lab 19: Adaptive FPGA System with Reinforcement Learning and Dynamic Hardware Reconfiguration

## 🧩 1. Objective
This lab explores **adaptive learning hardware** using FPGA-based reinforcement learning and real-time dynamic reconfiguration.

Students will learn to:
- Implement a **Reinforcement Learning (RL)** controller in FPGA logic.
- Dynamically update FPGA configuration parameters (e.g., via partial reconfiguration or register tuning).
- Integrate **sensor feedback**, policy updates, and reward computation in real-time.
- Demonstrate convergence, adaptability, and learning behavior in hardware.

---

## ⚙️ 2. Equipment and Tools
| Tool / Resource | Description |
|------------------|-------------|
| **FPGA Board (Zybo Z7 / PYNQ-Z2 / Nexys A7)** | Hardware test platform |
| **Vivado + Vitis HLS** | RTL and HLS co-design environment |
| **Python / PYNQ overlay control** | High-level control and learning updates |
| **UART / MQTT / JTAG** | Communication and dynamic configuration interface |
| **Node-RED / ThingsBoard** | Visualization and data monitoring dashboard |

---

## 🧠 3. Background Theory

### 3.1 Reinforcement Learning (RL) on FPGA
Reinforcement Learning operates based on the interaction between an **agent** and an **environment**:

- **Agent (FPGA logic):** selects actions (e.g., control signals).  
- **Environment (sensors/plant):** reacts and provides new state.  
- **Reward:** quantifies how good the action was.  
- **Policy Update:** improves the agent’s future actions.

**Q-learning formula:**  
\[ Q(s, a) = Q(s, a) + \alpha [r + \gamma \max_{a'} Q'(s', a') - Q(s, a)] \]

Where:
- \( Q \): State-action value  
- \( \alpha \): Learning rate  
- \( \gamma \): Discount factor  

### 3.2 Dynamic Reconfiguration
FPGAs can **reconfigure logic at runtime** without halting operations, allowing hardware modules to evolve, adjust gains, or change structures dynamically.  
This enables real-time learning and adaptation at the hardware level — a foundation for **self-optimizing systems**.

---

## ⚙️ 4. Verilog + HLS Hybrid Implementation

### 4.1 Sensor Interface
```verilog
module Sensor_IF (
  input clk, rst,
  input [11:0] sensor_in,
  output reg [11:0] state
);
  always @(posedge clk or posedge rst)
    if (rst) state <= 0;
    else state <= sensor_in;
endmodule
```

### 4.2 Reward Computation Unit
```verilog
module Reward_Compute (
  input clk,
  input [11:0] error,
  output reg [15:0] reward
);
  always @(posedge clk)
    reward <= 1000 - error; // higher reward for smaller error
endmodule
```

### 4.3 Q-Value Update Engine (Simplified RL Logic)
```verilog
module Q_Update (
  input clk, rst,
  input [15:0] q_old, reward,
  input [15:0] q_next_max,
  output reg [15:0] q_new
);
  parameter ALPHA = 2;   // learning rate (scaled)
  parameter GAMMA = 9;   // discount factor (scaled)
  always @(posedge clk or posedge rst)
    if (rst)
      q_new <= 0;
    else
      q_new <= q_old + (ALPHA * (reward + (GAMMA * q_next_max) - q_old)) / 10;
endmodule
```

### 4.4 Reconfigurable Control Module
```verilog
module Adaptive_Controller (
  input clk, rst,
  input [11:0] state,
  output reg [11:0] control,
  input [15:0] q_value
);
  always @(posedge clk or posedge rst)
    if (rst) control <= 0;
    else if (q_value > 800) control <= control + 10;
    else if (q_value < 500) control <= control - 10;
endmodule
```

### 4.5 Top-Level Adaptive System
```verilog
module RL_FPGA_System (
  input clk, rst,
  input [11:0] sensor_in,
  output [11:0] actuator_out
);
  wire [11:0] state;
  wire [15:0] reward, q_old, q_next, q_new;

  Sensor_IF sense(.clk(clk), .rst(rst), .sensor_in(sensor_in), .state(state));
  Reward_Compute rew(.clk(clk), .error(512 - state), .reward(reward));
  Q_Update rl(.clk(clk), .rst(rst), .q_old(q_old), .reward(reward), .q_next_max(q_next), .q_new(q_new));
  Adaptive_Controller ctrl(.clk(clk), .rst(rst), .state(state), .control(actuator_out), .q_value(q_new));
endmodule
```

---

## 🧩 5. Python / PYNQ Host Reinforcement Loop
```python
from pynq import Overlay, allocate
import numpy as np, time

overlay = Overlay("rl_fpga_system.bit")
q_table = np.zeros((16, 4))  # simplified lookup

for episode in range(100):
    state = np.random.randint(0, 16)
    action = np.argmax(q_table[state])
    reward = 100 - abs(state - 8)
    q_table[state, action] += 0.1 * (reward + 0.9 * np.max(q_table[state]) - q_table[state, action])
    print(f"Episode {episode}: State={state}, Reward={reward}")
```

---

## 🧮 6. Experiment Procedure
1. Create a Vivado project with all Verilog RL modules.  
2. Use **Python / PYNQ overlay** for high-level training control.  
3. Connect FPGA to sensor inputs (e.g., light or temperature).  
4. Monitor actuator output (e.g., LED brightness or servo speed).  
5. Record **Q-value convergence** and **reward changes** over time.  

---

## 📊 7. Observation Table
| Episode | State | Action | Reward | Q_new | Control Output | Status |
|----------|--------|---------|---------|---------|----------------|---------|
| 1 | 5 | 2 | 850 | 780 | 410 | OK |
| 10 | 8 | 3 | 920 | 890 | 480 | Stable |
| 30 | 9 | 3 | 940 | 920 | 505 | Optimal |

---

## 💡 8. Discussion Points
- How does **FPGA-based RL** differ from traditional software RL?  
- Why is **on-chip learning** faster for real-time adaptation?  
- How can **partial reconfiguration** modify logic without halting?  
- What trade-offs exist between **fixed** and **adaptive** control logic?  

---

## 🧠 9. Post-Lab Exercises
1. Implement **multi-agent FPGA RL** for cooperative control.  
2. Add **softmax policy** and **learning rate decay**.  
3. Integrate **multi-sensor fusion** for multidimensional states.  
4. Develop **cloud-based training + FPGA deployment** hybrid loop.  
5. Benchmark **FPGA RL vs CPU RL** in latency and power.  

---

## 🧾 10. Outcome
Students will be able to:
- Implement adaptive FPGA-based control systems.  
- Understand **hardware-level reinforcement learning** and dynamic reconfiguration.  
- Combine **HDL, HLS, and Python** for hybrid RL systems.  
- Develop foundations for **self-optimizing cyber-physical architectures**.  

---

## 📘 11. References
1. S. Mittal, *A Survey of FPGA-based Accelerators for Reinforcement Learning*, IEEE TNNLS (2021)  
2. Xilinx UG909 – *Partial Reconfiguration Flow*  
3. Lee & Seshia – *Introduction to Embedded Systems: A CPS Approach*  
4. Samir Palnitkar – *Verilog HDL: A Guide to Digital Design and Synthesis*  
5. Pong P. Chu – *FPGA Prototyping by Verilog Examples*  

---

**Author:** Dr. Komsan Kanjanasit  
**Publisher:** College of Computing, Prince of Songkla University, Thailand  
**Edition:** First Edition (2025)  
**License:** CC BY 4.0 – Free for academic and research use.
