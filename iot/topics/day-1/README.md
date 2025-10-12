# 🌐 Internet of Things (IoT) Architecture

The **Internet of Things (IoT)** architecture defines how connected devices, networks, cloud systems, and applications interact to collect, process, and use data intelligently.  
It provides a structured framework for designing IoT systems that can sense, communicate, process, and act upon real-world information.

---

## 1. Overview

IoT architecture describes the **layered structure** that connects physical devices (“things”) to the digital world.  
It ensures that sensors, actuators, gateways, cloud services, and user interfaces work together seamlessly.

At its core, the IoT architecture answers:

- 🟢 **What is sensed?** → Devices and sensors  
- 🟠 **How is data transmitted?** → Communication protocols  
- 🔵 **Where is data processed?** → Edge, fog, or cloud  
- ⚪ **How is information used?** → Applications and analytics  

---

## 2. Classical 3-Layer IoT Architecture

The **three-layer architecture** is the most fundamental model used to describe IoT systems.

### (a) Perception Layer (Sensing Layer)
**Function:** Collects data from the physical environment.  
**Components:** Sensors (temperature, light, motion), actuators, RFID tags, cameras.  

**Key Roles:**
- Identification of objects (e.g., RFID, barcodes)  
- Data acquisition from the physical world  
- Signal conversion (analog → digital)

**Example:**  
A temperature sensor reads **28°C** and sends the data to a microcontroller.

---

### (b) Network Layer (Transmission Layer)
**Function:** Transfers data from the perception layer to processing systems.  
**Technologies:** Wi-Fi, Bluetooth, ZigBee, LoRa, NB-IoT, 4G/5G, Ethernet, MQTT, HTTP.

**Key Roles:**
- Reliable data transmission  
- Communication between nodes and servers  
- Network addressing and routing  

**Example:**  
An **ESP32** sends sensor data via **MQTT** to a cloud broker.

---

### (c) Application Layer
**Function:** Provides application-specific services to users.  
**Examples:** Smart home apps, industrial dashboards, health monitoring platforms.

**Key Roles:**
- Data visualization  
- Decision-making and control  
- User interface and interaction  

**Example:**  
A mobile app displays humidity trends and allows a user to control a fan.

---

## 3. Five-Layer IoT Architecture (Extended Model)

For complex systems, a **five-layer architecture** adds detail between data transmission and application logic.

| Layer | Function | Example Technologies |
|-------|-----------|----------------------|
| Perception | Physical sensing and actuation | Sensors, RFID, Cameras |
| Transport | Data transfer protocols | MQTT, CoAP, HTTPS, AMQP |
| Processing (Middleware) | Data storage, analytics, decision-making | Cloud, Edge, Fog |
| Application | User-facing services | Smart grid, Smart healthcare |
| Business | System management and strategy | Billing, Service models |

**Purpose:**  
Connects technical operations to business goals, enabling scalability and service management.

---

## 4. IoT Reference Architecture (Cloud-Centric)

Modern IoT systems often use a **multi-tier, cloud-based architecture**, structured as follows:

| Layer | Description | Example Technologies |
|--------|--------------|----------------------|
| Device Layer | Sensors, actuators, microcontrollers | Arduino, ESP32, Raspberry Pi |
| Edge Layer | Local computation, filtering | Edge AI, TinyML, Fog nodes |
| Communication Layer | Network and protocol stack | Wi-Fi, LoRa, MQTT, 5G |
| Cloud Layer | Data storage, analytics, control | AWS IoT, Azure IoT Hub, Google Cloud IoT |
| Application Layer | Visualization and management | Node-RED dashboard, mobile apps |

---

## 5. Data Flow in IoT

1. **Sense:** Devices measure physical parameters.  
2. **Preprocess:** Data filtered or averaged at the edge to reduce noise.  
3. **Transmit:** Data sent to gateways or cloud using communication protocols.  
4. **Store:** Data stored in databases or data lakes.  
5. **Analyze:** Cloud or AI models derive insights (e.g., predictive maintenance).  
6. **Act:** Control commands or user notifications are sent back.

---

## 6. Security and Management Layers

IoT systems often include **cross-layer functions** to ensure reliability and safety:

- 🔐 **Security:** Authentication, encryption, and privacy  
- ⚙️ **Device Management:** Registration, configuration, OTA updates  
- 🗄️ **Data Management:** Data integrity, timestamping, and access control  

---

## 7. Example Use Case: Smart Agriculture

| Layer | Example Function |
|-------|------------------|
| Perception | Soil moisture, temperature, and pH sensors |
| Network | LoRaWAN or Wi-Fi for data transmission |
| Processing | Edge device filters and averages sensor data |
| Cloud | AWS IoT analyzes long-term soil trends |
| Application | Dashboard or mobile app controls irrigation pump |

---

## 8. Summary Table

| Layer | Function | Example |
|-------|-----------|---------|
| Perception | Data collection | Sensors, RFID |
| Network | Communication | Wi-Fi, LoRa, MQTT |
| Processing | Data management & analytics | Cloud/Fog computing |
| Application | End-user interaction | Dashboards, alerts |
| Business | Strategic and operational decisions | Billing, service models |

---

## 9. Key Takeaways

- IoT architecture bridges **physical and digital worlds**.  
- It can be modeled as **3-layer**, **5-layer**, or **cloud-centric** systems.  
- **Edge, fog, and cloud computing** define where data processing occurs.  
- **Security**, **scalability**, and **interoperability** are essential for real-world IoT deployments.

---

📘 *Prepared as part of the IoT Systems and Architecture Lab Documentation.*

