# Expected Result Pattern — Two-Road Intersection Traffic Controller with Pedestrian Crossing

## 1. Purpose

This document describes **expected physical FPGA behavior**, not a simulation or testbench. The intersection has separate RED, YELLOW, and GREEN lamps for the East–West (EW) and North–South (NS) roads, plus a pedestrian push button and WALK / DON'T WALK indicators.

> **Timing interpretation:** The requested “first post-reset rising edge at 2 ms” is incompatible with a **1 s clock period**. This guide interprets it as **2 s**. The timing below is a proposed hardware demonstration schedule, not measured output from supplied RTL.

## 2. FPGA Operating Clock and Reset

- **Logical operating clock:** `clk` changes level every **0.5 s**, giving a full period of **1 s**.
- **Active-high reset:** `rst = 1` from **0 to 1 s**; the controller remains in its safe reset state during this interval.
- **First active rising edge after reset:** **t = 2 s**, assuming rising edges at 0, 1, 2, 3, ... s and reset is released immediately *after* the 1 s edge. The next rising edges occur at **3, 4, 5, ... s**.
- **Nexys A7 implementation:** Use the board's **100 MHz oscillator** and a **1 Hz clock-enable pulse** for state updates. Do not route a logic-generated 1 Hz signal as an ordinary FPGA clock. A visible 1 Hz clock indicator may toggle every 0.5 s, while the FSM remains on the 100 MHz clock.
- Synchronize and debounce the physical reset and pedestrian buttons as appropriate. Define reset priority and startup behavior in RTL.

## 3. Expected FSM States and Outputs

`1` = lamp ON, `0` = lamp OFF; road output order `(R,Y,G)`.

| FSM State | EW (R,Y,G) | NS (R,Y,G) | Pedestrian | Purpose |
|---|:---:|:---:|---|---|
| `RESET` | `100` | `100` | DON'T WALK | Safe startup |
| `EW_GREEN` | `001` | `100` | DON'T WALK | EW traffic proceeds |
| `EW_YELLOW` | `010` | `100` | DON'T WALK | EW traffic prepares to stop |
| `ALL_RED_EW_NS` | `100` | `100` | DON'T WALK | Intergreen clearance |
| `NS_GREEN` | `100` | `001` | DON'T WALK | NS traffic proceeds |
| `NS_YELLOW` | `100` | `010` | DON'T WALK | NS traffic prepares to stop |
| `ALL_RED_NS_EW` | `100` | `100` | DON'T WALK | Intergreen clearance |
| `PED_WALK` | `100` | `100` | WALK | Exclusive pedestrian crossing |
| `PED_CLEAR` | `100` | `100` | DON'T WALK | Pedestrian clearance before vehicles resume |

## 4. Proposed Timing for Hardware Demonstration

For an easily observed demonstration, use the following **illustrative** state durations, expressed in **1 s FSM update ticks**:

| Phase | Duration |
|---|---:|
| EW GREEN | 4 s |
| EW YELLOW | 2 s |
| NS GREEN | 4 s |
| NS YELLOW | 2 s |
| ALL RED before next phase | 1 s |
| Pedestrian WALK | 3 s |
| Pedestrian clearance | 1 s |

The FSM should alternate between EW and NS traffic. Pedestrian WALK occurs **only following a button request** and only after the active vehicle road has completed its GREEN/YELLOW phase and both roads have entered ALL RED.

## 5. Expected Hardware Output — No Pedestrian Request

The table shows the state **immediately after each 1 s update**, beginning at the first post-reset update at **2 s**.

| Time (s) | State | EW (R,Y,G) | NS (R,Y,G) | Pedestrian |
|---:|---|:---:|:---:|---|
| 0–1 | `RESET` | `100` | `100` | DON'T WALK |
| 2–5 | `EW_GREEN` | `001` | `100` | DON'T WALK |
| 6–7 | `EW_YELLOW` | `010` | `100` | DON'T WALK |
| 8 | `ALL_RED_EW_NS` | `100` | `100` | DON'T WALK |
| 9–12 | `NS_GREEN` | `100` | `001` | DON'T WALK |
| 13–14 | `NS_YELLOW` | `100` | `010` | DON'T WALK |
| 15 | `ALL_RED_NS_EW` | `100` | `100` | DON'T WALK |
| 16–19 | `EW_GREEN` | `001` | `100` | DON'T WALK |

**Without a pedestrian request, WALK must remain OFF.**

## 6. Expected Hardware Output — Pedestrian Button Press

Example: the pedestrian **presses the button during EW GREEN** (e.g., at **t = 3.5 s**) and releases it at **t = 4.5 s**. The synchronized/debounced request is assumed to be recognized by the controller in time for the next safe crossing opportunity.

| Time (s) | Physical event / FSM state | EW (R,Y,G) | NS (R,Y,G) | Pedestrian |
|---:|---|:---:|:---:|---|
| 2–5 | `EW_GREEN`; request pressed during phase | `001` | `100` | DON'T WALK |
| 6–7 | `EW_YELLOW` | `010` | `100` | DON'T WALK |
| 8 | `ALL_RED_EW_NS` | `100` | `100` | DON'T WALK |
| 9–11 | `PED_WALK`; pending request serviced | `100` | `100` | **WALK** |
| 12 | `PED_CLEAR` | `100` | `100` | DON'T WALK |
| 13–16 | `NS_GREEN` | `100` | `001` | DON'T WALK |
| 17–18 | `NS_YELLOW` | `100` | `010` | DON'T WALK |

The pedestrian button **does not immediately force WALK** or interrupt a GREEN phase. A latched pending request is served at a safe all-red boundary. Once serviced, the pending flag is cleared. Exact response times depend on the implemented debounce and FSM logic.

## 7. Required Safety Conditions

1. EW GREEN and NS GREEN must never be ON simultaneously.
2. Pedestrian WALK is ON only when **both roads are RED**.
3. The active vehicle road passes through YELLOW before both roads become RED.
4. A pedestrian request is stored until the next permitted crossing phase.
5. Following WALK, the pedestrian clearance phase completes before a vehicle GREEN resumes.
6. Reset places both roads in RED and pedestrian signals in DON'T WALK.

## 8. Physical FPGA Verification Checklist

- [ ] 100 MHz Nexys A7 board clock is used with a 1 Hz update enable.
- [ ] Reset initializes both road signals to RED.
- [ ] EW and NS signal lamps alternate through GREEN → YELLOW → ALL RED.
- [ ] The pedestrian button is physically connected, synchronized, and debounced.
- [ ] Pressing the button during GREEN does not immediately activate WALK.
- [ ] WALK activates after both roads reach RED.
- [ ] WALK does not activate if no request is made.
- [ ] Pedestrian clearance completes before vehicle GREEN resumes.
- [ ] Actual observed state timings are recorded and compared with the proposed schedule.

**Hardware note:** The 1 s timing is for a classroom-scale demonstration and is not intended as real-world road traffic timing or a safety-certified traffic-control design.
