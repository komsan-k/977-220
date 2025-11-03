# 🔬 Lab 23: Self-Learning Cyber-Physical FPGA Agent with On-Chip Evolution

## 🧩 1. Objective

This laboratory focuses on building a **self-learning FPGA agent** that can **observe, evaluate, and adapt** to its environment in real-time.  
Students will:  

- Combine **reinforcement learning (RL)** and **neuromorphic processing**.  
- Implement a **policy update mechanism** directly on-chip.  
- Interface with real **sensors and actuators** for closed-loop feedback.  
- Demonstrate **evolutionary adaptation** through logic reconfiguration or parameter mutation.  

---

## ⚙️ 2. Equipment and Tools

| Tool / Resource | Description |
|:----------------|:-------------|
| **FPGA Board (PYNQ-Z2 / Zybo Z7 / Basys 3)** | Hardware platform for adaptive agent |
| **Vivado / Vitis HLS / ModelSim** | HDL design and simulation tools |
| **Python / PYNQ Overlay** | Environment interaction and control |
| **UART / I²C / GPIO** | Sensor–actuator interface |
| **LDR / TMP102 / Motor / Servo** | Physical environment components |

---

## 🧠 3. Background Theory

### 3.1 Self-Learning FPGA Architecture

The FPGA-based agent integrates three core layers:  

| Layer | Function | Technology |
|:------|:-----------|:------------|
| **Perception** | Sensor input and spike/event preprocessing | Neuromorphic circuits |
| **Decision** | Policy selection and reinforcement learning | Verilog / HLS logic |
| **Action** | Actuator control and environment feedback | PWM / GPIO interface |

---

### 3.2 Evolutionary Adaptation

Evolutionary algorithms improve behavior over time using **mutation** and **selection**.  

Reinforcement-based update:  
\[
W_{new} = W_{old} + \eta (Reward - Baseline)
\]  

Genetic mutation-based update:  
\[
W_{t+1} = W_t + \epsilon N(0, \sigma^2)
\]  

where  
- \( \eta \): learning rate  
- \( N(0, \sigma^2) \): Gaussian mutation  

This adaptive process enables **lifelong learning** within **Cyber-Physical Systems (CPS)**.  

---

## ⚙️ 4. Verilog Implementation

### 4.1 Perception Unit – Sensor Normalization
```verilog
module Sensor_Normalizer (
  input clk, rst,
  input [11:0] raw_sensor,
  output reg [7:0] normalized
);
  always @(posedge clk or posedge rst)
    if (rst) normalized <= 0;
    else normalized <= raw_sensor[11:4];  // scale 12-bit → 8-bit
endmodule
```

### 4.2 Decision Unit – Reinforcement Policy
```verilog
module RL_Policy (
  input clk, rst,
  input [7:0] state,
  input [15:0] reward,
  output reg [7:0] action
);
  reg [15:0] q_table [0:255];
  reg [7:0] best_action;
  integer i;

  always @(posedge clk or posedge rst)
    if (rst) begin
      for (i=0; i<256; i=i+1) q_table[i] <= 0;
      action <= 0;
    end else begin
      if (reward > q_table[state]) q_table[state] <= reward;
      best_action = (q_table[state] > 100) ? 1 : 0;
      action <= best_action;
    end
endmodule
```

### 4.3 Actuator Interface
```verilog
module Actuator_PWM (
  input clk,
  input [7:0] control,
  output reg pwm
);
  reg [7:0] count;
  always @(posedge clk)
    count <= count + 1;
  always @(*) pwm = (count < control);
endmodule
```

### 4.4 Evolutionary Weight Mutation
```verilog
module Evolutionary_Update (
  input clk, rst,
  input [15:0] reward,
  input [15:0] old_weight,
  output reg [15:0] new_weight
);
  parameter signed MUTATION_FACTOR = 2;
  always @(posedge clk or posedge rst)
    if (rst) new_weight <= 16'd100;
    else new_weight <= old_weight + (reward / MUTATION_FACTOR);
endmodule
```

### 4.5 Top-Level Agent System
```verilog
module SelfLearning_Agent (
  input clk, rst,
  input [11:0] sensor_in,
  output pwm_out
);
  wire [7:0] state, action;
  wire [15:0] reward, weight;

  Sensor_Normalizer sn (.clk(clk), .rst(rst), .raw_sensor(sensor_in), .normalized(state));
  RL_Policy policy (.clk(clk), .rst(rst), .state(state), .reward(reward), .action(action));
  Evolutionary_Update evo (.clk(clk), .rst(rst), .reward(reward), .old_weight(weight), .new_weight(weight));
  Actuator_PWM act (.clk(clk), .control(action * weight[7:0]), .pwm(pwm_out));
endmodule
```

---

## 🧩 5. Python Environment Simulation (for PYNQ or PC)
```python
import random, time

reward = 0
state = 0

for episode in range(20):
    sensor = random.randint(0, 255)
    action = 1 if sensor > 128 else 0
    reward = 200 - abs(sensor - 128)
    print(f"Episode {episode}: Sensor={sensor}, Action={action}, Reward={reward}")
    time.sleep(0.1)
```

---

## 🧮 6. Experiment Procedure

1. Connect FPGA to a light sensor (LDR) and LED or motor.  
2. Implement the **SelfLearning_Agent** design in Vivado.  
3. Use **sensor input** as the system state and **PWM output** as the control signal.  
4. Observe how the agent adapts LED brightness or motor speed over time.  
5. Record changes in **reward** and **weight** over learning episodes.  

---

## 📊 7. Observation Table

| Episode | Sensor | Action | Reward | Weight | Behavior |
|:----------|:----------|:----------|:----------|:----------|:----------|
| 1 | 40 | 0 | 88 | 102 | Exploring |
| 5 | 150 | 1 | 200 | 114 | Learning |
| 10 | 130 | 1 | 220 | 126 | Adapting |
| 20 | 128 | 1 | 240 | 130 | Stable |

---

## 💡 8. Discussion Points

- How does **on-chip learning** differ from CPU-based loops?  
- Discuss hardware **lifelong adaptation** and its constraints.  
- How could **multi-agent coordination** improve policy convergence?  
- What is the trade-off between **mutation rate** and **stability**?  

---

## 🧠 9. Post-Lab Exercises

- Extend to **multi-agent learning** (2+ FPGAs sharing reward signals).  
- Add **temperature or motion sensors** for multimodal perception.  
- Implement **genetic selection** using HLS-based population modules.  
- Visualize **evolution and learning metrics** in Node-RED or Python.  
- Compare **FPGA learning latency** to software RL loops.  

---

## 🧾 10. Outcome

Students will be able to:  
- Implement **real-time adaptive agents** directly in hardware.  
- Integrate **reinforcement and evolutionary learning** into CPS.  
- Demonstrate **autonomous FPGA control** responding to environment dynamics.  
- Evaluate **self-learning and reconfigurable intelligence** in embedded systems.  

---

## 📘 11. References

- S. Mittal, *Survey on Hardware-Aware Reinforcement and Evolutionary Learning*, IEEE Access, 2022.  
- Xilinx, *UG909 – Partial Reconfiguration and Adaptive Compute*.  
- F. Corradi et al., *Neuromorphic Hardware for Autonomous Agents*.  
- Lee & Seshia, *Embedded Systems: A Cyber-Physical Systems Approach*.  
- Chu, *FPGA Prototyping by Verilog Examples*.  

---

✅ **Author:** Dr. Komsan Kanjanasit  
**Publisher:** College of Computing, Prince of Songkla University, Thailand  
**Edition:** 1st Edition (2025)  
**License:** CC BY-NC 4.0  
