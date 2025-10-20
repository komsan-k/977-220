# 🌍 Lab: ESP32 MQTT Publishing of LDR Sensor Data (Wi-Fi and Cloud IoT Integration)

## 🧩 1. Objective

This laboratory exercise integrates **analog sensing**, **network connectivity**, and **cloud data publishing** using an **ESP32 microcontroller**.  
Students will learn to:
- Read analog data from an **LDR (Light Dependent Resistor)** via ESP32’s ADC.
- Establish a **Wi-Fi connection** using the built-in `WiFi.h` library.
- Publish sensor data to a public **MQTT broker (HiveMQ)** using the `PubSubClient` library.
- Understand message-based IoT communication for real-time monitoring applications.

---

## ⚙️ 2. Background Theory

### 2.1 Light Dependent Resistor (LDR)
An **LDR**, also known as a **photoresistor**, changes its resistance based on the amount of light falling on it:
- **Bright Light → Low Resistance → High ADC Reading**
- **Darkness → High Resistance → Low ADC Reading**

The output voltage (to the ESP32 ADC pin) is obtained through a **voltage divider** circuit:

Vout = Vin × (Rfixed / (RLDR + Rfixed))

### 2.2 MQTT Communication Model
**MQTT (Message Queuing Telemetry Transport)** is a lightweight, publish–subscribe protocol ideal for IoT communication.

| Role | Description |
|------|--------------|
| **Publisher** | Device that sends messages to a topic. |
| **Subscriber** | Device/application that receives messages. |
| **Broker** | Server that routes messages between publishers and subscribers. |

This lab configures the ESP32 as an **MQTT Publisher** that sends sensor data to the public broker `broker.hivemq.com`.

### 2.3 ESP32 ADC Overview
- **ADC Range:** 0–3.3V → digital output (0–4095).  
- **Pin Used:** GPIO 36 (ADC1_CH0).  
- **Resolution:** 12-bit analog input.  

---

## 🧰 3. Required Components

| Component | Quantity | Description |
|------------|-----------|-------------|
| ESP32 DevKit | 1 | Wi-Fi-enabled microcontroller |
| LDR Sensor | 1 | Light-dependent resistor |
| 10 kΩ Resistor | 1 | Voltage divider resistor |
| Breadboard & Jumpers | – | For prototyping |
| USB Cable | 1 | Power and programming |
| Wi-Fi Network | – | For Internet access |
| MQTT Broker | – | HiveMQ Public Server (broker.hivemq.com) |

---

## 🔌 4. Circuit Wiring

| Component | Connected To |
|------------|---------------|
| LDR Pin 1 | 3.3V (VCC) |
| LDR Pin 2 | GPIO 36 (Analog Input) |
| 10 kΩ Resistor | Between GPIO 36 and GND |
| ESP32 GND | Common ground |

### 🔧 Voltage Divider Circuit Diagram
```
   3.3V
    │
   [LDR]
    │───────► GPIO36 (Analog Input)
   [10 kΩ]
    │
   GND
```

---

## 💻 5. Source Code

```cpp
#include <WiFi.h>
#include <PubSubClient.h>

// --- Configuration ---
const char* BROKER_ADDRESS = "broker.hivemq.com";
const int BROKER_PORT = 1883;
const char* TOPIC = "esp32/ldr/raw_value";
const long PUBLISH_INTERVAL = 10000; // 10 seconds

// --- Sensor Pin ---
const int LDR_PIN = 36; // LDR connected to GPIO 36 (ADC1_CH0)

// --- WiFi Credentials ---
const char* ssid = "YOUR_WIFI_SSID";        // <--- CHANGE THIS
const char* password = "YOUR_WIFI_PASSWORD"; // <--- CHANGE THIS

// --- MQTT Setup ---
WiFiClient espClient;
PubSubClient client(espClient);
long lastPublishTime = 0;

// Function Prototypes
void setup_wifi();
void reconnect();
void publish_ldr_value();

void setup() {
  Serial.begin(115200);
  pinMode(LDR_PIN, INPUT);
  setup_wifi();
  client.setServer(BROKER_ADDRESS, BROKER_PORT);
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop(); // Maintain MQTT connection
  publish_ldr_value();
}

void publish_ldr_value() {
  if (millis() - lastPublishTime >= PUBLISH_INTERVAL) {
    lastPublishTime = millis();

    int ldrValue = analogRead(LDR_PIN);
    char payload[6];
    itoa(ldrValue, payload, 10);

    if (client.publish(TOPIC, payload)) {
      Serial.print("✅ Published LDR Value to ");
      Serial.print(TOPIC);
      Serial.print(": ");
      Serial.println(payload);
    } else {
      Serial.print("❌ Publish failed. State: ");
      Serial.println(client.state());
    }
  }
}

void setup_wifi() {
  delay(10);
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi connected");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
}

void reconnect() {
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    String clientId = "ESP32-LDR-Publisher-";
    clientId += String(random(0xffff), HEX);
    if (client.connect(clientId.c_str())) {
      Serial.println("connected");
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" trying again in 5 seconds");
      delay(5000);
    }
  }
}
```

---
# 🧠 6. Code Explanation

| **Section** | **Description** |
|--------------|----------------|
| **Wi-Fi Connection** | Connects to the specified SSID and prints IP address upon success. |
| **MQTT Broker Setup** | Configures the public broker `broker.hivemq.com` at port `1883`. |
| **LDR Reading** | Reads analog voltage via `analogRead()` from GPIO36. |
| **Data Publishing** | Converts sensor value to string and sends via MQTT every 10 seconds. |
| **Loop Logic** | Ensures continuous MQTT connection and publishes at fixed intervals. |

---

# 📟 7. Example Serial Monitor Output

```
Connecting to MyWiFiNetwork
........
WiFi connected
IP address: 192.168.1.45
Attempting MQTT connection...connected
✅ Published LDR Value to esp32/ldr/raw_value: 320
✅ Published LDR Value to esp32/ldr/raw_value: 1024
✅ Published LDR Value to esp32/ldr/raw_value: 3890
```

### 🧾 Observation:
- When the **LDR is covered**, the published value decreases.
- When **light increases**, the ADC and MQTT values increase proportionally.

---

# 🌐 8. Monitoring via HiveMQ Dashboard

You can verify the published messages using the **free HiveMQ Web MQTT Client**:

### Steps:
1. Open the web client: [HiveMQ Web MQTT Client](https://www.hivemq.com/demos/websocket-client/)
2. Connect to **broker.hivemq.com** on port **8000 (WebSocket)**.
3. Subscribe to topic:  
   ```
   esp32/ldr/raw_value
   ```
4. Observe live sensor data from your ESP32.

---

# 🔬 9. Lab Exercises

### 1. Dynamic Interval
Modify the code to publish data every **5 seconds** instead of 10.

### 2. Light Percentage
Send both raw and percentage values (0–100%) in JSON format, e.g.:
```json
{ "raw": 2800, "percent": 68.4 }
```

### 3. Local Broker Test
Install and use a **local Mosquitto broker** to publish and subscribe to the same topic.

### 4. Dual Topic Publishing
Publish LDR data to two topics — one for **raw value** and one for **percentage**.

### 5. Data Logger
Combine with the **NTP Lab** to timestamp each reading before publishing.

---

# 🧩 10. Discussion Questions

1. What is the advantage of using MQTT for IoT data transfer?  
2. Why is the publish interval important in IoT sensor networks?  
3. What would happen if the MQTT connection fails mid-transmission?  
4. How could you secure this connection using authentication or TLS?  
5. How could you extend this experiment to control an LED remotely?  

---

## ✅ 11. Conclusion

In this lab, students built a complete **Wi-Fi-connected IoT node** using the ESP32.  
They learned how to:
- Acquire real-world analog data using ADC.  
- Connect to a network and communicate via MQTT.  
- Publish continuous sensor data to a cloud broker.  

This experiment demonstrates the fundamental IoT pipeline:  
**Sense → Connect → Publish → Visualize.**
