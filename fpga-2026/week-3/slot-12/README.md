# 🔬 Lab: Vivado IP Core-2 — MicroBlaze

## 🧩 1. Objective

* Understand the architecture and operation of the **MicroBlaze soft-core processor**.
* Create a processor-based FPGA system using **Vivado IP Integrator**.
* Configure MicroBlaze, local memory, clock, reset, debug, and AXI interfaces.
* Understand the difference between a **soft-core processor** and dedicated FPGA logic.
* Build, synthesize, and implement a basic MicroBlaze system.
* Export the hardware platform for embedded software development.
* Create and execute a simple C application on MicroBlaze.
* Use UART for software output and debugging.
* Introduce **hardware/software co-design** using FPGA programmable logic and an embedded processor.

---

## ⚙️ 2. Equipment and Tools

| Tool / Resource                                   | Description                            |
| ------------------------------------------------- | -------------------------------------- |
| **Vivado Design Suite**                           | FPGA hardware design and IP Integrator |
| **Vitis / AMD Embedded Development Environment**  | Embedded C software development        |
| **FPGA Board (Nexys A7 / Basys 3 or equivalent)** | Hardware implementation                |
| **MicroBlaze IP Core**                            | FPGA soft-core processor               |
| **Block Memory Generator / BRAM**                 | Program and data memory                |
| **AXI Interconnect / SmartConnect**               | Processor-peripheral communication     |
| **MicroBlaze Debug Module (MDM)**                 | Processor debugging                    |
| **Clocking Wizard**                               | System clock generation                |
| **Processor System Reset**                        | Reset synchronization                  |
| **USB-JTAG / USB-UART**                           | Programming and terminal communication |

---

# 🧠 3. Background Theory

## 3.1 What Is MicroBlaze?

**MicroBlaze** is a configurable soft-core processor provided for AMD Xilinx FPGAs.

Unlike a fixed processor physically fabricated inside a chip, MicroBlaze is implemented using programmable FPGA resources such as:

* LUTs,
* flip-flops,
* block RAM,
* DSP resources,
* routing resources.

Therefore,

$$
\boxed{\text{MicroBlaze}=\text{Processor Implemented in FPGA Logic}}
$$

A simplified architecture is

```text
             ┌──────────────────┐
             │    MicroBlaze    │
             │    Processor     │
             └────────┬─────────┘
                      │
               AXI / Memory Bus
                      │
       ┌──────────────┼──────────────┐
       ▼              ▼              ▼
     Memory          GPIO          UART
```

---

## 3.2 Soft-Core versus Hard-Core Processor

A **soft-core processor** is synthesized into programmable FPGA logic.

A **hard-core processor** is physically integrated into the silicon.

| Characteristic       | MicroBlaze Soft Core | Hard Processor     |
| -------------------- | -------------------- | ------------------ |
| Implementation       | FPGA fabric          | Fixed silicon      |
| Configuration        | Highly configurable  | Limited            |
| Resource usage       | LUTs, FFs, BRAM      | Dedicated hardware |
| Performance          | Moderate–High        | Usually higher     |
| Flexibility          | Very high            | Lower              |
| Number of processors | Multiple possible    | Fixed              |
| Example              | MicroBlaze           | ARM Cortex-A53     |

The major advantage of MicroBlaze is flexibility.

---

# 🏗️ 4. MicroBlaze System Architecture

A minimal embedded system requires more than only the processor.

The basic architecture is

```text
                    ┌───────────────┐
                    │  MicroBlaze   │
                    └───────┬───────┘
                            │
               ┌────────────┼─────────────┐
               │            │             │
               ▼            ▼             ▼
          Local Memory    Debug         AXI Bus
               │                          │
               ▼                          ▼
             BRAM                   Peripherals
```

Important components include:

* MicroBlaze processor,
* local memory,
* memory controller,
* clock,
* reset,
* debug module,
* AXI interconnect,
* optional peripherals.

---

# 🧠 5. Basic Processor Model

A processor repeatedly performs the instruction cycle

$$
\boxed{
\text{Fetch}
\rightarrow
\text{Decode}
\rightarrow
\text{Execute}
}
$$

The instruction flow is

```text
Program Memory
      │
      ▼
Instruction Fetch
      │
      ▼
Instruction Decode
      │
      ▼
Execution Unit
      │
      ▼
Register / Memory Update
```

MicroBlaze implements this process in FPGA hardware.

---

# 📦 6. MicroBlaze Components

## 6.1 Register File

The processor contains registers used to store temporary data.

Conceptually,

$$
R_0,R_1,\ldots,R_n.
$$

Registers are significantly faster than external memory.

---

## 6.2 Arithmetic Logic Unit

The ALU performs operations such as

$$
A+B
$$

$$
A-B
$$

$$
A\land B
$$

$$
A\lor B
$$

$$
A\oplus B.
$$

---

## 6.3 Program Counter

The program counter identifies the address of the next instruction.

Conceptually,

$$
PC\leftarrow PC+4
$$

for a sequential instruction stream.

Branches and jumps can modify the PC.

---

## 6.4 Instruction and Data Memory

MicroBlaze requires memory to store:

* program instructions,
* variables,
* stack,
* runtime data.

For small embedded systems, FPGA block RAM is commonly used.

---

# 🧱 7. Local Memory Architecture

A common MicroBlaze system uses Local Memory Bus connections.

```text
                    MicroBlaze
                   /          \
                  /            \
                 ▼              ▼
        Instruction LMB      Data LMB
                 │              │
                 ▼              ▼
              BRAM            BRAM
```

In some configurations, instruction and data storage share the same block memory infrastructure.

This architecture provides low-latency memory access.

---

# 🔌 8. AXI Interface

MicroBlaze can communicate with peripherals using the AXI bus.

The system can be represented as

```text
MicroBlaze
    │
    ▼
AXI Master
    │
    ▼
AXI SmartConnect
    │
    ├── GPIO
    ├── UART
    ├── Timer
    └── Custom IP
```

AXI peripherals are commonly accessed through **memory-mapped I/O**.

For example,

$$
\text{Peripheral Register}
\leftrightarrow
\text{Address}.
$$

---

# 💾 9. Memory-Mapped I/O

In a processor system, a peripheral can appear as a memory location.

Conceptually,

```text
Address 0xXXXX0000 → GPIO
Address 0xXXXX1000 → UART
Address 0xXXXX2000 → Timer
```

The processor reads and writes these addresses using normal memory operations.

Thus,

$$
\boxed{
\text{Processor Read/Write}
\rightarrow
\text{Peripheral Control}
}
$$

The actual addresses should be obtained from the Vivado Address Editor and generated platform files.

---

# 🛠️ 10. Create a Vivado Project

## Step 1 — Start Vivado

Open Vivado and select

```text
Create Project
```

Choose

```text
RTL Project
```

and select the appropriate FPGA board.

For example,

```text
Nexys A7
```

---

# 🧱 11. Create an IP Integrator Block Design

Select

```text
IP Integrator
    ↓
Create Block Design
```

Name the design

```text
microblaze_system
```

Vivado opens the graphical block-design environment.

---

# 🧠 12. Add MicroBlaze IP

Select

```text
Add IP
```

and search for

```text
MicroBlaze
```

Add the processor to the block design.

At this stage the processor is not yet a complete system because it still requires memory, clock, reset, and other infrastructure.

---

# 🤖 13. Run Block Automation

Vivado can automatically build the basic MicroBlaze subsystem.

Select

```text
Run Block Automation
```

Typical options may include:

* local memory size,
* clock configuration,
* cache options,
* debug support,
* interrupt support.

For an introductory laboratory, use a simple configuration with:

```text
Local Memory : 64 KB or suitable available size
Debug        : Enabled
Cache        : Disabled
Interrupt    : Optional
```

Exact options depend on Vivado version and FPGA target.

---

# 🏗️ 14. Generated Processor Subsystem

After block automation, the design typically contains

```text
                  MicroBlaze
                       │
          ┌────────────┼────────────┐
          │            │            │
          ▼            ▼            ▼
        BRAM           MDM       AXI Interface
          │
       LMB BRAM
      Controller
```

Additional blocks may include:

* Clocking Wizard,
* Processor System Reset,
* Local Memory Bus,
* AXI Interconnect.

---

# 💾 15. Block RAM

FPGA Block RAM stores the software program and data.

If the memory size is

$$
64~\text{KB},
$$

then

$$
64~\text{KB}=65,536~\text{bytes}.
$$

This space may contain:

* executable program code,
* global variables,
* heap,
* stack.

Embedded programs must fit inside the available memory unless external memory is added.

---

# 🐞 16. MicroBlaze Debug Module

The **MicroBlaze Debug Module (MDM)** connects the processor to the JTAG debugging infrastructure.

The architecture is

```text
PC
 │
 ▼
USB-JTAG
 │
 ▼
MDM
 │
 ▼
MicroBlaze
```

This allows:

* program download,
* breakpoints,
* single stepping,
* register inspection,
* memory inspection.

---

# ⏱️ 17. Clock System

MicroBlaze requires a processor clock.

For example, the FPGA board may provide

$$
100~\text{MHz}.
$$

A Clocking Wizard can generate the desired processor clock.

```text
Board Clock
     │
     ▼
Clocking Wizard
     │
     ▼
MicroBlaze Clock
```

If the processor runs at

$$
100~\text{MHz},
$$

the clock period is

$$
T=\frac{1}{100\times10^6}=10~\text{ns}.
$$

---

# 🔄 18. Reset System

The reset subsystem ensures that the processor and AXI peripherals start in a known state.

The basic structure is

```text
External Reset
      │
      ▼
Processor System Reset
      │
      ├── MicroBlaze
      ├── AXI Interconnect
      └── Peripherals
```

Reset synchronization is important because different system blocks may operate on clocked logic.

---

# 📡 19. Add UART for Program Output

A useful processor system requires a communication interface.

Add

```text
AXI UARTLite
```

to the design.

The architecture becomes

```text
MicroBlaze
    │
    ▼
AXI SmartConnect
    │
    ▼
AXI UARTLite
    │
    ▼
USB-UART
    │
    ▼
PC Terminal
```

UART can be used to print

```text
Hello MicroBlaze!
```

from software.

---

# 🔗 20. Connect UARTLite

Use

```text
Run Connection Automation
```

to connect UARTLite to the MicroBlaze AXI interface.

Make the UART interface external.

Typical external signals are

```text
uart_rxd
uart_txd
```

Map these signals to the board's USB-UART pins using the correct XDC constraints.

---

# 🗺️ 21. Address Editor

Open

```text
Address Editor
```

and verify that UARTLite receives an address range.

For example, Vivado may assign an address region such as

```text
AXI_UARTLite → 0x4xxx_xxxx
```

The exact address depends on the generated system.

Software should use the addresses and device identifiers generated by the platform rather than manually assuming fixed values.

---

# ✅ 22. Validate the Block Design

Select

```text
Validate Design
```

Vivado checks:

* AXI connections,
* memory interfaces,
* clock inputs,
* reset signals,
* external ports.

The design should validate successfully before continuing.

---

# 📦 23. Generate HDL Wrapper

In the Sources window:

1. Right-click the block design.
2. Select

```text
Create HDL Wrapper
```

3. Select

```text
Let Vivado manage wrapper and auto-update
```

The wrapper becomes the top-level FPGA module.

---

# 🔨 24. Synthesis and Implementation

Run

```text
Run Synthesis
```

then

```text
Run Implementation
```

and finally

```text
Generate Bitstream
```

Vivado maps the MicroBlaze processor into FPGA resources.

---

# 📊 25. FPGA Resource Utilization

After synthesis, inspect the utilization report.

Record:

| FPGA Resource | Utilization |
| ------------- | ----------: |
| LUTs          |             |
| Flip-Flops    |             |
| BRAM          |             |
| DSP Slices    |             |
| I/O           |             |

MicroBlaze typically consumes LUTs, registers, and memory resources, while optional processor features can increase utilization.

---

# 🔍 26. Hierarchy Analysis

Open the elaborated or synthesized design.

The hierarchy should include blocks similar to

```text
microblaze_system_wrapper
          │
          ▼
microblaze_system
          │
          ├── MicroBlaze
          ├── Local Memory
          ├── LMB Controllers
          ├── AXI Interconnect
          ├── UARTLite
          ├── MDM
          ├── Clock Wizard
          └── Reset Module
```

Students should inspect the hierarchy to understand the relationship between processor, memory, bus, and peripherals.

---

# 📤 27. Export Hardware Platform

After generating the bitstream, export the hardware.

The hardware platform normally contains:

* processor configuration,
* memory configuration,
* peripherals,
* addresses,
* hardware bitstream information.

A typical export produces an

```text
.xsa
```

file.

This hardware definition is used by the embedded software development environment.

---

# 💻 28. Create a Software Platform

Open Vitis or the relevant AMD embedded-development environment.

Create a platform project using the exported `.xsa` file.

The software environment generates a **Board Support Package (BSP)** containing:

* peripheral drivers,
* processor definitions,
* memory map information,
* startup code.

---

# 🧠 29. First MicroBlaze Program

The first program can be

```c
#include <stdio.h>

int main()
{
    printf("Hello MicroBlaze!\r\n");

    while (1)
    {
    }

    return 0;
}
```

The program is:

1. compiled,
2. linked,
3. loaded into MicroBlaze memory,
4. executed by the FPGA processor.

The UART terminal should display

```text
Hello MicroBlaze!
```

---

# 🔁 30. Hardware and Software Execution Flow

The complete workflow is

```text
C Program
    │
    ▼
Compiler
    │
    ▼
Executable File
    │
    ▼
MicroBlaze Program Memory
    │
    ▼
Instruction Execution
    │
    ▼
UARTLite
    │
    ▼
PC Terminal
```

This demonstrates that the FPGA is no longer only executing fixed logic.

It is now running software on a processor implemented inside the FPGA.

---

# 🧪 31. Simple Arithmetic Program

Students can test arithmetic operations.

```c
#include <stdio.h>

int main()
{
    int a = 12;
    int b = 5;

    int sum = a + b;
    int product = a * b;

    printf("A = %d\r\n", a);
    printf("B = %d\r\n", b);
    printf("Sum = %d\r\n", sum);
    printf("Product = %d\r\n", product);

    while (1)
    {
    }

    return 0;
}
```

Expected output:

```text
A = 12
B = 5
Sum = 17
Product = 60
```

This demonstrates general-purpose computation on the FPGA processor.

---

# 🔁 32. Loop Processing

MicroBlaze can execute normal C control structures.

```c
#include <stdio.h>

int main()
{
    int i;

    for (i = 0; i < 10; i++)
    {
        printf("Count = %d\r\n", i);
    }

    while (1)
    {
    }

    return 0;
}
```

This highlights the difference between processor-based execution and fixed combinational FPGA circuits.

---

# 🧮 33. Software versus HDL Implementation

Consider the calculation

$$
Y=A+B.
$$

In Verilog:

```verilog
assign Y = A + B;
```

The hardware adder is continuously present.

In C:

```c
Y = A + B;
```

MicroBlaze performs the addition when the corresponding program instruction is executed.

Therefore,

| HDL                  | Processor Software            |
| -------------------- | ----------------------------- |
| Creates hardware     | Creates instructions          |
| Parallel by nature   | Mostly sequential execution   |
| Fixed datapath       | Programmable behavior         |
| Very low latency     | Instruction-dependent latency |
| More hardware effort | Easier control algorithms     |

---

# 🧠 34. Hardware/Software Co-Design

One major advantage of FPGA systems is the ability to combine both approaches.

For example,

```text
                 MicroBlaze
                     │
                     ▼
                  AXI Bus
                     │
          ┌──────────┼──────────┐
          ▼          ▼          ▼
        GPIO       UART      Custom MAC
                                │
                                ▼
                          Hardware Engine
```

MicroBlaze handles:

* control,
* communication,
* configuration,
* decision logic.

Custom FPGA hardware handles:

* high-speed arithmetic,
* signal processing,
* AI acceleration.

Thus,

$$
\boxed{
\text{Software Flexibility}
+
\text{Hardware Acceleration}
}
$$

is a key FPGA design concept.

---

# ⚡ 35. MicroBlaze and Custom Accelerators

Suppose an AI accelerator performs

$$
Y=\sum_iw_ix_i.
$$

Instead of implementing the complete system in software, the architecture can be

```text
MicroBlaze
    │
    ▼
AXI Bus
    │
    ▼
Custom MAC Accelerator
    │
    ▼
Result
```

MicroBlaze sends the data and control commands.

The custom accelerator performs the computationally intensive operation.

This is a common architecture in FPGA-based embedded AI systems.

---

# 🧪 36. Lab Tasks

### Task 1 — Create the Processor System

Add MicroBlaze to a new Vivado block design.

### Task 2 — Run Block Automation

Configure:

* local memory,
* clock,
* reset,
* debug.

### Task 3 — Examine the Architecture

Identify:

* MicroBlaze,
* LMB,
* BRAM,
* MDM,
* clock,
* reset.

### Task 4 — Add UARTLite

Connect AXI UARTLite to the processor.

### Task 5 — Address Assignment

Use the Address Editor to inspect the UART address.

### Task 6 — Validate Design

Run Vivado design validation.

### Task 7 — Generate Bitstream

Synthesize, implement, and generate the bitstream.

### Task 8 — Export Hardware

Export the FPGA hardware platform.

### Task 9 — Create Software Application

Create a C program that displays

```text
Hello MicroBlaze!
```

### Task 10 — Run on FPGA

Download and execute the program on the FPGA board.

---

# 📋 37. Experimental Results

Students should complete the following table.

| Test                  | Expected Result              | Measured Result | Pass/Fail |
| --------------------- | ---------------------------- | --------------- | --------- |
| Bitstream programming | FPGA programmed successfully |                 |           |
| MicroBlaze startup    | Processor starts             |                 |           |
| UART connection       | Terminal connected           |                 |           |
| Hello program         | Message displayed            |                 |           |
| Integer addition      | Correct sum                  |                 |           |
| Multiplication        | Correct product              |                 |           |
| Loop test             | Counter displayed            |                 |           |

---

# 📊 38. Processor Configuration Study

Record the selected MicroBlaze parameters.

| Parameter           | Configuration |
| ------------------- | ------------- |
| Processor Clock     |               |
| Local Memory        |               |
| Instruction Cache   |               |
| Data Cache          |               |
| Debug               |               |
| Interrupt Support   |               |
| Floating-Point Unit |               |
| AXI Interface       |               |

Students should note that changing processor options changes FPGA resource utilization.

---

# 📈 39. Resource Study

Compare a minimal processor with a more feature-rich implementation.

| Configuration               | LUT | FF | BRAM | DSP |
| --------------------------- | --: | -: | ---: | --: |
| Basic MicroBlaze            |     |    |      |     |
| MicroBlaze + UART           |     |    |      |     |
| MicroBlaze + Extra Features |     |    |      |     |

Discuss why additional functionality requires more FPGA resources.

---

# 💬 40. Discussion Points

1. What is a soft-core processor?
2. How does MicroBlaze differ from fixed FPGA logic?
3. What FPGA resources are used to implement MicroBlaze?
4. Why does MicroBlaze require memory?
5. What is the Local Memory Bus?
6. What is the purpose of the MicroBlaze Debug Module?
7. Why is AXI useful in a processor system?
8. What is memory-mapped I/O?
9. Why is a UART useful for processor debugging?
10. What is the purpose of the hardware platform file?
11. What is the difference between Verilog and C in an FPGA system?
12. Why is hardware/software co-design useful?

---

# 🧠 41. Post-Lab Exercises

1. **Increase Local Memory**
   Increase the MicroBlaze memory size and compare BRAM utilization.

2. **Add AXI GPIO**
   Add LEDs and switches to the processor system.

3. **LED Software Control**
   Write a C program to turn LEDs ON and OFF.

4. **Switch Reader**
   Read switch values and display them through UART.

5. **Add AXI Timer**
   Generate periodic events using a timer peripheral.

6. **Interrupt Support**
   Enable MicroBlaze interrupts.

7. **UART Echo**
   Create an application that echoes received UART characters.

8. **Performance Measurement**
   Measure the execution time of a software loop.

9. **Hardware Multiplier**
   Compare software multiplication with a custom FPGA multiplier.

10. **Custom MAC Accelerator**
    Connect the MAC design from a previous laboratory to MicroBlaze through AXI.

---

# 🔬 42. Advanced Exercise — MicroBlaze + GPIO + UART

Extend the architecture to

```text
                    MicroBlaze
                         │
                         ▼
                    AXI Bus
                    /      \
                   /        \
                  ▼          ▼
             AXI GPIO    AXI UARTLite
                │             │
                ▼             ▼
          Switch / LED    PC Terminal
```

Implement the following behavior:

1. read four FPGA switches,
2. copy the value to four LEDs,
3. print the switch value to UART.

For example,

```text
SW = 1010
```

should result in

```text
LED = 1010
```

and the terminal should display

```text
Switch = 10
```

---

# 🚀 43. Advanced Exercise — MicroBlaze-Controlled MAC

Connect a custom MAC accelerator.

The architecture is

```text
              MicroBlaze
                   │
                   ▼
                AXI Bus
                   │
                   ▼
            MAC Accelerator
             │    │    │
             A    B   Control
                   │
                   ▼
                 Result
```

MicroBlaze performs:

1. write input (A),
2. write input (B),
3. start the accelerator,
4. wait for completion,
5. read the MAC result.

This introduces the concept of **processor-accelerator co-design**.

---

# 🤖 44. Extension to AI-FPGA

A more advanced AI-FPGA architecture can be

```text
                       MicroBlaze
                           │
                           ▼
                        AXI Bus
           ┌───────────────┼───────────────┐
           ▼               ▼               ▼
       AXI GPIO        AXI UART       AI Accelerator
                                            │
                                 ┌──────────┼──────────┐
                                 ▼          ▼          ▼
                                MAC        ANN        CNN
```

MicroBlaze manages control and data movement, while custom logic performs neural-network computation.

This architecture supports

$$
\boxed{
\text{Embedded Processor}
+
\text{Programmable Hardware Accelerator}
}
$$

---

# 🧾 45. Expected Learning Outcomes

After completing this laboratory, students will be able to:

* Explain the concept of a soft-core processor.
* Describe the basic MicroBlaze architecture.
* Create a MicroBlaze system in Vivado IP Integrator.
* Configure local memory, clock, reset, and debugging.
* Understand the role of AXI in embedded FPGA systems.
* Add a UART peripheral to a processor system.
* Generate a bitstream for a processor-based FPGA design.
* Export a hardware platform.
* Compile and execute embedded C applications.
* Use UART to observe processor software output.
* Compare software processing with dedicated FPGA hardware.
* Understand hardware/software co-design.
* Prepare for custom accelerator integration.

---

# 📘 46. References

1. AMD Xilinx, *MicroBlaze Processor Reference Guide*.
2. AMD Xilinx, *Vivado Design Suite User Guide: Designing IP Subsystems Using IP Integrator*.
3. AMD Xilinx, *Vitis Unified Software Platform Documentation*.
4. AMD Xilinx, *AXI UARTLite Product Guide*.
5. ARM, *AMBA AXI and ACE Protocol Specification*.
6. M. D. Ciletti, *Advanced Digital Design with the Verilog HDL*, Pearson.
7. S. Brown and Z. Vranesic, *Fundamentals of Digital Logic with Verilog Design*, McGraw-Hill.

---

## 🔑 Key Concept

The central architecture studied in this laboratory is

$$
\boxed{
\text{MicroBlaze}
+
\text{Memory}
+
\text{AXI}
+
\text{Peripherals}
}
$$

The processor execution model is

$$
\boxed{
\text{Fetch}
\rightarrow
\text{Decode}
\rightarrow
\text{Execute}
}
$$

and the FPGA embedded-system model is

$$
\boxed{
\text{Programmable Logic}
+
\text{Soft-Core Processor}
+
\text{Embedded Software}
}
$$

This laboratory provides the foundation for subsequent work involving **AXI GPIO, UART, timers, interrupts, custom AXI IP, DSP accelerators, ANN/CNN accelerators, embedded AI, and FPGA-based cyber-physical systems**.
