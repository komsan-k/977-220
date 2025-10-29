# 💡 Lab: ESP32 LED Toggle with Button Interrupt and Debounce

## 🧩 1. Objective
This laboratory exercise demonstrates how to use **hardware interrupts** on the **ESP32** to control an LED using a **button**.  
Students will learn how to:
- Configure **external interrupts** using `attachInterrupt()`.
- Implement **software debounce** to prevent false triggers.
- Print **LED state changes** in the Serial Monitor in real-time.

---

## ⚙️ 2. Components Required

| **Component** | **Description** |
|----------------|------------------|
| ESP32 Development Board | Wi-Fi + GPIO capable microcontroller |
| LED | Connected to GPIO12 with current-limiting resistor (220Ω–330Ω) |
| Push Button | Connected to GPIO14 (active LOW) |
| Breadboard & Jumpers | For circuit wiring |
| USB Cable | For programming and serial monitoring |

---

## 🔌 3. Circuit Connections

| **Component** | **ESP32 Pin** | **Description** |
|----------------|----------------|-----------------|
| LED (Anode) | GPIO12 | Output pin to control LED |
| LED (Cathode) | GND | Connected via 220Ω resistor |
| Button | GPIO14 | Input pin with interrupt (active LOW) |
| Button | GND | Connected to ground |
| USB | — | Power and serial communication |

---

## 💻 4. Complete Arduino Code

```cpp
// === ESP32 LED Toggle with Button Interrupt + Debounce ===
// Description: Toggle LED on GPIO12 using button on GPIO14 via interrupt with debounce and Serial print feedback.

const int LED_PIN = 12;       // LED connected to GPIO12
const int BUTTON_PIN = 14;    // Button connected to GPIO14

volatile bool ledState = false;          // Track LED state
volatile unsigned long lastInterruptTime = 0; // Store last interrupt timestamp
const unsigned long debounceDelay = 200; // Debounce delay in milliseconds

// === Interrupt Service Routine (ISR) ===
void IRAM_ATTR handleButtonPress() {
  unsigned long currentTime = millis();
  if (currentTime - lastInterruptTime > debounceDelay) {  // Debounce check
    ledState = !ledState;                 // Toggle LED state
    digitalWrite(LED_PIN, ledState);      // Update LED output
    Serial.println(ledState ? "LED ON" : "LED OFF");  // Print LED state
    lastInterruptTime = currentTime;      // Update last interrupt timestamp
  }
}

void setup() {
  Serial.begin(115200);
  pinMode(LED_PIN, OUTPUT);
  pinMode(BUTTON_PIN, INPUT_PULLUP);      // Use internal pull-up resistor

  // Initialize LED OFF
  digitalWrite(LED_PIN, LOW);

  // Attach interrupt on FALLING edge (button press)
  attachInterrupt(digitalPinToInterrupt(BUTTON_PIN), handleButtonPress, FALLING);

  Serial.println("System ready. Press the button to toggle LED state.");
  Serial.println("LED initial state: OFF");
}

void loop() {
  // Nothing here — all handled via interrupt
}
```

---

## 🧠 5. Background Theory

### 5.1 Interrupts
An **interrupt** allows the ESP32 to respond immediately to external events (like button presses) without continuously checking their state in the main loop.

### 5.2 Debouncing
Mechanical switches cause rapid ON/OFF transitions called **bouncing**.  
Software debounce prevents multiple triggers from a single press by enforcing a **time delay (200 ms)** between valid interrupts.

---

## 📟 6. Example Serial Monitor Output

```
System ready. Press the button to toggle LED state.
LED initial state: OFF
LED ON
LED OFF
LED ON
```

---

## 🔍 7. Verification Steps

1. **Upload** the code to your ESP32 using the Arduino IDE.  
2. **Open Serial Monitor** (baud rate = 115200).  
3. **Press the button** connected to GPIO14.  
4. Observe that the **LED toggles ON/OFF**, and messages appear in Serial Monitor.  

| **Button Press** | **Expected Output** |
|------------------|---------------------|
| 1st press | LED ON |
| 2nd press | LED OFF |
| 3rd press | LED ON |

---

## 🧩 8. Exercises

1. Modify the debounce delay to **100 ms** and observe the difference.  
2. Change the LED pin to **GPIO2** or another available pin.  
3. Implement a **counter** that counts how many times the button is pressed.  
4. Extend the system to **publish LED state via MQTT** to an IoT dashboard.

---

## 🧠 9. Key Takeaways
- Interrupts allow real-time event handling without blocking the main program.  
- Debouncing ensures stable input from mechanical switches.  
- The ESP32’s flexibility allows combining interrupts with IoT communication, e.g., MQTT, HTTP, or WebSocket for remote control.

---

## 📎 10. References

1. Espressif Systems, *ESP32 Technical Reference Manual*  
2. Arduino Reference, *attachInterrupt()*  
3. Random Nerd Tutorials – *ESP32 Interrupts with Arduino IDE*  
4. Electronics Hub – *Switch Debouncing Techniques*  
