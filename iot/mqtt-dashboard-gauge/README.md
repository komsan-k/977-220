# 🧪 Lab Manuscript: IoT Temperature Gauge Dashboard using MQTT and Tkinter

## 1. Objective
The purpose of this laboratory exercise is to **develop a real-time IoT dashboard** using Python that:
- Subscribes to live sensor data (e.g., temperature) over MQTT.  
- Displays this data dynamically on an **analog-style gauge interface** using Tkinter and Matplotlib.  
- Demonstrates integration of **IoT communication protocols**, **data visualization**, and **thread-safe GUI updates**.

This lab combines **IoT networking**, **data visualization**, and **real-time application development**.

---

## 2. Theory: MQTT and Data Visualization

### 2.1 MQTT Protocol Overview
**MQTT (Message Queuing Telemetry Transport)** is a lightweight, publish–subscribe messaging protocol designed for small sensors and mobile devices with constrained bandwidth.

- **Publisher**: Sends data (e.g., sensor temperature) to a topic.  
- **Subscriber**: Listens to that topic and receives updates.  
- **Broker**: Manages message distribution between publishers and subscribers.

In this lab, the **Publisher** periodically publishes simulated temperature readings to a topic  
(e.g., `test/sensor/temperature`), while the **Subscriber** (our Tkinter dashboard) listens to that topic and visualizes the data in real time.

### 2.2 Visualization with Tkinter and Matplotlib
- **Tkinter**: Provides the GUI framework (window, labels, layout).  
- **Matplotlib (Polar Plot)**: Used to draw a semicircular analog gauge.  
- **Queue**: Ensures thread-safe data transfer between the MQTT callback and the Tkinter main loop.

This integration forms the core of **IoT Human–Machine Interfaces (HMI)** for monitoring smart environments.

---

## 3. Materials and Setup

| Component | Description |
|------------|-------------|
| Programming Language | Python 3.x |
| Libraries | `paho-mqtt`, `tkinter`, `matplotlib`, `numpy` |
| MQTT Broker | `broker.hivemq.com` (Public Broker) |
| Topic | `test/sensor/temperature` |
| Operating System | Windows / macOS / Linux |

### 3.1 Installation Commands
Install the required Python libraries:
```bash
pip install paho-mqtt matplotlib
```

Tkinter is pre-installed with Python on most systems.  
If missing, install it manually (Linux example):
```bash
sudo apt-get install python3-tk
```

---

## 4. Procedure

### Step 1: Setup the MQTT Broker
Use a **public broker** like `broker.hivemq.com`.  
Optionally, test using an MQTT publisher (e.g., a Python script or Node-RED flow) that sends random temperature data:

```python
# Example Publisher (optional)
import paho.mqtt.client as mqtt, time, random
client = mqtt.Client()
client.connect("broker.hivemq.com", 1883, 60)
while True:
    temperature = round(random.uniform(20, 30), 2)
    client.publish("test/sensor/temperature", temperature)
    print("Published:", temperature)
    time.sleep(3)
```

---

### Step 2: Write the Subscriber (Dashboard)

**Filename:** `mqtt_gauge_subscriber.py`

(Full Python script provided in class.)

---

## 5. Results and Observations

### Expected Output
- A GUI window appears with a **semicircular temperature gauge**.  
- As the publisher sends temperature readings, the needle moves accordingly.  
- The numerical display updates dynamically.

| Component | Observation |
|------------|--------------|
| MQTT Connection | Successful connection to `broker.hivemq.com` |
| Topic Subscription | Subscribed to `test/sensor/temperature` |
| Real-time Update | Gauge needle responds to new readings within ~0.1 sec |
| Thread Safety | Tkinter updates occur smoothly without blocking |

---

## 6. Discussion

This lab demonstrates:
- **MQTT interoperability** with Python GUIs.  
- **Thread-safe data visualization** using `SimpleQueue` to isolate network I/O from the UI thread.  
- **Polar coordinate plotting** to simulate analog instrumentation.  
- A scalable foundation for **IoT dashboards** that can be extended with:
  - Multiple gauges (e.g., humidity, CO₂)
  - Warning zones (color-coded arcs)
  - Database or cloud logging

---

## 7. Conclusion

The experiment successfully implemented a **real-time IoT dashboard** using MQTT and Tkinter, displaying live sensor data on a gauge interface.  
This project demonstrates the **integration of IoT communication, GUI programming, and data visualization**, fundamental to modern smart applications.

---

## 8. Exercises
1. Modify the gauge to display humidity (0–100%) with blue color.  
2. Add a digital thermometer widget showing the average temperature.  
3. Combine multiple MQTT topics (temperature, humidity, light) into one dashboard.  
4. Create color zones (green/yellow/red) to indicate safe and high temperature levels.  
5. Extend the dashboard to log temperature values into a CSV file.

---

## 9. References
- Eclipse Foundation, *MQTT Specification v5.0*, 2019.  
- Matplotlib Documentation: [https://matplotlib.org](https://matplotlib.org)  
- Tkinter GUI Guide: [https://docs.python.org/3/library/tkinter.html](https://docs.python.org/3/library/tkinter.html)  
- HiveMQ Public Broker: [https://www.hivemq.com/public-mqtt-broker/](https://www.hivemq.com/public-mqtt-broker/)

