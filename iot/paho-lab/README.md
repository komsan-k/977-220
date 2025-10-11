# 🧠 Lab: MQTT Publisher and Subscriber Implementation

This lab explores the implementation of the **Message Queuing Telemetry Transport (MQTT)** protocol for basic **Internet of Things (IoT)** communication using the **Python paho-mqtt** library.  
Two Python scripts were developed and executed:
- **Publisher** – Sends data to a topic  
- **Subscriber** – Receives and displays messages from that topic  

---

## 🎯 1. Objectives

- Establish a connection between Python clients and a **public MQTT broker** (`broker.hivemq.com`)
- Implement an **MQTT Publisher** that periodically sends a counter value to a topic  
- Implement an **MQTT Subscriber** that connects to the same topic and prints received messages  
- Demonstrate **asynchronous, decoupled communication** using the Publish/Subscribe pattern  

---

## 📘 2. Theory: MQTT Protocol

**MQTT** is a lightweight, open, and standardized messaging protocol designed for devices operating in low-bandwidth or high-latency environments — ideal for IoT systems.

### 🔑 Key Concepts

| Term | Description |
|------|--------------|
| **Publish/Subscribe** | Decouples data senders (Publishers) from receivers (Subscribers) |
| **Broker** | The central server that routes messages between clients |
| **Topic** | A routing key used to categorize messages |
| **QoS (Quality of Service)** | Defines delivery reliability: 0 = at most once, 1 = at least once, 2 = exactly once |

In this lab, the **QoS level 0** is used (At most once delivery).

---

## ⚙️ 3. Materials and Setup

| Component | Description |
|------------|-------------|
| **Programming Language** | Python 3.x |
| **Library** | paho-mqtt |
| **MQTT Broker** | `broker.hivemq.com` (Port 1883) |
| **Shared Topic** | `test/counter_topic` |

---

## 🧩 4. Procedure and Code Implementation

### 4.1 MQTT Publisher

The **Publisher** connects to the broker and periodically publishes an incrementing counter value.

#### 💻 Code Snippet (Publisher)
```python
import paho.mqtt.client as mqtt
import time

# --- Configuration ---
BROKER_ADDRESS = "broker.hivemq.com"
TOPIC = "test/counter_topic"
PUBLISH_INTERVAL = 3  # seconds

# --- Main Logic ---
client = mqtt.Client()
client.connect(BROKER_ADDRESS, 1883, 60)
client.loop_start()

counter = 0
try:
    time.sleep(1)
    while True:
        counter += 1
        payload = f"Count: {counter}"
        client.publish(TOPIC, payload)
        print(f"Published: {payload}")
        time.sleep(PUBLISH_INTERVAL)
except KeyboardInterrupt:
    client.loop_stop()
    client.disconnect()
```

---

### 4.2 MQTT Subscriber

The **Subscriber** connects to the same topic and waits for messages.

#### 💻 Code Snippet (Subscriber)
```python
import paho.mqtt.client as mqtt
import time

# --- Configuration ---
BROKER_ADDRESS = "broker.hivemq.com"
TOPIC = "test/counter_topic"

# --- Callback Functions ---
def on_connect(client, userdata, flags, rc):
    if rc == 0:
        client.subscribe(TOPIC)
        print(f"🔔 Subscribed to topic: {TOPIC}")

def on_message(client, userdata, msg):
    print(f"➡️ Received: [Topic: {msg.topic}] {msg.payload.decode()}")

# --- Main Logic ---
client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message

client.connect(BROKER_ADDRESS, 1883, 60)

try:
    print("🚀 Starting client loop. Press Ctrl+C to stop.")
    client.loop_forever()
except KeyboardInterrupt:
    client.disconnect()
```

---

## 🧠 5. Results and Observations

### 📤 Publisher Output (Example)
```
Connected to MQTT broker with result code 0
Published: Count: 1
Published: Count: 2
Published: Count: 3
```

### 📥 Subscriber Output (Example)
```
✅ Connected successfully to MQTT broker
🔔 Subscribed to topic: test/counter_topic
➡️ Received: [Topic: test/counter_topic] Count: 1
➡️ Received: [Topic: test/counter_topic] Count: 2
➡️ Received: [Topic: test/counter_topic] Count: 3
```

### 🔎 Observations
- **Successful Communication:** Subscriber receives all messages from Publisher  
- **Topic Matching:** Messages delivered only to exact topic matches  
- **Decoupled Design:** Publisher and Subscriber unaware of each other  
- **Asynchronous Operation:** Subscriber reacts to broker callbacks automatically  

---

## ✅ 6. Conclusion

The lab successfully implemented **MQTT communication** using Python.  
Two scripts — Publisher and Subscriber — demonstrated real-time data exchange via a public broker.  
This experiment confirms the effectiveness of MQTT’s **publish/subscribe model** for **IoT data transmission**, forming a solid foundation for future **IoT system design**.

---

## 📚 References

- MQTT v3.1.1 Specification — [https://mqtt.org](https://mqtt.org)  
- HiveMQ Public Broker — [https://www.hivemq.com/public-mqtt-broker](https://www.hivemq.com/public-mqtt-broker)  
- Paho-MQTT Python Client — [https://pypi.org/project/paho-mqtt](https://pypi.org/project/paho-mqtt)

---

© 2025 College of Computing, Prince of Songkla University, Phuket Campus  
*For educational use in IoT and Python Networking Labs.*
