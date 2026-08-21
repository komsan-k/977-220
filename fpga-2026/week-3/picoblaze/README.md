# 🔬 Lab: Vivado IP Core — PicoBlaze

## 🧩 1. Objective

* Understand the architecture and operation of the **PicoBlaze soft-core processor**.
* Learn the difference between **PicoBlaze and MicroBlaze**.
* Integrate a lightweight processor into an FPGA design using Vivado.
* Understand PicoBlaze program memory, registers, ports, and instruction execution.
* Implement a simple PicoBlaze-based embedded controller.
* Use FPGA switches as processor inputs and LEDs as processor outputs.
* Write a simple PicoBlaze assembly program.
* Simulate, synthesize, and deploy the design on a **Basys 3 / Nexys A7 FPGA**.
* Introduce processor-based control using minimal FPGA resources.

---

## ⚙️ 2. Equipment and Tools

| Tool / Resource                     | Description                                    |
| ----------------------------------- | ---------------------------------------------- |
| **Vivado Design Suite**             | FPGA synthesis, simulation, and implementation |
| **FPGA Board (Basys 3 / Nexys A7)** | Hardware implementation                        |
| **PicoBlaze Processor Core**        | Lightweight 8-bit soft-core processor          |
| **KCPSM6 / PicoBlaze Source**       | PicoBlaze processor implementation             |
| **Assembler**                       | PicoBlaze assembly-code generation             |
| **Program ROM**                     | Stores PicoBlaze machine instructions          |
| **Switches / Buttons**              | Processor input                                |
| **LEDs / 7-Segment Display**        | Processor output                               |
| **Vivado Simulator**                | Functional verification                        |

---

# 🧠 3. Background Theory

## 3.1 What Is PicoBlaze?

**PicoBlaze** is a compact 8-bit soft-core processor designed for FPGA-based control applications.

Unlike a large embedded processor, PicoBlaze is optimized for:

* simple control,
* state-machine replacement,
* peripheral management,
* protocol handling,
* low-resource embedded functions.

The processor is implemented using FPGA programmable logic.

Therefore,

$$
\boxed{
\text{PicoBlaze}
================

\text{Small Processor Implemented in FPGA Fabric}
}
$$

A simplified architecture is

```text
              ┌──────────────────┐
              │    PicoBlaze     │
              │     Processor    │
              └────────┬─────────┘
                       │
          ┌────────────┼────────────┐
          ▼            ▼            ▼
      Program ROM    Input Ports  Output Ports
```

---

## 3.2 PicoBlaze versus MicroBlaze

PicoBlaze and MicroBlaze are both soft-core processors, but they target different applications.

| Characteristic       | PicoBlaze              | MicroBlaze                |
| -------------------- | ---------------------- | ------------------------- |
| Architecture         | Lightweight 8-bit      | Configurable 32-bit       |
| Primary use          | Control logic          | Embedded computing        |
| Programming          | Assembly               | C/C++ and assembly        |
| Memory               | Small program ROM      | BRAM/external memory      |
| AXI support          | Not typically required | Native system integration |
| FPGA resources       | Very low               | Higher                    |
| Operating complexity | Low                    | Higher                    |
| OS support           | No                     | Possible                  |
| Best use             | Small control tasks    | Full embedded systems     |

Thus,

$$
\boxed{
\text{PicoBlaze}
\rightarrow
\text{Simple Embedded Control}
}
$$

while

$$
\boxed{
\text{MicroBlaze}
\rightarrow
\text{General Embedded Processing}
}
$$

---

# 🏗️ 4. Basic PicoBlaze Architecture

A PicoBlaze-based system contains three main blocks:

```text
         Program ROM
             │
             ▼
      ┌──────────────┐
      │  PicoBlaze   │
      └──────┬───────┘
             │
      ┌──────┼──────┐
      ▼             ▼
 Input Ports    Output Ports
      │             │
   Switches        LEDs
```

The processor repeatedly:

1. fetches an instruction,
2. decodes the instruction,
3. executes the instruction.

This is described by

$$
\boxed{
\text{Fetch}
\rightarrow
\text{Decode}
\rightarrow
\text{Execute}
}
$$

---

# 📦 5. PicoBlaze Registers

PicoBlaze contains a small register file.

Registers are commonly written as

```text
s0
s1
s2
...
sF
```

Each register stores an 8-bit value.

For example,

```text
LOAD s0, 05
```

places hexadecimal value `05` into register `s0`.

Thus,

$$
s0=0x05.
$$

---

# 🧮 6. Arithmetic and Logic Operations

PicoBlaze supports operations such as:

```text
ADD
SUB
AND
OR
XOR
COMPARE
TEST
```

For example,

```text
LOAD s0, 03
LOAD s1, 02
ADD  s0, s1
```

produces

$$
s0=3+2=5.
$$

Similarly,

```text
XOR s0, s1
```

performs a bitwise XOR.

---

# 🔄 7. Program Counter and Instruction Execution

PicoBlaze executes instructions sequentially.

Conceptually,

$$
PC\leftarrow PC+1.
$$

Branch instructions can modify the program counter.

For example,

```text
JUMP LOOP
```

causes program execution to continue from the label `LOOP`.

This allows:

* loops,
* conditional decisions,
* state-machine behavior,
* polling.

---

# 📥 8. Input Ports

PicoBlaze communicates with external FPGA logic through ports.

A typical input instruction is

```text
INPUT s0, 01
```

This reads data from input port address `01` and stores it in register `s0`.

The data path is

```text
FPGA Switches
      │
      ▼
Input Port Logic
      │
      ▼
PicoBlaze
      │
      ▼
Register s0
```

---

# 📤 9. Output Ports

The `OUTPUT` instruction writes register data to an FPGA output port.

For example,

```text
OUTPUT s0, 02
```

writes the value stored in `s0` to output port `02`.

The architecture becomes

```text
PicoBlaze
    │
    ▼
OUTPUT Instruction
    │
    ▼
Output Port
    │
    ▼
FPGA LEDs
```

---

# 🧠 10. Simple GPIO Application

The first laboratory application performs

$$
\boxed{
\text{Switches}
\rightarrow
\text{PicoBlaze}
\rightarrow
\text{LEDs}
}
$$

The processor continuously:

1. reads switches,
2. stores the value in a register,
3. writes the register value to LEDs.

The behavior is

$$
LED=SW.
$$

---

# 💻 11. PicoBlaze Assembly Program

A simple program is

```text
CONSTANT SW_PORT, 00
CONSTANT LED_PORT, 01

START:
    INPUT  s0, SW_PORT
    OUTPUT s0, LED_PORT
    JUMP   START
```

The program continuously loops.

The instruction flow is

```text
START
  │
  ▼
Read Switches
  │
  ▼
Write LEDs
  │
  ▼
Jump START
```

---

# 🔢 12. Example Operation

Suppose the four switches are

```text
SW3 SW2 SW1 SW0
 1   0   1   0
```

Then

$$
SW=1010_2=10.
$$

PicoBlaze executes

```text
INPUT s0, SW_PORT
```

so

$$
s0=00001010.
$$

Then

```text
OUTPUT s0, LED_PORT
```

produces

```text
LED3 LED2 LED1 LED0
 1    0    1    0
```

Thus,

$$
\boxed{LED=SW}.
$$

---

# 🧱 13. PicoBlaze Hardware Interface

A typical PicoBlaze core provides signals such as:

```text
address
instruction
port_id
in_port
out_port
read_strobe
write_strobe
interrupt
reset
clk
```

The most important I/O signals are

| Signal         | Description                |
| -------------- | -------------------------- |
| `port_id`      | Peripheral address         |
| `in_port`      | Data from external logic   |
| `out_port`     | Data to external logic     |
| `read_strobe`  | Indicates input operation  |
| `write_strobe` | Indicates output operation |

These signals create a simple peripheral interface.

---

# 🔌 14. Port Addressing

Suppose

```text
Port 00 → Switches
Port 01 → LEDs
Port 02 → Buttons
Port 03 → 7-Segment Display
```

PicoBlaze can select a peripheral using `port_id`.

Conceptually,

$$
port_id=0x00
\Rightarrow
\text{Switch Input}
$$

and

$$
port_id=0x01
\Rightarrow
\text{LED Output}.
$$

---

# 💻 15. PicoBlaze Top-Level Architecture

The top-level FPGA design can be represented as

```text
                    ┌──────────────┐
                    │ Program ROM  │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │  PicoBlaze   │
                    └──────┬───────┘
                           │
                ┌──────────┼──────────┐
                ▼                     ▼
          Input Decoder          Output Decoder
                │                     │
             Switches                LEDs
```

---

# 💻 16. Example Verilog Top Module

A conceptual top-level design is

```verilog
module picoblaze_top(
    input  wire       clk,
    input  wire       reset,
    input  wire [3:0] sw,
    output reg  [3:0] led
);

    wire [11:0] address;
    wire [17:0] instruction;

    wire [7:0] port_id;
    wire [7:0] out_port;
    reg  [7:0] in_port;

    wire write_strobe;
    wire read_strobe;

    kcpsm6 CPU (
        .address(address),
        .instruction(instruction),

        .port_id(port_id),
        .write_strobe(write_strobe),
        .out_port(out_port),

        .read_strobe(read_strobe),
        .in_port(in_port),

        .interrupt(1'b0),
        .interrupt_ack(),

        .reset(reset),
        .sleep(1'b0),

        .clk(clk)
    );

    program_rom ROM (
        .address(address),
        .instruction(instruction),
        .clk(clk)
    );

    always @(*) begin

        case (port_id)

            8'h00:
                in_port = {4'b0000, sw};

            default:
                in_port = 8'h00;

        endcase

    end

    always @(posedge clk) begin

        if (reset)
            led <= 4'b0000;

        else if (write_strobe &&
                 port_id == 8'h01)

            led <= out_port[3:0];

    end

endmodule
```

The exact PicoBlaze module and program-memory interfaces depend on the PicoBlaze source package and tool version.

---

# 📦 17. Program ROM

The processor instructions are stored in a program ROM.

The architecture is

```text
Program Counter
      │
      ▼
Address
      │
      ▼
Program ROM
      │
      ▼
Instruction
      │
      ▼
PicoBlaze
```

If PicoBlaze generates address (A), the program ROM returns

$$
Instruction[A].
$$

---

# 🛠️ 18. Assembly-to-ROM Flow

The PicoBlaze software development flow is

```text
Assembly Program
      │
      ▼
Assembler
      │
      ▼
Machine Instructions
      │
      ▼
Program ROM
      │
      ▼
Vivado Design
      │
      ▼
FPGA
```

For example,

```text
program.psm
```

may be assembled to generate a ROM description used in the FPGA project.

---

# 🔨 19. Vivado Project Procedure

## Step 1 — Create Project

Open Vivado and select

```text
Create Project
```

Choose an RTL project and select the target FPGA board.

---

## Step 2 — Add PicoBlaze Sources

Add the required PicoBlaze HDL source files, such as the processor core.

Also add the generated program-memory source.

The source hierarchy may look like

```text
picoblaze_top
    │
    ├── kcpsm6
    └── program_rom
```

---

## Step 3 — Add Assembly Program

Create a PicoBlaze assembly file.

Example:

```text
switch_led.psm
```

Enter:

```text
CONSTANT SW_PORT, 00
CONSTANT LED_PORT, 01

START:
    INPUT  s0, SW_PORT
    OUTPUT s0, LED_PORT
    JUMP   START
```

---

## Step 4 — Assemble the Program

Run the PicoBlaze assembler.

The assembler converts

$$
\text{Assembly}
\rightarrow
\text{Machine Code}.
$$

The resulting program memory is then included in Vivado.

---

# 🧩 20. Program Memory Integration

After assembly, the program ROM is connected to

```text
address
```

and

```text
instruction
```

signals of the PicoBlaze processor.

The hierarchy is

```text
PicoBlaze
   │
   ├── address ─────► Program ROM
   │
   └── instruction ◄─ Program ROM
```

---

# ✅ 21. RTL Analysis

Select

```text
RTL Analysis
    ↓
Open Elaborated Design
```

Then open the schematic.

Students should identify:

* PicoBlaze processor,
* program ROM,
* input-port logic,
* output-port logic.

The architecture should resemble

```text
ROM
 │
 ▼
PicoBlaze
 │
 ├── Input Decoder
 └── Output Decoder
```

---

# 🧪 22. Simulation Strategy

Simulation can verify:

* instruction fetching,
* port addresses,
* read strobes,
* write strobes,
* LED outputs.

Important waveform signals include:

```text
clk
reset
address
instruction
port_id
in_port
out_port
read_strobe
write_strobe
sw
led
```

---

# 🧪 23. Example Testbench

```verilog
`timescale 1ns / 1ps

module tb_picoblaze;

    reg clk;
    reg reset;

    reg [3:0] sw;

    wire [3:0] led;

    picoblaze_top uut (
        .clk(clk),
        .reset(reset),
        .sw(sw),
        .led(led)
    );

    initial begin

        clk = 0;

        forever #5 clk = ~clk;

    end

    initial begin

        reset = 1;
        sw = 4'b0000;

        #20;

        reset = 0;

        sw = 4'b0001;
        #100;

        sw = 4'b0101;
        #100;

        sw = 4'b1010;
        #100;

        sw = 4'b1111;
        #100;

        $finish;

    end

endmodule
```

Because the processor executes several instructions, enough simulation time should be allowed for each input change to propagate through the program.

---

# 📊 24. Expected Results

| Switch Input | Expected LED Output |
| :----------: | :-----------------: |
|    `0000`    |        `0000`       |
|    `0001`    |        `0001`       |
|    `0101`    |        `0101`       |
|    `1010`    |        `1010`       |
|    `1111`    |        `1111`       |

Thus,

$$
\boxed{LED=SW}.
$$

---

# ⚡ 25. FPGA Implementation

A simple I/O mapping is

| Signal   | FPGA Resource | Description     |
| -------- | ------------- | --------------- |
| `sw[0]`  | SW0           | Input bit 0     |
| `sw[1]`  | SW1           | Input bit 1     |
| `sw[2]`  | SW2           | Input bit 2     |
| `sw[3]`  | SW3           | Input bit 3     |
| `led[0]` | LED0          | Output bit 0    |
| `led[1]` | LED1          | Output bit 1    |
| `led[2]` | LED2          | Output bit 2    |
| `led[3]` | LED3          | Output bit 3    |
| `clk`    | Board Clock   | Processor clock |
| `reset`  | Button        | Processor reset |

Use the correct XDC file for the selected FPGA board.

---

# 🔁 26. PicoBlaze as an FSM Replacement

Consider a traditional finite-state machine:

```text
STATE0
  │
  ▼
STATE1
  │
  ▼
STATE2
  │
  └──► STATE0
```

This can be implemented in HDL.

Alternatively, PicoBlaze can implement the control sequence in software:

```text
STATE0:
    ...
    JUMP STATE1

STATE1:
    ...
    JUMP STATE2
```

This provides greater flexibility for moderately complex control algorithms.

---

# 🚦 27. Traffic-Light Example

PicoBlaze can control a simple traffic light.

Define the output bits:

```text
Bit 2 → RED
Bit 1 → YELLOW
Bit 0 → GREEN
```

A sequence could be

```text
RED
 ↓
GREEN
 ↓
YELLOW
 ↓
RED
```

An example assembly concept is

```text
LOAD s0, 04
OUTPUT s0, LIGHT_PORT
CALL DELAY

LOAD s0, 01
OUTPUT s0, LIGHT_PORT
CALL DELAY

LOAD s0, 02
OUTPUT s0, LIGHT_PORT
CALL DELAY

JUMP START
```

---

# ⏱️ 28. Software Delay

A basic software delay can use nested loops.

For example:

```text
DELAY:
    LOAD s1, FF

D1:
    LOAD s2, FF

D2:
    SUB s2, 01
    JUMP NZ, D2

    SUB s1, 01
    JUMP NZ, D1

    RETURN
```

This is useful for introductory experiments, although precise timing systems should use hardware timers or counters.

---

# 🧠 29. Conditional Processing

PicoBlaze can make decisions based on input data.

For example:

```text
INPUT s0, SW_PORT
COMPARE s0, 0F
JUMP Z, ALL_ON
```

If

$$
s0=0x0F,
$$

the program jumps to `ALL_ON`.

This allows embedded control algorithms to be implemented using software.

---

# 🧮 30. Arithmetic Example

Suppose two 4-bit values are supplied to the processor.

PicoBlaze can compute

$$
Y=A+B.
$$

Conceptually:

```text
INPUT s0, A_PORT
INPUT s1, B_PORT

ADD s0, s1

OUTPUT s0, RESULT_PORT
```

This demonstrates processor-based arithmetic.

---

# 📡 31. UART Extension

A UART transmitter can be added as external hardware.

The architecture becomes

```text
PicoBlaze
    │
    ▼
Output Port
    │
    ▼
UART TX Module
    │
    ▼
PC Terminal
```

PicoBlaze can write ASCII characters to a UART peripheral.

This enables:

* debugging,
* status messages,
* command interfaces.

---

# 🧱 32. PicoBlaze and Custom Hardware

PicoBlaze can control custom FPGA modules.

For example:

```text
                  PicoBlaze
                      │
             ┌────────┼────────┐
             ▼        ▼        ▼
           GPIO      UART      MAC
                               │
                               ▼
                           Accelerator
```

The processor can:

* send configuration data,
* start an operation,
* read status,
* collect results.

This provides simple hardware/software co-design.

---

# ⚡ 33. PicoBlaze-Controlled MAC

Suppose a MAC accelerator computes

$$
ACC\leftarrow ACC+A\times B.
$$

PicoBlaze can use ports such as

```text
Port 10 → A
Port 11 → B
Port 12 → Control
Port 13 → Result
```

The program performs

```text
OUTPUT A_VALUE, PORT_A
OUTPUT B_VALUE, PORT_B

LOAD s0, 01
OUTPUT s0, CONTROL_PORT

INPUT s1, RESULT_PORT
```

This combines a lightweight processor with dedicated FPGA acceleration.

---

# 🆚 34. PicoBlaze versus HDL Control

| Characteristic      | PicoBlaze        | HDL FSM             |
| ------------------- | ---------------- | ------------------- |
| Control description | Assembly program | Verilog FSM         |
| Modification        | Change software  | Change HDL          |
| Execution           | Sequential       | Parallel hardware   |
| Resource usage      | Low              | Very low–moderate   |
| Complex branching   | Easy             | More verbose        |
| Timing precision    | Lower            | Excellent           |
| Datapath processing | Limited          | Excellent           |
| Best use            | Control          | High-speed hardware |

The best FPGA design often combines both approaches.

---

# 🆚 35. PicoBlaze versus MicroBlaze

| Feature                | PicoBlaze            | MicroBlaze           |
| ---------------------- | -------------------- | -------------------- |
| Data width             | 8 bit                | 32 bit               |
| Programming            | Assembly             | C/C++                |
| Resource requirement   | Very low             | Moderate             |
| Memory                 | Small program ROM    | Larger system memory |
| AXI ecosystem          | Limited/direct ports | Extensive            |
| Software complexity    | Low                  | High                 |
| Computation capability | Basic                | Advanced             |
| Control applications   | Excellent            | Excellent            |
| AI software            | Limited              | More practical       |

Thus, PicoBlaze is especially suitable when the FPGA needs a small programmable controller without the overhead of a full embedded processor.

---

# 📈 36. Resource Utilization Study

After synthesis, record:

| FPGA Resource | Utilization |
| ------------- | ----------: |
| LUTs          |             |
| Flip-Flops    |             |
| BRAM          |             |
| DSP           |             |
| I/O           |             |

Compare the result with a MicroBlaze design.

| Processor  | LUT | FF | BRAM | DSP |
| ---------- | --: | -: | ---: | --: |
| PicoBlaze  |     |    |      |     |
| MicroBlaze |     |    |      |     |

PicoBlaze should generally require substantially fewer resources for simple control applications.

---

# 🔍 37. Timing Analysis

Record:

| Timing Parameter | Result |
| ---------------- | -----: |
| Clock Frequency  |        |
| Critical Path    |        |
| Worst Slack      |        |

Because PicoBlaze executes instructions sequentially, the time required for an operation depends on the number of instructions executed.

If an instruction requires approximately a fixed number of clock cycles, then application latency is approximately

$$
T_{\text{application}}
\propto
N_{\text{instructions}}T_{\text{clk}}.
$$

---

# 🧪 38. Lab Tasks

### Task 1 — Add PicoBlaze Core

Add the PicoBlaze processor source to a Vivado project.

### Task 2 — Create Program ROM

Generate and integrate PicoBlaze program memory.

### Task 3 — Write Assembly Program

Implement

$$
Switches\rightarrow LEDs.
$$

### Task 4 — Create Port Decoder

Map:

```text
00 → Switch input
01 → LED output
```

### Task 5 — Simulate

Verify:

* `port_id`,
* `read_strobe`,
* `write_strobe`,
* input data,
* output data.

### Task 6 — Synthesize

Run Vivado synthesis and record resource utilization.

### Task 7 — FPGA Deployment

Program the FPGA and verify switch-to-LED behavior.

### Task 8 — Modify Program

Add an XOR operation:

$$
LED=SW\oplus1111_2.
$$

---

# 💬 39. Discussion Points

1. What is PicoBlaze?
2. Why is PicoBlaze called a soft-core processor?
3. What is the difference between PicoBlaze and MicroBlaze?
4. Why does PicoBlaze use program ROM?
5. What is the role of `port_id`?
6. What is the purpose of `read_strobe`?
7. What is the purpose of `write_strobe`?
8. How does PicoBlaze communicate with FPGA peripherals?
9. Why is PicoBlaze useful for control-oriented FPGA applications?
10. When would an HDL FSM be preferable to PicoBlaze?
11. When would MicroBlaze be preferable to PicoBlaze?
12. How can PicoBlaze control a custom hardware accelerator?

---

# 🧠 40. Post-Lab Exercises

1. **Invert Switch Data**
   Implement

   $$
   LED=\overline{SW}.
   $$

2. **XOR Operation**
   Implement

   $$
   LED=SW\oplus1010_2.
   $$

3. **Button Control**
   Add FPGA push buttons as a second input port.

4. **7-Segment Display**
   Display PicoBlaze output on a seven-segment display.

5. **Counter Program**
   Implement an 8-bit software counter.

6. **Traffic-Light Controller**
   Implement RED, GREEN, and YELLOW sequencing.

7. **UART Output**
   Connect PicoBlaze to a UART transmitter.

8. **Multiple Peripheral Ports**
   Add switches, buttons, LEDs, and displays using separate port addresses.

9. **Interrupt Experiment**
   Explore PicoBlaze interrupt handling.

10. **MAC Controller**
    Use PicoBlaze to control the MAC design from the previous laboratory.

---

# 🔬 41. Advanced Exercise — PicoBlaze Peripheral System

Build the architecture

```text
                     PicoBlaze
                         │
          ┌──────────────┼──────────────┐
          ▼              ▼              ▼
       Switches        Buttons         UART
          │                              │
          │                              ▼
          │                         PC Terminal
          │
          └──────────────┐
                         ▼
                       LEDs
```

Use port addresses:

| Port | Peripheral |
| ---: | ---------- |
| `00` | Switches   |
| `01` | Buttons    |
| `02` | LEDs       |
| `03` | UART TX    |

The PicoBlaze program should read inputs and generate appropriate outputs.

---

# 🚀 42. Advanced Exercise — PicoBlaze + AI Accelerator

A more advanced architecture can be

```text
                      PicoBlaze
                          │
                   Control Ports
                          │
             ┌────────────┼────────────┐
             ▼            ▼            ▼
           GPIO          MAC        ANN/BNN
                           │
                           ▼
                         Result
```

PicoBlaze can manage:

* AI accelerator start,
* configuration parameters,
* status monitoring,
* output reporting.

The computationally intensive operation remains in custom FPGA logic.

Thus,

$$
\boxed{
\text{PicoBlaze Control}
+
\text{FPGA Accelerator}
}
$$

can provide an efficient lightweight embedded architecture.

---

# 🧾 43. Expected Learning Outcomes

After completing this laboratory, students will be able to:

* Explain PicoBlaze soft-core processor architecture.
* Compare PicoBlaze and MicroBlaze.
* Describe PicoBlaze instruction execution.
* Write simple PicoBlaze assembly programs.
* Use registers, arithmetic, branches, and loops.
* Interface PicoBlaze with FPGA input and output ports.
* Implement port-address decoding in Verilog.
* Generate and integrate program memory.
* Simulate processor/peripheral communication.
* Synthesize and deploy a PicoBlaze FPGA system.
* Analyze FPGA resource utilization.
* Explain when a lightweight processor is appropriate.
* Apply PicoBlaze to embedded-control and accelerator-management applications.

---

# 📘 44. References

1. AMD Xilinx, *PicoBlaze 8-bit Embedded Microcontroller User Guide*.
2. AMD Xilinx, *KCPSM6 PicoBlaze Processor Documentation*.
3. AMD Xilinx, *Vivado Design Suite User Guide: Synthesis*.
4. M. D. Ciletti, *Advanced Digital Design with the Verilog HDL*, Pearson.
5. S. Brown and Z. Vranesic, *Fundamentals of Digital Logic with Verilog Design*, McGraw-Hill.
6. M. M. Mano and M. D. Ciletti, *Digital Design*, Pearson.

---

## 🔑 Key Concept

The central architecture of this laboratory is

$$
\boxed{
\text{Program ROM}
\rightarrow
\text{PicoBlaze}
\rightarrow
\text{I/O Ports}
}
$$

The processor executes

$$
\boxed{
\text{Fetch}
\rightarrow
\text{Decode}
\rightarrow
\text{Execute}
}
$$

and interacts with FPGA hardware using

$$
\boxed{
\text{INPUT}
\rightarrow
\text{Processing}
\rightarrow
\text{OUTPUT}
}
$$

The complete embedded FPGA concept is therefore

$$
\boxed{
\text{Lightweight Soft-Core Processor}
+
\text{Program Memory}
+
\text{Custom FPGA Peripherals}
}
$$

This laboratory provides the foundation for subsequent work involving **PicoBlaze-controlled FSMs, UART interfaces, sensor controllers, custom accelerators, MAC engines, ANN/BNN modules, and lightweight FPGA embedded systems**.
