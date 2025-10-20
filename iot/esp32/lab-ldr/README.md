# 💡 Lab: Reading Light Intensity Using LDR and ESP32 (Analog Sensor Interface)

## 🧩 1. Objective

This lab demonstrates how to use an **ESP32** to measure **light intensity** from an **LDR (Light Dependent Resistor)** using the built-in **Analog-to-Digital Converter (ADC)**.  
Students will learn how to:
- Interface an analog sensor (LDR) with ESP32.
- Understand the concept of voltage divider circuits.
- Acquire and process analog data using `analogRead()`.
- Convert raw ADC values into human-readable light intensity percentages.
- Visualize sensor data using the Serial Monitor.

---

## ⚙️ 2. Background Theory

### 2.1 Light Dependent Resistor (LDR)
An **LDR**, or **photoresistor**, is a light-sensitive device whose resistance decreases as light intensity increases.  
- **Dark environment:** High resistance → low voltage output.  
- **Bright environment:** Low resistance → high voltage output.  

When used in a **voltage divider circuit**, the ESP32 can read this voltage and convert it into a digital value using its **ADC (Analog-to-Digital Converter)**.

### 2.2 ESP32 ADC Characteristics
- **Resolution:** 12-bit (0–4095).  
- **Input Voltage Range:** 0–3.3V.  
- **Typical Analog Input Pins:** GPIO 32–39 (ADC1 group).  

**GPIO 36 (ADC1_CH0)** is used in this experiment.

### 2.3 Voltage Divider Principle

The LDR is connected in series with a fixed resistor (typically 10 kΩ):

```
   3.3V
    │
   [LDR]
    │───────► A0 (GPIO36)
   [10 kΩ]
    │
   GND
```

The output voltage at the midpoint (to ESP32 Pin 36) is given by:

\[
V_{out} = V_{in} \times \frac{R_{fixed}}{R_{LDR} + R_{fixed}}
\]

Thus, as light increases (R_LDR decreases), Vout increases.

---

## 🧰 3. Required Components

| Component | Quantity | Description |
|------------|-----------|-------------|
| ESP32 DevKit Board | 1 | Main microcontroller |
| LDR Sensor | 1 | Light-sensitive resistor |
| 10 kΩ Resistor | 1 | Voltage divider resistor |
| Breadboard & Jumper Wires | – | For circuit assembly |
| USB Cable | 1 | For uploading and power |

---

## 🔌 4. Circuit Wiring

| Component | Connected To |
|------------|---------------|
| LDR Pin 1 | 3.3 V (VCC) |
| LDR Pin 2 | GPIO 36 (ADC input) |
| 10 kΩ Resistor | Between GPIO 36 and GND |
| ESP32 GND | Common ground |

### 🧭 Connection Summary
The LDR and resistor form a **voltage divider**, feeding a proportional voltage to GPIO 36.  
The ESP32’s ADC converts this voltage to a digital value (0 – 4095).

---

## 💻 5. Source Code

```cpp
// --- ESP32 LDR Reader ---
// Reads light intensity using an LDR connected to GPIO36 (ADC1_CH0)

const int LDR_PIN = 36;          // Analog pin connected to voltage divider
const int ADC_MAX_VALUE = 4095;  // 12-bit ADC resolution for ESP32

void setup() {
  Serial.begin(115200);
  pinMode(LDR_PIN, INPUT);
  Serial.println("📡 LDR Reader Initialized.");
  Serial.println("Reading light level from Pin 36...");
}

void loop() {
  // 1. Read the analog voltage from LDR
  int ldrValue = analogRead(LDR_PIN);

  // 2. Convert raw ADC value (0–4095) to percentage (0–100%)
  float lightPercentage = ((float)ldrValue / ADC_MAX_VALUE) * 100.0;

  // 3. Print readings to Serial Monitor
  Serial.print("Raw LDR Value: ");
  Serial.print(ldrValue);
  Serial.print("  |  Light Level: ");
  Serial.print(lightPercentage, 1); // 1 decimal place
  Serial.println("%");

  // 4. Wait before next reading
  delay(500);
}
```

---

## 🧠 6. Code Explanation

| Section | Description |
|----------|-------------|
| **LDR_PIN (GPIO36)** | Configured as analog input. |
| **analogRead()** | Reads voltage from 0–3.3 V, converted to 0–4095. |
| **Conversion Formula** | Converts raw ADC value to light intensity (%) for easier interpretation. |
| **Serial Output** | Displays live readings every 500 ms. |
| **Observation** | Higher light → higher ADC value and percentage. |

---

## 📟 7. Serial Monitor Example Output

```
📡 LDR Reader Initialized.
Reading light level from Pin 36...
Raw LDR Value: 350  |  Light Level: 8.5%
Raw LDR Value: 1250 |  Light Level: 30.5%
Raw LDR Value: 3890 |  Light Level: 95.0%
```

**Observation:**  
- When the LDR is covered → value drops toward 0%.  
- When light shines → value rises toward 100%.

---

## 🔬 8. Lab Exercises

1. **Threshold Detection:**  
   Add an `if` statement to turn ON an LED when light falls below 30%.  

2. **Averaging Filter:**  
   Modify the code to average 10 samples to reduce noise.  

3. **Serial Plotter Visualization:**  
   Use Arduino’s Serial Plotter to visualize light intensity changes in real time.  

4. **Ambient Light Mapping:**  
   Record values under different lighting conditions (e.g., dark room, sunlight, lamp).  

5. **Analog Calibration:**  
   Replace the 10 kΩ resistor with 4.7 kΩ or 47 kΩ and observe sensitivity differences.  

---

## 🧩 9. Discussion Questions

1. Why is a voltage divider necessary for LDR interfacing?  
2. What factors affect ADC accuracy on ESP32?  
3. How can analog readings be improved for stability?  
4. Why does the ADC range only go up to 4095?  
5. How could this LDR circuit be integrated into an IoT light-monitoring system?  

---

## ✅ 10. Conclusion

In this lab, students successfully interfaced an **LDR sensor** with the **ESP32** to measure ambient light intensity.  
Key learning outcomes include:
- Understanding analog-to-digital conversion.
- Building and analyzing a voltage divider circuit.
- Converting ADC readings to light percentage.
- Monitoring and interpreting sensor output dynamically.

This foundation supports advanced IoT experiments such as **automatic lighting control**, **environmental monitoring**, and **edge-based light analytics**.

---

## 📚 11. References

- Espressif Systems, *ESP32 Technical Reference Manual*  
- Arduino Official Documentation – [analogRead() Reference](https://www.arduino.cc/reference/en/language/functions/analog-io/analogread/)  
- Electronics Tutorials – [LDR Working Principle](https://www.electronics-tutorials.ws/io/io_4.html)  
- Random Nerd Tutorials – *ESP32 ADC Reading Examples*  
- Kanjanasit, K. (2025). *IoT Laboratory Series, Prince of Songkla University*  

---

📅 **End of Lab Report: ESP32 LDR Light Intensity Measurement**
