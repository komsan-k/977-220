# 🔬 Lab: ESP32 I²C Dual-Digit Counter Using HT16K33 8×16 LED Matrix

## 🧩 1. Objective
The purpose of this laboratory exercise is to interface the **ESP32 microcontroller** with the **Adafruit 8×16 LED Matrix display (HT16K33 driver)** using the **I²C protocol**.  
Students will learn to:
- Initialize and configure I²C communication on ESP32.  
- Display two-digit numbers (00–99) on a 16-column matrix.  
- Implement numeric swapping and timed updates using Arduino C++.

---

## ⚙️ 2. Required Components
| Component | Description | Quantity |
|------------|--------------|-----------|
| ESP32 Dev Board | Main microcontroller | 1 |
| HT16K33 8×16 LED Matrix | I²C display driver with LEDs | 1 |
| Jumper Wires | Male–Female | 4 |
| Breadboard | Optional for connections | 1 |
| USB Cable | Programming and power | 1 |

---

## 🔌 3. Circuit Connections
| ESP32 Pin | HT16K33 Pin | Description |
|------------|--------------|-------------|
| 3.3V | VCC | Power supply |
| GND | GND | Ground |
| GPIO21 | SDA | Serial Data |
| GPIO22 | SCL | Serial Clock |

> 💡 Note: The default I²C address for HT16K33 is **0x70**. You can modify it via address jumpers on the board if needed.

---

## 💻 4. Source Code

```cpp
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_LEDBackpack.h>

Adafruit_8x16matrix matrix = Adafruit_8x16matrix();

void setup() {
  Wire.begin(21, 22);         // SDA=21, SCL=22 for ESP32
  matrix.begin(0x70);         // Default I2C address for HT16K33
  matrix.setBrightness(8);    // Brightness 0..15
  matrix.clear();
  matrix.writeDisplay();
}

void loop() {
  for (int num = 0; num < 100; num++) {
    matrix.clear();

    // Extract digits
    int tens = num / 10;
    int ones = num % 10;

    matrix.setTextSize(1);
    matrix.setTextColor(LED_ON);

    // --- Swap positions ---
    // Ones digit on left (x=0..7)
    matrix.setCursor(0, 0);
    matrix.print(ones);

    // Tens digit on right (x≈8..15)
    matrix.setCursor(8, 0);
    matrix.print(tens);

    matrix.writeDisplay();
    delay(1000);  // 1 second per step
  }
}
```

---

## 🧠 5. Code Explanation
| Section | Description |
|----------|--------------|
| `Wire.begin(21, 22)` | Initializes the I²C bus with GPIO21 (SDA) and GPIO22 (SCL). |
| `matrix.begin(0x70)` | Starts communication with the HT16K33 device at address `0x70`. |
| `matrix.setBrightness(8)` | Sets the display brightness level (0–15). |
| `for (int num = 0; num < 100; num++)` | Loops through numbers 0–99. |
| `int tens = num / 10` and `int ones = num % 10` | Splits number into tens and ones digits. |
| `matrix.setCursor(x, y)` | Sets text position on the matrix. |
| `matrix.print(ones/tens)` | Prints digits at the designated locations. |
| `matrix.writeDisplay()` | Updates the LED matrix with the new data. |
| `delay(1000)` | Delays one second between updates. |

---

## 📟 6. Example Output
| Time (s) | Display (Left–Right) | Comment |
|-----------|---------------------|----------|
| 0 | 0 0 | Start |
| 5 | 5 0 | Counting |
| 10 | 0 1 | After 10 seconds, tens digit updates |
| 99 | 9 9 | End before reset |

---

## 🔍 7. Experiment Tasks
1. Modify the delay to 500 ms and observe the speed.  
2. Change brightness to 15 and note the visibility difference.  
3. Reverse the digit position (tens on left, ones on right).  
4. Extend the counter to three digits using two displays.  
5. Display custom characters such as “HI” or “OK”.

---

## 🧩 8. Troubleshooting Tips
| Issue | Possible Cause | Solution |
|--------|----------------|-----------|
| No display lights | Wrong I²C address | Check `matrix.begin(0x70)` or use I²C scanner. |
| Garbled text | Incorrect wiring | Verify SDA and SCL pins (21 & 22). |
| Display too dim | Low brightness setting | Increase `setBrightness()` value. |
| ESP32 reboot loop | Power instability | Use stable 3.3V supply. |

---

## 🧪 9. Learning Outcomes
After completing this lab, students should be able to:
- Interface an **I²C peripheral** with ESP32.  
- Write code to control **LED matrix displays** using Adafruit libraries.  
- Understand **digit extraction and text rendering** on LED matrices.  
- Implement simple visual counting systems for IoT or embedded displays.
