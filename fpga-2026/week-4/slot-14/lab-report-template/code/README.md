# AI-FPGA — ANN for Smart Traffic Control

This project completes the executable Verilog and simulation examples for the linked lab and adds a Nexys A7 board wrapper, XDC pin assignments, a fixed-time comparison, an optional two-digit seven-segment display, and an optional traffic-light FSM.

> **Important distinction:** The linked README's H1/H2/H3 threshold equations are *illustrative fixed parameters*, not demonstrated results of Python training. The FPGA implements **inference**, not learning. The source GitHub page itself starts with a "Topic-15" heading although it is located at `week-4/slot-14`; this package follows the **Slot-14** course location.

## 1. Baseline design

```text
SW3:0 (Road A) --\
                  +--> traffic_hidden_layer --> traffic_output_layer --> class[1:0]
SW7:4 (Road B) --/                                          |
                                                          v
                                                green_time_controller
                                                          |
                                                    green_time[5:0]
```

Input values are unsigned 4-bit road levels (0–15). The 2–3–2 ANN in the original lab is a **threshold-based illustrative model**:

- `H1 = (road_a + road_b >= 5)`
- `H2 = (road_a + road_b >= 9)`
- `H3 = (road_a + road_b >= 13)`
- `class = 00` if total ≤ 4, `01` if total is 5–8, `10` if total ≥ 9
- `green_time = 10, 20, 30` seconds for classes `00`, `01`, `10`

The third hidden neuron is preserved to match the source but does not create a fourth output class: both H2 and H3 produce **High**. Class `11` is reserved and defaults to 10 seconds in the timing selector.

**The core top module selects a number of seconds; it does not count real time or drive red/yellow/green signals.** The optional FSM is a separate exercise.

## 2. Files

| File | Purpose |
|---|---|
| `rtl/traffic_hidden_layer.v` | Three hidden threshold neurons |
| `rtl/traffic_output_layer.v` | Low / Medium / High priority encoder |
| `rtl/traffic_ann.v` | ANN hierarchy |
| `rtl/green_time_controller.v` | Green-time selection 10/20/30 |
| `rtl/smart_traffic_ai_top.v` | **Baseline simulation/synthesis top** |
| `sim/tb_smart_traffic_ai.v` | Self-checking 5 examples + boundaries + all 256 pairs |
| `rtl/fixed_time_controller.v` | Fixed 20-second comparison |
| `sim/tb_compare_fixed_adaptive.v` | Adaptive vs fixed timing selection |
| `sim/tb_green_time_controller.v` | Test all classes including reserved `11` |
| `rtl/smart_traffic_nexys_a7_top.v` | **Basic Nexys A7 FPGA synthesis top** |
| `constraints/smart_traffic_nexys_a7_top.xdc` | Basic switches and LEDs |
| `rtl/green_time_7seg.v` | Optional two-digit 7-segment display |
| `rtl/smart_traffic_nexys_a7_7seg_top.v` | **Optional display synthesis top** |
| `constraints/smart_traffic_nexys_a7_7seg_top.xdc` | Optional display constraints + 100 MHz clock |
| `rtl/traffic_light_fsm.v` | Optional *actual* seconds-counting traffic-light FSM |
| `sim/tb_traffic_light_fsm.v` | Optional accelerated FSM simulation |
| `python/verify_traffic_model.py` | Independent Python reference, creates 256-row CSV |
| `python/expected_truth_table.csv` | Generated expected values for all 256 pairs |

## 3. Vivado XSim: baseline simulation

1. Create a Vivado RTL project targeting your actual Nexys A7 device.
2. Add the five baseline files from `rtl/` as **Design Sources**.
3. Add `sim/tb_smart_traffic_ai.v` as a **Simulation Source**.
4. Set `tb_smart_traffic_ai` as **simulation top**.
5. Run **Behavioral Simulation**. Inspect `road_a`, `road_b`, `uut.ANN.HL.h1/h2/h3`, `traffic_class`, and `green_time`.
6. The testbench should print `PASS: ALL SMART TRAFFIC ANN TESTS` after 267 checks (5 example + 6 boundary + 256 exhaustive). This is an **expected** output until XSim is run.

## 4. Other simulations

- Set `tb_compare_fixed_adaptive` as simulation top to compare the selected duration with the fixed 20-second baseline. Include `fixed_time_controller.v`.
- Set `tb_green_time_controller` as simulation top to verify `00→10`, `01→20`, `10→30`, and `11→10`.
- Optional: set `tb_traffic_light_fsm` as simulation top and include `traffic_light_fsm.v`. The FSM test uses `CLK_HZ=2` for a fast simulation; the default module parameter is `100000000` for 100 MHz hardware.

## 5. Nexys A7 hardware: basic switches and LEDs

1. Add the baseline five RTL modules and `smart_traffic_nexys_a7_top.v`.
2. Add `constraints/smart_traffic_nexys_a7_top.xdc`.
3. Set **`smart_traffic_nexys_a7_top`** as the synthesis top (not `smart_traffic_ai_top`).
4. Run Synthesis, Implementation, Generate Bitstream, and Program Device.
5. Set **SW[3:0]** for Road A and **SW[7:4]** for Road B.
6. Read **LD[1:0]** for traffic class and **LD[7:2]** for 6-bit binary green time.

| Road A | Road B | Class | Green time | LED[7:0] (binary) |
|---:|---:|:---:|---:|:---:|
| 1 | 1 | 00 | 10 | `00101000` |
| 3 | 3 | 01 | 20 | `01010001` |
| 5 | 5 | 10 | 30 | `01111010` |
| 7 | 7 | 10 | 30 | `01111010` |
| 2 | 8 | 10 | 30 | `01111010` |

**Optional display:** Use `smart_traffic_nexys_a7_7seg_top` and its matching XDC **instead of** the basic wrapper/XDC. It displays `10`, `20`, or `30` on the rightmost two digits and requires the board's 100 MHz clock. Do not enable both XDC files simultaneously.

## 6. Optional real-time FSM

`traffic_light_fsm.v` cycles **GREEN → YELLOW → RED → GREEN**, sampling `selected_green_time` at the beginning of a green phase. It does not choose which of two roads gets green; that is a separate advanced extension. It is not part of the baseline `smart_traffic_ai_top` and must be wired into a separate top-level design for deployment.

## 7. Resource analysis and limitations

- Compare the original baseline with the optional display wrapper only when noting the different included functionality.
- The source model uses fixed thresholds and may synthesize to comparators rather than general MAC multipliers; **DSP utilization may be zero**.
- The baseline is combinational: do not report a clocked maximum frequency without adding registers and meaningful timing constraints.
- No FPGA timing, LUT, FF, DSP, or power figures are assumed; record them from Vivado.
- A selected green-time value is **not** a measured vehicle delay, congestion reduction, or a safety-qualified real traffic controller.

## 8. Independent reference check

Run `python python/verify_traffic_model.py` to regenerate `expected_truth_table.csv`. This validates the Python reference and expected cases; it does **not** replace an HDL simulation.
