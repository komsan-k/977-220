# 📡 Adding Wi-Fi RSSI Monitoring to ESP32 MQTT JSON Publisher (LDR & I²C Temperature Sensor)

## 🧩 1. Objective
This guide extends the existing **ESP32 MQTT JSON Publisher** project to include **Wi-Fi signal strength (RSSI)** monitoring.  
The goal is to add a real-time RSSI measurement to the same JSON payload already containing temperature and LDR values.

Students will learn to:
- Measure Wi-Fi signal strength using `WiFi.RSSI()`.
- Integrate RSSI readings into the existing JSON message.
- Verify the combined JSON payload using MQTT dashboards (e.g., HiveMQ WebSocket Client).

---

## ⚙️ 2. Required Changes Overview

| Step | Description |
|------|--------------|
| 1 | Add a function to read RSSI values |
| 2 | Integrate the RSSI data into the JSON payload |
| 3 | Increase the buffer size for JSON serialization |
| 4 | Verify results via Serial Monitor and MQTT broker |

---

## 💻 3. Code Integration Steps

### Step 1: Add RSSI Reading Function
Insert this code before your `setup()` function:
```cpp
// --- RSSI Reading Helper ---
long readRssiRaw() {
  return WiFi.RSSI();  // Returns signal strength in dBm (negative value)
}
```

(Optional) Add a simple averaging filter for more stable readings:
```cpp
long rssiBuf[8];
int  rssiCount = 0, rssiIndex = 0;

long readRssiAvg() {
  long value = WiFi.RSSI();
  rssiBuf[rssiIndex] = value;
  rssiIndex = (rssiIndex + 1) % 8;
  if (rssiCount < 8) rssiCount++;
  long sum = 0;
  for (int i = 0; i < rssiCount; i++) sum += rssiBuf[i];
  return sum / rssiCount;
}
```

---

### Step 2: Add RSSI into the JSON Payload
Inside your existing `publish_data()` function, after reading sensor values, insert:
```cpp
long rssi = readRssiAvg();  // or readRssiRaw();
```
Then include it as a new JSON field:
```cpp
doc["rssi_dbm"] = rssi;
```

---

### Step 3: Adjust JSON Document Size
Update your JSON document declaration to allocate more space:
```cpp
StaticJsonDocument<256> doc;
```
*(Increased from 200 to 256 bytes for additional fields.)*

---

### Step 4: Final `publish_data()` Example
```cpp
void publish_data() {
  int ldrValue = analogRead(LDR_PIN);
  float temperature = readI2CTemperature();
  long rssi = readRssiAvg();   // New RSSI value

  StaticJsonDocument<256> doc;
  doc["device_id"] = "ESP32_A1";
  doc["ldr_raw"] = ldrValue;
  doc["temperature_c"] = (temperature != -999.0) ? temperature : "ERROR";
  doc["rssi_dbm"] = rssi;  // New JSON field

  char jsonBuffer[256];
  serializeJson(doc, jsonBuffer);

  if (client.publish(TOPIC, jsonBuffer)) {
    Serial.printf("✅ Published JSON → %s: %s\n", TOPIC, jsonBuffer);
  } else {
    Serial.printf("❌ Publish failed. MQTT state: %d\n", client.state());
  }
}
```

---

## 🌐 5. Example JSON Output
When viewed in the MQTT client (e.g., HiveMQ WebSocket), you should see:
```json
{
  "device_id": "ESP32_A1",
  "ldr_raw": 2548,
  "temperature_c": 26.5,
  "rssi_dbm": -63
}
```

---

## 📊 6. Verification Steps

1. **Serial Monitor**:  
   Confirm that RSSI values appear correctly (e.g., -50 to -75 dBm).  

2. **MQTT Dashboard**:  
   Subscribe to `esp32/sensor_data` and ensure each message includes `"rssi_dbm"`.  

3. **Movement Test**:  
   Move the ESP32 closer/farther from the Wi-Fi router and observe how RSSI changes.  

| Location | RSSI (dBm) |
|-----------|------------|
| Near router | -45 |
| 5 meters away | -60 |
| Behind a wall | -70 |

---

## 🧠 7. Discussion
- **RSSI (Received Signal Strength Indicator)** represents the signal power level received by the ESP32.  
- Closer to **0 dBm = stronger signal**, while lower values (e.g., -80 dBm) indicate weaker connections.  
- Monitoring RSSI helps analyze **network stability** and can be used for **IoT diagnostics**, **mobility tracking**, or **edge reliability tests**.

---

## 🧩 8. Optional Enhancement: RSSI Quality Label
You can classify RSSI into human-readable quality levels:
```cpp
const char* quality;
if (rssi > -60) quality = "Excellent";
else if (rssi > -70) quality = "Good";
else quality = "Weak";

doc["rssi_quality"] = quality;
```

Sample MQTT message:
```json
{
  "device_id": "ESP32_A1",
  "ldr_raw": 2600,
  "temperature_c": 27.3,
  "rssi_dbm": -65,
  "rssi_quality": "Good"
}
```

---

## 📎 9. References
1. Espressif Systems, *ESP32 Wi-Fi API Reference*  
2. ArduinoJson Library by Benoit Blanchon  
3. Nick O’Leary, *PubSubClient MQTT Library*  
4. HiveMQ MQTT Web Client: [https://www.hivemq.com/demos/websocket-client/](https://www.hivemq.com/demos/websocket-client/)
