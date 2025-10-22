# 🧩 Lab: Installing and Testing a Local Mosquitto MQTT Broker (IPv4 Configuration)

## 1. Objective
This laboratory exercise guides students through installing, configuring, and testing a **local MQTT broker** using **Eclipse Mosquitto**.  
Students will learn to:
- Install and verify the Mosquitto MQTT broker on Windows, Linux, or Raspberry Pi.  
- Configure Mosquitto to work properly on **IPv4 networks**.  
- Test publish/subscribe operations using both CLI tools and an ESP32 MQTT client.  
- Understand local vs. cloud MQTT architecture.

---

## 2. Background Theory

### 2.1 MQTT Overview
**MQTT (Message Queuing Telemetry Transport)** is a lightweight publish/subscribe protocol for IoT communication.

| Role | Function |
|------|-----------|
| **Publisher** | Sends data (e.g., temperature, LDR). |
| **Subscriber** | Receives data from a topic. |
| **Broker** | Handles all message routing between clients. |

### 2.2 Why Use a Local Broker?
- Works **offline** in local LAN networks.  
- Provides **low latency** and **data privacy**.  
- Ideal for **classroom and lab experiments**.  

---

## 3. Required Components

| Component | Quantity | Description |
|------------|-----------|-------------|
| ESP32 DevKit | 1 | IoT microcontroller with Wi-Fi |
| LM73 / LM75 / TMP102 | 1 | I²C temperature sensor |
| Computer / Raspberry Pi | 1 | To host Mosquitto broker |
| Wi-Fi Router | 1 | Connects ESP32 and PC in same LAN |
| MQTT Explorer / MQTT.fx | 1 | For visual MQTT testing |
| USB Cable | 1 | Power and programming |

---

## 4. Installing Mosquitto Broker

### 🖥️ Windows Installation
1. Download the installer from  
   🔗 [https://mosquitto.org/download](https://mosquitto.org/download)
2. Enable:
   - ✅ *Install Service*
   - ✅ *Launch Broker Automatically at Startup*
3. Verify installation:
   ```bash
   mosquitto -v
   ```
   Expected output:
   ```
   mosquitto version 2.x starting
   Opening ipv4 listen socket on port 1883.
   ```

### 🐧 Linux / Raspberry Pi Installation
```bash
sudo apt update
sudo apt install mosquitto mosquitto-clients -y
sudo systemctl enable mosquitto
sudo systemctl start mosquitto
mosquitto -v
```

---

## 5. Configuring Mosquitto for IPv4 Operation

### 5.1 Locate or Create the Config File
- **Linux**: `/etc/mosquitto/mosquitto.conf`  
- **Windows**: `C:\Program Files\mosquitto\mosquitto.conf`

### 5.2 Edit Configuration
Add or modify these lines:
```conf
# ==============================
# Mosquitto IPv4 Configuration
# ==============================

# Listen on all IPv4 interfaces
listener 1883 0.0.0.0

# Allow anonymous access for testing (disable later for security)
allow_anonymous true

# Enable logging
log_dest file /var/log/mosquitto/mosquitto.log
log_type all

# Enable message persistence
persistence true
persistence_location /var/lib/mosquitto/
```

### 5.3 Restart the Service
```bash
sudo systemctl restart mosquitto
sudo systemctl status mosquitto
```
✅ Expected output:
```
Active: active (running)
Listening on port 1883 (IPv4)
```

---

## 6. Testing the Broker

### 6.1 Local Test with CLI
**Terminal 1 (Subscriber):**
```bash
mosquitto_sub -h localhost -t "test/topic"
```
**Terminal 2 (Publisher):**
```bash
mosquitto_pub -h localhost -t "test/topic" -m "Hello MQTT"
```
✅ Output:
```
Hello MQTT
```

### 6.2 Test Over LAN
Find your PC IP:
```bash
ipconfig   # Windows
ifconfig   # Linux
```
Test from another device:
```bash
mosquitto_sub -h 192.168.1.10 -t "test/topic"
mosquitto_pub -h 192.168.1.10 -t "test/topic" -m "Message over LAN"
```

---

## 7. ESP32 Integration
Modify your ESP32 code:
```cpp
const char* BROKER_ADDRESS = "192.168.1.10";  // Replace with PC IP
const int BROKER_PORT = 1883;
```
Verify output in Serial Monitor:
```
✅ WiFi connected, IP: 192.168.1.45
Attempting MQTT connection... connected
✅ Published Temp to esp32/temperature: 28.37 °C
```

---

## 8. Lab Tasks

| Task | Description | Expected Outcome |
|------|--------------|------------------|
| **Task 1** | Install Mosquitto and verify service. | Broker active and running on IPv4. |
| **Task 2** | Edit `mosquitto.conf` to allow IPv4 access. | `Opening ipv4 listen socket on port 1883` visible. |
| **Task 3** | Test with `mosquitto_pub` and `mosquitto_sub`. | Subscriber receives messages. |
| **Task 4** | Connect ESP32 publisher to local broker. | ESP32 data visible on local subscriber. |
| **Task 5** | Use MQTT Explorer or Node-RED dashboard. | Real-time visualization achieved. |

---

## 9. Discussion Questions
1. Why is `listener 1883 0.0.0.0` necessary in Mosquitto 2.x?  
2. How does IPv4 configuration differ from IPv6 (`::`)?  
3. What are the advantages of local brokers for IoT prototyping?  
4. How can TLS or authentication improve security?  
5. How could Node-RED or ThingSpeak extend this setup?

---

## 10. Example Outputs

**Broker Console:**
```
Opening ipv4 listen socket on port 1883.
New connection from 192.168.1.45
Client ESP32-I2C-Temp-Publisher connected.
```

**ESP32 Serial Monitor:**
```
✅ Published Temp to esp32/temperature: 26.88 °C
✅ Published Temp to esp32/temperature: 27.06 °C
```

---

## 11. Conclusion
In this lab, a **local Mosquitto MQTT broker** was successfully installed, configured, and verified for **IPv4 communication**.  
Students learned to integrate the broker with an **ESP32 temperature publisher**, test message flow, and monitor real-time IoT data using **CLI and GUI tools**.  
This forms the foundation for **secure, low-latency IoT networks** in educational and research environments.

---

## 12. References
- Eclipse Foundation. *Mosquitto MQTT Documentation* – [https://mosquitto.org](https://mosquitto.org)  
- Espressif Systems. *ESP32 Technical Reference Manual*  
- HiveMQ. *Public MQTT Broker Documentation*  
- Kanjanasit, K. (2025). *IoT Laboratory Series*, College of Computing, PSU–Phuket.  

---

📅 *End of Lab Report: Local Mosquitto MQTT Broker Configuration (IPv4)*
