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
- `clk` toggles every **5 ms**: period **10 ms**.
- Active-high reset `rst` is asserted from **0 to 20 ms**; first post-reset rising edge is **25 ms**.
- One rising edge represents one **accelerated simulation tick**, not one real-world second.
- EW GREEN: **4 ticks**; EW YELLOW: **2 ticks**.
- NS GREEN: **4 ticks**; NS YELLOW: **2 ticks**.
- All-red transition/clearance: **1 tick** per transition.
- Pedestrian WALK: **3 ticks**; pedestrian clearance (DON'T WALK, both roads RED): **1 tick**.
- `ped_request` is sampled and latched until serviced. In this proposed policy, a pending request is served at the **next safe all-red boundary** after the active road finishes YELLOW. The normal road alternation resumes afterward.

For clarity, the tables below show **state outputs immediately after each rising edge**. A state occupies its listed ticks, and the next state appears on the following rising edge. The first post-reset state is EW GREEN at 25 ms.

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

## 4. Normal Alternating Pattern — No Pedestrian Request

| Time (ms) | FSM state | EW (R,Y,G) | NS (R,Y,G) | Pedestrian |
|---:|---|:---:|:---:|---|
| 0–20 | `RESET` | `100` | `100` | DON'T WALK |
| 25 | `EW_GREEN` | `001` | `100` | DON'T WALK |
| 35 | `EW_GREEN` | `001` | `100` | DON'T WALK |
| 45 | `EW_GREEN` | `001` | `100` | DON'T WALK |
| 55 | `EW_GREEN` | `001` | `100` | DON'T WALK |
| 65 | `EW_YELLOW` | `010` | `100` | DON'T WALK |
| 75 | `EW_YELLOW` | `010` | `100` | DON'T WALK |
| 85 | `ALL_RED_EW_NS` | `100` | `100` | DON'T WALK |
| 95 | `NS_GREEN` | `100` | `001` | DON'T WALK |
| 105 | `NS_GREEN` | `100` | `001` | DON'T WALK |
| 115 | `NS_GREEN` | `100` | `001` | DON'T WALK |
| 125 | `NS_GREEN` | `100` | `001` | DON'T WALK |
| 135 | `NS_YELLOW` | `100` | `010` | DON'T WALK |
| 145 | `NS_YELLOW` | `100` | `010` | DON'T WALK |
| 155 | `ALL_RED_NS_EW` | `100` | `100` | DON'T WALK |
| 165 | `EW_GREEN` | `001` | `100` | DON'T WALK |

This is an illustrative state schedule. Actual transition edges depend on the implemented counter convention.

## 5. Pedestrian Request Pattern

Example: a pedestrian presses the button at **40 ms** during EW GREEN. The request is latched at the next rising edge. EW completes GREEN and YELLOW; both roads turn RED before WALK. After pedestrian clearance, NS receives the next GREEN phase.

| Time (ms) | Request pending | FSM state | EW (R,Y,G) | NS (R,Y,G) | Pedestrian |
|---:|:---:|---|:---:|:---:|---|
| 25 | 0 | `EW_GREEN` | `001` | `100` | DON'T WALK |
| 45 | 1 | `EW_GREEN` | `001` | `100` | DON'T WALK |
| 55 | 1 | `EW_GREEN` | `001` | `100` | DON'T WALK |
| 65 | 1 | `EW_YELLOW` | `010` | `100` | DON'T WALK |
| 75 | 1 | `EW_YELLOW` | `010` | `100` | DON'T WALK |
| 85 | 1 | `ALL_RED_EW_NS` | `100` | `100` | DON'T WALK |
| 95 | 0 | `PED_WALK` | `100` | `100` | WALK |
| 105 | 0 | `PED_WALK` | `100` | `100` | WALK |
| 115 | 0 | `PED_WALK` | `100` | `100` | WALK |
| 125 | 0 | `PED_CLEAR` | `100` | `100` | DON'T WALK |
| 135 | 0 | `NS_GREEN` | `100` | `001` | DON'T WALK |
| 145 | 0 | `NS_GREEN` | `100` | `001` | DON'T WALK |

**Policy clarification:** A request is cleared when `PED_WALK` starts. The next vehicle phase is the road that would normally have followed the interrupted all-red boundary. Requests during WALK or clearance require a defined policy (for example, ignore until the next vehicle phase or queue for the next safe boundary); students should document their choice.

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
Time | State           | EW(RYG) | NS(RYG) | WALK | Pending
---------------------------------------------------------
  25 | EW_GREEN        | 001     | 100     | 0    | 0
  45 | EW_GREEN        | 001     | 100     | 0    | 1
  65 | EW_YELLOW       | 010     | 100     | 0    | 1
  85 | ALL_RED_EW_NS   | 100     | 100     | 0    | 1
  95 | PED_WALK        | 100     | 100     | 1    | 0
 105 | PED_WALK        | 100     | 100     | 1    | 0
 115 | PED_WALK        | 100     | 100     | 1    | 0
 125 | PED_CLEAR       | 100     | 100     | 0    | 0
 135 | NS_GREEN        | 100     | 001     | 0    | 0
```

## 8. Verification Checklist

- [ ] Reset forces **both roads RED** and pedestrian DON'T WALK.
- [ ] EW RED/YELLOW/GREEN outputs follow their prescribed phases.
- [ ] NS RED/YELLOW/GREEN outputs follow their prescribed phases.
- [ ] EW GREEN and NS GREEN are **never** asserted together.
- [ ] A road turns GREEN only after the other road's YELLOW and an all-red interval.
- [ ] Pedestrian button requests are detected and retained until safely serviced.
- [ ] Pedestrian WALK is active only when **both roads RED**.
- [ ] WALK ends before vehicle traffic resumes; pedestrian clearance is enforced.
- [ ] With no request, traffic alternates EW → NS → EW.
- [ ] With a request during NS GREEN, the controller safely grants WALK and then resumes EW GREEN.
- [ ] XSim waveform and `$monitor` output agree with the RTL and timing assumptions.
- [ ] Nexys A7 LED outputs and request push button operate as expected.

**Suggested waveform signals:** `clk`, `rst`, `ped_request`, `request_pending`, `state`, `timer`, `ew_red`, `ew_yellow`, `ew_green`, `ns_red`, `ns_yellow`, `ns_green`, `ped_walk`, `ped_dont_walk`.

> **FPGA implementation:** Use the Nexys A7 100 MHz system clock with a clock-enable counter for practical timing. Synchronize and debounce the pedestrian push button. The 10 ms testbench clock above is for accelerated simulation only.
