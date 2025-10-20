# 🌡️ Lab: ESP32 MQTT Temperature Data Publisher using I²C Sensor (LM73/LM75/TMP102-Compatible)

## 🧩 1. Objective

This laboratory exercise integrates **I²C-based temperature sensing** with **cloud-based data publishing** using the **MQTT protocol**.  
Students will learn how to:

- Interface a digital temperature sensor (LM73/LM75/TMP102) with the ESP32 via the **I²C bus**.  
- Read 12-bit temperature data using the `Wire.h` library.  
- Establish Wi-Fi connectivity and publish data to an MQTT broker.  
- Develop a complete IoT pipeline: **Sense → Process → Transmit → Monitor**.

---

## ⚙️ 2. Background Theory

### 2.1 I²C Communication
**I²C (Inter-Integrated Circuit)** is a synchronous serial communication protocol with two lines:
- **SDA** (Serial Data): Transfers data.
- **SCL** (Serial Clock): Synchronizes communication.

Multiple slave devices can share the same bus using unique addresses.  
In this lab:
- ESP32 acts as the **Master**.
- The temperature sensor acts as the **Slave** (address `0x48` to `0x4B`).

### 2.2 Temperature Sensor Operation
Sensors like **LM75** and **TMP102** store temperature in a 16-bit register:

T(°C) = Raw Value × 0.0625

Each LSB corresponds to **0.0625°C**, providing a 12-bit resolution.

### 2.3 MQTT Communication
**MQTT (Message Queuing Telemetry Transport)** is a publish/subscribe protocol ideal for IoT systems.

| Role | Description |
|------|--------------|
| **Publisher** | Sends messages to a specific topic. |
| **Subscriber** | Receives messages from subscribed topics. |
| **Broker** | Manages message delivery between clients. |

In this experiment, the ESP32 acts as an **MQTT Publisher**, sending real-time temperature data to a public broker (`broker.hivemq.com`).

---

## 🧰 3. Required Components

| Component | Quantity | Description |
|------------|-----------|-------------|
| ESP32 DevKit | 1 | Wi-Fi-enabled microcontroller |
| LM73 / LM75 / TMP102 | 1 | I²C digital temperature sensor |
| Breadboard & Jumper Wires | – | For circuit assembly |
| 4.7 kΩ Resistors | 2 | I²C pull-up resistors (if not on module) |
| Wi-Fi Network | 1 | For Internet connectivity |
| MQTT Broker | 1 | Public or private MQTT server |
| USB Cable | 1 | For programming and power |

---

## 🔌 4. Circuit Wiring

| Sensor Pin | ESP32 GPIO Pin | Function |
|-------------|----------------|-----------|
| GND | GND | Ground |
| V+ | 3.3V | Power Supply |
| SDA | GPIO 4 | Serial Data |
| SCL | GPIO 5 | Serial Clock |

### ⚡ Notes:
- Add **4.7 kΩ pull-up resistors** to both SDA and SCL if using a bare sensor.  
- Breakout modules (like TMP102) usually include these resistors.

---

## 💻 5. Source Code

```cpp
#include <WiFi.h>
#include <PubSubClient.h>
#include <Wire.h>

// --- MQTT Configuration ---
const char* BROKER_ADDRESS = "broker.hivemq.com";
const int BROKER_PORT = 1883;
const char* TOPIC = "esp32/temperature";
const long PUBLISH_INTERVAL = 15000; // 15 seconds

// --- I2C Configuration ---
const int I2C_SDA_PIN = 4;
const int I2C_SCL_PIN = 5;
const uint8_t SENSOR_ADDRESS = 0x48;
const uint8_t TEMP_REGISTER = 0x00;

// --- Wi-Fi Credentials ---
const char* ssid = "YOUR_WIFI_SSID";        
const char* password = "YOUR_WIFI_PASSWORD"; 

// --- MQTT Setup ---
WiFiClient espClient;
PubSubClient client(espClient);
long lastPublishTime = 0;

// Function Prototypes
void setup_wifi();
void reconnect();
float readI2CTemperature();
void publish_temperature(float temp);

void setup() {
  Serial.begin(115200);
  Wire.begin(I2C_SDA_PIN, I2C_SCL_PIN);
  Serial.printf("📡 I2C started on SDA=%d, SCL=%d\n", I2C_SDA_PIN, I2C_SCL_PIN);

  setup_wifi();
  client.setServer(BROKER_ADDRESS, BROKER_PORT);
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  if (millis() - lastPublishTime >= PUBLISH_INTERVAL) {
    lastPublishTime = millis();
    float temperature = readI2CTemperature();

    if (temperature != -999.0) {
      publish_temperature(temperature);
    } else {
      Serial.println("❌ Failed to read temperature. Skipping publish.");
    }
  }
}

// --- I2C Reading Function ---
float readI2CTemperature() {
  uint16_t raw_temp;
  Wire.beginTransmission(SENSOR_ADDRESS);
  Wire.write(TEMP_REGISTER);
  if (Wire.endTransmission() != 0) return -999.0;

  Wire.requestFrom(SENSOR_ADDRESS, 2);
  if (Wire.available() == 2) {
    uint8_t msb = Wire.read();
    uint8_t lsb = Wire.read();
    raw_temp = (msb << 8) | lsb;
    int16_t signed_raw = (raw_temp) >> 4;
    return (float)signed_raw * 0.0625;
  }
  return -999.0;
}

// --- MQTT Publish Function ---
void publish_temperature(float temp) {
  char payload[10];
  sprintf(payload, "%.2f", temp);
  if (client.publish(TOPIC, payload)) {
    Serial.printf("✅ Published Temp to %s: %s °C\n", TOPIC, payload);
  } else {
    Serial.printf("❌ MQTT publish failed. State: %d\n", client.state());
  }
}

// --- Wi-Fi Connection ---
void setup_wifi() {
  Serial.printf("Connecting to %s...\n", ssid);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.printf("\n✅ WiFi connected, IP: %s\n", WiFi.localIP().toString().c_str());
}

// --- MQTT Reconnection ---
void reconnect() {
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    String clientId = "ESP32-I2C-Temp-Publisher-";
    clientId += String(random(0xffff), HEX);
    if (client.connect(clientId.c_str())) {
      Serial.println("connected");
    } else {
      Serial.printf("failed (rc=%d). Retrying in 5s...\n", client.state());
      delay(5000);
    }
  }
}
```

---

## 📟 6. Example Serial Monitor Output

```
📡 I2C started on SDA=4, SCL=5
Connecting to MyWiFi...
✅ WiFi connected, IP: 192.168.1.42
Attempting MQTT connection...connected
✅ Published Temp to esp32/temperature: 27.25 °C
✅ Published Temp to esp32/temperature: 27.31 °C
✅ Published Temp to esp32/temperature: 27.38 °C
```

If you see:  
```
❌ Failed to read temperature. Skipping publish.
```
→ Check your wiring, I²C address, or pull-up resistors.

---

## 🔬 7. Lab Exercises

1. **Change the I²C Pins:**  
   Modify the SDA/SCL pins to GPIO 21 and 22 and verify functionality.

2. **Publish in JSON Format:**  
   Send data as a JSON object, e.g. `{ "temp": 27.25, "unit": "C" }`.

3. **Add MQTT Subscription:**  
   Subscribe to a topic to receive control messages (e.g., LED toggle).

4. **Add NTP Timestamp:**  
   Combine this with the NTP lab to timestamp temperature readings.

5. **Dual Sensor Setup:**  
   Read from two sensors (0x48 and 0x49) and publish both values.

---

## 🧩 8. Discussion Questions

1. Why is MQTT more efficient for IoT communication than HTTP?  
2. How does the I²C address affect communication when using multiple sensors?  
3. What are the potential causes of intermittent MQTT publishing failures?  
4. How could TLS encryption improve data security?  
5. How could this experiment be extended into a dashboard application (Node-RED or ThingSpeak)?  

---

## ✅ 9. Conclusion

In this lab, students developed an **IoT-enabled ESP32 system** that reads temperature data from an **I²C sensor** and transmits it via **MQTT** to a public broker.  
They learned how to integrate **hardware communication**, **network configuration**, and **application-level data publishing**, forming a full IoT pipeline for real-world monitoring systems.

---

## 📚 10. References

- Texas Instruments. *LM75/TMP102 Datasheets.*  
- Espressif Systems. *ESP32 Technical Reference Manual.*  
- Nick O’Leary. *PubSubClient Library Documentation.*  
- HiveMQ Public Broker: [https://www.hivemq.com/public-mqtt-broker/](https://www.hivemq.com/public-mqtt-broker/)  
- Kanjanasit, K. (2025). *IoT Laboratory Series, College of Computing, PSU–Phuket.*  

---

📅 **End of Lab Report: ESP32 MQTT Temperature Data Publisher using I²C Sensor**
