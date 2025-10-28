# 📡 Adding Wi-Fi RSSI Monitoring and Distance Estimation to ESP32 MQTT JSON Publisher (LDR & I²C Temperature Sensor)

## 🧩 1. Objective
This guide extends the existing **ESP32 MQTT JSON Publisher** project to include both **Wi-Fi signal strength (RSSI)** and **approximate distance estimation** based on signal attenuation.  

Students will learn to:
- Measure Wi-Fi signal strength using `WiFi.RSSI()`.
- Estimate approximate distance from the router using a simple path-loss model.
- Integrate both RSSI and distance readings into the same JSON message.
- Verify the extended JSON payload using MQTT dashboards (e.g., HiveMQ WebSocket Client).

---

## ⚙️ 2. Required Changes Overview

| Step | Description |
|------|--------------|
| 1 | Add a function to read RSSI values |
| 2 | Compute approximate distance from RSSI |
| 3 | Integrate both into the JSON payload |
| 4 | Increase JSON buffer size |
| 5 | Verify via Serial Monitor and MQTT broker |

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

Add a simple averaging filter for smoother readings:
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

### Step 2: Add Distance Estimation Function
Add this below the RSSI function:
```cpp
// --- Distance Estimation from RSSI ---
// Reference model: d = 10 ^ ((RSSI_ref - RSSI) / (10 * n))
float estimateDistance(long rssi) {
  const float RSSI_REF = -40.0;  // RSSI at 1 meter (adjust experimentally)
  const float PATH_LOSS_EXP = 2.2;  // 2.0=open space, 2.7–3.5 indoor
  float distance = pow(10.0, (RSSI_REF - (float)rssi) / (10.0 * PATH_LOSS_EXP));
  return distance;
}
```

---

### Step 3: Integrate RSSI and Distance into JSON Payload
Inside your existing `publish_data()` function, after reading sensors, add:
```cpp
long rssi = readRssiAvg();         // RSSI in dBm
float distance_m = estimateDistance(rssi);  // Approx. distance in meters
```

Then include both in the JSON object:
```cpp
doc["rssi_dbm"] = rssi;
doc["distance_m"] = distance_m;
```

---

### Step 4: Adjust JSON Document Size
Update your JSON declaration to allocate more space:
```cpp
StaticJsonDocument<300> doc;
```

---

### Step 5: Final `publish_data()` Example
```cpp
void publish_data() {
  int ldrValue = analogRead(LDR_PIN);
  float temperature = readI2CTemperature();
  long rssi = readRssiAvg();
  float distance_m = estimateDistance(rssi);

  StaticJsonDocument<300> doc;
  doc["device_id"] = "ESP32_A1";
  doc["ldr_raw"] = ldrValue;
  doc["temperature_c"] = (temperature != -999.0) ? temperature : "ERROR";
  doc["rssi_dbm"] = rssi;
  doc["distance_m"] = distance_m;  // NEW FIELD

  char jsonBuffer[300];
  serializeJson(doc, jsonBuffer);

  if (client.publish(TOPIC, jsonBuffer)) {
    Serial.printf("✅ Published JSON → %s: %s\n", TOPIC, jsonBuffer);
  } else {
    Serial.printf("❌ Publish failed. MQTT state: %d\n", client.state());
  }
}
```

---

## 🌐 6. Example JSON Output
When viewed in the MQTT dashboard:
```json
{
  "device_id": "ESP32_A1",
  "ldr_raw": 2548,
  "temperature_c": 26.5,
  "rssi_dbm": -63,
  "distance_m": 2.38
}
```

---

## 📊 7. Verification Steps

1. **Serial Monitor:**  
   Verify real-time RSSI (dBm) and distance (m) values printed on the serial monitor.

2. **MQTT Dashboard:**  
   Subscribe to `esp32/sensor_data` and confirm that `"rssi_dbm"` and `"distance_m"` fields appear.

3. **Movement Test:**  
   Move the ESP32 closer/farther from the Wi-Fi router and note both RSSI and distance values.

| Location | RSSI (dBm) | Distance (m) |
|-----------|------------|--------------|
| Near router | -45 | 0.9 |
| 5 meters away | -60 | 2.3 |
| Behind a wall | -70 | 5.4 |

---

## 🧠 8. Discussion
- **RSSI** measures received signal power; **distance estimation** uses empirical formulas.  
- Distance values are **approximate** and affected by environment, walls, and antenna orientation.  
- Ideal for **RSSI-based IoT localization** or **signal strength diagnostics** in wireless sensor networks.

---

## 🧩 9. Optional Enhancement: RSSI Quality Label
You can classify signal quality in human-readable form:
```cpp
const char* quality;
if (rssi > -60) quality = "Excellent";
else if (rssi > -70) quality = "Good";
else quality = "Weak";
doc["rssi_quality"] = quality;
```

Sample MQTT payload:
```json
{
  "device_id": "ESP32_A1",
  "ldr_raw": 2600,
  "temperature_c": 27.3,
  "rssi_dbm": -68,
  "distance_m": 4.8,
  "rssi_quality": "Good"
}
```

---

## 📎 10. References
1. Espressif Systems, *ESP32 Wi-Fi API Reference*  
2. ArduinoJson Library by Benoit Blanchon  
3. Nick O’Leary, *PubSubClient MQTT Library*  
4. HiveMQ MQTT Web Client: [https://www.hivemq.com/demos/websocket-client/](https://www.hivemq.com/demos/websocket-client/)  
5. Path Loss Model: *Rappaport, Wireless Communications: Principles and Practice*, 2nd Ed.
