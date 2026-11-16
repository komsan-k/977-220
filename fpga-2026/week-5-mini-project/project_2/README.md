# Expected Result Pattern — Two-Road Intersection Traffic Controller with Pedestrian Crossing

This laboratory reference describes a **two-road intersection**: an **East–West (EW)** road crossing a **North–South (NS)** road. Each road has independent **RED, YELLOW, GREEN** signals, and a pedestrian push button requests an exclusive crossing phase. It revises the earlier one-direction traffic-controller example.

> **Scope and assumptions:** The original uploaded reference describes a stopwatch, not traffic-controller RTL. The FSM, timings, request-handling policy, and example traces here are **proposed instructional behavior**, not verified results from a supplied Verilog implementation. Adapt the timing and outputs to the actual RTL and testbench.

---

## 1. Intersection Concept

```text
                   NORTH
                     |
               [NS R Y G]
                     |
 WEST --- [EW R Y G] + [EW R Y G] --- EAST
                     |
               [NS R Y G]
                     |
                   SOUTH

            [Pedestrian request button]
            [WALK / DON'T WALK signals]
```

The paired signals on each road represent the same logical traffic phase. **Only one road may receive GREEN at a time.** Pedestrian WALK is permitted only when **both roads are RED**.

## 2. Testbench Timing Summary (Illustrative)

- `` `timescale 1ms/1us ``
- `clk` **toggles every 3 ms**; its full period is **6 ms**.
- Active-high reset `rst` is asserted from **0 to 3 ms** (released at 3 ms).
- The first rising clock edge **after reset** is **4 ms**. Subsequent rising edges occur at **10, 16, 22, 28, ... ms**.
- **Clock phase note:** To obtain the specified 4 ms rising edge while toggling every 3 ms, initialize `clk = 1` and toggle at 1, 4, 7, 10, ... ms. The 1 ms rising edge is *not* present: the first toggle at 1 ms is falling. An ordinary `clk=0; always #3 clk=~clk;` instead produces rising edges at 3, 9, 15, ... ms and does **not** match this schedule.
- One rising edge represents one **accelerated simulation tick**, not one real-world second.
- EW GREEN: **4 ticks**; EW YELLOW: **2 ticks**.
- NS GREEN: **4 ticks**; NS YELLOW: **2 ticks**.
- All-red transition/clearance: **1 tick** per transition.
- Pedestrian WALK: **3 ticks**; pedestrian clearance (DON'T WALK, both roads RED): **1 tick**.
- **Pedestrian WALK requires a button press** (`ped_button` / `ped_request`). No request means no WALK phase.
- A button press is sampled on a rising edge and **latched** as `request_pending` until serviced. The request is served at the **next safe all-red boundary** after the current vehicle phase completes YELLOW; the normal road alternation then resumes.
- For real FPGA hardware, synchronize and debounce the push button. In the testbench, hold the press long enough to span at least one sampling edge.

Tables below describe the outputs **immediately after each rising edge**, with the initial post-reset EW GREEN state at **4 ms**. State durations and request timing are illustrative design assumptions, not measurements from supplied traffic-controller RTL.

## 3. FSM States and Expected Outputs

`1` means the lamp is ON; `0` means OFF. Signal order is `(R,Y,G)`.

| State | EW (R,Y,G) | NS (R,Y,G) | Pedestrian WALK | Pedestrian DON'T WALK | Meaning |
|---|:---:|:---:|:---:|:---:|---|
| `EW_GREEN` | `001` | `100` | 0 | 1 | EW traffic moves |
| `EW_YELLOW` | `010` | `100` | 0 | 1 | EW prepares to stop |
| `ALL_RED_EW_NS` | `100` | `100` | 0 | 1 | Clearance before NS or pedestrian phase |
| `NS_GREEN` | `100` | `001` | 0 | 1 | NS traffic moves |
| `NS_YELLOW` | `100` | `010` | 0 | 1 | NS prepares to stop |
| `ALL_RED_NS_EW` | `100` | `100` | 0 | 1 | Clearance before EW or pedestrian phase |
| `PED_WALK` | `100` | `100` | 1 | 0 | Exclusive pedestrian crossing |
| `PED_CLEAR` | `100` | `100` | 0 | 1 | Pedestrian clearance before vehicles resume |
| `RESET` | `100` | `100` | 0 | 1 | Safe reset outputs |

**Safety requirements:**

- `!(EW_GREEN && NS_GREEN)`
- `ped_walk -> (EW_RED && NS_RED)`
- Neither road may display GREEN simultaneously with its own RED or YELLOW.
- Each road must pass through YELLOW and all-red clearance before the other road turns GREEN.

## 4. Normal Alternating Pattern — No Pedestrian Button Press

| Time (ms) | FSM state | EW (R,Y,G) | NS (R,Y,G) | Pedestrian |
|---:|---|:---:|:---:|---|
| 0–3 | `RESET` | `100` | `100` | DON'T WALK |
| 4 | `EW_GREEN` | `001` | `100` | DON'T WALK |
| 10 | `EW_GREEN` | `001` | `100` | DON'T WALK |
| 16 | `EW_GREEN` | `001` | `100` | DON'T WALK |
| 22 | `EW_GREEN` | `001` | `100` | DON'T WALK |
| 28 | `EW_YELLOW` | `010` | `100` | DON'T WALK |
| 34 | `EW_YELLOW` | `010` | `100` | DON'T WALK |
| 40 | `ALL_RED_EW_NS` | `100` | `100` | DON'T WALK |
| 46 | `NS_GREEN` | `100` | `001` | DON'T WALK |
| 52 | `NS_GREEN` | `100` | `001` | DON'T WALK |
| 58 | `NS_GREEN` | `100` | `001` | DON'T WALK |
| 64 | `NS_GREEN` | `100` | `001` | DON'T WALK |
| 70 | `NS_YELLOW` | `100` | `010` | DON'T WALK |
| 76 | `NS_YELLOW` | `100` | `010` | DON'T WALK |
| 82 | `ALL_RED_NS_EW` | `100` | `100` | DON'T WALK |
| 88 | `EW_GREEN` | `001` | `100` | DON'T WALK |

**Without a button press, WALK remains OFF throughout the cycle.**

## 5. Pedestrian Button-Request Pattern

Example: the pedestrian **presses the button at 13 ms** while EW is GREEN, and releases it at **19 ms**. The button is high across the rising edge at **16 ms**, so the controller records `request_pending = 1`. The controller finishes the EW GREEN and YELLOW phases and waits until both roads are RED before granting WALK.

| Time (ms) | Button | Request pending | FSM state | EW (R,Y,G) | NS (R,Y,G) | Pedestrian |
|---:|:---:|:---:|---|:---:|:---:|---|
| 4 | 0 | 0 | `EW_GREEN` | `001` | `100` | DON'T WALK |
| 10 | 0 | 0 | `EW_GREEN` | `001` | `100` | DON'T WALK |
| 13 | **1 (pressed)** | 0 | `EW_GREEN` | `001` | `100` | DON'T WALK |
| 16 | 1 | **1** | `EW_GREEN` | `001` | `100` | DON'T WALK |
| 19 | **0 (released)** | 1 | `EW_GREEN` | `001` | `100` | DON'T WALK |
| 22 | 0 | 1 | `EW_GREEN` | `001` | `100` | DON'T WALK |
| 28 | 0 | 1 | `EW_YELLOW` | `010` | `100` | DON'T WALK |
| 34 | 0 | 1 | `EW_YELLOW` | `010` | `100` | DON'T WALK |
| 40 | 0 | 1 | `ALL_RED_EW_NS` | `100` | `100` | DON'T WALK |
| 46 | 0 | **0** | `PED_WALK` | `100` | `100` | **WALK** |
| 52 | 0 | 0 | `PED_WALK` | `100` | `100` | **WALK** |
| 58 | 0 | 0 | `PED_WALK` | `100` | `100` | **WALK** |
| 64 | 0 | 0 | `PED_CLEAR` | `100` | `100` | DON'T WALK |
| 70 | 0 | 0 | `NS_GREEN` | `100` | `001` | DON'T WALK |
| 76 | 0 | 0 | `NS_GREEN` | `100` | `001` | DON'T WALK |

**Request policy:** The pending request is cleared when `PED_WALK` begins. A new request during WALK or clearance needs an explicit RTL policy (e.g., ignore it or queue it for a later safe boundary). A button press never immediately interrupts a vehicle GREEN phase.

## 6. General Expected Sequence

Without a pedestrian request:

```text
RESET (both RED)
    -> EW_GREEN -> EW_YELLOW -> ALL_RED_EW_NS
    -> NS_GREEN -> NS_YELLOW -> ALL_RED_NS_EW
    -> EW_GREEN -> ...
```

With a pedestrian request at a safe phase boundary:

```text
EW_GREEN -> EW_YELLOW -> ALL_RED_EW_NS
    -> PED_WALK -> PED_CLEAR -> NS_GREEN -> ...
```

A request during NS GREEN follows the analogous sequence ending with EW GREEN.

## 7. Example `$monitor` Console Output

**Illustrative output only — not an actual XSim log:**

```text
Time | Button | State           | EW(RYG) | NS(RYG) | WALK | Pending
-------------------------------------------------------------------
   4 |   0    | EW_GREEN        | 001     | 100     | 0    | 0
  10 |   0    | EW_GREEN        | 001     | 100     | 0    | 0
  16 |   1    | EW_GREEN        | 001     | 100     | 0    | 1
  22 |   0    | EW_GREEN        | 001     | 100     | 0    | 1
  28 |   0    | EW_YELLOW       | 010     | 100     | 0    | 1
  34 |   0    | EW_YELLOW       | 010     | 100     | 0    | 1
  40 |   0    | ALL_RED_EW_NS   | 100     | 100     | 0    | 1
  46 |   0    | PED_WALK        | 100     | 100     | 1    | 0
  52 |   0    | PED_WALK        | 100     | 100     | 1    | 0
  58 |   0    | PED_WALK        | 100     | 100     | 1    | 0
  64 |   0    | PED_CLEAR       | 100     | 100     | 0    | 0
  70 |   0    | NS_GREEN        | 100     | 001     | 0    | 0
```

### Suggested clock and button stimulus (Verilog testbench)

```verilog
`timescale 1ms/1us
reg clk = 1'b1;
reg rst = 1'b1;
reg ped_button = 1'b0;

// Falling at 1 ms, rising at 4 ms, then toggling every 3 ms.
initial begin
    #1 clk = ~clk;
    forever #3 clk = ~clk;
end

initial begin
    #3  rst = 1'b0;       // Release reset at 3 ms
    #10 ped_button = 1'b1; // Press at 13 ms
    #6  ped_button = 1'b0; // Release at 19 ms
end
```

This is **stimulus only**; the expected state schedule assumes a controller with the phase durations and request policy specified in Section 2. Ensure the DUT is reset safely at simulation start.

## 8. Verification Checklist

- [ ] Reset forces **both roads RED** and pedestrian DON'T WALK.
- [ ] EW RED/YELLOW/GREEN outputs follow their prescribed phases.
- [ ] NS RED/YELLOW/GREEN outputs follow their prescribed phases.
- [ ] EW GREEN and NS GREEN are **never** asserted together.
- [ ] A road turns GREEN only after the other road's YELLOW and an all-red interval.
- [ ] Pedestrian button presses are detected and retained until safely serviced; no press means no WALK.
- [ ] Pedestrian WALK is active only when **both roads RED**.
- [ ] WALK ends before vehicle traffic resumes; pedestrian clearance is enforced.
- [ ] With no request, traffic alternates EW → NS → EW.
- [ ] With a request during NS GREEN, the controller safely grants WALK and then resumes EW GREEN.
- [ ] XSim waveform and `$monitor` output agree with the RTL and timing assumptions.
- [ ] Nexys A7 LED outputs and request push button operate as expected.

**Suggested waveform signals:** `clk`, `rst`, `ped_button`, `request_pending`, `state`, `timer`, `ew_red`, `ew_yellow`, `ew_green`, `ns_red`, `ns_yellow`, `ns_green`, `ped_walk`, `ped_dont_walk`.

> **FPGA implementation:** Use the Nexys A7 100 MHz system clock with a clock-enable counter for practical timing. Synchronize and debounce the pedestrian push button. The 6 ms testbench clock above is for accelerated simulation only.
