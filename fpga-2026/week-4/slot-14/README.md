# 🔬 Lab: AI-FPGA — ANN for Smart Traffic Control

## 🧩 1. Objective

* Implement a simple **Artificial Neural Network (ANN)** for an FPGA-based smart traffic controller.
* Understand how traffic sensor data can be processed using **neural-network inference**.
* Implement ANN operations using **fixed-point/integer arithmetic in Verilog HDL**.
* Classify traffic conditions into **Low, Medium, and High traffic**.
* Use the ANN output to dynamically select an appropriate **green-light duration**.
* Simulate, synthesize, and deploy the smart traffic controller on an FPGA board such as the **Basys 3 or Nexys A7**.

---

## ⚙️ 2. Equipment and Tools

| Tool / Resource                     | Description                                            |
| ----------------------------------- | ------------------------------------------------------ |
| **Vivado / Quartus / ModelSim**     | HDL design, simulation, synthesis, and implementation  |
| **FPGA Board (Basys 3 / Nexys A7)** | Hardware implementation platform                       |
| **Verilog HDL**                     | ANN inference and traffic-control implementation       |
| **Waveform Viewer**                 | Verification of ANN and controller outputs             |
| **Switches / LEDs**                 | Traffic inputs and classification outputs              |
| **7-Segment Display**               | Optional display for traffic level or green-light time |
| **Python**                          | Optional ANN training and weight generation            |

---

## 🧠 3. Background Theory

### 3.1 Smart Traffic Control

A conventional traffic light normally operates with fixed timing. For example, the green light may remain active for 20 seconds regardless of the actual number of vehicles.

A **smart traffic controller** changes the signal timing according to current traffic conditions.

In this laboratory, two simplified traffic measurements are considered:

* (X_1): number of vehicles waiting on **Road A**
* (X_2): number of vehicles waiting on **Road B**

The ANN processes these inputs and classifies the current traffic condition.

| Traffic Class | Meaning        | Suggested Green Time |
| ------------- | -------------- | -------------------: |
| `00`          | Low traffic    |                 10 s |
| `01`          | Medium traffic |                 20 s |
| `10`          | High traffic   |                 30 s |
| `11`          | Reserved       |                    — |

Thus, the FPGA implements the basic pipeline

[
\text{Traffic Sensors}
\rightarrow
\text{ANN}
\rightarrow
\text{Traffic Classification}
\rightarrow
\text{Signal Timing}.
]

---

### 3.2 ANN Architecture

A simple feedforward ANN is used:

* **Input Layer:** 2 neurons
* **Hidden Layer:** 3 neurons
* **Output Layer:** 2 neurons
* **Activation:** Step function
* **Output:** 2-bit traffic classification

The architecture can be represented as

```text
          Traffic Sensors
               │
        ┌──────┴──────┐
        │             │
       X1            X2
        │             │
        └──────┬──────┘
               │
       ┌───────┼───────┐
       │       │       │
      H1      H2      H3
       │       │       │
       └───────┼───────┘
               │
          ┌────┴────┐
          │         │
         Y1        Y0
          │         │
          └────┬────┘
               │
        Traffic Class
               │
       Traffic Controller
               │
      Red / Yellow / Green
```

---

### 3.3 Mathematical Model

For each hidden neuron,

$$
H_i=f(W_{i1}X_1+W_{i2}X_2+b_i)
$$

where

* (X_1) and (X_2) are traffic inputs,
* (W_{ij}) represents ANN weights,
* (b_i) represents the neuron bias,
* (H_i) represents a hidden-layer output.

For the three hidden neurons,

$$
H_1=f(W_{11}X_1+W_{12}X_2+b_1)
$$

$$
H_2=f(W_{21}X_1+W_{22}X_2+b_2)
$$

$$
H_3=f(W_{31}X_1+W_{32}X_2+b_3).
$$

The output neurons are

$$
Y_0=f(W_{01}H_1+W_{02}H_2+W_{03}H_3+b_0)
$$

and

$$
Y_1=f(W_{11}^{(o)}H_1+W_{12}^{(o)}H_2+W_{13}^{(o)}H_3+b_1^{(o)}).
$$

A simple step activation is

$$
f(x)=
\begin{cases}
1,&x>0\
0,&x\leq0.
\end{cases}
$$

The two output bits form the traffic class

$$
C=(Y_1Y_0)_2.
$$

For example,

$$
C=
\begin{cases}
00,&\text{Low traffic}\
01,&\text{Medium traffic}\
10,&\text{High traffic}.
\end{cases}
$$

---

### 3.4 Fixed-Point ANN on FPGA

Software neural networks commonly use floating-point numbers. FPGA implementations can instead use **integer or fixed-point arithmetic** to reduce hardware complexity.

For example, a trained weight

$$
w=0.75
$$

can be quantized using a scale factor (S=16):

$$
W=\operatorname{round}(16w)=12.
$$

The FPGA then performs integer multiply-accumulate operations:

$$
z=\sum_i W_iX_i+B.
$$

This approach avoids floating-point arithmetic and is suitable for efficient AI inference hardware.

---

## 🚦 4. Simplified Traffic ANN Model

For this introductory laboratory, assume that the ANN has already been trained offline. The FPGA performs **inference only**.

Consider the hidden neurons

$$
H_1=f(X_1+X_2-4)
$$

$$
H_2=f(X_1+X_2-8)
$$

$$
H_3=f(X_1+X_2-12).
$$

These neurons behave as learned traffic-density thresholds.

Therefore:

* (H_1=0): very light traffic
* (H_1=1,H_2=0): low/medium traffic
* (H_2=1,H_3=0): medium/high traffic
* (H_3=1): heavy traffic

For the laboratory implementation, the outputs are encoded into three traffic classes.

---

## 💻 5. Verilog Implementation

### 5.1 Hidden Layer

```verilog
module traffic_hidden_layer(
    input  [3:0] x1,
    input  [3:0] x2,
    output reg h1,
    output reg h2,
    output reg h3
);

    reg [4:0] traffic_sum;

    always @(*) begin
        traffic_sum = x1 + x2;

        h1 = (traffic_sum >= 5)  ? 1'b1 : 1'b0;
        h2 = (traffic_sum >= 9)  ? 1'b1 : 1'b0;
        h3 = (traffic_sum >= 13) ? 1'b1 : 1'b0;
    end

endmodule
```

Here, `x1` and `x2` represent the number or normalized level of vehicles detected on two roads.

---

### 5.2 ANN Output Layer

The hidden-neuron states are converted into the traffic classification.

```verilog
module traffic_output_layer(
    input h1,
    input h2,
    input h3,
    output reg [1:0] traffic_class
);

    always @(*) begin

        if (h3)
            traffic_class = 2'b10;    // High traffic

        else if (h2)
            traffic_class = 2'b10;    // High traffic

        else if (h1)
            traffic_class = 2'b01;    // Medium traffic

        else
            traffic_class = 2'b00;    // Low traffic

    end

endmodule
```

---

### 5.3 ANN Top Module

```verilog
module traffic_ann(
    input  [3:0] x1,
    input  [3:0] x2,
    output [1:0] traffic_class
);

    wire h1;
    wire h2;
    wire h3;

    traffic_hidden_layer HL (
        .x1(x1),
        .x2(x2),
        .h1(h1),
        .h2(h2),
        .h3(h3)
    );

    traffic_output_layer OL (
        .h1(h1),
        .h2(h2),
        .h3(h3),
        .traffic_class(traffic_class)
    );

endmodule
```

---

## 🚥 6. ANN-Based Traffic Timing Controller

The ANN output is now used to determine the green-light duration.

```verilog
module green_time_controller(
    input [1:0] traffic_class,
    output reg [5:0] green_time
);

    always @(*) begin

        case (traffic_class)

            2'b00:
                green_time = 6'd10;   // Low traffic

            2'b01:
                green_time = 6'd20;   // Medium traffic

            2'b10:
                green_time = 6'd30;   // High traffic

            default:
                green_time = 6'd10;

        endcase

    end

endmodule
```

Therefore,

```text
Low Traffic       → Green = 10 s
Medium Traffic    → Green = 20 s
High Traffic      → Green = 30 s
```

---

## 🔗 7. Complete AI-FPGA Top Module

```verilog
module smart_traffic_ai_top(
    input  [3:0] road_a,
    input  [3:0] road_b,

    output [1:0] traffic_class,
    output [5:0] green_time
);

    traffic_ann ANN (
        .x1(road_a),
        .x2(road_b),
        .traffic_class(traffic_class)
    );

    green_time_controller CTRL (
        .traffic_class(traffic_class),
        .green_time(green_time)
    );

endmodule
```

The complete hardware data path is therefore

```text
Road A ──┐
         │
         ├──► ANN ──► Traffic Class ──► Timing Controller
         │                                │
Road B ──┘                                ▼
                                  Green-Light Time
```

---

## 🧪 8. Testbench

```verilog
`timescale 1ns / 1ps

module tb_smart_traffic_ai;

    reg [3:0] road_a;
    reg [3:0] road_b;

    wire [1:0] traffic_class;
    wire [5:0] green_time;

    smart_traffic_ai_top uut (
        .road_a(road_a),
        .road_b(road_b),
        .traffic_class(traffic_class),
        .green_time(green_time)
    );

    initial begin

        $display(
          "Road A | Road B | Class | Green Time"
        );

        road_a = 1;
        road_b = 1;
        #10;

        road_a = 3;
        road_b = 3;
        #10;

        road_a = 5;
        road_b = 5;
        #10;

        road_a = 7;
        road_b = 7;
        #10;

        road_a = 2;
        road_b = 8;
        #10;

        $finish;

    end

    initial begin

        $monitor(
          "%d      %d       %b       %d",
          road_a,
          road_b,
          traffic_class,
          green_time
        );

    end

endmodule
```

---

## 📊 9. Expected Simulation Results

| Road A (X_1) | Road B (X_2) | Total Traffic | ANN Class | Condition | Green Time |
| -----------: | -----------: | ------------: | :-------: | --------- | ---------: |
|            1 |            1 |             2 |    `00`   | Low       |       10 s |
|            3 |            3 |             6 |    `01`   | Medium    |       20 s |
|            5 |            5 |            10 |    `10`   | High      |       30 s |
|            7 |            7 |            14 |    `10`   | High      |       30 s |
|            2 |            8 |            10 |    `10`   | High      |       30 s |

The expected waveform should demonstrate that the ANN classification changes when the traffic inputs cross the learned decision thresholds.

---

## ⚡ 10. FPGA Implementation

### 10.1 Switch and LED Mapping

For a simple FPGA demonstration, eight switches can represent the two traffic measurements.

| Signal             | FPGA Resource | Description                   |
| ------------------ | ------------- | ----------------------------- |
| `road_a[3:0]`      | SW3–SW0       | Road A traffic level          |
| `road_b[3:0]`      | SW7–SW4       | Road B traffic level          |
| `traffic_class[0]` | LED0          | ANN output bit 0              |
| `traffic_class[1]` | LED1          | ANN output bit 1              |
| `green_time`       | 7-Segment     | Optional green-light duration |

For example,

```text
SW3 SW2 SW1 SW0
      │
      └── Road A traffic

SW7 SW6 SW5 SW4
      │
      └── Road B traffic
```

---

### 10.2 Example Operation

Suppose

```text
Road A = 0011 = 3 vehicles
Road B = 0011 = 3 vehicles
```

Then

$$
X_1+X_2=6.
$$

The ANN generates

```text
traffic_class = 01
```

which represents **Medium Traffic**.

Therefore,

```text
green_time = 20 seconds
```

If traffic increases to

```text
Road A = 0111 = 7
Road B = 0110 = 6
```

then

$$
X_1+X_2=13,
$$

and the ANN generates

```text
traffic_class = 10
```

resulting in a **30-second green interval**.

---

## 🔄 11. AI-FPGA Design Flow

The complete development process is

```text
Traffic Dataset
      │
      ▼
ANN Training
   (Python)
      │
      ▼
Weights + Biases
      │
      ▼
Quantization
      │
      ▼
Integer / Fixed-Point Parameters
      │
      ▼
Verilog ANN
      │
      ▼
Simulation
      │
      ▼
Synthesis
      │
      ▼
FPGA
      │
      ▼
Smart Traffic Controller
```

A practical AI-FPGA system therefore separates **training** and **inference**.

### Offline Training

Training can be performed using Python with a traffic dataset:

$$
\mathcal{D}
===========

{(X_1,X_2,C)}.
$$

The training process determines

$$
W^*,b^*
=======

\arg\min_{W,b}
\mathcal{L}(C,\hat{C}).
$$

### FPGA Inference

The learned parameters are transferred to the FPGA.

The FPGA evaluates

$$
\hat{C}
=======

F_{\mathrm{ANN}}(X;W^*,b^*)
$$

in real time.

Therefore, the FPGA does not need to perform computationally expensive ANN training.

---

## 💡 12. Why Use an FPGA for Smart Traffic AI?

An FPGA provides several advantages for edge-AI applications:

* **Parallel computation** — multiple neurons can operate simultaneously.
* **Low latency** — inference is performed directly in hardware.
* **Deterministic timing** — useful for real-time traffic-control systems.
* **Low-power edge processing** — sensor information can be processed locally.
* **Reconfigurability** — the ANN architecture can be modified after deployment.
* **Hardware acceleration** — multiply-accumulate operations can use FPGA DSP resources.

The laboratory therefore introduces the concept of

$$
\boxed{\text{Sensor}+\text{ANN Inference}+\text{FPGA Control}}
$$

as a basic **AI-at-the-edge architecture**.

---

## 💬 13. Discussion Points

1. Why is ANN training normally performed on a computer rather than directly on a small FPGA?
2. What is the difference between **ANN training** and **ANN inference**?
3. Why are integer or fixed-point weights useful in FPGA implementations?
4. How does reducing the number of weight bits affect ANN accuracy?
5. What happens if the traffic conditions are outside the ANN training dataset?
6. How could cameras replace switches as traffic inputs?
7. What advantages does an FPGA have compared with a microcontroller for neural-network inference?
8. How could multiple intersections communicate to form an intelligent traffic network?

---

## 🧠 14. Post-Lab Exercises

1. **Four Traffic Classes**
   Extend the ANN to classify traffic as:

   * Very Low
   * Low
   * Medium
   * High

2. **Three-Road ANN**
   Modify the network to accept

   $$
   X=[X_1,X_2,X_3].
   $$

3. **Real ANN Weights**
   Train a small neural network in Python and replace the manually selected thresholds with trained weights and biases.

4. **Weight Quantization**
   Compare ANN implementations using:

   * 16-bit weights
   * 8-bit weights
   * 4-bit weights

5. **Traffic-Light FSM**
   Integrate the ANN with an FSM containing

   ```text
   RED → GREEN → YELLOW → RED
   ```

6. **7-Segment Display**
   Display the selected green-light duration on the FPGA board.

7. **Resource Analysis**
   Compare the FPGA utilization in terms of:

   * LUTs
   * Flip-flops
   * DSP slices
   * BRAM
   * Maximum clock frequency

8. **Advanced Challenge — Two-Way Adaptive Traffic Control**
   Modify the ANN so that it determines both:

   $$
   \text{Which road receives green?}
   $$

   and

   $$
   \text{How long should it remain green?}
   $$

---

## 📋 15. Lab Tasks

### Task 1 — ANN Simulation

Implement the ANN modules and verify all traffic classes using the testbench.

### Task 2 — FPGA Synthesis

Synthesize the ANN using Vivado and record:

* LUT utilization
* Flip-flop utilization
* DSP utilization
* Maximum operating frequency

### Task 3 — Hardware Testing

Use FPGA switches to generate different traffic conditions and verify the ANN output using LEDs.

### Task 4 — Adaptive Timing

Connect the ANN classification to the green-time controller and verify:

$$
00\rightarrow10~\mathrm{s}
$$

$$
01\rightarrow20~\mathrm{s}
$$

$$
10\rightarrow30~\mathrm{s}.
$$

### Task 5 — Analysis

Compare a **fixed-time traffic controller** with the proposed **ANN-based adaptive controller**.

---

## 🧾 16. Expected Learning Outcomes

After completing this laboratory, students will be able to:

* Explain the architecture of a basic ANN.
* Distinguish between ANN **training** and **inference**.
* Implement neural-network inference using Verilog HDL.
* Apply integer/fixed-point arithmetic to FPGA-based AI.
* Interface ANN outputs with digital control logic.
* Implement a simple adaptive smart traffic controller.
* Analyze FPGA resource utilization for AI hardware.
* Understand the fundamentals of **AI acceleration on FPGA**.

---

## 📘 17. References

1. S. Haykin, *Neural Networks and Learning Machines*, Pearson.
2. M. D. Ciletti, *Advanced Digital Design with the Verilog HDL*, Pearson.
3. AMD Xilinx, *Vivado Design Suite User Guide: Synthesis*.
4. AMD Xilinx, *7 Series DSP48E1 Slice User Guide*.
5. IEEE Std 1364-2005, *IEEE Standard for Verilog Hardware Description Language*.
6. I. Goodfellow, Y. Bengio, and A. Courville, *Deep Learning*, MIT Press.

---

### 🔬 Key Concept

The main concept demonstrated in this laboratory is

$$
\boxed{
\text{Traffic Data}
\rightarrow
\text{Quantized ANN}
\rightarrow
\text{FPGA Inference}
\rightarrow
\text{Adaptive Traffic Control}
}
$$

This provides a foundation for more advanced FPGA-AI laboratories involving **CNN accelerators, TinyML, computer vision, intelligent transportation systems, and real-time edge AI**.
