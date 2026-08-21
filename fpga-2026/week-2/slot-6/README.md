# 🔬 Lab: Vivado-2 — Hello FPGA

## LED Blinking and FPGA Programming

## 🧩 1. Objective

* Understand the basic FPGA development flow using **Vivado Design Suite**.
* Create a simple sequential Verilog design.
* Implement an **LED blinking circuit** using a clock divider.
* Understand the role of the FPGA system clock.
* Create and apply FPGA pin constraints using an **XDC file**.
* Run synthesis and implementation in Vivado.
* Generate an FPGA bitstream.
* Program an FPGA board using the Vivado Hardware Manager.
* Verify the LED blinking operation on a **Basys 3 / Nexys A7 FPGA**.

---

## ⚙️ 2. Equipment and Tools

| Tool / Resource                     | Description                                             |
| ----------------------------------- | ------------------------------------------------------- |
| **Vivado Design Suite**             | FPGA design, synthesis, implementation, and programming |
| **FPGA Board (Basys 3 / Nexys A7)** | Hardware implementation                                 |
| **USB-JTAG Cable**                  | FPGA programming interface                              |
| **Verilog HDL**                     | LED blinking circuit design                             |
| **XDC Constraints File**            | FPGA clock and LED pin assignment                       |
| **Vivado Hardware Manager**         | FPGA bitstream programming                              |
| **Onboard Clock**                   | System clock source                                     |
| **Onboard LED**                     | Visual FPGA output                                      |

---

# 🧠 3. Background Theory

## 3.1 What Is an FPGA?

FPGA stands for

> **Field-Programmable Gate Array**

An FPGA contains programmable digital resources such as:

* Lookup Tables (LUTs)
* Flip-flops
* Block RAM
* DSP slices
* Clocking resources
* Programmable routing
* Input/output blocks

Unlike a microcontroller, an FPGA does not normally execute instructions sequentially unless a processor is implemented inside it.

Instead, Verilog HDL describes hardware structures that operate directly and often in parallel.

The basic FPGA design flow is

```text
Verilog HDL
    │
    ▼
Simulation
    │
    ▼
Synthesis
    │
    ▼
Implementation
    │
    ▼
Bitstream
    │
    ▼
FPGA Programming
    │
    ▼
Hardware Operation
```

---

## 3.2 Hello FPGA

In software programming, the first program is often

```text
Hello World
```

For FPGA design, a common first hardware experiment is

```text
Blink an LED
```

Therefore,

$$
\boxed{
\text{Hello FPGA}
=================

\text{Blinking LED}
}
$$

This simple experiment verifies:

* clock operation,
* sequential logic,
* synthesis,
* FPGA pin assignment,
* bitstream generation,
* hardware programming.

---

# ⏱️ 4. FPGA Clock

Most FPGA development boards contain an onboard oscillator.

For example, a board may provide

$$
f_{clk}=100~\text{MHz}.
$$

The clock period is

$$
T_{clk}
=======

\frac{1}{f_{clk}}.
$$

Therefore,

$$
T_{clk}
=======

# \frac{1}{100\times10^6}

10~\text{ns}.
$$

This means the FPGA receives

$$
100,000,000
$$

clock cycles every second.

---

# 💡 5. Why a Clock Divider Is Required

If an LED changed state directly at 100 MHz, the human eye would not perceive individual transitions.

For example,

```verilog
always @(posedge clk)
    led <= ~led;
```

would toggle the LED every clock cycle.

The output frequency would be approximately

$$
f_{LED}
=======

# \frac{f_{clk}}{2}

50~\text{MHz}.
$$

This is far too fast to observe.

Therefore, a **clock divider** or counter is required.

---

# 🧮 6. Frequency Division Using a Counter

A binary counter naturally divides the input clock frequency.

For a counter bit (n),

$$
f_n
===

\frac{f_{clk}}
{2^{n+1}}.
$$

If

$$
f_{clk}=100~\text{MHz},
$$

then a high-order counter bit changes much more slowly.

For example,

$$
f_{25}
======

\frac{100\times10^6}{2^{26}}
\approx1.49~\text{Hz}.
$$

Thus, the LED appears to blink approximately once every fraction of a second.

---

# 🏗️ 7. LED Blinker Architecture

The basic architecture is

```text
FPGA Clock
    │
    ▼
Binary Counter
    │
    ▼
High-Order Counter Bit
    │
    ▼
LED
```

The counter continuously increments:

$$
COUNT
\leftarrow
COUNT+1.
$$

One high-order bit is connected to the LED.

---

# 💻 8. Basic Verilog LED Blinker

Create a Verilog source file:

```text
led_blink.v
```

Use:

```verilog
module led_blink(
    input  wire clk,
    output wire led
);

    reg [25:0] counter = 26'd0;

    always @(posedge clk) begin
        counter <= counter + 1'b1;
    end

    assign led = counter[25];

endmodule
```

The LED is driven by the most significant counter bit.

---

# 🧠 9. How the Code Works

The register

```verilog
reg [25:0] counter;
```

creates a 26-bit counter.

The statement

```verilog
counter <= counter + 1'b1;
```

increments the counter at every rising edge of `clk`.

The statement

```verilog
assign led = counter[25];
```

connects the most significant counter bit to the physical LED.

Therefore,

$$
\boxed{
\text{Fast Clock}
\rightarrow
\text{Counter}
\rightarrow
\text{Slow LED Signal}
}
$$

---

# 🔄 10. Version with Reset Input

A more complete design includes reset.

```verilog
module led_blink_reset(
    input  wire clk,
    input  wire reset,
    output wire led
);

    reg [25:0] counter;

    always @(posedge clk) begin

        if (reset)
            counter <= 26'd0;

        else
            counter <= counter + 1'b1;

    end

    assign led = counter[25];

endmodule
```

When

```text
reset = 1
```

the counter returns to zero.

---

# 🧪 11. Behavioral Simulation

Although the final objective is FPGA programming, the circuit can first be tested using behavioral simulation.

A full 26-bit divider would require many simulated clock cycles.

Therefore, use a smaller counter during simulation.

---

# 💻 12. Simulation-Friendly LED Blinker

```verilog
module led_blink_sim(
    input  wire clk,
    output wire led
);

    reg [3:0] counter = 4'd0;

    always @(posedge clk) begin
        counter <= counter + 1'b1;
    end

    assign led = counter[3];

endmodule
```

With a 4-bit counter, LED transitions occur quickly enough to observe in simulation.

---

# 🧪 13. Testbench

```verilog
`timescale 1ns / 1ps

module tb_led_blink;

    reg clk;
    wire led;

    led_blink_sim uut (
        .clk(clk),
        .led(led)
    );

    initial begin
        clk = 0;

        forever #5 clk = ~clk;
    end

    initial begin
        #500;
        $finish;
    end

endmodule
```

The simulated clock period is

$$
10~\text{ns},
$$

corresponding to

$$
100~\text{MHz}.
$$

---

# 📊 14. Expected Simulation Waveform

The waveform should show:

```text
clk      _-_-_-_-_-_-_-_-_-_-_

counter  0 1 2 3 4 5 6 7 ...

led      ________--------________
```

The LED output changes much more slowly than the input clock.

---

# 🛠️ 15. Create a Vivado Project

## Step 1 — Start Vivado

Open Vivado and select

```text
Create Project
```

Choose a project name such as

```text
Vivado_Hello_FPGA
```

---

## Step 2 — Select RTL Project

Select

```text
RTL Project
```

Choose the correct FPGA board or FPGA device.

Examples:

* Basys 3
* Nexys A7

---

# 📁 16. Add Design Source

Select

```text
Add Sources
    ↓
Add or Create Design Sources
```

Create

```text
led_blink.v
```

and enter the Verilog HDL code.

The Sources panel should contain

```text
Design Sources
    └── led_blink
```

---

# 🧷 17. FPGA Constraints

The logical HDL ports must be connected to physical FPGA pins.

This is performed using an **XDC constraint file**.

The two required signals are

```text
clk
led
```

The clock is connected to the onboard oscillator.

The LED output is connected to an onboard LED.

---

# 📌 18. Example XDC Structure

The exact pin names depend on the FPGA board.

A typical XDC structure is

```tcl
set_property PACKAGE_PIN <CLOCK_PIN> [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

set_property PACKAGE_PIN <LED_PIN> [get_ports led]
set_property IOSTANDARD LVCMOS33 [get_ports led]
```

For the clock, a timing constraint should also be specified.

For a 100 MHz clock:

```tcl
create_clock -add -name sys_clk \
-period 10.000 \
-waveform {0 5} \
[get_ports clk]
```

Students should use the official board master XDC file to obtain the correct package pins.

---

# ⏱️ 19. Clock Constraint

For

$$
f=100~\text{MHz},
$$

the clock period is

$$
T=10~\text{ns}.
$$

Therefore,

```tcl
-period 10.000
```

informs Vivado that the system clock period is 10 ns.

This information is used during timing analysis.

---

# 🔍 20. RTL Analysis

Before synthesis, select

```text
RTL Analysis
    ↓
Open Elaborated Design
```

Then open

```text
Schematic
```

The expected structure should resemble

```text
           ┌──────────────┐
clk ──────►│   Counter    │
           └──────┬───────┘
                  │
                  ▼
                 LED
```

Students should identify:

* counter register,
* increment logic,
* output connection.

---

# 🔨 21. Run Synthesis

Select

```text
Run Synthesis
```

Vivado converts the RTL design into FPGA logic resources.

After synthesis, inspect:

* LUT utilization,
* flip-flop utilization,
* clock resources,
* I/O resources.

---

# 📊 22. Expected Resource Utilization

The exact resource count depends on synthesis optimization and the target device.

A typical design requires:

| Resource   | Expected Use                |
| ---------- | --------------------------- |
| LUTs       | Small                       |
| Flip-Flops | Approximately counter width |
| DSP        | 0                           |
| BRAM       | 0                           |
| I/O        | Clock + LED                 |

The counter is primarily implemented using flip-flops and carry logic.

---

# 🏗️ 23. Run Implementation

After synthesis, select

```text
Run Implementation
```

Vivado performs:

```text
Place
   │
   ▼
Route
   │
   ▼
Timing Analysis
```

Placement determines where FPGA resources are used.

Routing connects those resources.

---

# ⏱️ 24. Timing Analysis

After implementation, check the timing summary.

Important parameters include:

| Parameter            | Result |
| -------------------- | -----: |
| Clock Period         |        |
| Worst Negative Slack |        |
| Total Negative Slack |        |
| Timing Met?          |        |

For a valid design, Vivado should normally report that the timing requirements are satisfied.

---

# 📦 25. Generate Bitstream

Select

```text
Generate Bitstream
```

Vivado converts the implemented FPGA configuration into a `.bit` file.

The design flow is now

```text
Verilog
   │
   ▼
Synthesis
   │
   ▼
Implementation
   │
   ▼
Bitstream
```

The bitstream contains the FPGA configuration information.

---

# 🔌 26. Connect the FPGA Board

Connect the FPGA development board to the PC using USB.

The same USB connection may provide:

* power,
* JTAG programming,
* UART communication,

depending on the board.

Turn the FPGA board ON.

---

# 🛠️ 27. Open Hardware Manager

In Vivado, select

```text
Open Hardware Manager
```

Then choose

```text
Open Target
    ↓
Auto Connect
```

Vivado should detect the FPGA device.

The device may appear in the Hardware window.

---

# 📥 28. Program the FPGA

Select

```text
Program Device
```

Vivado automatically selects or allows selection of the generated `.bit` file.

Click

```text
Program
```

The bitstream is transferred through JTAG into the FPGA configuration memory.

---

# 💡 29. Expected Hardware Result

After programming, the selected onboard LED should blink continuously.

The expected behavior is

```text
LED ON
   │
   ▼
LED OFF
   │
   ▼
LED ON
   │
   ▼
LED OFF
   │
   ▼
...
```

This confirms that:

* the clock is working,
* the counter is operating,
* the LED pin is correctly assigned,
* synthesis succeeded,
* implementation succeeded,
* the FPGA was programmed correctly.

---

# 📋 30. Experimental Results

Students should record:

| Test                 | Expected Result | Measured Result | Pass/Fail |
| -------------------- | --------------- | --------------- | --------- |
| Vivado synthesis     | Successful      |                 |           |
| Implementation       | Successful      |                 |           |
| Timing               | Met             |                 |           |
| Bitstream generation | Successful      |                 |           |
| FPGA detected        | Yes             |                 |           |
| FPGA programming     | Successful      |                 |           |
| LED blinking         | Visible         |                 |           |

---

# 🧮 31. Estimate the LED Blink Frequency

For a counter bit (n),

$$
f_{LED}
=======

\frac{f_{clk}}
{2^{n+1}}.
$$

Suppose

$$
f_{clk}=100~\text{MHz}
$$

and the output is

```verilog
counter[25]
```

then

$$
f_{LED}
=======

\frac{100\times10^6}{2^{26}}
\approx1.49~\text{Hz}.
$$

The corresponding period is

$$
T_{LED}
=======

\frac{1}{1.49}
\approx0.671~\text{s}.
$$

Thus, a complete ON/OFF cycle takes approximately 0.67 seconds.

---

# 🔬 32. Study of Different Counter Bits

Students can connect different counter bits to the LED.

For

$$
f_{clk}=100~\text{MHz},
$$

|   Counter Bit | Approx. Output Frequency |
| ------------: | -----------------------: |
| `counter[22]` |                 11.92 Hz |
| `counter[23]` |                  5.96 Hz |
| `counter[24]` |                  2.98 Hz |
| `counter[25]` |                  1.49 Hz |
| `counter[26]` |                 0.745 Hz |

Higher-order bits produce slower blinking.

---

# 💻 33. Parameterized LED Blinker

A reusable module can be written using a parameter.

```verilog
module led_blink_param #(
    parameter COUNTER_WIDTH = 26
)(
    input  wire clk,
    input  wire reset,
    output wire led
);

    reg [COUNTER_WIDTH-1:0] counter;

    always @(posedge clk) begin

        if (reset)
            counter <= {COUNTER_WIDTH{1'b0}};

        else
            counter <= counter + 1'b1;

    end

    assign led = counter[COUNTER_WIDTH-1];

endmodule
```

Changing

```text
COUNTER_WIDTH
```

changes the blink rate.

---

# ⏲️ 34. Exact 1 Hz Blink Generator

A binary divider does not always produce an exact desired frequency.

For an exact timing design, a terminal-count counter can be used.

Suppose

$$
f_{clk}=100~\text{MHz}
$$

and we want the LED to toggle every

$$
0.5~\text{s}.
$$

The required number of clock cycles is

$$
N
=

# 100\times10^6\times0.5

50,000,000.
$$

The LED toggles every 50 million cycles, producing a full 1-second ON/OFF period.

---

# 💻 35. Exact 1 Hz LED Blinker

```verilog
module led_blink_1hz(
    input  wire clk,
    input  wire reset,
    output reg  led
);

    reg [25:0] counter;

    always @(posedge clk) begin

        if (reset) begin

            counter <= 26'd0;
            led <= 1'b0;

        end

        else if (counter == 26'd49_999_999) begin

            counter <= 26'd0;
            led <= ~led;

        end

        else begin

            counter <= counter + 1'b1;

        end

    end

endmodule
```

This implementation provides a more controlled blink frequency for a 100 MHz clock.

---

# 🧠 36. Why Not Generate a New Clock?

A beginner may create a slow clock signal such as

```verilog
slow_clk <= ~slow_clk;
```

and then use `slow_clk` as another clock.

For simple FPGA designs, it is generally preferable to keep logic in a single clock domain and use a **clock enable** rather than creating arbitrary fabric-generated clocks.

A recommended architecture is

```text
100 MHz Clock
     │
     ▼
Counter
     │
     ▼
Clock Enable
     │
     ▼
Sequential Logic
```

This simplifies timing analysis and clock routing.

---

# 🔘 37. Add a Push-Button Reset

The design can be extended to include a reset button.

```text
BTN0
 │
 ▼
Reset
 │
 ▼
Counter = 0
 │
 ▼
LED = Initial State
```

This allows students to observe the effect of synchronous reset on FPGA hardware.

---

# 🚥 38. Multiple Blinking LEDs

Multiple counter bits can drive multiple LEDs.

```verilog
module multi_led_blink(
    input  wire clk,
    output wire [3:0] led
);

    reg [27:0] counter = 28'd0;

    always @(posedge clk) begin
        counter <= counter + 1'b1;
    end

    assign led[0] = counter[24];
    assign led[1] = counter[25];
    assign led[2] = counter[26];
    assign led[3] = counter[27];

endmodule
```

The LEDs blink at different frequencies.

This visually demonstrates binary frequency division.

---

# 📊 39. Binary Counter Visualization

A multi-LED counter may appear as

```text
LED3 LED2 LED1 LED0
 0    0    0    0
 0    0    0    1
 0    0    1    0
 0    0    1    1
 ...
```

At low enough frequencies, the LEDs provide a visual representation of binary counting.

---

# 🆚 40. Simulation versus Hardware

| Characteristic           | Behavioral Simulation   | FPGA Hardware         |
| ------------------------ | ----------------------- | --------------------- |
| Hardware board required  | No                      | Yes                   |
| Time                     | Simulated               | Real                  |
| Internal signals visible | High                    | Limited               |
| Input source             | Testbench               | Physical hardware     |
| Output                   | Waveform                | LED                   |
| Debugging                | Easy                    | More difficult        |
| Main purpose             | Functional verification | Physical verification |

Both are important in the FPGA development process.

---

# 🧪 41. Lab Tasks

### Task 1 — Create the Vivado Project

Create a new RTL project for the target FPGA board.

### Task 2 — Implement LED Blinker

Write a counter-based LED blinking module.

### Task 3 — Behavioral Simulation

Use a reduced counter width and verify LED toggling in simulation.

### Task 4 — Add XDC Constraints

Assign:

* onboard clock,
* onboard LED.

### Task 5 — RTL Analysis

Open the elaborated schematic and identify the counter.

### Task 6 — Synthesis

Run synthesis and inspect resource utilization.

### Task 7 — Implementation

Run place-and-route and verify timing.

### Task 8 — Generate Bitstream

Generate the FPGA configuration bitstream.

### Task 9 — Program FPGA

Use Hardware Manager to program the board.

### Task 10 — Verify LED

Confirm that the onboard LED blinks continuously.

---

# 📈 42. Resource Utilization Table

Students should record:

| FPGA Resource | Utilization |
| ------------- | ----------: |
| LUTs          |             |
| Flip-Flops    |             |
| BRAM          |             |
| DSP           |             |
| I/O           |             |
| Clock Buffers |             |

---

# ⏱️ 43. Timing Results

Record:

| Timing Parameter        | Result |
| ----------------------- | -----: |
| Input Clock Frequency   |        |
| Clock Period            |        |
| Worst Negative Slack    |        |
| Timing Met              |        |
| Estimated LED Frequency |        |
| Measured LED Frequency  |        |

---

# 💬 44. Discussion Points

1. What is an FPGA?
2. Why is LED blinking considered a "Hello FPGA" experiment?
3. Why is a counter required for visible LED blinking?
4. What is the relationship between clock frequency and clock period?
5. What does synthesis do?
6. What does implementation do?
7. What is an FPGA bitstream?
8. What is the purpose of an XDC file?
9. Why must the onboard clock pin be constrained correctly?
10. What is the function of Vivado Hardware Manager?
11. What happens if the LED pin assignment is incorrect?
12. Why are higher counter bits slower?
13. What is the difference between simulation time and real hardware time?
14. Why is using a clock enable often preferable to creating a new clock in logic?

---

# 🧠 45. Post-Lab Exercises

1. **Change Blink Frequency**
   Select another counter bit and observe the result.

2. **Slow Blink**
   Modify the design to produce approximately 0.5 Hz.

3. **Fast Blink**
   Produce approximately 5 Hz.

4. **Four Blinking LEDs**
   Drive four LEDs from four different counter bits.

5. **Push-Button Reset**
   Add a button that resets the counter.

6. **Enable Switch**
   Add a switch that enables or disables blinking.

7. **Exact 1 Hz Blinker**
   Use a terminal-count counter.

8. **Binary Counter Display**
   Connect high-order counter bits to several LEDs.

9. **LED Pattern Generator**
   Create a shifting LED pattern.

10. **7-Segment Counter**
    Display a counter value on a seven-segment display.

---

# 🔬 46. Advanced Exercise — LED Running Light

Create a running-light sequence:

```text
0001
  ↓
0010
  ↓
0100
  ↓
1000
  ↓
0001
```

The architecture is

```text
Clock
  │
  ▼
Clock Enable
  │
  ▼
Shift Register
  │
  ▼
4 LEDs
```

This extends the simple blinker into a basic sequential-control system.

---

# 🚀 47. Advanced Exercise — FPGA Heartbeat Signal

In larger FPGA systems, a blinking LED is often used as a **heartbeat indicator**.

For example,

```text
FPGA Running Correctly
        │
        ▼
System Clock Active
        │
        ▼
Heartbeat Counter
        │
        ▼
LED Blinking
```

If the LED stops blinking, it may indicate:

* clock failure,
* reset state,
* incorrect programming,
* system lockup.

Thus, the simple LED blinker can also serve as a useful hardware diagnostic signal.

---

# 🔄 48. Complete Vivado FPGA Flow

The complete workflow introduced in this laboratory is

```text
Create Project
     │
     ▼
Write Verilog
     │
     ▼
Add Constraints
     │
     ▼
Behavioral Simulation
     │
     ▼
RTL Analysis
     │
     ▼
Synthesis
     │
     ▼
Implementation
     │
     ▼
Timing Verification
     │
     ▼
Generate Bitstream
     │
     ▼
Open Hardware Manager
     │
     ▼
Program FPGA
     │
     ▼
Observe LED
```

This flow is used repeatedly in almost every later FPGA laboratory.

---

# 🧾 49. Expected Learning Outcomes

After completing this laboratory, students will be able to:

* Explain the basic FPGA design flow.
* Describe the relationship between clock frequency and period.
* Implement a binary counter in Verilog.
* Use a counter as a frequency divider.
* Create an LED blinking circuit.
* Simulate a simple sequential FPGA design.
* Create and apply FPGA XDC constraints.
* Run Vivado synthesis and implementation.
* Interpret basic utilization and timing reports.
* Generate an FPGA bitstream.
* Connect to the FPGA using Hardware Manager.
* Program an FPGA development board.
* Verify a real digital circuit using an onboard LED.

---

# 📘 50. References

1. AMD Xilinx, *Vivado Design Suite User Guide: Using the Vivado IDE*.
2. AMD Xilinx, *Vivado Design Suite User Guide: Synthesis*.
3. AMD Xilinx, *Vivado Design Suite User Guide: Implementation*.
4. AMD Xilinx, *Vivado Design Suite User Guide: Programming and Debugging*.
5. M. D. Ciletti, *Advanced Digital Design with the Verilog HDL*, Pearson.
6. S. Brown and Z. Vranesic, *Fundamentals of Digital Logic with Verilog Design*, McGraw-Hill.
7. IEEE Std 1364-2005, *IEEE Standard for Verilog Hardware Description Language*.

---

## 🔑 Key Concept

The main concept of this laboratory is

$$
\boxed{
\text{FPGA Clock}
\rightarrow
\text{Counter}
\rightarrow
\text{Frequency Division}
\rightarrow
\text{LED Blink}
}
$$

The complete Vivado workflow is

$$
\boxed{
\text{Verilog}
\rightarrow
\text{Simulation}
\rightarrow
\text{Synthesis}
\rightarrow
\text{Implementation}
\rightarrow
\text{Bitstream}
\rightarrow
\text{FPGA Programming}
}
$$

This laboratory establishes the practical foundation for subsequent work involving **switches, buttons, counters, FSMs, hierarchical design, MAC units, AXI IP cores, MicroBlaze, PicoBlaze, and AI-FPGA accelerators**.
