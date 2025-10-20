# 🌡️ Lab: ESP32 I²C Temperature Sensor Interface (LM73/LM75/TMP102-Compatible)

## 🧩 1. Objective

This laboratory exercise introduces the use of the **I²C communication protocol** on the **ESP32** to acquire temperature data from a **digital temperature sensor** such as the LM73, LM75, or TMP102.  
Students will learn to:

- Configure custom I²C pins on the ESP32 (GPIO 4 and GPIO 5).  
- Communicate with an I²C temperature sensor using the `Wire.h` library.  
- Read, process, and interpret 12-bit temperature data.  
- Display the temperature output on the Serial Monitor.  

---

## ⚙️ 2. Background Theory

### 2.1 I²C Protocol Overview
**Inter-Integrated Circuit (I²C)** is a two-wire serial communication protocol used to connect low-speed peripherals to microcontrollers.

| Signal | Description |
|---------|-------------|
| **SDA** | Serial Data — transfers data between devices |
| **SCL** | Serial Clock — synchronizes communication |
| **Master** | Controls the clock and initiates data transfers (ESP32 acts as master) |
| **Slave** | Responds to master’s commands (the sensor) |

The ESP32 allows custom I²C pin mapping, enabling flexible hardware design.

### 2.2 LM73 / LM75 / TMP102 Temperature Sensors
- **LM73**: Typically an **SPI** sensor, but some breakout modules adapt it for I²C.  
- **LM75/TMP102**: Native **I²C** sensors widely used for temperature measurement.  

Each device stores temperature data in a **register** accessible via its **I²C address**, commonly **0x48**–**0x4B**.

### 2.3 Temperature Conversion Principle
The sensor sends a **16-bit digital word** containing temperature information:

T(°C) = Raw Value × 0.0625

(assuming a 12-bit resolution where each LSB = 0.0625°C)

---

## 🧰 3. Required Components

| Component | Quantity | Description |
|------------|-----------|-------------|
| ESP32 DevKit | 1 | Wi-Fi & I²C-capable microcontroller |
| LM73 / LM75 / TMP102 Module | 1 | Digital temperature sensor |
| Breadboard & Jumper Wires | – | For circuit assembly |
| 4.7 kΩ Resistors | 2 | I²C pull-up resistors (if not onboard) |
| USB Cable | 1 | Power and programming |

---

## 🔌 4. Circuit Wiring

| Sensor Pin | ESP32 GPIO Pin | Function |
|-------------|----------------|-----------|
| GND | GND | Ground |
| V+ | 3.3V | Power supply |
| SDA | GPIO 4 | Serial Data |
| SCL | GPIO 5 | Serial Clock |

### ⚡ Important Notes
- If using a **bare sensor chip**, ensure **4.7 kΩ pull-up resistors** on both SDA and SCL to 3.3V.  
- Many commercial breakout boards (e.g., TMP102, LM75 modules) already include these resistors.  

### 🧭 I²C Bus Configuration
The ESP32 supports multiple I²C buses. This experiment uses **custom pin assignment** via:
```cpp
Wire.begin(4, 5); // SDA = 4, SCL = 5
```

---

## 💻 5. Source Code

```cpp
#include <Wire.h>

// --- Configuration ---
// I2C Pins
const int I2C_SDA_PIN = 4;
const int I2C_SCL_PIN = 5;

// I2C Address (0x48–0x4B depending on module)
const uint8_t SENSOR_ADDRESS = 0x48;

// Temperature Register (default for LM75/TMP102)
const uint8_t TEMP_REGISTER = 0x00;

void setup() {
  Serial.begin(115200);
  delay(1000);
  Serial.println("🌡️ I2C Temperature Reader Initialized.");

  // Initialize I2C bus with custom pins
  Wire.begin(I2C_SDA_PIN, I2C_SCL_PIN);
}

void loop() {
  float temperature = readI2CTemperature();

  if (temperature != -999.0) {
    Serial.print("Temperature: ");
    Serial.print(temperature, 2);
    Serial.println(" °C");
  } else {
    Serial.println("⚠️ Error reading I2C sensor. Check wiring or address.");
  }

  delay(2000);
}

// ---------------------------------
// --- I2C Reading Function ---
// ---------------------------------

float readI2CTemperature() {
  uint16_t raw_temp;

  // Step 1: Send request to temperature register
  Wire.beginTransmission(SENSOR_ADDRESS);
  Wire.write(TEMP_REGISTER);
  if (Wire.endTransmission() != 0) return -999.0;

  // Step 2: Request two bytes from the sensor
  Wire.requestFrom(SENSOR_ADDRESS, 2);
  if (Wire.available() == 2) {
    uint8_t msb = Wire.read();
    uint8_t lsb = Wire.read();
    raw_temp = (msb << 8) | lsb;

    // Step 3: Convert to Celsius (12-bit, 0.0625°C/LSB)
    int16_t signed_raw = raw_temp >> 4;
    float temperature_c = (float)signed_raw * 0.0625;
    return temperature_c;
  }

  // Error: no data received
  return -999.0;
}
```

---

## 📟 6. Example Serial Monitor Output

```
🌡️ I2C Temperature Reader Initialized.
Temperature: 26.38 °C
Temperature: 26.44 °C
Temperature: 26.50 °C
```

If the output shows:
```
⚠️ Error reading I2C sensor. Check wiring or address.
```
→ Verify SDA/SCL wiring, I²C address, or pull-up resistors.

---

## 🔬 7. Lab Exercises

1. **Change I²C Pins:**  
   Modify the code to use GPIO 21 (SDA) and GPIO 22 (SCL) and observe results.

2. **Multiple Sensors:**  
   Add a second sensor with address `0x49` and read both sequentially.

3. **Temperature Averaging:**  
   Implement averaging of 5 samples to stabilize the reading.

4. **OLED Display Integration:**  
   Display the temperature on a 0.96" I²C OLED screen using the same bus.

5. **Alert Threshold:**  
   Add an LED to GPIO 2 that lights up when the temperature exceeds 30°C.

---

## 🧩 8. Discussion Questions

1. What are the key advantages of I²C over SPI for sensor networks?  
2. How do pull-up resistors stabilize I²C communication?  
3. Why does the ESP32 allow reassignment of I²C pins?  
4. How does data resolution (12-bit vs 16-bit) affect accuracy?  
5. How could this lab be extended to publish data to an MQTT broker?

---

## ✅ 9. Conclusion

In this lab, students successfully implemented **I²C communication** between an **ESP32** and a **digital temperature sensor**.  
They learned how to configure custom I²C pins, read data registers, and convert binary values into human-readable temperature data.  

This experiment serves as a foundation for **IoT sensor nodes**, where temperature data can later be **transmitted via MQTT or HTTP** to cloud platforms for monitoring and analytics.

---

## 📚 10. References

- Texas Instruments. *LM73, LM75, and TMP102 Datasheets.*  
- Espressif Systems. *ESP32 Technical Reference Manual.*  
- Arduino Documentation – [Wire Library](https://www.arduino.cc/en/reference/wire).  
- Kanjanasit, K. (2025). *IoT Laboratory Series, College of Computing, PSU–Phuket.*  

---

📅 **End of Lab Report: ESP32 I²C Temperature Sensor Interface**
