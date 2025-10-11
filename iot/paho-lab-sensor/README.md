# 🌡️ Lab: IoT Sensor Simulation using MQTT

This lab documents the implementation of a basic **Internet of Things (IoT)** data pipeline using the **MQTT protocol** to simulate a temperature sensor publishing data and a consumer script subscribing to and displaying that data.

---

## 🎯 1. Objectives

- Implement an **MQTT Publisher** simulating an IoT sensor that generates and publishes random temperature data to a specific topic.  
- Implement a **corresponding MQTT Subscriber** that connects to the same topic and receives the temperature data.  
- Establish asynchronous communication between the simulated sensor and data consumer using a **public MQTT broker**.  
- Demonstrate the use of Python’s **`random`** module for generating realistic sensor-like data.

---

## 🧠 2. Theory: MQTT and Simulated Sensing

This experiment demonstrates the **Publish/Subscribe (Pub/Sub)** model of MQTT, where the **Publisher (Sensor Simulator)** and **Subscriber (Data Consumer)** are decoupled through a central **Broker**.

### 🔹 Simulated Sensor
- The Publisher uses `random.uniform()` to generate floating-point numbers between **20.0°C** and **30.0°C**, simulating real temperature fluctuations.

### 🔹 Topic Routing
- All messages are sent via the broker under the topic:  
  ```
  test/sensor/temperature
  ```

### 🔹 Data Consumer
- The Subscriber waits passively and prints messages as the broker delivers them, representing a backend data collection system.

---

## ⚙️ 3. Materials and Setup

| Component | Description |
|------------|-------------|
| **Programming Language** | Python 3.x |
| **Libraries** | paho-mqtt, random |
| **MQTT Broker** | `broker.hivemq.com` (Port 1883) |
| **Shared Topic** | `test/sensor/temperature` |
| **Publish Interval** | 5 seconds |

---

## 🧩 4. Procedure and Code Implementation

### 4.1 MQTT Publisher (Sensor Simulator)

The Publisher generates a random temperature every 5 seconds and publishes it to the topic.

#### 💡 Key Implementation
- `random` module is used for data generation.  
- `TEMP_MIN` and `TEMP_MAX` define the temperature range.  
- The value is formatted using `f"{temperature:.2f}"` for realism.  

#### 💻 Code Snippet (Publisher)
```python
# MQTT Publisher (Sensor Simulator)
import paho.mqtt.client as mqtt
import time
import random

BROKER_ADDRESS = "broker.hivemq.com"
TOPIC = "test/sensor/temperature"
PUBLISH_INTERVAL = 5
TEMP_MIN = 20.0
TEMP_MAX = 30.0

client = mqtt.Client()
client.connect(BROKER_ADDRESS, 1883, 60)
client.loop_start()

try:
    time.sleep(1)
    while True:
        temperature = random.uniform(TEMP_MIN, TEMP_MAX)
        payload = f"{temperature:.2f}"
        client.publish(TOPIC, payload)
        print(f"Published Temperature: {payload}°C")
        time.sleep(PUBLISH_INTERVAL)
except KeyboardInterrupt:
    client.loop_stop()
    client.disconnect()
```

---

### 4.2 MQTT Subscriber (Data Consumer)

The Subscriber connects to the broker, subscribes to the same topic, and prints the received data.

#### 💡 Key Implementation
- `on_connect()` subscribes to the topic upon successful connection.  
- `on_message()` decodes the payload and converts it to a float.  
- `try-except` handles potential non-numeric data errors gracefully.

#### 💻 Code Snippet (Subscriber)
```python
# MQTT Subscriber (Data Consumer)
import paho.mqtt.client as mqtt
import time

BROKER_ADDRESS = "broker.hivemq.com"
TOPIC = "test/sensor/temperature"

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        client.subscribe(TOPIC)
        print(f"🔔 Subscribed to topic: {TOPIC}")

def on_message(client, userdata, msg):
    try:
        temperature = float(msg.payload.decode())
        print(f"➡️ Received Temperature: {temperature:.2f}°C [Topic: {msg.topic}]")
    except ValueError:
        print(f"Error: Non-numeric data received from {msg.topic}: {msg.payload.decode()}")

client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message
client.connect(BROKER_ADDRESS, 1883, 60)

try:
    print("🚀 Waiting for temperature data... Press Ctrl+C to stop.")
    client.loop_forever()
except KeyboardInterrupt:
    client.disconnect()
```

---

## 📊 5. Results and Observations

Both the Publisher and Subscriber were executed simultaneously in separate terminal windows.

### 🧾 Publisher Output (Example)
```
Connected to MQTT broker with result code 0
Publishing random temperatures to 'test/sensor/temperature' every 5 seconds.
Published Temperature: 22.51°C
Published Temperature: 28.90°C
Published Temperature: 20.15°C
```

### 🧾 Subscriber Output (Example)
```
✅ Connected successfully to MQTT broker
🔔 Subscribed to topic: test/sensor/temperature
🚀 Waiting for temperature data...
➡️ Received Temperature: 22.51°C [Topic: test/sensor/temperature]
➡️ Received Temperature: 28.90°C [Topic: test/sensor/temperature]
➡️ Received Temperature: 20.15°C [Topic: test/sensor/temperature]
```

### 🔍 Observations
- **Successful Data Flow:** Subscriber received all temperature readings with 5-second intervals.  
- **Data Parsing:** Payloads converted to floats successfully for computation.  
- **Topic Integrity:** Topic-based routing ensured correct message delivery.  
- **Asynchronous Operation:** Publisher and Subscriber worked independently via the broker.

---

## ✅ 6. Conclusion

This lab successfully simulated an **IoT temperature sensor** and **data consumer** using the MQTT protocol.  
Through random data generation and the `paho-mqtt` library, students demonstrated how **lightweight and decoupled communication** can be achieved in IoT systems.  
This exercise validates MQTT’s **efficiency, scalability, and suitability** for resource-constrained IoT applications.

---

## 📚 References

- MQTT v3.1.1 Specification — [https://mqtt.org](https://mqtt.org)  
- HiveMQ Public Broker — [https://www.hivemq.com/public-mqtt-broker](https://www.hivemq.com/public-mqtt-broker)  
- Paho-MQTT Python Client — [https://pypi.org/project/paho-mqtt](https://pypi.org/project/paho-mqtt)

---

© 2025 College of Computing, Prince of Songkla University, Phuket Campus  
*For educational use in IoT and Python Networking Labs.*
