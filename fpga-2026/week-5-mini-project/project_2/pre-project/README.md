# Pre-Project: System-Level Design of a Traffic Light Controller with Pedestrian Crossing

**Platform:** Nexys A7 FPGA  
**Language:** Verilog HDL  
**Tool:** AMD Vivado  
**Assessment:** Physical FPGA operation; no simulation required

## 1. Overview
Design and implement a traffic controller for **one vehicle road** and a pedestrian crossing. Vehicle LEDs indicate RED, YELLOW, and GREEN; pedestrian LEDs indicate WALK and DON'T WALK. A push button registers a crossing request. The controller must transition safely from vehicle GREEN through YELLOW and ALL RED before allowing WALK. This pre-project prepares students for a two-road intersection controller.

## 2. Learning Outcomes
- Decompose a system into reusable functional modules.
- Design an FSM with state transitions and timing.
- Derive a one-second clock-enable pulse from the Nexys A7 100 MHz clock.
- Synchronize, debounce, and latch a push-button request.
- Integrate modules using hierarchical Verilog and demonstrate behavior on hardware.

## 3. System-Level Architecture

```text
Nexys A7 100 MHz clock ----> 1 Hz Clock-Enable Generator --+
                                                           |
Pedestrian Push Button ---> Synchronizer / Debounce ------+--> Traffic FSM + Phase Timer
                                 / Request Latch            |           |
Reset -----------------------------------------------------+           +--> Vehicle R/Y/G LEDs
                                                                       +--> Pedestrian WALK/STOP LEDs
```

**Design principle:** Use the 100 MHz clock for all sequential logic; distribute a 1 Hz **clock enable**, not a logic-generated secondary clock. Reset initializes the system to a safe state.

## 4. System Inputs and Outputs

| Signal | Direction | Description |
|---|---|---|
| `clk` | Input | Nexys A7 100 MHz clock |
| `rst` | Input | Active-high reset |
| `ped_button` | Input | Pedestrian crossing request |
| `red`, `yellow`, `green` | Output | Vehicle traffic LEDs |
| `ped_walk`, `ped_stop` | Output | Pedestrian signal LEDs |

## 5. Functional Requirements
1. Start in a safe reset state with vehicle RED and pedestrian DON'T WALK; then begin normal vehicle operation.
2. In normal operation, vehicle GREEN is active and pedestrian DON'T WALK is active.
3. A button press registers one pending pedestrian request; it must not immediately turn on WALK.
4. After the minimum vehicle GREEN interval, a pending request triggers YELLOW, then ALL RED, then WALK.
5. Both vehicle GREEN and pedestrian WALK must **never** be active simultaneously.
6. After WALK, display pedestrian DON'T WALK while vehicle RED remains active during clearance; then return to GREEN.
7. A held button must not repeatedly retrigger requests; require a release and a new press for a new request.

## 6. Proposed FSM and Timing

| State | Vehicle signal | Pedestrian signal | Proposed duration | Next state |
|---|---|---|---|---|
| `S_RESET` | RED | DON'T WALK | While reset asserted | `S_GREEN` after reset |
| `S_GREEN` | GREEN | DON'T WALK | Minimum 4 s, then wait for request | `S_YELLOW` on pending request after minimum time |
| `S_YELLOW` | YELLOW | DON'T WALK | 2 s | `S_ALL_RED` |
| `S_ALL_RED` | RED | DON'T WALK | 1 s | `S_WALK` |
| `S_WALK` | RED | WALK | 3 s | `S_PED_CLEAR` |
| `S_PED_CLEAR` | RED | DON'T WALK | 1 s | `S_GREEN` |

The durations are **illustrative lab parameters** and may be changed by the instructor. For this pre-project, accept requests in `S_GREEN`; students may optionally extend the design to queue requests in other states.

### State transition concept

```text
 RESET (RED) --release--> GREEN --button request + minimum time--> YELLOW
                        ^                                        |
                        |                                        v
                   PED_CLEAR <-- WALK <-- ALL_RED <--------------+
```

## 7. Hierarchical Module Plan

| Module | Responsibility |
|---|---|
| `clock_enable_1hz` | Emit a single-cycle enable pulse every 100,000,000 clock cycles |
| `button_interface` | Synchronize, debounce, detect rising edge, and latch request |
| `traffic_fsm` | Maintain FSM state, phase timer, and request servicing |
| `traffic_output` | Decode FSM state to vehicle/pedestrian LED outputs |
| `traffic_top` | Instantiate modules and connect board inputs/outputs |

Suggested top-level interface:

```verilog
module traffic_top (
    input  wire clk,
    input  wire rst,
    input  wire ped_button,
    output wire red,
    output wire yellow,
    output wire green,
    output wire ped_walk,
    output wire ped_stop
);
    // Instantiate clock-enable, button interface,
    // traffic FSM, and LED output decoder here.
endmodule
```

## 8. FPGA Implementation Procedure

1. **System specification:** Draw a block diagram and write the state/output table.
2. **Module design:** Implement clock-enable generation, button conditioning, FSM, and output decoding.
3. **Integration:** Connect modules in `traffic_top`; check signal names and reset polarity.
4. **Vivado project:** Create a project for the actual Nexys A7 variant and add all Verilog source files.
5. **Pin constraints:** Use the official Nexys A7 master XDC to assign the 100 MHz clock, reset, request button, and LEDs; verify pins against the board variant.
6. **Build:** Run synthesis, implementation, and bitstream generation; resolve errors and critical warnings.
7. **Hardware test:** Program the FPGA and observe the LEDs through a full crossing request cycle.

## 9. Expected FPGA Results

| Test | Action | Expected LED behavior |
|---|---|---|
| Reset | Hold `rst` active | Vehicle RED, pedestrian DON'T WALK |
| Normal operation | Release reset, do not press button | Vehicle GREEN after reset; pedestrian DON'T WALK |
| Request | Press and release pedestrian button | Request stored; no immediate WALK |
| Vehicle transition | Wait for minimum green interval | GREEN → YELLOW (2 s) → RED (1 s clearance) |
| Pedestrian crossing | Observe next phase | Vehicle RED; pedestrian WALK for 3 s |
| Crossing completion | Wait for WALK to finish | Vehicle RED and DON'T WALK for 1 s, then GREEN |
| Safety | Observe all phases | Never GREEN and WALK simultaneously |
| Button held | Hold request button | No repeated crossing until released and pressed again |

**Timing note:** The 100 MHz board clock is not physically replaced by a 1 Hz clock. The one-second timing is generated by a clock-enable counter. Time observations may differ slightly depending on when the button is pressed relative to the 1 Hz tick.

## 10. Required Deliverables
- System-level architecture diagram and module hierarchy.
- FSM state diagram and state/output table.
- Verilog source code and top-level module.
- Vivado project with verified XDC constraints and generated bitstream.
- Live Nexys A7 demonstration showing normal traffic, request handling, WALK, clearance, and return to GREEN.
- Brief explanation of timing logic and safety interlock.

## 11. Suggested Evaluation Rubric

| Criterion | Weight |
|---|---:|
| System architecture and hierarchical modules | 25% |
| FSM states and timed vehicle sequence | 25% |
| Pedestrian request and safe WALK sequence | 30% |
| FPGA hardware demonstration and explanation | 20% |
| **Total** | **100%** |

## 12. Extension to Mini-Project II
Extend the pre-project to two intersecting roads, **East–West** and **North–South**, each with independent RED/YELLOW/GREEN signals, while preserving pedestrian request handling, all-red clearance, and mutual exclusion of conflicting GREEN/WALK outputs.
