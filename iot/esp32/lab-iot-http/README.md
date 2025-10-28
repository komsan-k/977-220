# 🌐 Lab: ESP32 HTTP Counter Sender

## 🧩 1. Objective

This laboratory exercise demonstrates how to build a simple **IoT HTTP-based client** using an **ESP32** microcontroller.  
Students will learn how to:
- Connect an ESP32 to a **Wi-Fi network**.  
- Use the **HTTPClient library** to send data to a web server.  
- Format and send an **incremental counter value** as part of a URL query string.  
- Observe and interpret the **HTTP response** from the server.

---

## ⚙️ 2. Background

### 2.1 HTTP in IoT
**HTTP (HyperText Transfer Protocol)** is the foundation of data communication on the web.  
IoT devices often use HTTP for:
- Sending telemetry data to RESTful APIs.  
- Receiving configuration updates.  
- Integrating with cloud dashboards or web-based visualization tools.

Although **MQTT** is more efficient for continuous messaging, **HTTP** remains essential for many web-integrated IoT systems.

### 2.2 HTTP Request Structure
An HTTP GET request typically follows the format:

```
http://server-address/path?key1=value1&key2=value2
```

For example:
```
http://example.com/data?device_id=esp32&count=10
```

This query sends key–value pairs (`device_id`, `count`) that the server can process and store.

---

## 🔌 3. Required Hardware

| Component | Description |
|------------|-------------|
| ESP32 Dev Board | NodeMCU-32S, ESP-WROOM-32, or similar |
| USB Cable | For programming and serial monitoring |
| Wi-Fi Network | 2.4 GHz network with Internet access |

---

## 🧰 4. Required Software

| Tool | Purpose |
|------|----------|
| Arduino IDE | Main development environment |
| ESP32 Board Package | Install via **Boards Manager** |
| HTTPClient Library | Included by default with ESP32 core |
| Serial Monitor | To view output logs |

---

## 🧠 5. Code Listing

```cpp
#include <WiFi.h>
#include <HTTPClient.h>

// ====== Wi-Fi Configuration ======
const char* ssid     = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";

// ====== Server Configuration ======
const char* serverURL = "https://httpbin.org/get";   // or your own API endpoint

// ====== Global Variables ======
int counter = 0;

void setup() {
  Serial.begin(115200);
  delay(1000);
  Serial.println("\nConnecting to WiFi...");

  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\n✅ WiFi connected!");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());
}

void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;

    // Build URL with counter parameter
    String url = String(serverURL) + "?device_id=esp32&count=" + String(counter);
    Serial.println("🌐 Sending request: " + url);

    http.begin(url);
    int httpResponseCode = http.GET();

    if (httpResponseCode > 0) {
      Serial.print("✅ Response code: ");
      Serial.println(httpResponseCode);
      String payload = http.getString();
      Serial.println("📦 Server response:");
      Serial.println(payload);
    } else {
      Serial.print("❌ Error code: ");
      Serial.println(httpResponseCode);
    }

    http.end();
  } else {
    Serial.println("⚠️ WiFi not connected!");
  }

  counter++;
  delay(5000);  // send every 5 seconds
}
```

---

## 🧪 6. Experiment Procedure

1. Open the Arduino IDE and select **ESP32 Dev Module** from the board list.  
2. Copy and paste the above code.  
3. Enter your **Wi-Fi SSID** and **password**.  
4. Verify and upload the sketch to your ESP32 board.  
5. Open **Serial Monitor** at **115200 baud**.  
6. Observe:
   - The ESP32 connects to Wi-Fi.
   - The HTTP GET request is printed with the counter value.
   - The server responds with echoed data.

---

## 📟 7. Example Serial Monitor Output

```
Connecting to WiFi...
........
✅ WiFi connected!
IP Address: 192.168.1.45
🌐 Sending request: https://httpbin.org/get?device_id=esp32&count=0
✅ Response code: 200
📦 Server response:
{
  "args": {
    "count": "0",
    "device_id": "esp32"
  },
  ...
}
🌐 Sending request: https://httpbin.org/get?device_id=esp32&count=1
✅ Response code: 200
📦 Server response:
{
  "args": {
    "count": "1",
    "device_id": "esp32"
  }
}
```

---

## 🌍 8. Testing with a Local Server (Optional)

### Option 1: Python HTTP Server (Quick Echo)
```bash
python3 -m http.server 8080
```

### Option 2: Flask Server
```python
from flask import Flask, request
app = Flask(__name__)

@app.route('/', methods=['GET'])
def index():
    count = request.args.get('count')
    return f"Received counter: {count}"

app.run(host='0.0.0.0', port=8080)
```

---

## 📈 9. Observations and Discussion

- The counter value increments and is sent at regular intervals.  
- Each HTTP GET request includes parameters in the query string.  
- The server response can confirm receipt and provide feedback.  
- The delay interval (`delay(5000)`) controls data frequency — can be tuned as needed.

---

## 🧭 10. Extensions

Students can modify the lab to:
- Include multiple parameters (e.g., temperature, humidity).  
- Use **HTTP POST** to send JSON payloads.  
- Implement **error recovery** when Wi-Fi disconnects.  
- Send data to a **cloud IoT dashboard** (e.g., ThingSpeak, InfluxDB, Node-RED HTTP input).

---

## 🧾 11. Summary

This lab demonstrates a fundamental **IoT-to-Cloud communication** pattern using the HTTP protocol.  
It provides a foundation for:
- Understanding web-based IoT data transmission.  
- Developing RESTful IoT applications.  
- Expanding toward MQTT or HTTPS secure communication.

---

## ✍️ 12. References

1. Espressif Systems. *ESP32 Arduino Core Documentation.* [https://docs.espressif.com/](https://docs.espressif.com/)  
2. Arduino. *HTTPClient Library Reference.* [https://www.arduino.cc/reference/en/libraries/httpclient/](https://www.arduino.cc/reference/en/libraries/httpclient/)  
3. HiveMQ. *MQTT vs HTTP in IoT Applications.* [https://www.hivemq.com](https://www.hivemq.com)  
4. Flask Documentation. *Quickstart Guide.* [https://flask.palletsprojects.com/](https://flask.palletsprojects.com/)
