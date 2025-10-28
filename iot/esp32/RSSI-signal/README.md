# 📡 Lab: Measuring Wi-Fi RSSI using ESP32 (Arduino)

## 🧩 1. Objective
This laboratory exercise demonstrates how to measure and analyze the **Wi-Fi signal strength (RSSI)** using an **ESP32** microcontroller programmed via the **Arduino IDE**.  

Students will learn to:
- Connect an ESP32 to a Wi-Fi network and retrieve its **RSSI (Received Signal Strength Indicator)**.
- Scan and display the RSSI of nearby Wi-Fi networks.
- Implement **smoothing (averaging)** and **visual indication** of signal quality using LEDs.
- Optionally estimate **approximate distance** from RSSI using a path-loss model.

---

## ⚙️ 2. Background Theory

### 2.1 RSSI Overview  
**RSSI (Received Signal Strength Indicator)** is a measure of the power level that a device receives from a wireless access point (AP).  
- It is typically expressed in **dBm (decibels relative to 1 milliwatt)**.  
- The values are **negative numbers**, with higher (closer to 0) values indicating a stronger signal.  
  - Example:  
    - -40 dBm → Excellent  
    - -65 dBm → Good  
    - -80 dBm → Weak  

### 2.2 Measurement Importance  
RSSI is crucial for:
- **Network diagnostics** and range optimization.  
- **IoT deployments**, ensuring sensor nodes remain connected within coverage zones.  
- **Adaptive communication systems**, where data rate or transmission power adjusts based on signal quality.

---

## 🧰 3. Required Components

| Component | Description |
|------------|-------------|
| ESP32 Dev Board | Wi-Fi/Bluetooth-enabled microcontroller |
| USB Cable | Programming interface to PC |
| Wi-Fi Access Point | Any Wi-Fi router or hotspot |
| Optional LED | For visual indication of signal strength |
| Resistor (330 Ω) | For LED current limiting (optional) |

---

## 🔌 4. Circuit Diagram

| Connection | ESP32 Pin | Description |
|-------------|------------|-------------|
| LED (optional) | GPIO2 | Built-in or external LED |
| GND | GND | Common ground |
| VCC | 3.3V | Power for LED or sensor |

> ⚠️ **Note:** Most ESP32 boards have an onboard LED connected to **GPIO2**.

---

## 💻 5. Arduino Code

### 5.1 Basic RSSI Reader
```cpp
#include <WiFi.h>

const char* SSID = "YOUR_SSID";
const char* PASS = "YOUR_PASSWORD";

void setup() {
  Serial.begin(115200);
  WiFi.mode(WIFI_STA);
  WiFi.setSleep(false);
  WiFi.begin(SSID, PASS);

  Serial.print("Connecting to "); Serial.println(SSID);
  while (WiFi.status() != WL_CONNECTED) {
    delay(300);
    Serial.print(".");
  }
  Serial.println("\nConnected!");
  Serial.print("IP: "); Serial.println(WiFi.localIP());
}

void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    long rssi = WiFi.RSSI();
    Serial.print("RSSI: ");
    Serial.print(rssi);
    Serial.println(" dBm");
  } else {
    Serial.println("WiFi disconnected");
  }
  delay(1000);
}
```

### 5.2 Scanning Nearby Networks
```cpp
#include <WiFi.h>

void setup() {
  Serial.begin(115200);
  WiFi.mode(WIFI_STA);
  WiFi.disconnect(true);
  delay(100);

  Serial.println("Scanning...");
  int n = WiFi.scanNetworks();
  if (n == 0) {
    Serial.println("No networks found.");
  } else {
    for (int i = 0; i < n; i++) {
      Serial.printf("[%2d] SSID: %-20s RSSI: %4d dBm  %s\n",
                    i, WiFi.SSID(i).c_str(), WiFi.RSSI(i),
                    (WiFi.encryptionType(i) == WIFI_AUTH_OPEN) ? "OPEN" : "SECURED");
    }
  }
}

void loop() {}
```

### 5.3 LED-Based Signal Indicator
```cpp
#include <WiFi.h>

const char* SSID = "YOUR_SSID";
const char* PASS = "YOUR_PASSWORD";
const int LED_PIN = 2;

void setup() {
  Serial.begin(115200);
  pinMode(LED_PIN, OUTPUT);
  WiFi.mode(WIFI_STA);
  WiFi.begin(SSID, PASS);
  while (WiFi.status() != WL_CONNECTED) {
    delay(300);
    Serial.print(".");
  }
  Serial.println("\nConnected.");
}

void loop() {
  long rssi = WiFi.RSSI();

  if (rssi > -60) {
    digitalWrite(LED_PIN, HIGH);
  } else if (rssi > -70) {
    digitalWrite(LED_PIN, millis() / 300 % 2);
  } else {
    digitalWrite(LED_PIN, millis() / 100 % 2);
  }

  Serial.printf("RSSI: %ld dBm\n", rssi);
  delay(200);
}
```

### 5.4 (Optional) Distance Estimation
```cpp
#include <WiFi.h>

const float RSSI_AT_1M = -40.0;
const float PATH_LOSS_EXP = 2.2;

void setup() {
  Serial.begin(115200);
  WiFi.begin("YOUR_SSID", "YOUR_PASSWORD");
  while (WiFi.status() != WL_CONNECTED) { delay(300); Serial.print("."); }
  Serial.println("\nConnected.");
}

void loop() {
  long rssi = WiFi.RSSI();
  float distance = pow(10.0, (RSSI_AT_1M - rssi) / (10.0 * PATH_LOSS_EXP));
  Serial.printf("RSSI: %ld dBm  ≈ Distance: %.2f m\n", rssi, distance);
  delay(1000);
}
```

---

## 📊 6. Experimental Verification

### Expected Serial Output
```
Connecting to MyWiFiNetwork
........
Connected!
IP: 192.168.1.45
RSSI: -58 dBm
RSSI: -60 dBm
```

| Distance (m) | RSSI (dBm) |
|---------------|-------------|
| 1             | -42         |
| 3             | -55         |
| 5             | -63         |
| 10            | -70         |

---

## 🔍 7. Discussion
- RSSI decreases as distance increases due to path loss.  
- Variations occur from interference or antenna orientation.  
- Averaging improves signal stability.  
- Path-loss estimation provides only approximate distances.

---

## 🧠 8. Exercises
1. Compute and display average RSSI over 10 samples.  
2. Plot RSSI vs distance.  
3. Compare multiple routers.  
4. Log RSSI data to SD or MQTT broker.

---

## 📎 9. References
1. Espressif Systems, *ESP32 Wi-Fi API Reference*  
2. IEEE 802.11 Standard, *RSSI Measurement Fundamentals*  
3. Arduino Reference: [WiFi.RSSI()](https://www.arduino.cc/en/Reference/WiFiRSSI)  
4. Espressif Docs: [RSSI API](https://docs.espressif.com/)
