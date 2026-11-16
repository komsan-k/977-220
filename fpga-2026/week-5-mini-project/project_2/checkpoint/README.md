# Mini-Project II: Two-Road Intersection Traffic Controller with Pedestrian Crossing

## Checkpoint & Evaluation Criteria — FPGA Hardware Demonstration Only

## Session Details

- **Date:** **26 November 2026**
- **Time:** **10:00–11:00**
- **Total Marks:** **5%**
- **Platform:** Nexys A7 FPGA, Verilog HDL, Vivado (synthesis, implementation, bitstream generation, and FPGA programming)
- **Assessment method:** Live hardware demonstration; **no simulation, XSim waveforms, testbenches, or `$monitor` logs required**.
- **Penalty policy:**
  - No deduction for demonstrations completed during **10:00–10:29**.
  - From **10:30**, deduct **0.5 percentage points for each started 5-minute interval**.

---

## Checkpoint Objective

Demonstrate an FSM-based traffic controller for a two-road intersection comprising **East–West (EW)** and **North–South (NS)** roads. Each road has independent RED, YELLOW, and GREEN traffic signals. A pedestrian request push button must initiate a safe pedestrian WALK phase, with both roads displaying RED throughout the crossing. After the crossing and clearance interval, normal alternating vehicle operation resumes.

## Required FPGA Demonstrations

1. **Two-road traffic-light FSM:** Demonstrate EW GREEN → EW YELLOW → ALL RED → NS GREEN → NS YELLOW → ALL RED → EW GREEN, with the configured timing intervals. EW and NS GREEN must never be ON simultaneously.
2. **Pedestrian push-button operation:** Press the pedestrian request button during a vehicle phase. Demonstrate that the request is registered, the active vehicle phase completes safely, both roads turn RED, and the pedestrian WALK signal turns ON for the specified interval. Show the subsequent pedestrian clearance interval and return to normal traffic operation. Without a button request, the WALK phase must be skipped.
3. **Physical FPGA operation:** Program the Nexys A7 and demonstrate working traffic LEDs, pedestrian WALK/DON'T WALK indications, reset behavior, and timed state changes. Explain the FSM, timing counter, and clock-enable implementation. Use the board's 100 MHz oscillator and a **1 Hz clock enable** for one-second state updates, rather than a fabric-generated clock.

### Expected Hardware Operating Pattern

| Phase | EW road | NS road | Pedestrian | Example duration |
|---|---|---|---|---:|
| EW_GREEN | GREEN | RED | DON'T WALK | 4 s |
| EW_YELLOW | YELLOW | RED | DON'T WALK | 2 s |
| ALL_RED | RED | RED | DON'T WALK | 1 s |
| PED_WALK *(only if requested)* | RED | RED | WALK | 3 s |
| PED_CLEAR *(after WALK)* | RED | RED | DON'T WALK | 1 s |
| NS_GREEN | RED | GREEN | DON'T WALK | 4 s |
| NS_YELLOW | RED | YELLOW | DON'T WALK | 2 s |
| ALL_RED | RED | RED | DON'T WALK | 1 s |

*Durations are illustrative and should match the approved project implementation. The pedestrian phase may be inserted at a safe all-red transition after a pending request; it must not interrupt an active green light abruptly.*

---

## No-Penalty Period

| Demonstration time | Deduction | Maximum mark |
|---|---:|---:|
| **10:00–10:29** | 0.0% | **5.0%** |

## Late-Penalty Schedule

| Demonstration time | Deduction from earned mark | Maximum mark |
|---|---:|---:|
| **10:30–10:34** | −0.5% | **4.5%** |
| **10:35–10:39** | −1.0% | **4.0%** |
| **10:40–10:44** | −1.5% | **3.5%** |
| **10:45–10:49** | −2.0% | **3.0%** |
| **10:50–10:54** | −2.5% | **2.5%** |
| **10:55–10:59** | −3.0% | **2.0%** |
| **11:00 onward** | Session ended; instructor decision | Not specified |

*The deduction is applied to the earned score, with a minimum score of zero. The table shows the maximum possible mark for each interval.*

---

## Evaluation Rubric (5% Total)

| Criterion | Description | Marks |
|---|---|---:|
| **Two-Road Traffic FSM Functionality** | Correct EW/NS RED–YELLOW–GREEN sequencing, timing, and safe all-red transitions | **1.0%** |
| **Pedestrian Crossing Integration** | Button request capture, WALK only when both roads are RED, clearance phase, and return to normal operation | **2.0%** |
| **FPGA Hardware Demonstration** | Successful bitstream/programming, physical LED outputs, reset operation, and explanation of timing/FSM implementation | **2.0%** |
| **Total** | | **5.0%** |

---

## Required Evidence

- Verilog source code and top-level module, including FSM and timing logic.
- FSM state diagram or transition table.
- Successful **live demonstration on the Nexys A7** showing EW/NS traffic signals, pedestrian button, WALK/DON'T WALK indications, and reset.
- Brief explanation of the FPGA input/output pin mapping and timing implementation.

**Safety checks:** EW GREEN and NS GREEN must never be ON together. Pedestrian WALK must never coincide with either vehicle GREEN or YELLOW. The WALK phase must occur only in response to a pedestrian request.
