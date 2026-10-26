# Introduction to FPGA Design with Vivado

This four-topic sequence introduces the Vivado design workflow, progressing from simulation and testbench development to implementing combinational circuits, sequential circuits, and finite state machines on an FPGA.

## Topic 5: Vivado-1 — Simulation & Testbench

Verify Verilog/SystemVerilog designs through simulation before deploying them to hardware.

- Vivado project creation and source-file management.
- Testbench structure, input stimulus, and expected outputs.
- Behavioral simulation and waveform analysis.
- Clock and reset generation for sequential testing.

**Practice:** Create a testbench for a multiplexer and counter, then verify their behavior using waveforms.

## Topic 6: Vivado-2 — Hello FPGA

Explore the complete workflow for implementing a simple design on an FPGA board.

- FPGA device and board selection.
- Top-level modules and XDC pin constraints.
- Synthesis, implementation, and bitstream generation.
- FPGA programming through Vivado Hardware Manager.

**Practice:** Use switches or push buttons to control onboard LEDs.

## Topic 7: Vivado-3 — FPGA Combinational Design

Implement and test combinational circuits using physical FPGA inputs and outputs.

- Multiplexers, decoders, comparators, and arithmetic circuits.
- Mapping switches, buttons, LEDs, and seven-segment displays.
- Simulation-based verification before implementation.
- Reviewing synthesis results and resource utilization.

**Practice:** Implement a small ALU using switches as inputs and LEDs to display its output.

## Topic 8: Vivado-4 — Sequential and FSM Design

Build clock-driven circuits and controllers that respond to events over time.

- Registers, counters, and clock-enable generation.
- Input synchronization and push-button debouncing.
- FSM implementation with state, next-state, and output logic.
- Clock constraints, timing reports, and hardware verification.

**Practice:** Implement a traffic-light controller using an FSM and a counter-generated timing enable.

