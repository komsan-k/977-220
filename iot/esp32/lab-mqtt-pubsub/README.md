# 🌡️ Lab: IoT Temperature Publisher using ESP32 and MQTT

## 🧩 1. Objective

The objective of this lab is to design and implement an **IoT temperature publisher** using an **ESP32** that:
- Simulates and publishes temperature values periodically.  
- Communicates with a public **MQTT broker** using the **PubSubClient** library.  
- Demonstrates real-time IoT data flow from a device to a cloud-based server (e.g., HiveMQ, Node-RED, or MQTT Explorer).  

---

## ⚙️ 2. Background Theory

### 2.1 MQTT Overview
**MQTT (Message Queuing Telemetry Transport)** is a lightweight communication protocol designed for IoT systems.  
It follows a **publish–subscribe** model involving:
- **Publisher**: Sends messages to specific topics.  
- **Subscriber**: Receives messages from subscribed topics.  
- **Broker**: The central server that routes messages between publishers and subscribers.

MQTT is efficient because it:
- Consumes low bandwidth.
- Maintains persistent connections.
- Supports Quality of Service (QoS) levels for reliable delivery.

---

### 2.2 ESP32 and PubSubClient Library
The **ESP32** is a microcontroller with Wi-Fi capability, ideal for IoT devices.  
The **PubSubClient** library provides a simple API for MQTT connectivity, allowing users to:
- Connect to MQTT brokers (like `broker.hivemq.com`).
- Publish messages to topics.
- Subscribe and receive updates from other devices.

In this lab, the ESP32 acts as a **publisher**, sending random temperature data to a topic named `test/sensor/temperature`.

---

## 🧰 3. Equipment and Software

| Component | Description |
|------------|-------------|
| **ESP32 Dev Board** | NodeMCU-32S or ESP32-DevKitC |
| **Wi-Fi Network** | For internet access |
| **Arduino IDE** | Programming environment |
| **PubSubClient Library** | For MQTT communication |
| **MQTT Explorer / Node-RED** | To verify message reception |

---

## 📘 4. Source Code

```cpp
#include <WiFi.h> 
#include <PubSubClient.h>

// --- Configuration ---
const char* BROKER_ADDRESS = "broker.hivemq.com";
const int BROKER_PORT = 1883; // Standard MQTT port
const char* TOPIC = "test/sensor/temperature";
const long PUBLISH_INTERVAL = 5000; // milliseconds (5 seconds)
const float TEMP_MIN = 20.0;
const float TEMP_MAX = 30.0;

// --- WiFi Credentials ---
const char* ssid = "YOUR_WIFI_SSID";    // <--- CHANGE THIS
const char* password = "YOUR_WIFI_PASSWORD"; // <--- CHANGE THIS

// --- MQTT Setup ---
WiFiClient espClient;
PubSubClient client(espClient);
long lastPublishTime = 0;

// Function Prototypes
void setup_wifi();
void reconnect();

void setup() {
  Serial.begin(115200);
  randomSeed(analogRead(0)); // Initialize random number generator
  setup_wifi();
  client.setServer(BROKER_ADDRESS, BROKER_PORT);
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop(); // Keeps the MQTT connection alive and processes pings

  // Check if the publish interval has passed
  if (millis() - lastPublishTime >= PUBLISH_INTERVAL) {
    lastPublishTime = millis();
    
    // 1. Simulate a random temperature
    float random_range = TEMP_MAX - TEMP_MIN;
    float temperature = TEMP_MIN + ((float)random(0, 1000) / 1000.0) * random_range;
    
    // 2. Format the payload string
    char payload[10]; // Buffer to hold formatted string
    sprintf(payload, "%.2f", temperature); 
    
    // 3. Publish the message
    if (client.publish(TOPIC, payload)) {
      Serial.print("Published Temperature: ");
      Serial.print(payload);
      Serial.println("°C");
    } else {
      Serial.println("Publish failed.");
    }
  }
}

// ----------------------
// --- Connection Functions ---
// ----------------------

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
    String clientId = "ESP32-TempSensor-";
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

## 🧠 5. Code Explanation

| Section | Description |
|----------|-------------|
| **Wi-Fi Setup** | The ESP32 connects to the local Wi-Fi using SSID and password. |
| **MQTT Configuration** | Establishes connection to `broker.hivemq.com` on port `1883`. |
| **Temperature Simulation** | Generates random float values between 20.0°C and 30.0°C. |
| **Payload Formatting** | Converts the floating-point value to a string with 2 decimal precision using `sprintf()`. |
| **Publishing** | Sends the formatted temperature string to topic `test/sensor/temperature`. |
| **Connection Maintenance** | `client.loop()` keeps MQTT alive and reconnects automatically if disconnected. |

---

## 📡 6. Expected Output

### Serial Monitor Output:
```
Connecting to YOUR_WIFI_SSID
......
WiFi connected
IP address: 192.168.1.45
Attempting MQTT connection...connected
Published Temperature: 24.87°C
Published Temperature: 26.45°C
Published Temperature: 29.01°C
...
```

### MQTT Explorer or Node-RED:
| Topic | Payload Example | Interval |
|--------|------------------|-----------|
| `test/sensor/temperature` | `25.43` | Every 5 seconds |

---

## 📊 7. Node-RED Flow (Example)

**Flow Overview:**
```
[mqtt in] → [json parser] → [gauge/chart/text] → [debug]
```

**Configuration:**
- Server: `broker.hivemq.com`  
- Topic: `test/sensor/temperature`  
- Output: Parsed string or numeric  

**Dashboard Output:**
- Gauge showing current temperature  
- Chart showing 60-second rolling history  
- Text node showing the latest published value  

---

## 🧪 8. Exercises

1. Modify the temperature range to 10–40°C.  
2. Add a **JSON payload** format:  
   ```json
   {"temperature": 26.7, "unit": "C"}
   ```  
3. Increase the publishing interval to 10 seconds.  
4. Add a **timestamp** in the payload using `millis()`.  
5. Use Node-RED to trigger alerts when temperature > 28°C.  
6. Extend this lab by subscribing to a control topic (`device/control`).  

---

## 🧩 9. Discussion Questions

1. Why is `sprintf()` used instead of `String()` for MQTT payloads?  
2. What would happen if the Wi-Fi is disconnected for a long time?  
3. How can you secure MQTT communication?  
4. What is the difference between QoS 0, 1, and 2?  
5. How could this program be integrated with a database or cloud dashboard?

---

## ✅ 10. Conclusion

This lab demonstrated how to implement an **ESP32-based temperature publisher** using MQTT.  
Students learned how to:
- Simulate sensor data,
- Format and transmit messages,
- Use MQTT as a lightweight IoT communication protocol.

This experiment forms the foundation for building **real-world IoT systems** that integrate sensors, cloud platforms, and user dashboards for smart monitoring applications.
