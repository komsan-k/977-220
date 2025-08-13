# Sequential Logic Design in Verilog

## Introduction to Sequential Logic
Unlike combinational logic, which depends only on current input values, sequential logic systems incorporate memory elements and depend on both current inputs and past states. These systems are fundamental to building counters, registers, state machines, and memory elements in digital systems.

Sequential circuits operate under the influence of a clock signal that coordinates data transfer and synchronization across different components. They are essential in designing processors, communication interfaces, digital controllers, and more.

## Memory Elements: Latches and Flip-Flops

### Latches
Latches are level-sensitive storage elements. The most common types include:
- **SR Latch:** Set-Reset latch using NOR or NAND gates.
- **D Latch:** Transparent latch storing the input when enable is high.

### Flip-Flops
Flip-flops are edge-triggered memory elements. The D-type flip-flop (data flip-flop) is the most commonly used:
```verilog
always @(posedge clk)
  q <= d;
```

Other types include:
- **T Flip-Flop:** Toggles the output on each clock edge.
- **JK Flip-Flop:** A universal flip-flop with control logic.

## Registers and Register Banks

### Multi-Bit Registers
Registers store multi-bit binary data. Example 8-bit register:
```verilog
reg [7:0] data;
```

### Register Bank Implementation
Arrays of registers can store multiple values:
```verilog
reg [7:0] reg_file [0:15];
```

## Counters

### Up Counter
```verilog
always @(posedge clk)
  count <= count + 1;
```

### Down Counter
Decrements on each clock pulse.

### Up-Down Counter
Direction determined by a control signal.

### Mod-N Counter
Wraps after reaching N-1. Useful in clock division.

## Shift Registers

### Types of Shift Registers
- Serial-In Serial-Out (SISO)
- Serial-In Parallel-Out (SIPO)
- Parallel-In Serial-Out (PISO)
- Bidirectional Shift Registers

### Design Example: 8-Bit Shift Register
```verilog
always @(posedge clk)
  out <= {out[6:0], in};
```

## Edge Detection and Pulse Generation
Detecting rising or falling edges of asynchronous signals is crucial for event-driven logic:
```verilog
always @(posedge clk)
  signal_edge <= signal & ~prev_signal;
```

## Clocking and Reset Strategies

### Synchronous vs. Asynchronous Reset
- **Synchronous reset** is applied on the clock edge.
- **Asynchronous reset** is applied immediately, independent of the clock.

### Clock Domain Crossing
Multiple clock domains require synchronization to avoid metastability.

### Clock Gating
Used to disable parts of the circuit to save power.

## Design Examples
- 4-Bit Synchronous Counter
- Binary-Coded Decimal (BCD) Counter
- Simple Stopwatch Design
- Traffic Light Controller
- UART Bit Transmitter

## Modeling Sequential Circuits

### Sequential Always Blocks
Use non-blocking assignments to avoid race conditions.

### State Retention
Flip-flops and latches retain state across clock cycles.

### Initialization
In simulation, use `initial` blocks. In hardware, apply reset.

## Simulation of Sequential Logic
```verilog
module tb_counter;
  reg clk = 0, rst = 0;
  wire [3:0] count;

  counter uut(.clk(clk), .rst(rst), .count(count));

  always #5 clk = ~clk;

  initial begin
    rst = 1; #10;
    rst = 0; #100;
    $finish;
  end
endmodule
```

## Synthesis Considerations
- Avoid unintended latches.
- Ensure complete state coverage.
- Use proper clocking techniques to minimize skew.

## Common Pitfalls
- Incorrect edge sensitivity.
- Mixing blocking and non-blocking assignments.
- Glitches due to incomplete logic.

## Summary
Sequential logic circuits form the backbone of memory and control in digital systems. Mastering flip-flops, counters, shift registers, and clock strategies is essential for building complex digital designs.

## Exercises
1. Write a Verilog module for a 3-bit synchronous up counter with asynchronous reset.
2. Implement an 8-bit parallel-load shift register.
3. Design a pulse generator that produces a one-cycle pulse when a signal rises.
4. Create a traffic light controller for a two-way intersection.
5. Develop a testbench for a 4-bit binary counter.

