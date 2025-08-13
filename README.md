# 977-220


# Internet of Things: Concepts, Design, and Practice

## Preface
This textbook provides a concise yet comprehensive foundation for the Internet of Things (IoT)—from concepts and architectures to device design, platforms, data and analytics, application development, and hands-on laboratories. It is intended for senior undergraduate or graduate students in Electrical and Computer Engineering, Computer Science, or related disciplines, as well as practitioners who need a structured, practical guide.

Each chapter opens with learning objectives and closes with a chapter bibliography and exercises. The laboratory chapter uses ESP32, Wi‑Fi, Bluetooth Low Energy (BLE), Mosquitto MQTT, Python, and Node‑RED. This modular structure should support project-driven courses and self-paced learning.

The author thanks the open-source community and the many researchers whose work has shaped the field. Any errors are the author's own—please send corrections and suggestions for future editions.

---

## Chapter 1: IoT Concepts and Design Fundamentals

### Learning Objectives
- Explain the evolution and scope of the Internet of Things (IoT).
- Identify the key components and layers of IoT systems.
- Interpret common IoT reference architectures.
- Analyze design trade-offs related to power, scalability, and security.

### Introduction to IoT
The Internet of Things (IoT) refers to the network of physical devices embedded with sensors, actuators, computing capability, and connectivity, enabling them to collect, exchange, and act upon data. IoT has evolved from earlier machine-to-machine (M2M) communication systems, expanding to heterogeneous devices interacting across local and wide-area networks and cloud services.

The progression of IoT can be categorized into phases:
1. **IoT 1.0** — Connecting devices with basic sensing and control.
2. **IoT 2.0** — Interoperability, cloud integration, data analytics at scale.
3. **IoT 3.0** — AI-enabled autonomy, edge computing, and semantic interoperability.

Representative domains include smart cities, healthcare, industrial IoT (IIoT), and precision agriculture.

### Core Components of IoT Systems
- **Sensors and Actuators** — Measure physical parameters and perform actions.
- **Embedded Controllers** — Handle local processing (e.g., ESP32, STM32).
- **Communication Modules** — Wi‑Fi, BLE, Zigbee, LoRaWAN, NB‑IoT, Ethernet.
- **Data Processing Units** — Gateways and edge devices reduce latency.

### IoT Reference Architectures
- **Three-Layer Architecture** — Perception, Network, Application.
- **Five-Layer Architecture** — Adds Edge/Processing and Middleware layers.
- **IoT-A / ISO/IEC Frameworks** — Structured guidance for security, privacy, and manageability.

### Design Considerations
- **Power Efficiency** — Low-power MCUs, sleep modes, duty cycling.
- **Scalability & Interoperability** — Modular design and open protocols.
- **Security & Privacy** — End-to-end encryption, mutual authentication, secure boot.
- **Regulatory Compliance** — Standards such as ISO 27001.

---

## Chapter 2: Development of IoT End Nodes

### Learning Objectives
- Select microcontrollers, sensors, and actuators.
- Integrate hardware components.
- Apply power management strategies.
- Develop and debug embedded firmware.

**Topics include:**
- Hardware selection (ESP32, STM32, RP2040).
- Sensor and actuator interfacing.
- Power management (deep sleep, duty cycling, energy harvesting).
- Firmware development (Arduino IDE, PlatformIO, ESP-IDF).
- Testing and debugging.

---

## Chapter 3: IoT Platforms and Device Connectivity

**Covers:**
- Short-range protocols (Wi‑Fi, BLE, Zigbee, Z-Wave).
- Long-range protocols (LoRaWAN, NB‑IoT, LTE-M).
- Networking (IPv6, 6LoWPAN, mesh topologies).
- Platforms (AWS IoT Core, Azure IoT Hub, Google Cloud IoT, ThingsBoard, Node‑RED).
- Security in connectivity (TLS/DTLS, X.509, secure boot).

---

## Chapter 4: IoT Data Processing and Analytics

**Covers:**
- Data acquisition, preprocessing, normalization.
- Storage (edge storage, cloud storage, time-series databases).
- Real-time and batch processing.
- Analytics: descriptive, predictive, prescriptive.
- AI/ML for IoT (TinyML, anomaly detection).
- Visualization with Grafana, Kibana.

---

## Chapter 5: IoT Application Development

**Covers:**
- Application lifecycle (requirements, prototyping, scaling).
- Frameworks: Flutter, React Native, Node.js, REST/WebSockets.
- Edge-to-cloud integration (MQTT, HTTP, CoAP).
- Deployment and maintenance (CI/CD, OTA updates, monitoring).
- Case studies (smart home automation, predictive maintenance).

---

## Chapter 6: IoT Laboratory Practice

**Covers:**
- Programming ESP32 with Wi‑Fi and BLE.
- MQTT messaging with Mosquitto.
- Python MQTT clients for logging and processing.
- Node‑RED dashboards and bidirectional control.
- Ten labs from ESP32 setup to a full smart home monitor project.

---

**Note:** For full exercises and bibliographies, refer to the complete LaTeX source or compiled PDF.
