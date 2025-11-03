# 🔬 Lab 18: Cyber-Physical FPGA System with Real-Time Control and Digital Twin Visualization

## 🧩 1. Objective
This lab guides students in designing and implementing an **FPGA-based cyber-physical control system** that operates in real-time and interacts with a **digital twin dashboard**.  

Students will:
- Interface FPGA with **sensors** (analog or I²C).
- Compute control responses (PID or threshold logic) in **hardware logic**.
- Publish sensor and actuator data to a **digital twin dashboard** via MQTT/HTTP.
- Synchronize **physical and virtual systems** in real-time.  

---

## ⚙️ 2. Equipment and Tools
| Tool / Resource | Description |
|------------------|-------------|
| **FPGA Board (Basys 3 / PYNQ-Z2 / Zybo Z7)** | With analog or I²C input support |
| **Vivado / ModelSim / Vitis HLS** | Design, synthesis, and verification tools |
| **Python (PYNQ / MQTT / Node-RED)** | Dashboard and data-twin interface |
| **LDR / TMP102 / MPU6050** | Example sensors |
| **LED / Servo / Motor driver** | Actuators for response testing |
| **Cloud MQTT Broker / ThingsBoard / Node-RED** | Digital twin visualization backend |

---

## 🧠 3. Background Theory

### 3.1 Cyber-Physical Systems (CPS)
CPS integrate **computation**, **communication**, and **physical processes** into a closed-loop control system.

```
        +--------------------------+
        |        Cloud / GUI       |
        |   Digital-Twin Dashboard |
        +------------▲-------------+
                     │  MQTT / HTTP
   ┌─────────────────┼─────────────────┐
   │   FPGA SoC (CPS Core)            │
   │ Sensors → Control Logic → Actuators │
   └─────────────────┼─────────────────┘
                     │  Physical World
               [Temperature, Light, Motion]
```

### 3.2 PID Control in Hardware
A discrete-time PID controller calculates control output as:

\( u(t) = K_p e(t) + K_i \int e(t) dt + K_d \frac{d e(t)}{dt} \)

where \( e(t) = \text{desired} - \text{measured} \).  
Hardware PID logic ensures deterministic timing and high-speed feedback.

---

## ⚙️ 4. Verilog Implementation

### 4.1 Sensor Interface (ADC / I²C Input)
```verilog
module Sensor_IF (
  input clk, rst,
  input [11:0] sensor_in,    // from ADC or I²C interface
  output reg [11:0] sensor_value
);
  always @(posedge clk or posedge rst)
    if (rst) sensor_value <= 0;
    else     sensor_value <= sensor_in;
endmodule
```

### 4.2 PID Controller
```verilog
module PID_Controller(
  input clk, rst,
  input [11:0] setpoint,
  input [11:0] feedback,
  output reg [11:0] control
);
  parameter Kp = 2, Ki = 1, Kd = 1;
  reg signed [15:0] error, prev_error, integral, derivative;

  always @(posedge clk or posedge rst)
    if (rst) begin
      error <= 0; prev_error <= 0; integral <= 0; control <= 0;
    end else begin
      error <= setpoint - feedback;
      integral <= integral + error;
      derivative <= error - prev_error;
      control <= (Kp*error + Ki*integral + Kd*derivative);
      prev_error <= error;
    end
endmodule
```

### 4.3 Actuator Driver (LED or PWM)
```verilog
module Actuator_IF(
  input clk,
  input [11:0] control,
  output reg pwm_out
);
  reg [11:0] counter;
  always @(posedge clk)
    counter <= counter + 1;
  always @(*) pwm_out = (counter < control);
endmodule
```

### 4.4 Top-Level CPS Integration
```verilog
module CPS_Top(
  input clk, rst,
  input [11:0] sensor_in,
  input [11:0] setpoint,
  output pwm_out
);
  wire [11:0] feedback, control;
  Sensor_IF sensor (.clk(clk), .rst(rst), .sensor_in(sensor_in), .sensor_value(feedback));
  PID_Controller pid (.clk(clk), .rst(rst), .setpoint(setpoint), .feedback(feedback), .control(control));
  Actuator_IF act (.clk(clk), .control(control), .pwm_out(pwm_out));
endmodule
```

---

## 🌐 5. Digital-Twin Integration (Python + MQTT)
```python
import serial, paho.mqtt.client as mqtt, json, time

ser = serial.Serial('COM4', 115200)
client = mqtt.Client("FPGA_CPS_Node")
client.connect("broker.hivemq.com")

while True:
    val = int(ser.readline().decode().strip())
    payload = json.dumps({"timestamp": time.time(), "sensor": val})
    client.publish("fpga/cps/sensor", payload)
    print("Sent:", payload)
```

**Node-RED Flow:**  
```
MQTT IN → JSON Parser → Gauge + Chart → Dashboard
(Optional) HTTP OUT for Digital Twin synchronization
```

---

## 🧮 6. Experiment Procedure
1. Implement **CPS_Top** in Vivado and connect ADC/I²C input.  
2. Attach sensor and actuator to FPGA I/O pins.  
3. Add UART transmitter logic to send sensor data.  
4. Run the **Python MQTT bridge** to publish live readings.  
5. Open the **Node-RED dashboard** to visualize data.  
6. Adjust setpoint and observe synchronized FPGA ↔ dashboard behavior.

---

## 📊 7. Observation Table
| Time (s) | Setpoint | Sensor | Control | Actuator Duty (%) | Dashboard Status |
|-----------|-----------|---------|----------|------------------|------------------|
| 0 | 512 | 400 | 112 | 22 | OK |
| 2 | 512 | 480 | 32 | 6 | OK |
| 4 | 512 | 505 | 7 | 1 | Steady |

---

## 💡 8. Discussion Points
- How does **FPGA latency** impact real-time control?  
- Compare **PID hardware vs software** implementations (speed, determinism).  
- What are the benefits of **local control with cloud visualization**?  
- How can **digital twins** enhance predictive maintenance?  

---

## 🧠 9. Post-Lab Exercises
1. Implement an **auto-tuning PID** using Vitis HLS.  
2. Add **multi-sensor fusion** (temperature + light).  
3. Integrate an **AI-based anomaly detector**.  
4. Implement **bidirectional twin feedback** from dashboard → FPGA.  
5. Measure closed-loop **latency and bandwidth**.  

---

## 🧾 10. Outcome
Students will be able to:
- Build a **real-time feedback controller** in FPGA hardware.  
- Connect physical and virtual systems using **digital-twin dashboards**.  
- Integrate **sensor input, computation, and actuation** within a single FPGA node.  
- Evaluate **CPS stability and synchronization**.  

---

## 📘 11. References
1. Xilinx UG902 – *Vivado Designing with IP Integrator*  
2. IEEE 1451 – *Smart Transducer Interface Standard*  
3. Lee & Seshia – *Introduction to Embedded Systems: A Cyber-Physical Systems Approach*  
4. Samir Palnitkar – *Verilog HDL: A Guide to Digital Design and Synthesis*  
5. Pong P. Chu – *FPGA Prototyping by Verilog Examples*  

---

**Author:** Dr. Komsan Kanjanasit  
**Publisher:** College of Computing, Prince of Songkla University, Thailand  
**Edition:** First Edition (2025)  
**License:** CC BY 4.0 – Free for academic and research use.
