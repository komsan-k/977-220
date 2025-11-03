# 🔬 Lab 15: FPGA–Cloud Integration and Edge AI Deployment Using Verilog SoC

## 🧩 1. Objective
This laboratory integrates **FPGA-based AI or signal-processing accelerators** with **cloud/IoT platforms** for remote monitoring and inference.  
Students will:
- Connect FPGA (SoC or PYNQ) to **cloud IoT services** (AWS IoT, ThingsBoard, or Node-RED).  
- Interface accelerators (from Lab 14) using **UART, MQTT, or HTTP**.  
- Build a **real-time Edge AI pipeline** for data acquisition, hardware acceleration, and cloud visualization.  

---

## ⚙️ 2. Equipment and Tools
| Tool / Resource | Description |
|------------------|-------------|
| **PYNQ-Z2 / Zybo / Nexys A7 FPGA** | FPGA with USB or Ethernet connectivity |
| **Vivado + Vitis / Quartus** | Hardware synthesis and programming |
| **Python (PYNQ, MQTT, Node-RED)** | Cloud communication and visualization |
| **AWS IoT / HiveMQ / ThingsBoard** | Cloud dashboard / MQTT broker |
| **Local Sensors (Optional)** | LDR, temperature, IMU inputs |

---

## 🧠 3. Background Theory

### 3.1 FPGA–Cloud Architecture
The FPGA acts as an **edge compute node**, performing inference or signal processing, and sends results to a **cloud dashboard** for real-time visualization.

```
+---------------------------+
|       Cloud Platform      |
|  ┌──────────────────────┐ |
|  │ Dashboard / Database │ |
|  └──────────────────────┘ |
|         ▲        │
|         │        ▼
|   MQTT / HTTP   API
+---------│--------+
          │
     +────▼────┐
     | FPGA SoC| ← Sensors / Accelerators
     | (Verilog + HLS IP) |
     └─────────┘
```

---

## ⚙️ 4. System Components

### 4.1 Verilog UART–Accelerator Bridge
```verilog
module UART_AccelBridge(
  input clk, rst,
  input rx,
  output tx,
  output [15:0] result
);
  wire [7:0] rx_data;
  wire rx_ready;
  reg [7:0] A, B;
  reg start;
  wire done;

  UART_RX #(50000000, 9600) RX (.clk(clk), .rst(rst), .rx(rx), .data_out(rx_data), .rx_ready(rx_ready));
  UART_TX #(50000000, 9600) TX (.clk(clk), .rst(rst), .tx(tx));

  MAC_Accelerator mac (.clk(clk), .rst(rst), .start(start), .A(A), .B(B), .result(result), .done(done));

  always @(posedge clk or posedge rst)
    if (rst)
      {A, B, start} <= 0;
    else if (rx_ready) begin
      A <= rx_data[7:4];
      B <= rx_data[3:0];
      start <= 1;
    end else
      start <= 0;
endmodule
```

---

### 4.2 Python Cloud Gateway (MQTT)
```python
import paho.mqtt.client as mqtt
import serial, time, json

# Serial link to FPGA
fpga = serial.Serial('COM3', 9600)
broker = "broker.hivemq.com"
topic = "fpga/edgeai/result"

client = mqtt.Client("FPGA_EDGE_AI")
client.connect(broker)

while True:
    if fpga.in_waiting:
        data = fpga.readline().decode().strip()
        payload = json.dumps({"timestamp": time.time(), "result": data})
        client.publish(topic, payload)
        print("Sent:", payload)
    time.sleep(0.5)
```

---

### 4.3 Node-RED / ThingsBoard Dashboard Flow
**Nodes:**
1. **MQTT IN** → subscribes to `fpga/edgeai/result`.  
2. **JSON Parser** → extracts result data.  
3. **Gauge/Chart Node** → real-time visualization.  
4. **Database Node (optional)** → stores results to MongoDB / InfluxDB.  

---

## 🧮 5. Experiment Procedure
1. Program the FPGA with your **Verilog SoC** containing the accelerator and UART bridge.  
2. Run the **Python MQTT gateway** script on your PC.  
3. Open **Node-RED / ThingsBoard dashboard** to visualize results.  
4. Send test data (from PC → FPGA) and monitor real-time cloud updates.  
5. *(Optional)* Connect sensors (LDR, Temp) to stream live data to the accelerator.  

---

## 📊 6. Observation Table
| Test # | Input (A,B) | Accelerator Output | Cloud Dashboard Value | MQTT Status |
|:-------|:-------------|:------------------:|:----------------------:|:-------------:|
| 1 | (10,5) | 50 | 50 | ✅ Sent |
| 2 | (8,3) | 74 | 74 | ✅ Sent |
| 3 | (2,4) | 82 | 82 | ✅ Sent |

---

## 💡 7. Discussion Points
- Why is **MQTT** preferred for FPGA–cloud communication?  
- How can FPGA accelerators perform **edge AI inference**?  
- Discuss **latency trade-offs** between FPGA processing and network transmission.  
- How can FPGA **power telemetry** be integrated for remote monitoring?  

---

## 🧠 8. Post-Lab Exercises
1. Extend the accelerator to perform a **2-layer neural network** and publish results to the cloud.  
2. Implement **dashboard-to-FPGA feedback control** (cloud → device).  
3. Add **local data logging** with timestamp synchronization.  
4. Compare **HTTP vs MQTT vs WebSocket** performance.  
5. Build an **Edge AI health-monitoring system** using a temperature sensor + FPGA filter accelerator.  

---

## 🧾 9. Outcome
Students will be able to:
- Integrate FPGA-based accelerators with **cloud IoT platforms**.  
- Develop **hybrid Verilog–Python–Cloud pipelines** for Edge AI.  
- Evaluate **latency, performance, and reliability** in FPGA–cloud systems.  
- Understand FPGA’s role as an **intelligent IoT node** in CPS/Edge architectures.  

---

## 📘 10. References
1. Xilinx, *PYNQ-Z2 IoT Projects and Cloud Connectivity*  
2. Xilinx, *Vitis Unified Software Platform Documentation*  
3. AWS, *IoT Core Developer Guide*  
4. HiveMQ, *MQTT Essentials*  
5. Pong P. Chu, *FPGA Prototyping by Verilog Examples*  
6. Samir Palnitkar, *Verilog HDL: A Guide to Digital Design and Synthesis*  

---

**Author:** Dr. Komsan Kanjanasit  
**Publisher:** College of Computing, Prince of Songkla University, Thailand  
**Edition:** First Edition (2025)  
**License:** CC BY 4.0 — Free to use with attribution
