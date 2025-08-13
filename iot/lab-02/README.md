# Lab 2: Connecting ESP32 to Wi-Fi

## Objective
- Configure ESP32 to connect to a local Wi-Fi network.
- Verify successful network connection by retrieving the assigned IP address.
- Understand the role of Wi-Fi libraries and event handling in IoT applications.

## Required Hardware and Software
- **Hardware:**
  - ESP32 development board
  - Micro-USB cable
  - Computer with Arduino IDE configured for ESP32 development
  - Local Wi-Fi network (2.4 GHz recommended; SSID and password known)
  - Optional: Smartphone or another device to ping/test the ESP32’s IP address

## Background Theory
The ESP32 has a built-in Wi-Fi transceiver, supporting 802.11 b/g/n standards in the 2.4 GHz band. It can act as a *station* (STA), *access point* (AP), or both simultaneously (AP+STA). In most IoT applications, the STA mode is used to connect the device to an existing Wi-Fi network for Internet access.

In Arduino IDE, the `WiFi.h` library provides functions for:
- Connecting to a specified SSID with a password.
- Checking connection status.
- Retrieving the device’s IP address.

## Procedure
1. **Open Arduino IDE** and create a new sketch named `WiFi_Connect`.
2. **Include the Wi-Fi library:**
   ```cpp
   #include <WiFi.h>
   ```
3. **Define network credentials:**
   ```cpp
   const char* ssid     = "Your_SSID";
   const char* password = "Your_PASSWORD";
   ```
4. **Write the setup function:**
   ```cpp
   void setup() {
     Serial.begin(115200);
     delay(1000);

     Serial.println();
     Serial.print("Connecting to ");
     Serial.println(ssid);

     WiFi.begin(ssid, password);

     while (WiFi.status() != WL_CONNECTED) {
       delay(500);
       Serial.print(".");
     }

     Serial.println("");
     Serial.println("WiFi connected.");
     Serial.print("IP address: ");
     Serial.println(WiFi.localIP());
   }
   ```
5. **Empty loop function:**
   ```cpp
   void loop() {
     // No repetitive tasks needed for this lab
   }
   ```
6. **Upload the code** to the ESP32 using the same procedure as Lab 1.
7. **Open the Serial Monitor** at 115200 baud to view the connection process and the assigned IP address.
8. **Test connectivity:** From another device on the same network, ping the IP address displayed.

## Expected Results
- The ESP32 successfully connects to the Wi-Fi network.
- The assigned local IP address is displayed on the Serial Monitor.
- The ESP32 responds to ping requests from other devices on the same network.

## Discussion Questions
1. What happens if you enter an incorrect SSID or password?
2. Why is the connection check (`WiFi.status()`) placed inside a `while` loop?
3. How can you modify the code to attempt reconnection if the Wi-Fi is lost during operation?
4. What are the potential security concerns of hardcoding Wi-Fi credentials in firmware?

