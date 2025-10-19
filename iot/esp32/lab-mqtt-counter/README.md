# 🔬 Lab: IoT MQTT Counter Publisher using ESP32

## 🧩 1. Objective
The objective of this laboratory exercise is to:
- Implement a **basic MQTT publisher** using an ESP32.
- Periodically publish a **counter value** to a public MQTT broker.
- Understand the **Wi-Fi setup**, **MQTT connection handling**, and **publishing mechanism** using the PubSubClient library.
- Observe MQTT message flow using **Node-RED**, **MQTT Explorer**, or any other MQTT dashboard.

---

## ⚙️ 2. Background Theory

### 2.1 Internet of Things (IoT) Communication
In IoT, devices often communicate through **lightweight protocols** designed for constrained networks. One of the most common is **MQTT (Message Queuing Telemetry Transport)** — a simple publish–subscribe messaging protocol ideal for IoT applications.

### 2.2 MQTT Publisher and Subscriber
- **Publisher**: Sends messages to a specific *topic*.
- **Subscriber**: Receives messages by subscribing to that topic.
- **Broker**: Manages message routing between publishers and subscribers.

In this lab, the ESP32 acts as a **publisher**, sending a **counter value** to a public MQTT broker (`broker.hivemq.com`) every 3 seconds.

### 2.3 ESP32 and PubSubClient
The **ESP32** uses Wi-Fi for Internet connectivity. The **PubSubClient** library handles MQTT functions such as:
- Connecting to the broker  
- Publishing messages  
- Maintaining the connection  

---

## 🧰 3. Equipment and Software

| Item | Description |
|------|--------------|
| **ESP32 Board** | ESP32 DevKit or NodeMCU-32S |
| **Wi-Fi Network** | Internet access required |
| **Arduino IDE** | For coding and uploading |
| **PubSubClient Library** | MQTT communication |
| **MQTT Explorer / Node-RED** | To visualize messages |

---

## 📘 4. Code Listing

```cpp
#include <WiFi.h>
#include <PubSubClient.h>

// --- Configuration ---
const char* BROKER_ADDRESS = "broker.hivemq.com";
const int BROKER_PORT = 1883; // Standard MQTT port
const char* TOPIC = "test/counter_topic";
const long PUBLISH_INTERVAL = 3000; // milliseconds (3 seconds)

// --- WiFi Credentials ---
const char* ssid = "YOUR_WIFI_SSID";        // <--- CHANGE THIS
const char* password = "YOUR_WIFI_PASSWORD"; // <--- CHANGE THIS

// --- MQTT Setup ---
WiFiClient espClient;
PubSubClient client(espClient);
long lastPublishTime = 0;
int messageCount = 0; // Counter to be published

// Function Prototypes
void setup_wifi();
void reconnect();
void publish_counter();

void setup() {
  Serial.begin(115200);
  setup_wifi();
  client.setServer(BROKER_ADDRESS, BROKER_PORT);
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop(); // Keeps the MQTT connection alive
  publish_counter();
}

// ----------------------
// --- FUNCTIONS ---
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

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
}

void reconnect() {
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    String clientId = "ESP32Client-";
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

void publish_counter() {
  if (millis() - lastPublishTime > PUBLISH_INTERVAL) {
    lastPublishTime = millis();
    messageCount++;
    String message = String(messageCount);

    Serial.print("Publishing to topic ");
    Serial.print(TOPIC);
    Serial.print(": ");
    Serial.println(message);

    client.publish(TOPIC, message.c_str());
  }
}
```

---

## 🧠 5. Explanation of the Code

| Section | Description |
|----------|--------------|
| **Wi-Fi Setup** | The function `setup_wifi()` connects the ESP32 to your router using the provided SSID and password. |
| **Broker Connection** | `reconnect()` ensures the ESP32 is always connected to the MQTT broker. |
| **Publishing Loop** | Every 3 seconds, `publish_counter()` sends an incrementing number to the topic `test/counter_topic`. |
| **PubSubClient** | Handles MQTT connection and message publishing through the TCP socket managed by `WiFiClient`. |
| **Serial Monitor Output** | Displays the connection status and each published message. |

---

## 📡 6. Expected Output

### Serial Monitor:
```
Connecting to YOUR_WIFI_SSID
.......
WiFi connected
IP address: 192.168.1.25
Attempting MQTT connection...connected
Publishing to topic test/counter_topic: 1
Publishing to topic test/counter_topic: 2
Publishing to topic test/counter_topic: 3
...
```

### Node-RED or MQTT Explorer:
- **Topic:** `test/counter_topic`
- **Payload:** `1, 2, 3, 4, …` every 3 seconds  

---

## 📊 7. Node-RED Dashboard Example

**Flow (Conceptual):**
```
[mqtt in → chart → text → debug]
```

**Settings:**
- Server: `broker.hivemq.com`
- Topic: `test/counter_topic`
- Output: Numeric payload

**Dashboard Result:**  
A live-updating counter displayed on both a text node and a chart node.

---

## 🧪 8. Exercises

1. Modify the interval to publish every **1 second**.  
2. Add a **timestamp** to the published message.  
3. Modify the topic to include your name or device ID, e.g., `psu/komsan/counter`.  
4. Add a **JSON payload**, e.g.  
   ```json
   {"count": 12, "device": "ESP32", "status": "active"}
   ```
5. Use Node-RED to **subscribe and display** the counter on a **dashboard gauge**.  
6. Extend the program to **subscribe** to a topic for remote reset (`counter/reset`).  
7. Add **reconnection feedback** LEDs or buzzer alerts when MQTT connection fails.  

---

## 🧩 9. Discussion Questions

1. Why is MQTT preferred for IoT communication compared to HTTP?  
2. What happens if the broker goes offline?  
3. How can the reliability of message delivery be improved using **QoS** levels?  
4. How can you make the MQTT connection more secure?  
5. What’s the difference between a **publisher-only** and a **bidirectional** MQTT client?

---

## ✅ 10. Conclusion
This lab demonstrates how the **ESP32** can act as a simple **MQTT publisher**, sending messages to a **public broker** at periodic intervals.  
It reinforces the understanding of:
- IoT communication principles,  
- MQTT protocol usage, and  
- Wi-Fi–based embedded system integration.  

The concept can be extended to include sensors, actuators, and dashboards for **real-world IoT applications**.
