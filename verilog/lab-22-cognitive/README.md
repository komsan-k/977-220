# 🔬 Lab 22: Cognitive FPGA System with Neuromorphic Event-Driven Processing

## 🧩 1. Objective

This laboratory introduces **neuromorphic-style FPGA systems** that perform **event-driven sensing**, **spiking communication**, and **adaptive decision-making**.  
Students will:  

- Implement **spiking neuron models** in Verilog HDL.  
- Create **synaptic weight adaptation (plasticity)** via STDP.  
- Demonstrate **event-driven computation** rather than clock-driven execution.  
- Interface with sensors to demonstrate **cognitive and low-power behavior** in hardware.  

---

## ⚙️ 2. Equipment and Tools

| Tool / Resource | Description |
|:----------------|:-------------|
| **FPGA board (PYNQ-Z2 / Zybo Z7 / Basys 3)** | Hardware platform for spiking neural network |
| **Vivado / Vitis HLS** | RTL + HLS design tools |
| **UART / SPI / GPIO** | Event and sensor interface |
| **Python / PYNQ Overlay** | Stimulus generation and visualization |
| **Oscilloscope / Logic Analyzer** | Event timing verification |

---

## 🧠 3. Background Theory

### 3.1 Spiking Neural Networks (SNNs)

Spiking Neural Networks (SNNs) emulate **biological neuron behavior**, where computation occurs upon **spike (event)** arrivals instead of continuous activation signals.  
Each neuron integrates incoming weighted spikes and fires when a threshold is reached.  

\[
V_{mem}(t+1) = V_{mem}(t) + \sum_i w_i \cdot spike_i(t)
\]
\[
spike(t+1) =
\begin{cases}
1 & \text{if } V_{mem} > \theta \\
0 & \text{otherwise}
\end{cases}
\]

### 3.2 Event-Driven Hardware

Event-driven architectures perform computations only upon **stimulus activity**, reducing power and latency.  
This principle is foundational for **neuromorphic CPS**, **edge AI**, and **robotic perception** systems.  

---

## ⚙️ 4. Verilog Implementation

### 4.1 Spiking Neuron Module
```verilog
module Spiking_Neuron (
  input clk, rst,
  input spike_in,
  input signed [7:0] weight,
  output reg spike_out
);
  reg signed [15:0] Vmem;
  parameter signed TH = 100;

  always @(posedge clk or posedge rst)
    if (rst) begin
      Vmem <= 0; spike_out <= 0;
    end else begin
      if (spike_in) Vmem <= Vmem + weight;
      if (Vmem > TH) begin
        spike_out <= 1;
        Vmem <= 0; // reset after firing
      end else spike_out <= 0;
    end
endmodule
```

### 4.2 Synaptic Plasticity (STDP) Unit
```verilog
module STDP_Synapse (
  input clk, rst,
  input pre_spike, post_spike,
  output reg signed [7:0] weight
);
  parameter signed A_plus  = 2;
  parameter signed A_minus = -1;

  always @(posedge clk or posedge rst)
    if (rst) weight <= 8'd10;
    else begin
      if (pre_spike && post_spike) weight <= weight + A_plus;   // strengthen
      else if (pre_spike && !post_spike) weight <= weight + A_minus; // weaken
    end
endmodule
```

### 4.3 Two-Neuron Network
```verilog
module TwoNeuron_Network (
  input clk, rst,
  input ext_spike,
  output spike_out_A, spike_out_B
);
  wire signed [7:0] wAB, wBA;
  wire preA, preB;

  Spiking_Neuron A(.clk(clk), .rst(rst), .spike_in(ext_spike), .weight(wAB), .spike_out(preA));
  Spiking_Neuron B(.clk(clk), .rst(rst), .spike_in(preA),      .weight(wBA), .spike_out(preB));

  STDP_Synapse S1(.clk(clk), .rst(rst), .pre_spike(preA), .post_spike(preB), .weight(wAB));
  STDP_Synapse S2(.clk(clk), .rst(rst), .pre_spike(preB), .post_spike(preA), .weight(wBA));

  assign spike_out_A = preA;
  assign spike_out_B = preB;
endmodule
```

---

## 🧩 4.4 Event Visualization (Python Plot)
```python
import serial, matplotlib.pyplot as plt, time

ser = serial.Serial('COM4', 115200)
spikeA, spikeB, t = [], [], []

for i in range(200):
    line = ser.readline().decode().strip()
    if line.startswith("A"): spikeA.append(i)
    if line.startswith("B"): spikeB.append(i)
    t.append(i)
    time.sleep(0.01)

plt.eventplot([spikeA, spikeB], colors=['red','blue'])
plt.xlabel("Time")
plt.ylabel("Neuron Spikes")
plt.title("Event-Driven Spike Activity")
plt.show()
```

---

## 🧮 5. Experiment Procedure

1. Implement `TwoNeuron_Network` in Vivado or Vitis HLS.  
2. Drive `ext_spike` using a sensor or Python-based stimulus.  
3. Observe **spike trains** and **adaptive weights** using an oscilloscope or serial terminal.  
4. Record the **evolution of synaptic weights** over time.  
5. Discuss how **plasticity** alters responses to repeated stimuli.  

---

## 📊 6. Observation Table

| Trial | Input Spikes | Weight AB | Weight BA | Spike Rate A | Spike Rate B | Behavior |
|:------|:--------------|:-----------|:-----------|:---------------|:---------------|:------------|
| 1 | 10 | 12 | 10 | Low | Low | Initialization |
| 5 | 50 | 17 | 15 | Medium | High | Learning |
| 10 | 100 | 23 | 22 | High | High | Stabilized |

---

## 💡 7. Discussion Points

- How does **event-driven computation** minimize power and latency?  
- Compare **spiking networks** with **clocked ANNs** in timing and power.  
- Why is **synaptic plasticity** vital for autonomous learning?  
- How can FPGA **partial reconfiguration** scale neuromorphic topologies?  

---

## 🧠 8. Post-Lab Exercises

- Extend to **multi-layer spiking networks** (>4 neurons).  
- Implement **leaky integrate-and-fire** models with membrane decay.  
- Add **event timestamping** for precise temporal coding.  
- Integrate **LDR or microphone sensors** as stimuli.  
- Combine neuromorphic FPGA logic with **cloud-based learning feedback**.  

---

## 🧾 9. Outcome

Students will be able to:  
- Design **event-driven neuromorphic architectures** in Verilog.  
- Implement **on-chip synaptic plasticity (STDP)**.  
- Analyze **spiking behavior, timing, and adaptivity**.  
- Understand the basis of **cognitive and self-learning FPGA systems**.  

---

## 📘 10. References

- Indiveri & Horiuchi, *Frontiers in Neuromorphic Engineering*, 2011.  
- Xilinx, *Adaptive Compute Acceleration Platform (ACAP)*.  
- Boahen, K. A. *Neuromorphic Circuits for Brains and Machines*, Proc. IEEE, 2017.  
- Chu, *FPGA Prototyping by Verilog Examples*.  
- Palnitkar, *Verilog HDL: A Guide to Digital Design and Synthesis*.  

---

✅ **Author:** Dr. Komsan Kanjanasit  
**Publisher:** College of Computing, Prince of Songkla University, Thailand  
**Edition:** 1st Edition (2025)  
**License:** CC BY-NC 4.0  
