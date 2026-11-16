# Mini-Project II: One-Direction Intersection Traffic Controller with Pedestrian Crossing

## Checkpoint & Evaluation Criteria

## Session Details

- **Date:** **26 November 2026**
- **Time:** **10:00–11:00**
- **Total Marks:** **5%**
- **Platform:** Nexys A7 FPGA, Verilog HDL, Vivado XSim
- **Penalty Policy:**
  - **No deduction from 10:00 to 10:29** (30-minute grace period).
  - **From 10:30 onward, deduct 0.5 percentage points for each started 5-minute interval.**

---

## Checkpoint Objective

Demonstrate an FSM-based traffic controller for a single vehicle direction with a pedestrian crossing. The design must coordinate vehicle red/yellow/green lights and pedestrian WALK/DON'T WALK indications, accept a pedestrian request through a push button, and prevent conflicting vehicle and pedestrian movements.

## Required Demonstrations

1. **Traffic-light FSM:** Show the state transitions and timed sequence for vehicle green, yellow, and red.
2. **Pedestrian-crossing control:** Show how a button request is registered and served during a safe crossing interval. Vehicle traffic must remain red whenever pedestrian WALK is active. Explain how the design returns to the normal traffic cycle.
3. **Simulation and FPGA output:** Present Verilog source, an XSim waveform and/or monitor log showing the request and crossing sequence, and an FPGA demonstration using LEDs and a push button. Explain the timing counter or clock-enable logic.

---

## ⏰ No Penalty Period

| Time Submitted | Penalty | Maximum Mark |
|---|---:|---:|
| **10:00–10:29** | 0% | **5.00%** |

---

## 📉 Penalty After 10:30

| Time Slot | Minutes After 10:30 | Penalty (−0.5% per started 15 min) | Final Mark (from 5%) |
|---|---:|---:|---:|
| 10:30–10:35 | 0–14 min | −1.0% | **4.5%** |
| 10:35–10:39 | 0–14 min | −1.0% | **4.0%** |
| 10:40–10:45 | 0–14 min | −1.0% | **3.5%** |
| 10:45–10:49 | 0–14 min | −2.0% | **3.0%** |
| 10:50–10:55 | 0–14 min | −1.0% | **2.5%** |
| 10:55–10:59 | 0–14 min | −3.0% | **2.0%** |
| **11:00 onward** | Session ended | **Submission after session; instructor decision required** | **Not specified** |

*Note: This schedule follows the penalty rule stated in the uploaded document. Its original penalty table contained inconsistent time slots and deductions.*

---

## 🎯 Evaluation Rubric (5% Total)

| Criterion | Description | Marks |
|---|---|---:|
| Traffic-Light FSM Functionality | Correct vehicle red/yellow/green state transitions and timing | **1.0%** |
| Pedestrian Crossing Integration | Request-button handling, safe WALK phase, conflict prevention, and return to vehicle operation | **2.0%** |
| Output | XSim waveforms + monitor logs + Nexys A7 FPGA implementation | **2.0%** |
| **Total** | | **5.0%** |

---

## Submission Evidence

- Verilog source code and top-level module.
- FSM state diagram or transition table.
- Simulation waveform and/or console log demonstrating the vehicle sequence and a pedestrian request.
- Nexys A7 FPGA demonstration with vehicle and pedestrian LED indications.

**Safety check:** Pedestrian WALK and vehicle GREEN must never be asserted simultaneously.
