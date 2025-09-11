# Minimal Wokwi Clock Generator Example

This project demonstrates a **minimal working `diagram.json`** that uses the hidden **`wokwi-clock-generator`** to blink an LED at **1 Hz** — with no Arduino or custom chip required.

---

## `diagram.json`

```json
{
  "version": 1,
  "author": "you",
  "editor": "wokwi",
  "parts": [
    { "type": "wokwi-clock-generator", "id": "clk1", "top": 40, "left": 160,
      "attrs": { "frequency": "1" } },             // 1 Hz square wave
    { "type": "wokwi-led", "id": "led1", "top": 120, "left": 320,
      "attrs": { "color": "red", "label": "CLK" } },
    { "type": "wokwi-gnd", "id": "gnd", "top": 200, "left": 320 }
  ],
  "connections": [
    ["clk1:CLK", "led1:A", "green"],
    ["led1:C",   "gnd:GND", "black"]
  ]
}
```

---

## Notes

- The clock output pin is `clk1:CLK`.
- The LED’s **anode (A)** connects to the clock generator.
- The LED’s **cathode (C)** connects to ground.
- Change `"frequency": "1"` to any value in **Hz**:
  - `"2"` → 2 Hz
  - `"1000"` → 1 kHz

---

## ✅ Usage

1. Open [Wokwi](https://wokwi.com) and create a new project.
2. Replace the project’s `diagram.json` with the JSON above.
3. Run the simulation.  
   - The LED will blink at the specified frequency.

