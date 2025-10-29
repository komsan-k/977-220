
# 🌐 Lab: MQTT-Based LED Control with ESP32 (Subscriber using analogWrite())

## 🧩 1. Objective

This lab demonstrates **MQTT-based device control** using an **ESP32** subscriber that controls an LED brightness through the **analogWrite()** function.  
The ESP32 receives MQTT messages (`on`, `off`, or `0–100` for dimming) and adjusts the LED brightness accordingly.

### Students will learn to:
- Configure the ESP32 as an MQTT subscriber.
- Establish Wi-Fi and MQTT connectivity.
- Use **analogWrite()** for PWM-based dimming.
- Test MQTT control using **Node-RED** or **HiveMQ Web Dashboard**.

---

## ⚙️ 2. Background Theory

### 2.1 MQTT Communication
**Message Queuing Telemetry Transport (MQTT)** is a lightweight protocol designed for IoT. It uses a **publish–subscribe** architecture.  
Devices can publish or subscribe to topics via a **broker**, enabling two-way communication.

| Term | Description |
|------|--------------|
| **Broker** | Server that routes messages between publishers and subscribers. |
| **Topic** | String identifier for message channels. |
| **Publisher** | Sends messages to a topic. |
| **Subscriber** | Receives messages from a topic. |

### 2.2 PWM Control using analogWrite()
**Pulse Width Modulation (PWM)** simulates analog voltage by varying the width of digital pulses.  
On ESP32 (Arduino Core v2.0.9+), `analogWrite()` provides a simple way to output PWM signals without LEDC configuration.

\[	ext{Duty Cycle (%) = (ON Time / Period) × 100}\]

---

## 🔌 3. Components and Requirements

| Component | Quantity | Description |
|------------|-----------|--------------|
| ESP32 Dev Board | 1 | Any model (ESP32-WROOM-32 recommended) |
| LED | 1 | Any color |
| Resistor | 1 | 220 Ω |
| Breadboard & Jumpers | — | For prototyping |
| MQTT Broker | 1 | `broker.hivemq.com` (public) |
| PC | 1 | Running Arduino IDE and Node-RED / HiveMQ Client |

---

## ⚡ 4. Circuit Diagram

| ESP32 Pin | Component | Description |
|------------|------------|--------------|
| GPIO 12 | LED anode (+) | PWM output |
| GND | LED cathode (−) | Through 220 Ω resistor |

**Description:**  
The LED on **GPIO 12** is controlled by `analogWrite()` to vary brightness smoothly.

---

## 💻 5. Program Code (ESP32 Subscriber with analogWrite())

```cpp
#include <WiFi.h>
#include <PubSubClient.h>

// ====== WiFi Configuration ======
const char* ssid     = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";

// ====== MQTT Configuration ======
const char* mqtt_server = "broker.hivemq.com";   // Public broker
const int   mqtt_port   = 1883;
const char* mqtt_topic  = "esp32/led/control";   // Subscription topic

// ====== LED Configuration ======
const int LED_PIN = 12;      // GPIO for LED
const int PWM_MAX = 255;     // analogWrite() range

WiFiClient espClient;
PubSubClient client(espClient);

// ====== Wi-Fi Setup ======
void setup_wifi() {
  Serial.print("Connecting to ");
  Serial.println(ssid);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\n✅ WiFi connected!");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
}

// ====== MQTT Callback ======
void callback(char* topic, byte* payload, unsigned int length) {
  String message;
  for (unsigned int i = 0; i < length; i++) message += (char)payload[i];
  message.trim();
  message.toLowerCase();

  Serial.print("📩 Message received: ");
  Serial.println(message);

  if (message == "on") {
    analogWrite(LED_PIN, PWM_MAX);  // Full brightness
    Serial.println("💡 LED ON (100%)");
  } else if (message == "off") {
    analogWrite(LED_PIN, 0);        // Turn off LED
    Serial.println("💤 LED OFF (0%)");
  } else {
    bool numeric = message.length() > 0;
    for (unsigned int i = 0; i < message.length(); i++) {
      if (!isDigit(message[i])) { numeric = false; break; }
    }

    if (numeric) {
      int percent = constrain(message.toInt(), 0, 100);
      int duty = map(percent, 0, 100, 0, PWM_MAX);
      analogWrite(LED_PIN, duty);
      Serial.printf("🔆 LED DIMMED to %d%% (Duty: %d)\n", percent, duty);
    } else {
      Serial.println("⚠️ Invalid command. Use 'on', 'off', or a number 0–100.");
    }
  }
}

// ====== MQTT Reconnect ======
void reconnect() {
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    if (client.connect("ESP32_LED_Subscriber")) {
      Serial.println("connected ✅");
      client.subscribe(mqtt_topic);
    } else {
      Serial.print("failed, rc=");
      Serial.println(client.state());
      delay(5000);
    }
  }
}

// ====== Setup ======
void setup() {
  Serial.begin(115200);
  pinMode(LED_PIN, OUTPUT);
  analogWrite(LED_PIN, 0); // Start LED OFF

  setup_wifi();
  client.setServer(mqtt_server, mqtt_port);
  client.setCallback(callback);
}

// ====== Loop ======
void loop() {
  if (!client.connected()) reconnect();
  client.loop();
}
```

---

## 🧠 6. Code Explanation

| Section | Description |
|----------|--------------|
| **Wi-Fi Connection** | Connects to Wi-Fi network and prints local IP. |
| **MQTT Setup** | Defines broker and topic for LED control. |
| **Callback Function** | Interprets MQTT messages and controls LED brightness. |
| **analogWrite()** | Writes PWM value (0–255) directly to GPIO pin. |
| **Loop** | Keeps MQTT client connected continuously. |

---

## 📟 7. Example Serial Monitor Output

```
Connecting to MyWiFiNetwork
.......
✅ WiFi connected!
IP address: 192.168.1.102
Attempting MQTT connection...connected ✅
📩 Message received: on
💡 LED ON (100%)
📩 Message received: 50
🔆 LED DIMMED to 50% (Duty: 128)
📩 Message received: off
💤 LED OFF (0%)
```

---

## 🌐 8. Testing with MQTT Dashboard

### Option 1 — HiveMQ Web Client
- Open: [HiveMQ WebSocket Client](https://www.hivemq.com/demos/websocket-client/)
- **Broker:** `broker.hivemq.com`, Port `8000`
- **Topic:** `esp32/led/control`
- Publish: `on`, `off`, `25`, `50`, `75`, `100`

### Option 2 — Node-RED Flow
- Inject → MQTT out → Debug nodes  
- **Topic:** `esp32/led/control`  
- **Payload:** `"on"`, `"off"`, or numeric (0–100)

---

## 🔬 9. Exercises

1. Publish `"on"` and `"off"` commands to test LED control.  
2. Test dimming using values `25`, `50`, `75`, and `100`.  
3. Modify to use another GPIO (e.g., GPIO 2).  
4. Control multiple LEDs with separate topics.  
5. Create a Node-RED dashboard slider for real-time dimming.

---

## 🧾 10. Observation Table

| Command | Payload | Duty (0–255) | LED Brightness (%) |
|----------|----------|---------------|--------------------|
| on | 255 | 255 | 100 |
| off | 0 | 0 | 0 |
| 25 | 25 | 64 | 25 |
| 50 | 50 | 128 | 50 |
| 75 | 75 | 191 | 75 |

---

## 🧩 11. Discussion

This experiment simplifies **PWM control** using `analogWrite()` on ESP32, enabling efficient MQTT-based LED dimming.  
The architecture can be applied to smart lighting, fan control, or any actuator requiring variable intensity.

---

## 📚 12. References

1. MQTT.org — *MQTT Version 3.1.1 Specification*  
2. Espressif Systems — *ESP32 Technical Reference Manual*  
3. HiveMQ — *WebSocket MQTT Client Demo*  
4. PubSubClient Library — [https://pubsubclient.knolleary.net](https://pubsubclient.knolleary.net)
