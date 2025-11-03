# 🔬 Lab 25: Digital-Twin-Driven Autonomous FPGA Network with Self-Orchestration

## 🧩 1. Objective

This laboratory demonstrates a **bi-directional digital twin system** integrating **FPGA edge agents** with a **cloud-based AI twin**.  
Students will:  

- Implement **two-way synchronization** between physical FPGA nodes and digital-twin models.  
- Employ **cloud-hosted reinforcement learning (RL)** to dynamically tune FPGA parameters.  
- Demonstrate **self-healing** and **self-optimization** across a distributed AI-CPS architecture.  

---

## ⚙️ 2. Equipment and Tools

| Tool / Resource | Description |
|:----------------|:-------------|
| **2–4 FPGA Boards (Basys 3 / PYNQ-Z2 / Zybo Z7)** | Physical CPS agents |
| **Vivado + Vitis HLS** | FPGA synthesis and co-simulation |
| **Python + Flask / Node-RED / MQTT** | Cloud twin orchestration and dashboard |
| **Docker + TensorFlow / PyTorch** | RL and simulation environment |
| **Sensors / Actuators** | LDR, motor, servo, temperature sensor |

---

## 🧠 3. Background Theory

### 3.1 Digital Twin Concept

A **digital twin** is a real-time, cloud-hosted model mirroring the behavior and state of a **physical system**.  
It enables **predictive optimization** and **adaptive control** through synchronized updates:  

\[
State_{twin}(t) \approx State_{physical}(t)
\]  
\[
Action_{twin}(t+1) \Rightarrow Update_{physical}(t+1)
\]  

This creates a **closed-loop feedback** between the digital twin and physical agent, essential for next-generation **CPS 6.0**.  

### 3.2 Self-Orchestration in CPS

Self-orchestration combines **edge autonomy** with **cloud intelligence**, enabling:  
- **Self-configuration** – FPGA logic adapts to context.  
- **Self-optimization** – RL agents fine-tune parameters for best performance.  
- **Self-healing** – system recovery from faults or perturbations.  

---

## ⚙️ 4. FPGA Design Modules

### 4.1 Physical Agent Core
```verilog
module Physical_Agent (
  input clk, rst,
  input [11:0] sensor,
  input [15:0] twin_update,
  output reg [15:0] perf_metric
);
  reg [15:0] param;
  always @(posedge clk or posedge rst)
    if (rst) begin
      param <= 16'd100;
      perf_metric <= 0;
    end else begin
      param <= (param + twin_update) >> 1; // twin-guided adaptation
      perf_metric <= (sensor * param) >> 8;
    end
endmodule
```

### 4.2 Twin Synchronizer
```verilog
module Twin_Sync (
  input clk, rst,
  input [15:0] perf_metric,
  output reg [15:0] twin_update
);
  // Placeholder for MQTT/Serial interface
  always @(posedge clk or posedge rst)
    if (rst) twin_update <= 0;
    else twin_update <= perf_metric >> 2; // simplified feedback
endmodule
```

### 4.3 Top-Level Integration
```verilog
module CPS6_System (
  input clk, rst,
  input [11:0] sensor,
  output [15:0] actuation
);
  wire [15:0] perf, twin_signal;

  Physical_Agent phys (.clk(clk), .rst(rst), .sensor(sensor),
                       .twin_update(twin_signal), .perf_metric(perf));
  Twin_Sync sync (.clk(clk), .rst(rst),
                  .perf_metric(perf), .twin_update(twin_signal));

  assign actuation = perf;
endmodule
```

---

## ☁️ 5. Cloud Twin Server (Python Flask)
```python
from flask import Flask, request, jsonify
import numpy as np
app = Flask(__name__)

state_db = {}

@app.route("/update", methods=["POST"])
def update():
    node = request.json["node"]
    metric = request.json["metric"]
    # RL or ML model predicts next twin signal
    twin_signal = 0.5 * metric + np.random.randint(-10,10)
    state_db[node] = twin_signal
    return jsonify({"twin_update": twin_signal})

app.run(host="0.0.0.0", port=5001)
```

---

## 🧩 6. Node-RED Dashboard Design

**MQTT Topics:**  
- `fpga/node1/performance`  
- `fpga/node1/twin_update`  
- `fpga/global/overview`  

**Dashboard Widgets:**  
| Widget | Function |
|:--------|:-----------|
| **Gauge** | Displays real-time performance metric |
| **Chart** | Shows twin vs physical state over time |
| **Button** | Allows manual retraining or reset |

---

## 🧮 7. Experiment Procedure

1. Implement `CPS6_System` on FPGA as a physical edge agent.  
2. Connect a sensor and actuator (e.g., LED brightness = performance metric).  
3. Deploy Flask server for the digital twin and connect via MQTT/HTTP.  
4. Visualize bidirectional updates on Node-RED dashboard.  
5. Apply perturbations (e.g., sensor noise or reset) and observe **self-healing** and **adaptive response**.  

---

## 📊 8. Observation Table

| Cycle | Sensor | Perf Metric | Twin Update | Param | Behavior |
|:-------|:----------|:-------------|:--------------|:-----------|:-------------|
| 1 | 110 | 420 | 105 | 95 | Initial learning |
| 3 | 90 | 360 | 92 | 97 | Converging |
| 6 | 130 | 500 | 120 | 105 | Adaptive response |
| 10 | 100 | 400 | 100 | 100 | Stabilized |

---

## 💡 9. Discussion Points

- How does **digital-twin feedback** accelerate FPGA adaptation?  
- Compare **on-chip learning** vs **cloud-twin learning**.  
- Discuss synchronization latency and its effect on stability.  
- How could **blockchain/DAO** manage federated CPS networks?  

---

## 🧠 10. Post-Lab Exercises

- Extend to **3+ FPGA nodes** sharing a common twin database.  
- Implement **RL-based reward prediction** on the cloud.  
- Trigger **event-based retraining** during performance degradation.  
- Visualize 3D twin models using **ThingSpeak**, **Unity**, or **MATLAB Simulink**.  
- Demonstrate **self-healing behavior** after intentional node failure.  

---

## 🧾 11. Outcome

Students will be able to:  
- Design a **bi-directional FPGA–cloud twin** system.  
- Integrate **real-time feedback** for autonomous adaptation.  
- Demonstrate **self-orchestrating CPS** with RL and event-driven control.  
- Understand **CPS 6.0 architecture** for next-generation **Physical AI systems**.  

---

## 📘 12. References

- Tao et al., *Digital Twin in Industrial CPS — Framework and Applications*, IEEE TII, 2022.  
- Mittal, S., *FPGA Architectures for Edge-to-Cloud AI*, IEEE Access, 2024.  
- Xilinx, *UG908 – Dynamic Partial Reconfiguration Guide*.  
- Lee & Seshia, *Embedded Systems: A Cyber-Physical Systems Approach*.  
- Palnitkar, *Verilog HDL: A Guide to Digital Design and Synthesis*.  

---

✅ **Author:** Dr. Komsan Kanjanasit  
**Publisher:** College of Computing, Prince of Songkla University, Thailand  
**Edition:** 1st Edition (2025)  
**License:** CC BY-NC 4.0  
