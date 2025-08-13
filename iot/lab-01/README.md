# Lab 1: Introduction to ESP32 and Development Environment

## Objective
- Install and configure the development environment for ESP32 programming.
- Verify ESP32 functionality by running a basic LED blink program.
- Familiarize with serial monitoring for debugging and output observation.

## Required Hardware and Software
- **Hardware:**
  - ESP32 development board (e.g., ESP32-DevKitC or NodeMCU-32S)
  - Micro-USB cable for data and power
  - Computer with Internet access
- **Software:**
  - Arduino IDE (latest version)
  - ESP32 Board Support Package (BSP) for Arduino IDE
  - USB-to-Serial driver (e.g., CP210x or CH340 driver, depending on board)

## Background Theory
The ESP32 is a low-cost, low-power system-on-chip (SoC) with integrated Wi-Fi and Bluetooth, making it a popular choice for IoT projects. It can be programmed using the Arduino IDE, which offers a simplified environment for rapid prototyping. The onboard LED or an external LED can be used to validate that the development environment is correctly set up and the board is functioning.

The Arduino programming model consists of:
- `setup()` — runs once at startup; used for initialization.
- `loop()` — runs repeatedly after `setup()`.

## Procedure
1. **Install Arduino IDE**  
   Download and install the Arduino IDE from:  
   [https://www.arduino.cc/en/software](https://www.arduino.cc/en/software)
   
2. **Install ESP32 Board Package**
   1. Open Arduino IDE.
   2. Go to **File → Preferences**.
   3. In the *Additional Board Manager URLs* field, add:  
      `https://dl.espressif.com/dl/package_esp32_index.json`
   4. Go to **Tools → Board → Boards Manager**, search for "ESP32" and install the package.

3. **Connect ESP32 to Computer**  
   Use the Micro-USB cable.

4. **Select Board and Port**
   1. **Tools → Board** → Select your ESP32 model.
   2. **Tools → Port** → Select the COM port associated with the ESP32.

5. **Write the Blink Program**
   ```cpp
   void setup() {
     pinMode(2, OUTPUT); // GPIO2 is often connected to onboard LED
   }

   void loop() {
     digitalWrite(2, HIGH); // LED ON
     delay(1000);           // wait 1 second
     digitalWrite(2, LOW);  // LED OFF
     delay(1000);           // wait 1 second
   }
   ```

6. **Upload Program**  
   Click the upload button. If upload fails initially, press and hold the "BOOT" button on the ESP32 while uploading.

7. **Observe Output**  
   The onboard LED should blink every second.

8. **Open Serial Monitor (Optional)**  
   **Tools → Serial Monitor** to view debug messages.

## Expected Results
- The ESP32's onboard LED blinks at a 1-second interval.
- The Arduino IDE successfully compiles and uploads code to the ESP32.
- Students understand how to select the correct board and COM port.

## Discussion Questions
1. Why is GPIO2 often used for the onboard LED on ESP32 boards?
2. What is the function of the `delay()` command in Arduino code?
3. How can you modify the program to blink the LED twice as fast?
4. What steps would you take if the Arduino IDE cannot detect the ESP32?
