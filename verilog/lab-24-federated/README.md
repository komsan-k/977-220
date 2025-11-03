# 🔬 Lab 24: Federated FPGA Intelligence – Edge–Cloud Co-Learning Architecture

## 🧩 1. Objective

This laboratory focuses on **federated learning** between **FPGA edge nodes** and a **cloud coordinator**.  
Students will:

- Implement **local learning logic** on FPGA using Q-Learning or Gradient Update.  
- Exchange model parameters via **MQTT or HTTP** with a cloud server.  
- Perform **federated averaging (FedAvg)** on the server side.  
- Re-deploy the global model for synchronized inference across all FPGA nodes.  

---

## ⚙️ 2. Equipment and Tools

| Tool / Resource | Description |
|:----------------|:-------------|
| **2–4 FPGA Boards (Basys 3 / PYNQ-Z2 / Zybo Z7)** | Edge learning nodes |
| **Vivado / Vitis HLS** | FPGA local model implementation |
| **Python + Flask / Node-RED** | Cloud aggregation server |
| **MQTT / HTTP client** | Communication middleware |
| **Sensors (LDR, Temp, IMU)** | Local input for environment data |

---

## 🧠 3. Background Theory

### 3.1 Federated Learning Principle

Each FPGA node \(i\) trains local model parameters \(\theta_i\) on its own dataset \(D_i\).  
The server then performs aggregation using the **FedAvg** rule:

\[
\theta_{global} = \frac{1}{N} \sum_i \theta_i
\]

The aggregated model \(\theta_{global}\) is redistributed to all nodes, allowing **privacy-preserving** and **decentralized learning** without sharing raw sensor data.

---

### 3.2 Edge Hardware Learning

On FPGAs, “training” corresponds to **incremental parameter updates** or **logic-level tuning**, enabling embedded reinforcement or gradient-based learning.  

---

## ⚙️ 4. Verilog Modules (for Edge Learning)

### 4.1 Local Gradient Update
```verilog
module Local_Update (
  input clk, rst,
  input [15:0] grad_in,
  input [15:0] weight_in,
  output reg [15:0] weight_out
);
  parameter LEARNING_RATE = 2;  // scaled by 1/10
  always @(posedge clk or posedge rst)
    if (rst) weight_out <= 16'd100;
    else weight_out <= weight_in - (grad_in / LEARNING_RATE);
endmodule
```

### 4.2 Parameter Serializer (for MQTT Transmission)
```verilog
module Param_Serializer (
  input clk, rst,
  input [15:0] weight,
  output reg [7:0] tx_data,
  output reg tx_ready
);
  reg [1:0] byte_idx;
  always @(posedge clk or posedge rst)
    if (rst) begin tx_ready<=0; byte_idx<=0; end
    else begin
      case(byte_idx)
        0: tx_data <= weight[15:8];
        1: tx_data <= weight[7:0];
      endcase
      tx_ready <= 1;
      byte_idx <= byte_idx + 1;
    end
endmodule
```

---

### 4.3 Cloud Aggregator (Python Server)
```python
from flask import Flask, request, jsonify
import numpy as np

app = Flask(__name__)
weights = []

@app.route('/upload', methods=['POST'])
def upload():
    global weights
    data = request.json['weights']
    weights.append(np.array(data))
    return "OK"

@app.route('/aggregate', methods=['GET'])
def aggregate():
    global weights
    avg = np.mean(weights, axis=0).tolist()
    weights = []
    return jsonify({'global_model': avg})

app.run(host='0.0.0.0', port=5000)
```

---

### 4.4 FPGA Client (Python on PYNQ)
```python
import requests, random, time

local_weights = [random.uniform(0.8, 1.2) for _ in range(4)]
for round in range(5):
    grads = [random.uniform(-0.05, 0.05) for _ in range(4)]
    local_weights = [w - 0.1*g for w,g in zip(local_weights, grads)]
    requests.post("http://192.168.1.10:5000/upload", json={'weights': local_weights})
    agg = requests.get("http://192.168.1.10:5000/aggregate").json()
    local_weights = agg['global_model']
    print(f"Round {round}: Updated weights = {local_weights}")
    time.sleep(3)
```

---

## 🧮 5. Experiment Procedure

1. Configure 2–4 FPGA boards as **edge learning nodes**.  
2. Deploy the **Flask server** on a cloud or local machine.  
3. Each FPGA node sends its **local model weights** via HTTP/MQTT.  
4. The server performs **FedAvg aggregation** and redistributes results.  
5. Visualize convergence using **Matplotlib** or **Node-RED dashboards**.  

---

## 📊 6. Observation Table

| Round | Node A Weight | Node B Weight | Global Average | Loss | Remarks |
|:-------|:---------------|:---------------|:----------------|:------|:----------|
| 0 | 1.00 | 1.20 | 1.10 | 0.45 | Init |
| 1 | 0.96 | 1.12 | 1.04 | 0.32 | Sync |
| 3 | 0.91 | 0.92 | 0.915 | 0.20 | Converging |
| 5 | 0.88 | 0.90 | 0.89 | 0.15 | Stabilized |

---

## 💡 7. Discussion Points

- How does **federated learning** enhance privacy in distributed CPS systems?  
- Why is **synchronization** important between edge and cloud nodes?  
- Compare **federated aggregation** with traditional centralized training.  
- Discuss the trade-off between **communication rate** and **convergence speed**.  

---

## 🧠 8. Post-Lab Exercises

- Extend to **3+ FPGA agents** for complete FedAvg simulation.  
- Implement **weighted averaging** based on local dataset size.  
- Integrate **cloud-based fine-tuning** using TensorFlow or PyTorch.  
- Build a **Node-RED dashboard** to visualize global weights and loss.  
- Compare **MQTT vs HTTP** for communication latency and reliability.  

---

## 🧾 9. Outcome

Students will be able to:  
- Implement **distributed learning** logic on FPGA hardware.  
- Design an **edge–cloud AI pipeline** for federated co-learning.  
- Quantify **synchronization and convergence** behavior.  
- Apply **privacy-preserving learning** in real CPS environments.  

---

## 📘 10. References

- McMahan et al., *Communication-Efficient Learning of Deep Networks from Decentralized Data*, 2017.  
- Mittal, S., *FPGA Architectures for Distributed and Federated Learning*, IEEE Access, 2023.  
- Xilinx, *Vitis AI User Guide*.  
- Lee & Seshia, *Embedded Systems: A Cyber-Physical Systems Approach*.  
- Palnitkar, *Verilog HDL: A Guide to Digital Design and Synthesis*.  

---

✅ **Author:** Dr. Komsan Kanjanasit  
**Publisher:** College of Computing, Prince of Songkla University, Thailand  
**Edition:** 1st Edition (2025)  
**License:** CC BY-NC 4.0  
