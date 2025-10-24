# 🌡️ Lab: ESP32 MQTT JSON Publisher (LDR & I²C Temperature Sensor)

## 🧩 1. Objective

This laboratory exercise demonstrates how to **integrate multiple sensors** on an **ESP32** and publish their readings to a cloud-based **MQTT broker** in a structured **JSON format**.  
Students will learn how to:
- Interface an analog **Light Dependent Resistor (LDR)** and an **I²C temperature sensor (LM73/LM75/TMP102-compatible)**.  
- Construct a unified JSON message containing multiple sensor readings.  
- Transmit data via **MQTT** to a public broker (HiveMQ).  

---

## ⚙️ 2. Background

### 2.1 MQTT Overview  
**MQTT (Message Queuing Telemetry Transport)** is a lightweight publish–subscribe messaging protocol widely used in IoT systems.  
It enables efficient communication between devices and servers (brokers), even in low-bandwidth environments.

### 2.2 JSON Format  
**JSON (JavaScript Object Notation)** is a human-readable data format ideal for publishing multiple sensor values in a single, structured payload.  
Example:
```json
{
  "temperature_c": 25.45,
  "ldr_raw": 2560,
  "device_id": "ESP32_A1"
}
```

---

## 🧰 3. Required Components

| **Component** | **Description** |
|----------------|-----------------|
| ESP32 Development Board | Wi-Fi capable microcontroller |
| LDR Sensor | Analog light sensor (connect with resistor divider) |
| LM73/LM75/TMP102 | I²C-compatible temperature sensor |
| Breadboard & Jumpers | For circuit wiring |
| Resistors | 10 kΩ (LDR pull-down), 4.7 kΩ (I²C pull-up) |

---

## 🔌 4. Circuit Connections

| **Sensor/Component** | **ESP32 Pin** | **Function** |
|------------------------|----------------|----------------|
| LDR (via resistor divider) | GPIO36 | Analog Input |
| I²C SDA | GPIO4 | Data Line |
| I²C SCL | GPIO5 | Clock Line |
| I²C VCC | 3.3 V | Power |
| I²C GND | GND | Ground |

**Note:** Use **4.7 kΩ pull-up resistors** on SDA and SCL lines to ensure stable I²C communication.

---

## 💻 5. Arduino Code

### 5.1 Required Libraries
Before uploading the code, install the following libraries using **Arduino IDE → Sketch → Include Library → Manage Libraries...**
- `PubSubClient` by Nick O’Leary  
- `ArduinoJson` by Benoit Blanchon  
- `Wire` (built-in)

---

### 5.2 Complete Code: ESP32 MQTT JSON Publisher

```cpp
#include <WiFi.h>
#include <PubSubClient.h>
#include <Wire.h>
#include <ArduinoJson.h>

// --- MQTT Configuration ---
const char* BROKER_ADDRESS = "broker.hivemq.com";
const int BROKER_PORT = 1883;
const char* TOPIC = "esp32/sensor_data"; // Unified topic
const long PUBLISH_INTERVAL = 15000;     // Publish every 15 seconds

// --- Sensor Pins ---
const int LDR_PIN = 36;          // Analog LDR input
const int I2C_SDA_PIN = 4;       // I²C SDA
const int I2C_SCL_PIN = 5;       // I²C SCL
const uint8_t SENSOR_ADDRESS = 0x48; // I²C temperature sensor address
const uint8_t TEMP_REGISTER = 0x00;  // Register for temperature read

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
void publish_data();

void setup() {
  Serial.begin(115200);
  pinMode(LDR_PIN, INPUT);
  Wire.begin(I2C_SDA_PIN, I2C_SCL_PIN);

  Serial.printf("I²C started on SDA=%d, SCL=%d\n", I2C_SDA_PIN, I2C_SCL_PIN);
  setup_wifi();
  client.setServer(BROKER_ADDRESS, BROKER_PORT);
}

void loop() {
  if (!client.connected()) reconnect();
  client.loop();

  if (millis() - lastPublishTime >= PUBLISH_INTERVAL) {
    lastPublishTime = millis();
    publish_data();
  }
}

// --- Sensor Read: I²C Temperature ---
float readI2CTemperature() {
  Wire.beginTransmission(SENSOR_ADDRESS);
  Wire.write(TEMP_REGISTER);
  if (Wire.endTransmission() != 0) return -999.0;

  Wire.requestFrom(SENSOR_ADDRESS, 2);
  if (Wire.available() == 2) {
    uint8_t msb = Wire.read();
    uint8_t lsb = Wire.read();
    uint16_t raw = (msb << 8) | lsb;
    int16_t signed_raw = raw >> 4;
    return signed_raw * 0.0625;  // 12-bit, 0.0625 °C/LSB
  }
  return -999.0;
}

// --- Data Publishing ---
void publish_data() {
  int ldrValue = analogRead(LDR_PIN);
  float temperature = readI2CTemperature();

  StaticJsonDocument<200> doc;
  doc["device_id"] = "ESP32_A1";
  doc["ldr_raw"] = ldrValue;
  doc["temperature_c"] = (temperature != -999.0) ? temperature : "ERROR";

  char jsonBuffer[200];
  serializeJson(doc, jsonBuffer);

  if (client.publish(TOPIC, jsonBuffer)) {
    Serial.printf("✅ Published JSON → %s: %s\n", TOPIC, jsonBuffer);
  } else {
    Serial.printf("❌ Publish failed. MQTT state: %d\n", client.state());
  }
}

// --- Wi-Fi Setup ---
void setup_wifi() {
  Serial.printf("Connecting to %s", ssid);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500); Serial.print(".");
  }
  Serial.printf("\nWiFi connected, IP: %s\n", WiFi.localIP().toString().c_str());
}

// --- MQTT Reconnection ---
void reconnect() {
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    String clientId = "ESP32_JSON_" + String(random(0xffff), HEX);
    if (client.connect(clientId.c_str())) {
      Serial.println("connected");
    } else {
      Serial.printf("failed (rc=%d), retrying in 5s\n", client.state());
      delay(5000);
    }
  }
}
```

---

## 🧪 6. Experimental Verification

### 6.1 Expected Serial Monitor Output
```
Connecting to MyWiFiNetwork
........
WiFi connected, IP: 192.168.1.42
✅ Published JSON → esp32/sensor_data: {"temperature_c":25.31,"ldr_raw":2685,"device_id":"ESP32_A1"}
```

### 6.2 Example MQTT JSON Payload
```json
{
  "temperature_c": 25.45,
  "ldr_raw": 2560,
  "device_id": "ESP32_A1"
}
```

### 6.3 HiveMQ Web Dashboard Verification
1. Go to [https://www.hivemq.com/demos/websocket-client/](https://www.hivemq.com/demos/websocket-client/).  
2. Connect to broker **broker.hivemq.com** on port **8000 (WebSocket)**.  
3. Subscribe to topic **esp32/sensor_data**.  
4. Observe the published JSON messages from your ESP32.

---

## 🔍 7. Discussion

- **MQTT** ensures efficient data delivery with minimal overhead.  
- **JSON** provides an easily interpretable and extensible structure for multi-sensor data.  
- Combining **analog and digital sensors** demonstrates practical IoT integration for real-world monitoring systems.  
- System reliability depends on consistent I²C communication and stable Wi-Fi connectivity.

---

## 🧠 8. Exercises

1. Modify the JSON payload to include an additional field for **timestamp** using `millis()` or RTC.  
2. Extend the code to subscribe to a topic and control an LED remotely.  
3. Use a **local Mosquitto broker** instead of HiveMQ for testing offline communication.  
4. Evaluate MQTT latency by measuring publish–subscribe delays under different network conditions.

---

## 📎 9. References

1. Nick O’Leary, *PubSubClient Library Documentation*  
2. Benoit Blanchon, *ArduinoJson Library Guide*  
3. HiveMQ MQTT Client Tool – [https://www.hivemq.com/demos/websocket-client/](https://www.hivemq.com/demos/websocket-client/)  
4. Espressif Systems, *ESP32 Technical Reference Manual*  
