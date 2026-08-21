
# 🧪 Mini Projects: 4-Week FPGA Design Series

| Week       | Mini Project            |
| ---------- | ----------------------- |
| **Week 1** | Traffic Light FSM       |
| **Week 2** | FPGA Calculator         |
| **Week 3** | UART + GPIO System      |
| **Week 4** | FPGA XOR Neural Network |

---

# 🚦 Week 1 Mini Project — Traffic Light FSM

## 1. Objective

* Design a practical **Finite-State Machine (FSM)** using Verilog/SystemVerilog.
* Apply Moore FSM concepts to a traffic-light controller.
* Use clock, reset, state encoding, and state transitions.
* Simulate the controller before FPGA implementation.
* Display RED, YELLOW, and GREEN states using FPGA LEDs.

---

## 2. System Specification

The traffic-light controller contains three primary states:

```text
RED → GREEN → YELLOW → RED
```

The outputs are mapped as follows:

| State  | Red | Yellow | Green |
| ------ | :-: | :----: | :---: |
| RED    |  1  |    0   |   0   |
| GREEN  |  0  |    0   |   1   |
| YELLOW |  0  |    1   |   0   |

---

## 3. State Diagram

```text
       ┌─────────┐
       │   RED   │
       └────┬────┘
            │
            ▼
       ┌─────────┐
       │  GREEN  │
       └────┬────┘
            │
            ▼
       ┌─────────┐
       │ YELLOW  │
       └────┬────┘
            │
            └────────► RED
```

---

## 4. SystemVerilog Design

```systemverilog
module traffic_light_fsm(
    input  logic clk,
    input  logic reset,

    output logic red,
    output logic yellow,
    output logic green
);

    typedef enum logic [1:0] {
        RED    = 2'b00,
        GREEN  = 2'b01,
        YELLOW = 2'b10
    } state_t;

    state_t state, next_state;

    always_ff @(posedge clk) begin
        if (reset)
            state <= RED;
        else
            state <= next_state;
    end

    always_comb begin

        next_state = state;

        case (state)

            RED:
                next_state = GREEN;

            GREEN:
                next_state = YELLOW;

            YELLOW:
                next_state = RED;

            default:
                next_state = RED;

        endcase

    end

    always_comb begin

        red    = 1'b0;
        yellow = 1'b0;
        green  = 1'b0;

        case (state)

            RED:
                red = 1'b1;

            GREEN:
                green = 1'b1;

            YELLOW:
                yellow = 1'b1;

            default:
                red = 1'b1;

        endcase

    end

endmodule
```

---

## 5. Testbench

```systemverilog
`timescale 1ns/1ps

module tb_traffic_light;

    logic clk;
    logic reset;

    logic red;
    logic yellow;
    logic green;

    traffic_light_fsm dut (
        .clk(clk),
        .reset(reset),
        .red(red),
        .yellow(yellow),
        .green(green)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        $dumpfile("dump.vcd");
        $dumpvars(0, tb_traffic_light);

        reset = 1;

        #12;
        reset = 0;

        #80;

        $finish;

    end

endmodule
```

---

## 6. FPGA Mapping

| Signal   | FPGA Resource |
| -------- | ------------- |
| `reset`  | BTN0          |
| `red`    | LED0          |
| `yellow` | LED1          |
| `green`  | LED2          |
| `clk`    | Onboard clock |

For visible FPGA operation, use a slow clock-enable signal so each state remains active long enough to observe.

---

## 7. Mini-Project Tasks

1. Implement the three-state FSM.
2. Create a simulation testbench.
3. Verify the state sequence.
4. Add a clock-enable generator.
5. Program the FPGA.
6. Observe RED, GREEN, and YELLOW LEDs.
7. Extend the FSM with an `ALL_RED` state.
8. Add an optional pedestrian request input.

---

## 8. Expected Outcome

Students should demonstrate

$$
\boxed{
RED
\rightarrow
GREEN
\rightarrow
YELLOW
\rightarrow
RED
}
$$

using both simulation waveforms and FPGA LEDs.

---

# 🧮 Week 2 Mini Project — FPGA Calculator

## 1. Objective

* Design a simple **4-bit FPGA calculator**.
* Apply combinational arithmetic and logic operations.
* Implement an Arithmetic Logic Unit (ALU).
* Use switches for operands and operation selection.
* Display results using LEDs or a 7-segment display.
* Verify arithmetic operations using simulation.

---

## 2. Calculator Functions

The calculator uses

$$
A[3:0]
$$

and

$$
B[3:0]
$$

as operands.

A 2-bit operation selector determines the function.

|  OP  | Operation   | Function    |
| :--: | ----------- | ----------- |
| `00` | Addition    | (A+B)       |
| `01` | Subtraction | (A-B)       |
| `10` | AND         | (A\land B)  |
| `11` | XOR         | (A\oplus B) |

---

## 3. System Architecture

```text
A[3:0] ──────┐
              │
              ▼
           ┌─────┐
B[3:0] ───►│ ALU │────► Result[4:0]
           └──▲──┘
              │
           OP[1:0]
```

---

## 4. SystemVerilog Calculator

```systemverilog
module fpga_calculator(
    input  logic [3:0] A,
    input  logic [3:0] B,
    input  logic [1:0] OP,

    output logic [4:0] RESULT
);

    always_comb begin

        case (OP)

            2'b00:
                RESULT = A + B;

            2'b01:
                RESULT = {1'b0, A - B};

            2'b10:
                RESULT = {1'b0, A & B};

            2'b11:
                RESULT = {1'b0, A ^ B};

            default:
                RESULT = 5'b00000;

        endcase

    end

endmodule
```

---

## 5. Example Operations

|      A |      B |  OP  | Operation | RESULT |
| -----: | -----: | :--: | --------- | -----: |
|      3 |      2 | `00` | (3+2)     |      5 |
|      7 |      3 | `01` | (7-3)     |      4 |
| `1010` | `1100` | `10` | AND       | `1000` |
| `1010` | `1100` | `11` | XOR       | `0110` |

---

## 6. Testbench

```systemverilog
`timescale 1ns/1ps

module tb_fpga_calculator;

    logic [3:0] A;
    logic [3:0] B;
    logic [1:0] OP;

    logic [4:0] RESULT;

    fpga_calculator dut (
        .A(A),
        .B(B),
        .OP(OP),
        .RESULT(RESULT)
    );

    initial begin

        $dumpfile("dump.vcd");
        $dumpvars(0, tb_fpga_calculator);

        A = 4'd3;
        B = 4'd2;

        OP = 2'b00;
        #10;

        OP = 2'b01;
        #10;

        OP = 2'b10;
        #10;

        OP = 2'b11;
        #10;

        A = 4'd7;
        B = 4'd5;

        OP = 2'b00;
        #10;

        $finish;

    end

endmodule
```

---

## 7. FPGA Mapping

| Signal        | FPGA Resource |
| ------------- | ------------- |
| `A[3:0]`      | SW3–SW0       |
| `B[3:0]`      | SW7–SW4       |
| `OP[1:0]`     | SW9–SW8       |
| `RESULT[4:0]` | LED4–LED0     |

---

## 8. Mini-Project Tasks

1. Implement addition.
2. Implement subtraction.
3. Implement AND.
4. Implement XOR.
5. Add a 2-bit operation selector.
6. Create a complete testbench.
7. Synthesize the design.
8. Implement it on FPGA.
9. Add optional OR and comparison functions.
10. Extend the output to a 7-segment display.

---

## 9. Expected Outcome

Students should demonstrate

$$
\boxed{
\text{Switch Inputs}
\rightarrow
\text{FPGA ALU}
\rightarrow
\text{Calculated Result}
}
$$

in real time.

---

# 📡 Week 3 Mini Project — UART + GPIO System

## 1. Objective

* Build an FPGA-based embedded I/O system.
* Understand the roles of **GPIO and UART communication**.
* Read switches as digital inputs.
* Drive LEDs as digital outputs.
* Send or receive serial data through UART.
* Integrate processor-based or custom HDL-based control.

---

## 2. System Architecture

A processor-based implementation may use

```text
               ┌─────────────┐
               │ MicroBlaze  │
               └──────┬──────┘
                      │
                     AXI
             ┌────────┴────────┐
             ▼                 ▼
        AXI GPIO          AXI UARTLite
         │     │                │
         ▼     ▼                ▼
     Switches LEDs          PC Terminal
```

A pure-HDL implementation may alternatively use

```text
Switches
   │
   ▼
GPIO Logic
   │
   ├────► LEDs
   │
   ▼
UART TX
   │
   ▼
PC Terminal
```

---

## 3. Functional Requirements

The system should:

1. Read a 4-bit switch value.
2. Copy the value to four LEDs.
3. Transmit the switch value through UART.
4. Optionally receive UART commands to control LEDs.

For example,

```text
SW = 0101
```

should produce

```text
LED = 0101
```

and a terminal message such as

```text
Switch = 5
```

---

## 4. GPIO Concept

The basic GPIO behavior is

$$
LED=SW.
$$

A simple HDL version is

```systemverilog
module gpio_loopback(
    input  logic [3:0] sw,
    output logic [3:0] led
);

    always_comb begin
        led = sw;
    end

endmodule
```

---

## 5. UART Frame

A typical UART frame uses

```text
Start | D0 D1 D2 D3 D4 D5 D6 D7 | Stop
```

with configuration such as

```text
115200 baud
8 data bits
No parity
1 stop bit
```

or

```text
115200-8-N-1
```

---

## 6. UART Command Example

A possible command interface is:

```text
PC sends '0' → LEDs OFF
PC sends '1' → LED0 ON
PC sends 'A' → All LEDs ON
PC sends 'R' → Read switch value
```

The control path is

```text
PC
 │
 ▼
UART RX
 │
 ▼
Command Logic
 │
 ▼
GPIO
 │
 ▼
LEDs
```

---

## 7. MicroBlaze Software Concept

A processor-based implementation may follow:

```c
while (1)
{
    switches = XGpio_DiscreteRead(&Gpio, 1);

    XGpio_DiscreteWrite(
        &Gpio,
        2,
        switches
    );

    // Send switch value using UARTLite
}
```

The exact driver identifiers should be taken from the generated hardware platform.

---

## 8. Expected Demonstration

The demonstration should show:

```text
Switch Change
     │
     ▼
GPIO Read
     │
     ├────► LED Update
     │
     └────► UART Message
                    │
                    ▼
                PC Terminal
```

---

## 9. Mini-Project Tasks

1. Build a GPIO subsystem.
2. Read four switches.
3. Drive four LEDs.
4. Add UART communication.
5. Transmit a startup message.
6. Send current switch values to the terminal.
7. Implement UART echo.
8. Add one UART command for LED control.
9. Verify the system on hardware.
10. Document the FPGA resource utilization.

---

## 10. Expected Outcome

Students should demonstrate

$$
\boxed{
\text{FPGA GPIO}
+
\text{UART Communication}
=========================

\text{Interactive Embedded System}
}
$$

with both physical I/O and PC communication.

---

# 🧠 Week 4 Mini Project — FPGA XOR Neural Network

## 1. Objective

* Implement a simple **Artificial Neural Network (ANN)** on FPGA.
* Understand why XOR requires a hidden layer.
* Implement weighted sums, biases, and activation functions.
* Use fixed integer weights for hardware-friendly inference.
* Verify the ANN in simulation.
* Use FPGA switches as ANN inputs and an LED as the predicted XOR output.
* Connect digital-logic concepts with AI-FPGA acceleration.

---

## 2. XOR Dataset

The XOR truth table is

|  A  |  B  | Target Y |
| :-: | :-: | :------: |
|  0  |  0  |     0    |
|  0  |  1  |     1    |
|  1  |  0  |     1    |
|  1  |  1  |     0    |

The XOR problem is not linearly separable.

Therefore, a hidden layer is required.

---

## 3. ANN Architecture

Use a

$$
2-2-1
$$

network:

```text
A ─────┬────► H1 ─────┐
       │               │
       │               ├────► Y
       │               │
B ─────┴────► H2 ─────┘
```

The network contains:

* 2 input neurons,
* 2 hidden neurons,
* 1 output neuron.

---

## 4. Mathematical Model

The hidden neurons are

$$
H_1=f(2A+2B-1)
$$

and

$$
H_2=f(-2A-2B+3).
$$

The output is

$$
Y=f(2H_1+2H_2-3).
$$

where

$$
f(x)=
\begin{cases}
1,&x>0\
0,&x\leq0.
\end{cases}
$$

This implementation uses integer-scaled weights to avoid floating-point arithmetic.

---

## 5. Hidden Layer

```systemverilog
module xor_hidden_layer(
    input  logic A,
    input  logic B,

    output logic H1,
    output logic H2
);

    logic signed [4:0] sum1;
    logic signed [4:0] sum2;

    always_comb begin

        sum1 =
            2*$signed({1'b0,A})
            + 2*$signed({1'b0,B})
            - 1;

        sum2 =
            -2*$signed({1'b0,A})
            - 2*$signed({1'b0,B})
            + 3;

        H1 = (sum1 > 0);
        H2 = (sum2 > 0);

    end

endmodule
```

---

## 6. Output Neuron

```systemverilog
module xor_output_neuron(
    input  logic H1,
    input  logic H2,

    output logic Y
);

    logic signed [4:0] sum;

    always_comb begin

        sum =
            2*$signed({1'b0,H1})
            + 2*$signed({1'b0,H2})
            - 3;

        Y = (sum > 0);

    end

endmodule
```

---

## 7. Complete ANN

```systemverilog
module xor_ann_top(
    input  logic A,
    input  logic B,

    output logic H1,
    output logic H2,
    output logic Y
);

    xor_hidden_layer HL (
        .A(A),
        .B(B),
        .H1(H1),
        .H2(H2)
    );

    xor_output_neuron OL (
        .H1(H1),
        .H2(H2),
        .Y(Y)
    );

endmodule
```

---

## 8. Testbench

```systemverilog
`timescale 1ns/1ps

module tb_xor_ann;

    logic A;
    logic B;

    logic H1;
    logic H2;
    logic Y;

    xor_ann_top dut (
        .A(A),
        .B(B),
        .H1(H1),
        .H2(H2),
        .Y(Y)
    );

    initial begin

        $dumpfile("dump.vcd");
        $dumpvars(0, tb_xor_ann);

        A = 0; B = 0; #10;
        A = 0; B = 1; #10;
        A = 1; B = 0; #10;
        A = 1; B = 1; #10;

        $finish;

    end

endmodule
```

---

## 9. Expected Results

|  A  |  B  |  H1 |  H2 |  Y  |
| :-: | :-: | :-: | :-: | :-: |
|  0  |  0  |  0  |  1  |  0  |
|  0  |  1  |  1  |  1  |  1  |
|  1  |  0  |  1  |  1  |  1  |
|  1  |  1  |  1  |  0  |  0  |

Therefore,

$$
\boxed{
Y=A\oplus B
}
$$

---

## 10. FPGA Mapping

| Signal | FPGA Resource |
| ------ | ------------- |
| `A`    | SW0           |
| `B`    | SW1           |
| `Y`    | LED0          |
| `H1`   | LED1          |
| `H2`   | LED2          |

This allows direct observation of the ANN hidden neurons.

---

## 11. Mini-Project Tasks

1. Explain why a single perceptron cannot solve XOR.
2. Implement the hidden layer.
3. Implement the output neuron.
4. Combine the layers.
5. Verify all four XOR patterns.
6. Display the hidden-neuron outputs.
7. Synthesize the ANN.
8. Program the FPGA.
9. Compare the ANN solution with a direct XOR gate.
10. Discuss why XOR is used as an introductory AI-FPGA example.

---

## 12. Expected Outcome

Students should demonstrate

$$
\boxed{
[A,B]
\rightarrow
\text{Hidden Layer}
\rightarrow
\text{Output Neuron}
\rightarrow
\text{XOR Prediction}
}
$$

on the FPGA.

---

# 📊 5. Four-Week Mini-Project Progression

| Week | Mini Project            | Main Concept           | Primary HDL Topic                |
| ---- | ----------------------- | ---------------------- | -------------------------------- |
| 1    | Traffic Light FSM       | Digital control        | Sequential logic / FSM           |
| 2    | FPGA Calculator         | Arithmetic datapath    | Combinational logic / ALU        |
| 3    | UART + GPIO System      | Embedded communication | IP / I/O / processor integration |
| 4    | FPGA XOR Neural Network | AI inference           | ANN / arithmetic hardware        |

The learning progression is therefore

$$
\boxed{
\text{Digital Control}
\rightarrow
\text{Arithmetic}
\rightarrow
\text{Embedded System}
\rightarrow
\text{AI-FPGA}
}
$$

---

# 📋 6. Suggested Mini-Project Deliverables

Each project should include:

1. **System specification**
2. **Block diagram**
3. **Verilog/SystemVerilog source code**
4. **Testbench**
5. **Simulation waveform**
6. **Expected and measured results**
7. **FPGA implementation**
8. **Resource-utilization report**
9. **Discussion**
10. **Short demonstration**

A recommended report structure is:

```text
1. Objective
2. Background
3. System Design
4. HDL Implementation
5. Testbench
6. Simulation Results
7. FPGA Implementation
8. Results and Discussion
9. Conclusion
```

---

# 📊 7. Suggested Evaluation Rubric

| Criterion                |   Marks |
| ------------------------ | ------: |
| Design correctness       |      4 |
| HDL implementation       |      4 |
| Testbench and simulation |      4 |
| FPGA implementation      |      3 |
| Hardware demonstration   |      3 |
| Analysis and discussion  |      2 |
| **Total**                | **20** |

---

# 💬 8. Discussion Questions

1. Which mini project relies most strongly on sequential logic?
2. Which project primarily uses combinational logic?
3. Why does the UART + GPIO project require both hardware and software concepts?
4. Why is the XOR neural network more complex than a simple XOR gate?
5. How does the traffic-light FSM demonstrate state memory?
6. How does the calculator introduce a datapath?
7. How can the UART + GPIO project be extended into an IoT gateway?
8. How can the XOR ANN be extended to a larger AI accelerator?
9. Which project is most resource intensive?
10. How are these four projects related in a complete FPGA system?

---

# 🧠 9. Extension Projects

After completing the four mini projects, students can combine them into larger designs such as:

* **AI-Based Traffic Controller**
* **UART-Controlled Calculator**
* **MicroBlaze + Custom ALU**
* **UART-Controlled ANN**
* **FPGA Smart Traffic System**
* **BNN Accelerator**
* **CNN Accelerator**
* **Sensor-to-AI FPGA Edge System**

For example:

```text
Traffic Sensors
      │
      ▼
GPIO Interface
      │
      ▼
ANN / AI Accelerator
      │
      ▼
Traffic FSM
      │
      ▼
Traffic Lights
      │
      └────► UART Monitoring
```

This integrates all four mini-project concepts.

---

# 🧾 10. Expected Learning Outcomes

After completing the four-week mini-project series, students will be able to:

* Design and implement finite-state machines.
* Create FPGA arithmetic datapaths.
* Develop basic processor/peripheral systems.
* Interface FPGA hardware through GPIO and UART.
* Write and verify HDL using testbenches.
* Simulate and debug digital systems.
* Synthesize and program FPGA hardware.
* Analyze FPGA resource utilization.
* Implement simple ANN inference in hardware.
* Understand the progression from **digital logic to embedded FPGA systems and AI acceleration**.

---

# 📘 References

1. M. M. Mano and M. D. Ciletti, *Digital Design*, Pearson.
2. S. Brown and Z. Vranesic, *Fundamentals of Digital Logic with Verilog Design*, McGraw-Hill.
3. M. D. Ciletti, *Advanced Digital Design with the Verilog HDL*, Pearson.
4. D. M. Harris and S. L. Harris, *Digital Design and Computer Architecture*, Morgan Kaufmann.
5. AMD Xilinx, *Vivado Design Suite User Guide*.
6. AMD Xilinx, *MicroBlaze Processor Reference Guide*.
7. AMD Xilinx, *AXI GPIO Product Guide*.
8. AMD Xilinx, *AXI UARTLite Product Guide*.
9. S. Haykin, *Neural Networks and Learning Machines*, Pearson.
10. IEEE Std 1800, *SystemVerilog—Unified Hardware Design, Specification, and Verification Language*.

---

## 🔑 Key Concept

The four projects form a progressive FPGA learning path:

$$
\boxed{
\text{Week 1: FSM Control}
\rightarrow
\text{Week 2: Datapath}
\rightarrow
\text{Week 3: Embedded I/O}
\rightarrow
\text{Week 4: AI Inference}
}
$$

Together, they introduce the complete concept of

$$
\boxed{
\text{Digital Logic}
+
\text{Control}
+
\text{Communication}
+
\text{Artificial Intelligence}
==============================

\text{Intelligent FPGA System}
}
$$
