# 🛰️ Bidirectional IoT Communication and Control using Node-RED and Paho MQTT

## 🧩 Abstract
This experiment demonstrates the implementation of a **bidirectional IoT communication system** for remote monitoring and control using the lightweight **MQTT (Message Queuing Telemetry Transport)** protocol.  
A **Node-RED** environment was used as the central logic and visualization platform, connected to the public **HiveMQ** broker.  

The project successfully achieved two core goals:
1. **Unidirectional Data Monitoring** — subscribing to live floating-point temperature data published by a **Python Paho-MQTT script**.  
2. **Bidirectional Device Control** — enabling a user to send ON/OFF commands through a Node-RED dashboard and track interactions using an incremental counter.

The results confirm Node-RED and MQTT as effective tools for creating responsive, low-latency IoT control applications.

---

## ⚙️ 1. Introduction
The **Internet of Things (IoT)** depends on efficient communication between distributed devices and central systems.  
**MQTT**, based on a **publish/subscribe** model, is the most widely adopted protocol for lightweight IoT communication.  

**Node-RED**, a visual programming environment, allows users to rapidly prototype, integrate, and visualize data from IoT systems.  
This lab integrates Node-RED with the **Python Paho-MQTT** client to demonstrate both **data ingestion** (temperature sensor simulation) and **command publication** (remote control logic).

---

## 🎯 2. Objectives
The main objectives of this laboratory exercise are:

1. **Unidirectional Monitoring:**  
   Configure a Node-RED flow to subscribe to the topic  
   `test/sensor/temperature` and display temperature data published by a **Python Paho-MQTT script**.

2. **Bidirectional Control:**  
   Create a Node-RED dashboard button to:
   - Toggle and publish ON/OFF device states.
   - Maintain an incremental counter for command frequency.

3. **Data Verification:**  
   Validate the integrity and format of MQTT payloads for both temperature monitoring and device control.

---

## 🏗️ 3. Methodology

### 3.1 System Architecture
The system is based on a **star topology** using the **HiveMQ MQTT Broker**.  
**Node-RED** serves as the control and visualization interface, while **Python Paho-MQTT** functions as the temperature publisher.

| Component | Role | Configuration |
|------------|------|----------------|
| **Server** | Node-RED Host | Local PC / Cloud Instance |
| **MQTT Broker** | Messaging Backbone | `broker.hivemq.com:1883` |
| **Sensor Client** | Paho Publisher | Python Paho-MQTT Script |
| **Control Interface** | Dashboard + Logic | Node-RED Dashboard |

---

### 3.2 Paho Sensor Client Configuration
The **Python Publisher** simulates a temperature sensor that generates and publishes data as a **floating-point string** every 5 seconds.

**Configuration:**
- **Broker:** `broker.hivemq.com`
- **Topic:** `test/sensor/temperature`
- **Interval:** 5 seconds
- **Payload:** Floating-point string, e.g., `"25.42"`

**Example Publisher Code:**
```python
import paho.mqtt.client as mqtt
import time, random, json

# --- MQTT Configuration ---
BROKER = "broker.hivemq.com"
PUB_TOPIC = "test/sensor/temperature"
SUB_TOPIC = "device/control/state"

# --- Callback: Connection Established ---
def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("✅ Connected to MQTT broker successfully.")
        client.subscribe(SUB_TOPIC)
        print(f"📡 Subscribed to topic: {SUB_TOPIC}")
    else:
        print(f"❌ Connection failed with code {rc}")

# --- Callback: Message Received ---
def on_message(client, userdata, msg):
    try:
        payload = msg.payload.decode()
        print(f"📥 Received from {msg.topic}: {payload}")

        # Try to parse JSON payload (if structured control command)
        try:
            data = json.loads(payload)
            if "state" in data:
                state = data["state"]
                print(f"🟢 Device Command: State set to {state}")
        except json.JSONDecodeError:
            print("⚠️ Non-JSON message received.")

    except Exception as e:
        print(f"Error processing message: {e}")

# --- Initialize Client ---
client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message

client.connect(BROKER, 1883, 60)
client.loop_start()

# --- Main Loop: Publish Temperature ---
try:
    while True:
        temperature = round(random.uniform(20.0, 30.0), 2)
        client.publish(PUB_TOPIC, str(temperature))
        print(f"🌡️ Published Temperature: {temperature} °C")
        time.sleep(5)

except KeyboardInterrupt:
    print("\n🛑 KeyboardInterrupt detected, disconnecting...")
    client.loop_stop()
    client.disconnect()
    print("🔌 Disconnected from MQTT broker.")

```

---

### 3.3 Node-RED Flow Implementation
The Node-RED flow is divided into two subsystems:

#### A. Temperature Monitoring
1. **MQTT-In Node**
   - Server: `broker.hivemq.com`
   - Topic: `test/sensor/temperature`
   - Output Type: `string`

2. **Change Node**
   - Converts string to numeric:  
     `msg.payload = number(msg.payload)`

3. **Gauge Node**
   - Displays temperature in real-time on Node-RED Dashboard.

---

#### B. Device Control with Counter
Although the Paho publisher only sends data, Node-RED implements a parallel **control path** to send structured command data.

1. **Button Node:** Sends ON/OFF commands.  
2. **Change Node:** Manages state (`flow.device_state`) and counter (`flow.command_count`).
3. **JSON Payload:**
   ```json
   { "state": "ON", "press_count": 3 }
   ```
4. **MQTT-Out Node:** Publishes control data to `device/control/state`.
5. **Text Node:** Displays current state and command count on the dashboard.

---

## 📈 4. Results and Discussion

### 4.1 Temperature Monitoring
The Node-RED flow successfully received periodic temperature updates from the Python publisher every 5 seconds via the `test/sensor/temperature` topic.

| Parameter | Observation |
|------------|-------------|
| Payload Format | Floating-point string |
| Conversion | Correctly parsed to numeric |
| Visualization | Real-time updates on Gauge Node |
| Broker | Stable connection with `broker.hivemq.com` |

✅ **Result:** Smooth, low-latency data updates confirm the Paho publisher integration and accurate Node-RED visualization.

---

### 4.2 Command Publishing
The Node-RED dashboard successfully published structured ON/OFF commands and maintained an internal counter.

| Command Action | Count | Payload | Status |
|----------------|--------|----------|---------|
| First Click | 1 | `{ "state": "ON", "press_count": 1 }` | ✅ Published |
| Second Click | 2 | `{ "state": "OFF", "press_count": 2 }` | ✅ Published |

This validates Node-RED’s **bidirectional capability**, even when the external client (Python script) does not yet subscribe to the control topic.

---

## ✅ 5. Conclusion
The experiment achieved successful integration between **Node-RED** and **Python Paho-MQTT** clients for **IoT data monitoring** and **control**.

- Temperature data was transmitted, subscribed, and visualized in real time.  
- Node-RED effectively published structured control messages (ON/OFF + counter).  
- HiveMQ’s public broker demonstrated reliable message delivery.

This confirms the feasibility of using Node-RED as a supervisory control interface for distributed IoT environments.

---

## 🔭 6. Future Work
1. **Full Bidirectional Communication:**  
   Modify the Python script to **subscribe** to `device/control/state` and respond to commands.

2. **Persistent Data Storage:**  
   Store the command counter using file-based or database context persistence in Node-RED.

3. **Security Improvements:**  
   Transition to a private MQTT broker with **TLS/SSL encryption** and **user authentication**.

4. **Extended Dashboard:**  
   Add temperature history plots and alert triggers for threshold values.

---

## 📚 References
- Eclipse Foundation, *MQTT Specification v5.0*, 2019.  
- Node-RED Documentation: [https://nodered.org/docs](https://nodered.org/docs)  
- HiveMQ Public Broker: [https://www.hivemq.com/public-mqtt-broker/](https://www.hivemq.com/public-mqtt-broker/)  
- Paho MQTT Client Library: [https://www.eclipse.org/paho/](https://www.eclipse.org/paho/)
