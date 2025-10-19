# 📡 Lab: IoT Temperature Subscriber using ESP32 and MQTT

## 🧩 1. Objective

This laboratory exercise focuses on creating an **MQTT Subscriber** using the **ESP32 microcontroller**.  
The ESP32 will:
- Connect to a public MQTT broker.  
- Subscribe to a topic named `test/sensor/temperature`.  
- Receive and display real-time temperature data published by another IoT device or simulated source.

This lab helps students understand **message reception**, **topic subscription**, and **data visualization** within IoT systems.

---

## ⚙️ 2. Background Theory

### 2.1 MQTT Communication Model
MQTT (Message Queuing Telemetry Transport) uses a **publish–subscribe** architecture.  
- **Publisher** → sends messages to a topic.  
- **Subscriber** → listens for messages on the topic.  
- **Broker** → acts as a middleman that distributes messages between publishers and subscribers.

In this lab, the ESP32 acts as a **subscriber**, while another device (or simulator) publishes temperature values periodically.

---

### 2.2 PubSubClient Library
The **PubSubClient** library provides MQTT functionality for Arduino-compatible boards. It allows:
- Connection to MQTT brokers.  
- Topic subscription.  
- Message handling via callback functions.  

This library is lightweight and optimized for embedded systems like the ESP32.

---

## 🧰 3. Equipment and Software

| Item | Description |
|------|--------------|
| **ESP32 Development Board** | NodeMCU-32S / ESP32-DevKitC |
| **Wi-Fi Network** | Required for MQTT communication |
| **Arduino IDE** | For programming the ESP32 |
| **PubSubClient Library** | For MQTT handling |
| **MQTT Broker** | `broker.hivemq.com` (Public test broker) |
| **Publisher Device** | ESP32 or PC-based MQTT Publisher (optional) |

---

## 📘 4. Source Code

```cpp
#include <WiFi.h> 
#include <PubSubClient.h>

// --- Configuration ---
const char* BROKER_ADDRESS = "broker.hivemq.com";
const int   BROKER_PORT    = 1883; // Standard MQTT port
const char* TOPIC          = "test/sensor/temperature";

// --- WiFi Credentials ---
const char* ssid     = "your_SSID";      // <--- CHANGE THIS
const char* password = "your_password";  // <--- CHANGE THIS

// --- MQTT Setup ---
WiFiClient espClient;
PubSubClient client(espClient);

// Function Prototypes
void setup_wifi();
void reconnect();
void callback(char* topic, byte* payload, unsigned int length);

void setup() {
  Serial.begin(115200);
  setup_wifi();
  client.setServer(BROKER_ADDRESS, BROKER_PORT);
  client.setCallback(callback); // handle incoming messages
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop(); // maintain connection and process messages
}

// ----------------------
// --- FUNCTIONS ---
// ----------------------

// Handles incoming MQTT messages
void callback(char* topic, byte* payload, unsigned int length) {
  String message;
  message.reserve(length);
  for (unsigned int i = 0; i < length; i++) {
    message += (char)payload[i];
  }

  Serial.print("➡️ Received Temperature: ");
  Serial.print(message);
  Serial.print(" °C  [Topic: ");
  Serial.print(topic);
  Serial.println("]");
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

  Serial.println();
  Serial.println("✅ WiFi connected");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
}

void reconnect() {
  // Loop until reconnected
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection... ");
    String clientId = "ESP32-Subscriber-";
    clientId += String((uint32_t)ESP.getEfuseMac(), HEX);

    if (client.connect(clientId.c_str())) {
      Serial.println("connected");
      client.subscribe(TOPIC);
      Serial.print("🔔 Subscribed to topic: ");
      Serial.println(TOPIC);
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" — retry in 5s");
      delay(5000);
    }
  }
}
```

---

## 🧠 5. Explanation of the Code

| Section | Description |
|----------|-------------|
| **Wi-Fi Setup** | Connects the ESP32 to the specified Wi-Fi network. |
| **MQTT Connection** | Configures broker address and maintains connection via `client.loop()`. |
| **Callback Function** | Called when a message is received on the subscribed topic. |
| **Reconnect Function** | Automatically reconnects to the broker and resubscribes to the topic if disconnected. |
| **Serial Output** | Displays received temperature data with the associated topic name. |

---

## 📡 6. Expected Output

### Serial Monitor Example:
```
Connecting to your_SSID
......
✅ WiFi connected
IP address: 192.168.1.54
Attempting MQTT connection... connected
🔔 Subscribed to topic: test/sensor/temperature
➡️ Received Temperature: 25.34 °C  [Topic: test/sensor/temperature]
➡️ Received Temperature: 26.02 °C  [Topic: test/sensor/temperature]
➡️ Received Temperature: 28.55 °C  [Topic: test/sensor/temperature]
```

---

## 📊 7. Node-RED Visualization

**Node-RED Flow Concept:**
```
[mqtt in] → [json parser] → [chart/gauge/text]
```

**Configuration:**
- **Server:** `broker.hivemq.com`  
- **Topic:** `test/sensor/temperature`  
- **Output Type:** Parsed text or JSON

**Dashboard Example:**
- **Gauge:** Displays current temperature.  
- **Chart:** Shows historical temperature over time.  
- **Text Node:** Displays the latest received value.

---

## 🧪 8. Exercises

1. Modify the topic name to include your ID, e.g., `psu/studentID/temperature`.  
2. Add timestamp to display when the message was received.  
3. Connect two ESP32 boards (one publisher, one subscriber) for peer communication.  
4. Modify the callback to handle **JSON messages** such as:
   ```json
   {"temperature": 27.3, "unit": "C"}
   ```  
5. Extend the subscriber to trigger an LED or buzzer when the temperature exceeds 28°C.  
6. Combine Node-RED with the subscriber to visualize and store received data in a database (InfluxDB or SQLite).  

---

## 🧩 9. Discussion Questions

1. What is the purpose of the callback function in MQTT?  
2. What happens if the MQTT broker goes offline?  
3. How is topic-based filtering implemented in MQTT?  
4. What is the difference between a **publisher** and a **subscriber** in terms of data flow?  
5. How can MQTT communication be secured with SSL/TLS?  

---

## ✅ 10. Conclusion

This lab introduces the **subscriber-side operation** of the MQTT protocol using the **ESP32**.  
Students learned how to:
- Connect to a broker,  
- Subscribe to a topic,  
- Receive and process messages.  

The subscriber complements the publisher device, enabling **bi-directional IoT communication** that forms the foundation of **cloud-connected sensor systems**.
