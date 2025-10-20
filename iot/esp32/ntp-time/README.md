🌐 Lab: ESP32 Real-Time Clock Synchronization using NTP Server

## 🧩 1. Objective

This lab demonstrates how to use the **ESP32 microcontroller** to obtain accurate **real-time clock (RTC)** information from an **NTP (Network Time Protocol) server** over Wi-Fi.  
Students will learn how to:
- Connect the ESP32 to a Wi-Fi network.  
- Configure NTP synchronization using the ESP32 time library.  
- Display the current time in **UTC+7 (Thailand/Hanoi)**.  
- Periodically update and print the local time to the Serial Monitor.  

---

## ⚙️ 2. Background Theory

### 2.1 What is NTP?
**Network Time Protocol (NTP)** is a standard protocol for synchronizing the clocks of devices over a network.  
It ensures that all networked systems maintain accurate and consistent time, which is crucial in IoT applications such as:
- Timestamping sensor data.
- Coordinating distributed devices.
- Scheduling cloud-based automation.

### 2.2 ESP32 and NTP Integration
The **ESP32** includes built-in support for NTP synchronization using the `configTime()` function from the **time.h** library.  
The function retrieves the current UTC time from a network time server and maintains it using the device’s internal RTC.

### 2.3 Time Zone and Offset
- **GMT Offset (gmtOffset_sec):** Time zone difference in seconds (e.g., +7 hours → 7 × 3600 = 25200).  
- **Daylight Offset (daylightOffset_sec):** Additional offset for regions with Daylight Saving Time (usually 0 or 3600).  
- **NTP Server:** The URL of the time synchronization service (e.g., `pool.ntp.org`).

---

## 🧰 3. Required Components

| Item | Description |
|------|--------------|
| **ESP32 Board** | NodeMCU-32S / ESP32 DevKitC |
| **Wi-Fi Network** | Required for Internet access |
| **Arduino IDE** | For coding and uploading firmware |
| **USB Cable** | For programming and serial monitoring |

---

## 💻 4. Source Code

```cpp
#include <WiFi.h>
#include "time.h"

// --- Configuration ---
const char* ssid = "YOUR_WIFI_SSID";       // <--- CHANGE THIS
const char* password = "YOUR_WIFI_PASSWORD"; // <--- CHANGE THIS

// NTP Server and Time Zone settings
const char* ntpServer = "pool.ntp.org";
const long  gmtOffset_sec = 25200; // Offset for +7:00 (Thailand/Hanoi)
const int   daylightOffset_sec = 0; // No daylight saving

void setup_wifi() {
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("\\nWiFi connected");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());
}

void printLocalTime() {
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) {
    Serial.println("Failed to obtain time");
    return;
  }

  // Format time as YYYY-MM-DD HH:MM:SS
  char time_output[64];
  strftime(time_output, 64, "%Y-%m-%d %H:%M:%S", &timeinfo);
  Serial.print("Current Time (UTC+7): ");
  Serial.println(time_output);
}

void setup() {
  Serial.begin(115200);
  setup_wifi();

  Serial.println("Configuring NTP Time...");
  configTime(gmtOffset_sec, daylightOffset_sec, ntpServer);

  // Initial print
  printLocalTime();
}

void loop() {
  static unsigned long lastPrintTime = 0;
  if (millis() - lastPrintTime >= 10000) {
    printLocalTime();
    lastPrintTime = millis();
  }
}
```

---

## 🧠 5. Code Explanation

| Section | Description |
|----------|-------------|
| **Wi-Fi Connection** | The ESP32 connects to the specified Wi-Fi network using SSID and password. |
| **NTP Configuration** | `configTime()` initializes synchronization with `pool.ntp.org`. |
| **Time Printing** | `printLocalTime()` retrieves and formats the current time using `strftime()`. |
| **Loop Function** | Updates the displayed time every 10 seconds. |
| **Time Zone Setup** | The offset `25200` seconds corresponds to UTC+7. |

---

## 📡 6. Serial Monitor Output Example

When successfully connected and synchronized, the output appears as:

```
Connecting to MyWiFiNetwork
.........
WiFi connected
IP Address: 192.168.1.42
Configuring NTP Time...
Current Time (UTC+7): 2025-10-20 10:15:24
Current Time (UTC+7): 2025-10-20 10:15:34
Current Time (UTC+7): 2025-10-20 10:15:44
```

---

## 🧩 7. Exercises

1. **Time Zone Modification:**  
   Change the `gmtOffset_sec` value to correspond to your own time zone (e.g., UTC+8 for Singapore = 28800 seconds).  

2. **Daylight Saving:**  
   Simulate Daylight Saving by setting `daylightOffset_sec = 3600` and observe the time shift.  

3. **Custom NTP Server:**  
   Replace `pool.ntp.org` with your regional NTP pool, e.g., `th.pool.ntp.org`.  

4. **Display Format:**  
   Modify the `strftime()` pattern to include day name or AM/PM format, e.g., `"%A %I:%M:%S %p"`.  

5. **LCD/Display Extension:**  
   Connect a 16×2 LCD or OLED display to show the current time instead of Serial Monitor.  

6. **Timestamping Application:**  
   Extend the code to print time-stamped sensor readings (temperature, humidity, etc.).  

---

## 📚 8. Discussion Questions

1. Why is NTP synchronization important in IoT systems?  
2. What happens if the ESP32 loses Wi-Fi connection — will the time still update?  
3. How often should NTP synchronization occur in a real IoT system?  
4. Explain how `configTime()` differs from manually setting the clock.  
5. How can you ensure long-term clock accuracy in offline IoT devices?  

---

## ✅ 9. Conclusion

This lab demonstrates how the ESP32 can **synchronize time automatically** using an **NTP server**, a crucial capability in modern IoT systems.  
Students learned how to:
- Connect to Wi-Fi.  
- Use `configTime()` for real-time clock updates.  
- Display formatted local time in the serial monitor.  

The technique lays the foundation for **timestamped IoT data logging**, **real-time scheduling**, and **synchronized edge devices**.

---

## 🔗 10. References

- [ESP32 Arduino Core Documentation](https://docs.espressif.com/projects/arduino-esp32/en/latest/)  
- [Network Time Protocol (NTP)](https://www.ntp.org/)  
- [Arduino time.h Reference](https://www.arduino.cc/reference/en/libraries/time/)  
- [ESP-IDF time API](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/system/system_time.html)  
- [pool.ntp.org Project](https://www.pool.ntp.org/)

---

📅 **End of Lab Report: ESP32 NTP Synchronization**
"""

# Save to file
path = Path("/mnt/data/README_ESP32_NTP_Lab.md")
path.write_text(lab_ntp_content, encoding="utf-8")



