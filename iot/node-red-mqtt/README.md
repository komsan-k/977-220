# 🌐 IoT Node-RED, MQTT, and Dashboard Integration

## 1. Overview

**Node-RED** is a **flow-based programming tool** that allows users to connect hardware devices, APIs, and online services through an intuitive visual interface.  
When combined with **MQTT (Message Queuing Telemetry Transport)**, Node-RED becomes a powerful platform for **Internet of Things (IoT)** applications such as data collection, real-time monitoring, and device control.

This ecosystem enables **low-code IoT integration**, allowing both beginners and professionals to design complete IoT solutions—from sensors to dashboards—without writing extensive code.

---

## 2. Node-RED Architecture

Node-RED operates as a **server-side runtime**, typically running on:
- Local computers (Windows/Linux/macOS),
- Single-board devices (e.g., Raspberry Pi),
- Cloud platforms (e.g., IBM Cloud, AWS EC2).

### Key Components

| Component | Description |
|------------|-------------|
| **Runtime Engine** | Executes flows and manages node logic. |
| **Editor (Flow Designer)** | Web-based interface at `http://localhost:1880` used to build and deploy flows. |
| **Dashboard** | Optional user interface (UI) for real-time data visualization and control widgets. |

---

## 3. MQTT in Node-RED

### 3.1 What is MQTT?
**MQTT** is a lightweight **publish/subscribe** protocol used for exchanging messages between devices and servers. It is ideal for IoT systems due to its:
- Low bandwidth consumption,
- Reliability on unstable networks,
- Simple topic-based communication model.

### 3.2 MQTT Terminology

| Term | Description |
|------|--------------|
| **Broker** | The central server that routes messages between clients. Example: `broker.hivemq.com` |
| **Publisher** | Device or application that sends (publishes) messages to a topic. |
| **Subscriber** | Device or application that listens (subscribes) to a topic to receive messages. |
| **Topic** | A string identifier used to categorize messages (e.g., `test/sensor/temperature`). |

---

## 4. Connecting MQTT in Node-RED

Node-RED includes built-in **MQTT nodes** to handle data exchange.

### 4.1 MQTT Input Node (`mqtt in`)
- **Purpose:** Subscribes to an MQTT topic and receives messages from a broker.
- **Configuration Parameters:**
  - Server: e.g., `broker.hivemq.com`
  - Port: `1883` (default, non-secure)
  - Topic: e.g., `test/sensor/temperature`
  - Output Type: String or JSON

### 4.2 MQTT Output Node (`mqtt out`)
- **Purpose:** Publishes messages to a topic on the broker.
- **Typical Use:** Sending control commands or status updates (e.g., `device/control/state`).

### Example Flow:
1. **MQTT Input** → Subscribes to `test/sensor/temperature`  
2. **Change Node** → Converts payload to a number  
3. **Gauge Node** → Displays temperature value  
4. **MQTT Output** → Publishes command back to device  

---

## 5. Node-RED Dashboard

### 5.1 Installation
To install the dashboard:
```bash
npm install node-red-dashboard
```

### 5.2 Accessing the Dashboard
After installation, open:
```
http://localhost:1880/ui
```

### 5.3 Dashboard Nodes

| Node | Function |
|------|-----------|
| **ui_gauge** | Displays live values (e.g., temperature, humidity). |
| **ui_chart** | Plots historical data trends in real-time. |
| **ui_button** | Triggers user actions (e.g., turning ON/OFF devices). |
| **ui_text** | Shows live status or messages. |

---

## 6. Example: IoT Temperature Monitoring and Control

### System Components

| Role | Tool |
|------|------|
| **Sensor Simulator** | Python (Paho MQTT Publisher) |
| **Broker** | HiveMQ (`broker.hivemq.com`) |
| **Dashboard Interface** | Node-RED |

### Workflow
1. Python script publishes temperature values to topic `test/sensor/temperature`.  
2. Node-RED’s **MQTT In Node** receives the data.  
3. A **Change Node** parses the payload.  
4. Data is displayed on a **Dashboard Gauge** and stored or plotted using a **Chart Node**.  
5. A **Button Node** allows the user to publish commands back to a topic (e.g., turning a fan ON/OFF).

---

## 7. Advantages of Node-RED + MQTT for IoT

| Feature | Description |
|----------|--------------|
| **Low-Code Development** | Build IoT systems through drag-and-drop flows. |
| **Real-Time Interaction** | Instant updates and control using dashboard widgets. |
| **Protocol Flexibility** | MQTT, HTTP, WebSocket, and Modbus supported. |
| **Scalability** | Suitable for single devices or large IoT networks. |
| **Cross-Platform** | Runs on local, cloud, or embedded systems. |

---

## 8. Example Dashboard Layout

```
-------------------------------------
| Temperature Gauge | ON/OFF Button |
-------------------------------------
|     Line Chart of Temperature     |
-------------------------------------
| Status Text: "Device is ON"       |
-------------------------------------
```

Users can monitor temperature changes, visualize trends, and toggle control states — all in real time through a web browser.

---

## 9. Summary

- **Node-RED** provides a visual, low-code environment for building IoT systems.  
- **MQTT** handles reliable, lightweight data communication between devices.  
- **Dashboards** offer a user-friendly interface for monitoring and controlling connected devices.  

Together, they form an **end-to-end IoT ecosystem**, capable of real-time data visualization, edge control, and cloud integration.
