# Minimal Wokwi Project with Clock Generator and 4-bit Counter

This project demonstrates how to use the hidden **wokwi-clock-generator** to drive a custom **4-bit counter chip** and display its outputs on LEDs.

---

## Files

- `diagram.json` — connects the clock generator, custom chip, and LEDs  
- `mychip.chip.v` — Verilog source for the 4-bit counter (top module `wokwi`)  
- `mychip.chip.json` — pin mapping for the custom chip

---

## `diagram.json`

```json
{
  "version": 1,
  "author": "you",
  "editor": "wokwi",
  "parts": [
    { "type": "chip-mychip", "id": "dut", "top": 120, "left": 200 },

    { "type": "wokwi-clock-generator", "id": "clk1", "top": 20, "left": 200,
      "attrs": { "frequency": "1000" } },  // 1 kHz

    { "type": "wokwi-led", "id": "led0", "top": 120, "left": 420, "attrs": { "color": "red",   "label": "OUT0" } },
    { "type": "wokwi-led", "id": "led1", "top": 160, "left": 420, "attrs": { "color": "green", "label": "OUT1" } },
    { "type": "wokwi-led", "id": "led2", "top": 200, "left": 420, "attrs": { "color": "yellow","label": "OUT2" } },
    { "type": "wokwi-led", "id": "led3", "top": 240, "left": 420, "attrs": { "color": "blue",  "label": "OUT3" } },

    { "type": "wokwi-gnd", "id": "gnd", "top": 300, "left": 420 }
  ],
  "connections": [
    ["clk1:CLK", "dut:CLK", "green"],

    ["dut:OUT0", "led0:A", "orange"],
    ["dut:OUT1", "led1:A", "orange"],
    ["dut:OUT2", "led2:A", "orange"],
    ["dut:OUT3", "led3:A", "orange"],

    ["led0:C", "gnd:GND", "black"],
    ["led1:C", "gnd:GND", "black"],
    ["led2:C", "gnd:GND", "black"],
    ["led3:C", "gnd:GND", "black"]
  ]
}
```

---

## Usage

1. Open [Wokwi](https://wokwi.com) and create a new project.  
2. Add a **Custom Chip** named `mychip`, and upload:
   - `mychip.chip.v`
   - `mychip.chip.json`
3. Replace the project `diagram.json` with the code above.  
4. Run the simulation.  
   - The hidden **wokwi-clock-generator** will drive your counter at **1 kHz**.  
   - The four LEDs will display the binary count from `OUT0..OUT3`.  

---

## ✅ Notes

- The clock generator `"frequency"` is in **Hz**. Change `"1000"` to adjust speed.  
- Your `mychip.chip.json` must define pins: `CLK`, `OUT0`, `OUT1`, `OUT2`, `OUT3`.  
- The Verilog top module must be named **`wokwi`**.  

