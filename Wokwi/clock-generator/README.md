# Using the Wokwi Clock Generator

The **wokwi-clock-generator** is an unofficial/hidden part you can add manually to your Wokwi project. It acts like a square-wave generator that you can wire into your custom Verilog chip’s `CLK` input.

---

## Steps to Add the Clock Generator

1. Open your **Wokwi project**.
2. In the editor, click the **`diagram.json`** tab (you may need to enable "Show Diagram JSON").
3. Inside the `"parts": [ … ]` array, add a part entry like this:

```json
{
  "type": "wokwi-clock-generator",
  "id": "clk1",
  "top": -57.6,
  "left": -38.4,
  "attrs": { "frequency": "1000" }
}
```

---

## Attributes

- `"frequency": "1000"` → generates a **1 kHz** clock  
- You can change the value to any frequency you want:
  - `"2"` → 2 Hz
  - `"1000000"` → 1 MHz

---

## Wiring it Up

In the `"connections": [ … ]` section of `diagram.json`, connect the clock generator to your chip’s clock input:

```json
["clk1:CLK", "dut:IN", "green"]
```

- Here, `dut:IN` refers to your **custom chip’s input pin**, as defined in `mychip.chip.json`.

---

## ✅ Run the Simulation

When you run the simulation, the **wokwi-clock-generator** will drive your chip’s input at the specified frequency — **no Arduino or 555 timer required**.

