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

