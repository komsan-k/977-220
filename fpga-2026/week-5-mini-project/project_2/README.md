# Expected Result Pattern for One-Direction Intersection Traffic Controller with Pedestrian Crossing

This document provides an **illustrative expected output pattern** for a Verilog FSM simulation. It adapts the timing-summary, early-pattern, transition, and console-output structure of the supplied stopwatch reference. **The uploaded file contains stopwatch timing only; no traffic-controller RTL, state durations, or testbench were supplied.** Therefore, the state durations and pedestrian-request timing below are proposed test assumptions, not verified results from an existing design.

---

## ⏱ Testbench Timing Summary (Proposed)

- `timescale 1ms/1us`
- Clock toggles every **5 ms** → full clock period = **10 ms**.
- Active-high reset (`rst`) stays high for the first **20 ms**.
- First rising edge after reset: **t = 25 ms**.
- One clock cycle is treated as one timing tick for this **accelerated simulation** (not a real-time traffic-light interval).
- Example state durations: vehicle GREEN = **4 ticks**, YELLOW = **2 ticks**, all-red clearance = **1 tick**, pedestrian WALK = **3 ticks**, pedestrian clearance = **1 tick**.
- Pedestrian button (`ped_request`) is sampled synchronously and latched until serviced. Requests are **not** allowed to interrupt vehicle GREEN immediately.

> Actual transitions must be adjusted to match the student's RTL and testbench. An FPGA implementation should use a clock-enable generator to achieve practical real-time intervals.

---

## 🚦 1. States and Expected Outputs

| State | Vehicle RED | Vehicle YELLOW | Vehicle GREEN | Pedestrian WALK | Pedestrian DON'T WALK |
|---|:---:|:---:|:---:|:---:|:---:|
| `VEH_GREEN` | 0 | 0 | 1 | 0 | 1 |
| `VEH_YELLOW` | 0 | 1 | 0 | 0 | 1 |
| `ALL_RED` | 1 | 0 | 0 | 0 | 1 |
| `PED_WALK` | 1 | 0 | 0 | 1 | 0 |
| `PED_CLEAR` | 1 | 0 | 0 | 0 | 1 |

**Safety invariant:** `!(vehicle_green && pedestrian_walk)` must hold at all times. Vehicle traffic remains red throughout the pedestrian WALK and clearance phases.

---

## ✅ 2. Early FSM Pattern (No Pedestrian Request)

After reset, the controller begins in `VEH_GREEN`. The example assumes a timer that counts four active clock edges in the GREEN state, including the first edge at 25 ms.

| Time (ms) | Example state | Vehicle light | Pedestrian signal |
|---:|---|---|---|
| 0–20 | Reset | RED (safe reset output) | DON'T WALK |
| 25 | `VEH_GREEN` | GREEN | DON'T WALK |
| 35 | `VEH_GREEN` | GREEN | DON'T WALK |
| 45 | `VEH_GREEN` | GREEN | DON'T WALK |
| 55 | `VEH_GREEN` | GREEN | DON'T WALK |
| 65 | `VEH_YELLOW` | YELLOW | DON'T WALK |
| 75 | `VEH_YELLOW` | YELLOW | DON'T WALK |
| 85 | `ALL_RED` | RED | DON'T WALK |
| 95 | `VEH_GREEN` | GREEN | DON'T WALK |

**Note:** The exact edge at which a state changes depends on the FSM timer implementation; this table is a reference schedule for the proposed tick convention.

---

## 🚶 3. Pedestrian Request and Crossing Pattern

For this illustrative test, a pedestrian presses the button while vehicles are GREEN, at **t = 40 ms**. The request is latched, and the controller finishes the current GREEN interval, passes through YELLOW and ALL_RED, and then grants pedestrian WALK.

| Time (ms) | Request pending | State | Vehicle light | Pedestrian signal |
|---:|:---:|---|---|---|
| 25 | 0 | `VEH_GREEN` | GREEN | DON'T WALK |
| 45 | 1 | `VEH_GREEN` | GREEN | DON'T WALK |
| 55 | 1 | `VEH_GREEN` | GREEN | DON'T WALK |
| 65 | 1 | `VEH_YELLOW` | YELLOW | DON'T WALK |
| 75 | 1 | `VEH_YELLOW` | YELLOW | DON'T WALK |
| 85 | 1 | `ALL_RED` | RED | DON'T WALK |
| 95 | 0 | `PED_WALK` | RED | WALK |
| 105 | 0 | `PED_WALK` | RED | WALK |
| 115 | 0 | `PED_WALK` | RED | WALK |
| 125 | 0 | `PED_CLEAR` | RED | DON'T WALK |
| 135 | 0 | `VEH_GREEN` | GREEN | DON'T WALK |

This schedule assumes that the pending request is cleared when the `PED_WALK` phase begins. A design may use a different clear point if it is documented and verified.

---

## 🔄 4. General Expected Behavior

1. **Reset:** Establish a safe vehicle RED and pedestrian DON'T WALK condition.
2. **Normal operation:** Sequence vehicle GREEN → YELLOW → ALL_RED → GREEN if no pedestrian request is pending.
3. **Button request:** Latch a pedestrian request and wait until vehicle GREEN and YELLOW phases have completed.
4. **Crossing:** Set vehicle RED and pedestrian WALK for the specified crossing interval.
5. **Clearance:** Turn pedestrian WALK off while keeping vehicle RED for a clearance interval.
6. **Resume:** Return to vehicle GREEN only after the crossing and clearance phases finish.

---

## 🧪 5. Example Console Output

The following is **illustrative**, not an actual simulation log:

```text
Time | State       | Veh(R,Y,G) | Ped(WALK) | Pending
---------------------------------------------------
  25 | VEH_GREEN   | 0 0 1      | 0         | 0
  45 | VEH_GREEN   | 0 0 1      | 0         | 1
  65 | VEH_YELLOW  | 0 1 0      | 0         | 1
  85 | ALL_RED     | 1 0 0      | 0         | 1
  95 | PED_WALK    | 1 0 0      | 1         | 0
 105 | PED_WALK    | 1 0 0      | 1         | 0
 115 | PED_WALK    | 1 0 0      | 1         | 0
 125 | PED_CLEAR   | 1 0 0      | 0         | 0
 135 | VEH_GREEN   | 0 0 1      | 0         | 0
```

---

## ⚠️ 6. Verification Checklist

- [ ] Reset establishes safe traffic and pedestrian outputs.
- [ ] Vehicle lights follow the required state sequence and durations.
- [ ] A pedestrian request is latched and not lost while GREEN is active.
- [ ] Vehicle GREEN and pedestrian WALK are never active together.
- [ ] Pedestrian WALK begins only after vehicle YELLOW and ALL_RED.
- [ ] Vehicle RED remains active during WALK and pedestrian clearance.
- [ ] A request-free cycle returns to normal vehicle operation.
- [ ] Vivado XSim waveforms and `$monitor` output agree with the implemented RTL.
- [ ] Hardware LEDs and pedestrian request push button behave consistently with simulation.

**Suggested waveform signals:** `clk`, `rst`, `ped_request`, `request_pending`, `state`, `timer`, `veh_red`, `veh_yellow`, `veh_green`, `ped_walk`.

*The sample values are instructional assumptions and must be replaced by measured XSim results when students submit their checkpoint evidence.*
