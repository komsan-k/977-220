# 🔬 Lab: AI-FPGA — Binary Neural Network (BNN)

## 🧩 1. Objective

* Understand the fundamental architecture of a **Binary Neural Network (BNN)**.
* Understand the difference between a conventional ANN and a BNN.
* Implement binary weights and binary activations on an FPGA.
* Replace conventional multiply-accumulate operations with efficient **XNOR and popcount operations**.
* Design, simulate, and synthesize a BNN inference engine using **Verilog HDL**.
* Evaluate FPGA resource utilization and hardware efficiency.
* Deploy a simple BNN classifier on a **Basys 3 / Nexys A7 FPGA**.

---

## ⚙️ 2. Equipment and Tools

| Tool / Resource                     | Description                                 |
| ----------------------------------- | ------------------------------------------- |
| **Vivado / Quartus / ModelSim**     | HDL synthesis and simulation                |
| **FPGA Board (Basys 3 / Nexys A7)** | Hardware implementation                     |
| **Verilog HDL**                     | BNN hardware design                         |
| **Waveform Viewer**                 | Verification of BNN signals                 |
| **Switches**                        | Binary input features                       |
| **LEDs**                            | Classification output                       |
| **Python**                          | Optional BNN training and weight generation |

---

# 🧠 3. Background Theory

## 3.1 Conventional Artificial Neural Network

A conventional neuron computes

$$
z=\sum_{i=1}^{N}w_i x_i+b
$$

followed by an activation function

$$
y=f(z).
$$

The weights and activations are normally represented using floating-point or fixed-point values.

For example,

$$
w=[0.72,-0.35,0.81,-0.42].
$$

Implementing this operation requires several multipliers and adders.

On an FPGA, these operations may consume:

* DSP slices
* LUTs
* registers
* memory
* routing resources

For large neural networks, multiply-accumulate operations can become computationally expensive.

---

## 3.2 Binary Neural Network

A **Binary Neural Network (BNN)** reduces the numerical precision of neural-network parameters.

The weights are restricted to

$$
w_i\in{-1,+1}.
$$

Binary activations can similarly be represented as

$$
x_i\in{-1,+1}.
$$

Therefore,

$$
z=\sum_{i=1}^{N}w_i x_i.
$$

Instead of performing conventional multiplication, binary multiplication can be implemented using simple digital logic.

---

## 3.3 Binary Encoding

For hardware implementation, the values

$$
-1,\quad +1
$$

can be represented using one bit:

| Mathematical Value | Binary Representation |
| :----------------: | :-------------------: |
|        (-1)        |          `0`          |
|        (+1)        |          `1`          |

Consider

$$
x_i,w_i\in{-1,+1}.
$$

Their multiplication produces

| (x_i) | (w_i) | (x_iw_i) |
| :---: | :---: | :------: |
|  (-1) |  (-1) |   (+1)   |
|  (-1) |  (+1) |   (-1)   |
|  (+1) |  (-1) |   (-1)   |
|  (+1) |  (+1) |   (+1)   |

Using binary encoding, this corresponds exactly to an **XNOR operation**:

|  X  |  W  | XNOR |
| :-: | :-: | :--: |
|  0  |  0  |   1  |
|  0  |  1  |   0  |
|  1  |  0  |   0  |
|  1  |  1  |   1  |

Therefore,

$$
\boxed{\text{Binary multiplication}\rightarrow\text{XNOR}}
$$

This is the key idea behind efficient BNN hardware.

---

# ⚡ 4. XNOR-Popcount Computation

## 4.1 XNOR Operation

Consider a four-element input vector

$$
X=[x_3,x_2,x_1,x_0]
$$

and binary weight vector

$$
W=[w_3,w_2,w_1,w_0].
$$

The FPGA computes

$$
M=X\operatorname{XNOR}W.
$$

For example,

```text
X = 1011
W = 1101
---------
M = 1001
```

The matching bits have output `1`.

---

## 4.2 Popcount

The **population count**, or popcount, counts the number of `1` bits.

For

```text
M = 1001
```

the popcount is

$$
P=2.
$$

For an (N)-input binary neuron,

$$
P=\operatorname{popcount}(X\operatorname{XNOR}W).
$$

The equivalent bipolar dot product is

$$
z=2P-N.
$$

Thus, a BNN neuron can replace

$$
\boxed{
\text{Multiplication + Accumulation}
}
$$

with

$$
\boxed{
\text{XNOR + Popcount}
}
$$

---

# 🧠 5. BNN Neuron Model

The conventional neuron

$$
z=\sum_{i=1}^{N}w_ix_i+b
$$

can be transformed into the binary form

$$
z=2P-N+b
$$

where

$$
P=\operatorname{popcount}
\left(
X\operatorname{XNOR}W
\right).
$$

The activation can then be implemented using a threshold:

$$
y=
\begin{cases}
1,&P\geq T\
0,&P<T
\end{cases}
$$

where (T) is the neuron threshold.

This gives the FPGA data path

```text
Binary Input
     │
     ▼
   XNOR
     │
     ▼
  Popcount
     │
     ▼
 Threshold
     │
     ▼
Binary Output
```

---

# 🏗️ 6. BNN Architecture

In this laboratory, a small BNN classifier is implemented using:

* **Input layer:** 4 binary features
* **Hidden layer:** 4 binary neurons
* **Output layer:** 2 binary neurons
* **Output:** 2-bit classification

The architecture is

```text
 X0 ──┐
 X1 ──┤
 X2 ──┼────► H1 ──┐
 X3 ──┘            │
                   │
 X0 ──┐            ├────► Y0
 X1 ──┼────► H2 ───┤
 X2 ──┤            │
 X3 ──┘            │
                   │
 X0 ──┐            ├────► Y1
 X1 ──┼────► H3 ───┤
 X2 ──┤            │
 X3 ──┘            │
                   │
       ─────► H4 ──┘
```

The computation is

$$
\mathbf{X}
\rightarrow
\text{Binary Hidden Layer}
\rightarrow
\text{Binary Output Layer}
\rightarrow
\text{Class}.
$$

---

# 💻 7. Verilog Implementation

## 7.1 Four-Bit Popcount Module

The first module counts the number of `1` bits in a four-bit vector.

```verilog
module popcount4(
    input  [3:0] data,
    output [2:0] count
);

    assign count =
        data[0] +
        data[1] +
        data[2] +
        data[3];

endmodule
```

The output requires three bits because

$$
0\leq P\leq4.
$$

---

## 7.2 Binary Neuron

A binary neuron performs:

1. XNOR
2. Popcount
3. Threshold comparison

```verilog
module bnn_neuron #(
    parameter [3:0] WEIGHT = 4'b1010,
    parameter [2:0] THRESHOLD = 3'd2
)(
    input  [3:0] x,
    output y
);

    wire [3:0] xnor_result;
    wire [2:0] pop_count;

    assign xnor_result = ~(x ^ WEIGHT);

    popcount4 PC (
        .data(xnor_result),
        .count(pop_count)
    );

    assign y = (pop_count >= THRESHOLD);

endmodule
```

The expression

```verilog
~(x ^ WEIGHT)
```

implements bitwise XNOR.

---

# 🧩 8. BNN Hidden Layer

Four binary neurons are implemented in parallel.

```verilog
module bnn_hidden_layer(
    input  [3:0] x,
    output [3:0] h
);

    bnn_neuron #(
        .WEIGHT(4'b1010),
        .THRESHOLD(3'd2)
    ) N0 (
        .x(x),
        .y(h[0])
    );

    bnn_neuron #(
        .WEIGHT(4'b1100),
        .THRESHOLD(3'd3)
    ) N1 (
        .x(x),
        .y(h[1])
    );

    bnn_neuron #(
        .WEIGHT(4'b0110),
        .THRESHOLD(3'd2)
    ) N2 (
        .x(x),
        .y(h[2])
    );

    bnn_neuron #(
        .WEIGHT(4'b1001),
        .THRESHOLD(3'd3)
    ) N3 (
        .x(x),
        .y(h[3])
    );

endmodule
```

All four neurons operate simultaneously, demonstrating the parallel-processing capability of an FPGA.

---

# 🧮 9. BNN Output Layer

The hidden-layer outputs are used as inputs to two additional binary neurons.

```verilog
module bnn_output_layer(
    input  [3:0] h,
    output [1:0] y
);

    bnn_neuron #(
        .WEIGHT(4'b1101),
        .THRESHOLD(3'd3)
    ) O0 (
        .x(h),
        .y(y[0])
    );

    bnn_neuron #(
        .WEIGHT(4'b1011),
        .THRESHOLD(3'd2)
    ) O1 (
        .x(h),
        .y(y[1])
    );

endmodule
```

The two output bits provide four possible classes:

| Output | Class   |
| :----: | ------- |
|  `00`  | Class 0 |
|  `01`  | Class 1 |
|  `10`  | Class 2 |
|  `11`  | Class 3 |

---

# 🔗 10. Complete BNN Top Module

```verilog
module bnn_top(
    input  [3:0] x,
    output [3:0] hidden,
    output [1:0] class_out
);

    bnn_hidden_layer HL (
        .x(x),
        .h(hidden)
    );

    bnn_output_layer OL (
        .h(hidden),
        .y(class_out)
    );

endmodule
```

The complete FPGA processing architecture becomes

```text
              ┌──────────────────┐
Input ───────►│ Binary Input X   │
              └────────┬─────────┘
                       │
                       ▼
              ┌──────────────────┐
              │ XNOR + Popcount  │
              │  Hidden Layer    │
              └────────┬─────────┘
                       │
                    H[3:0]
                       │
                       ▼
              ┌──────────────────┐
              │ XNOR + Popcount  │
              │  Output Layer    │
              └────────┬─────────┘
                       │
                       ▼
                  Class[1:0]
```

---

# 🧪 11. Testbench

```verilog
`timescale 1ns / 1ps

module tb_bnn;

    reg  [3:0] x;

    wire [3:0] hidden;
    wire [1:0] class_out;

    bnn_top uut (
        .x(x),
        .hidden(hidden),
        .class_out(class_out)
    );

    initial begin

        $display("Input | Hidden | Class");

        x = 4'b0000;
        #10;

        x = 4'b0001;
        #10;

        x = 4'b0011;
        #10;

        x = 4'b0101;
        #10;

        x = 4'b1010;
        #10;

        x = 4'b1100;
        #10;

        x = 4'b1110;
        #10;

        x = 4'b1111;
        #10;

        $finish;

    end

    initial begin

        $monitor(
            "%b | %b | %b",
            x,
            hidden,
            class_out
        );

    end

endmodule
```

---

# 📊 12. Simulation Results

Students should record the simulation results.

| Input (X) | Hidden (H) | Predicted Class |
| :-------: | :--------: | :-------------: |
|   `0000`  |      —     |        —        |
|   `0001`  |      —     |        —        |
|   `0011`  |      —     |        —        |
|   `0101`  |      —     |        —        |
|   `1010`  |      —     |        —        |
|   `1100`  |      —     |        —        |
|   `1110`  |      —     |        —        |
|   `1111`  |      —     |        —        |

Students should compare the waveform results with manual calculations of the XNOR and popcount operations.

---

# 🔍 13. Manual BNN Calculation

Consider one neuron with

```text
Input  X = 1011
Weight W = 1010
```

### Step 1 — XNOR

$$
M=X\operatorname{XNOR}W
$$

giving

```text
X      = 1011
W      = 1010
----------------
XNOR   = 1110
```

### Step 2 — Popcount

$$
P=\operatorname{popcount}(1110)=3.
$$

### Step 3 — Threshold

Suppose

$$
T=2.
$$

Since

$$
3\geq2,
$$

the neuron output is

$$
\boxed{Y=1}.
$$

Thus,

```text
1011
 │
 ▼
XNOR with 1010
 │
 ▼
1110
 │
 ▼
Popcount = 3
 │
 ▼
3 >= 2
 │
 ▼
Y = 1
```

---

# ⚡ 14. FPGA Implementation

## 14.1 Pin Mapping

A simple implementation can use four FPGA switches as BNN inputs.

| Signal         | FPGA Resource | Description          |
| -------------- | ------------- | -------------------- |
| `x[0]`         | SW0           | Input feature 0      |
| `x[1]`         | SW1           | Input feature 1      |
| `x[2]`         | SW2           | Input feature 2      |
| `x[3]`         | SW3           | Input feature 3      |
| `hidden[0]`    | LED4          | Hidden neuron 0      |
| `hidden[1]`    | LED5          | Hidden neuron 1      |
| `hidden[2]`    | LED6          | Hidden neuron 2      |
| `hidden[3]`    | LED7          | Hidden neuron 3      |
| `class_out[0]` | LED0          | Classification bit 0 |
| `class_out[1]` | LED1          | Classification bit 1 |

For the Nexys A7 or Basys 3, students should use the board's appropriate XDC constraint file rather than assuming physical FPGA package-pin numbers.

---

# 🔄 15. BNN Training-to-FPGA Workflow

In a practical BNN system, the model is normally trained offline.

```text
        Training Dataset
               │
               ▼
        Python / PyTorch
               │
               ▼
          BNN Training
               │
               ▼
      Floating-Point Weights
               │
               ▼
           Binarization
               │
       ┌───────┴───────┐
       ▼               ▼
      -1              +1
       │               │
       └───────┬───────┘
               ▼
        Binary Encoding
               │
               ▼
       Verilog Parameters
               │
               ▼
        FPGA BNN Engine
               │
               ▼
          Classification
```

A common weight binarization operation is

$$
W_b=\operatorname{sign}(W)
$$

where

$$
\operatorname{sign}(W)=
\begin{cases}
+1,&W\geq0\
-1,&W<0.
\end{cases}
$$

The FPGA stores only the resulting binary weights.

---

# 🆚 16. ANN versus BNN

| Characteristic      | Conventional ANN        | BNN                           |
| ------------------- | ----------------------- | ----------------------------- |
| Weight              | FP32 / FP16 / INT8 etc. | 1 bit                         |
| Activation          | Multi-bit               | Often 1 bit                   |
| Multiplication      | Multiplier / DSP        | XNOR                          |
| Accumulation        | Arithmetic addition     | Popcount                      |
| Weight memory       | High                    | Very low                      |
| DSP utilization     | Potentially high        | Potentially very low          |
| Parallelism         | Moderate–High           | Very high                     |
| Hardware complexity | Higher                  | Lower                         |
| Accuracy            | Usually higher          | May decrease                  |
| FPGA suitability    | Good                    | Excellent for suitable models |

The central hardware transformation is therefore

$$
\boxed{
\text{MAC}
\rightarrow
\text{XNOR-Popcount}
}
$$

---

# 📦 17. Memory Advantage

Consider a neural network containing

$$
N=1,000,000
$$

weights.

Using 32-bit floating-point weights requires

$$
1,000,000\times32
=================

32,000,000\text{ bits}.
$$

Using binary weights requires only

$$
1,000,000\times1
================

1,000,000\text{ bits}.
$$

The theoretical weight-storage reduction relative to FP32 is therefore

$$
\frac{32,000,000}{1,000,000}=32.
$$

Thus, binary weights can provide approximately

$$
\boxed{32\times}
$$

less raw weight storage than FP32 weights, excluding metadata and implementation overhead.

---

# 🚀 18. Parallel BNN Processing

One major advantage of FPGA implementation is that several binary neurons can operate simultaneously.

```text
                    ┌──► Neuron 1 ──► H1
                    │
                    ├──► Neuron 2 ──► H2
Input Vector ───────┼──► Neuron 3 ──► H3
                    │
                    ├──► Neuron 4 ──► H4
                    │
                    └──► Neuron N ──► HN
```

Each neuron can contain an independent

$$
\text{XNOR}\rightarrow\text{Popcount}\rightarrow\text{Threshold}
$$

data path.

This enables highly parallel BNN inference.

---

# 💬 19. Discussion Points

1. Why can multiplication be replaced by XNOR in a BNN?
2. What is the purpose of the popcount operation?
3. Why are BNNs attractive for FPGA implementation?
4. How much memory can theoretically be saved by converting FP32 weights to binary weights?
5. Does a BNN always provide the same accuracy as a full-precision ANN?
6. How does the threshold affect neuron output?
7. How can a large popcount operation be implemented efficiently?
8. What happens to FPGA resource utilization when more neurons are implemented in parallel?
9. Why might a BNN require fewer DSP slices than a conventional ANN?
10. What is the trade-off between **accuracy, precision, memory, and hardware efficiency**?

---

# 🧠 20. Post-Lab Exercises

1. **Eight-Input Binary Neuron**
   Extend the binary neuron from 4 inputs to 8 inputs.

2. **Popcount8**
   Implement an eight-bit popcount circuit.

3. **Eight-Neuron Hidden Layer**
   Expand the hidden layer from 4 neurons to 8 neurons.

4. **Programmable Threshold**
   Replace the constant threshold with an FPGA switch input.

5. **Weight Memory**
   Store BNN weights in a ROM instead of Verilog parameters.

6. **Pipelined BNN**
   Insert registers between

   ```text
   XNOR → Popcount → Threshold
   ```

   and determine the new maximum clock frequency.

7. **Resource Comparison**
   Implement equivalent ANN and BNN neurons and compare:

   * LUTs
   * flip-flops
   * DSP slices
   * memory
   * maximum clock frequency

8. **Python-to-FPGA BNN**
   Train a BNN using Python and automatically export the learned binary weights to Verilog.

---

# 🔬 21. Advanced Exercise — BNN Image Classifier

Extend the architecture to classify a small binary image.

For example, consider a

$$
4\times4
$$

binary image:

```text
0 1 1 0
1 0 0 1
1 1 1 1
1 0 0 1
```

The image can be flattened into

$$
X=[x_0,x_1,\ldots,x_{15}].
$$

The BNN then computes

$$
P_j=
\operatorname{popcount}
(X\operatorname{XNOR}W_j)
$$

for each output class (j).

The predicted class can be selected using

$$
\hat{C}
=======

\arg\max_j P_j.
$$

This introduces students to the basic architecture used by larger FPGA-based BNN classifiers.

---

# 📋 22. Lab Tasks

### Task 1 — Binary Neuron

Implement and simulate a single

$$
\boxed{\text{XNOR + Popcount + Threshold}}
$$

neuron.

### Task 2 — Hidden Layer

Implement four BNN neurons operating in parallel.

### Task 3 — Complete BNN

Connect the hidden layer to the binary output layer.

### Task 4 — FPGA Deployment

Use FPGA switches as binary features and LEDs to display the classification result.

### Task 5 — Hardware Analysis

Record the synthesis results.

| Metric            | Result |
| ----------------- | -----: |
| LUTs              |        |
| Flip-Flops        |        |
| DSP Slices        |        |
| BRAM              |        |
| Maximum Frequency |        |
| Estimated Power   |        |

### Task 6 — ANN/BNN Comparison

Compare the BNN implementation with the previous conventional ANN implementation.

Discuss the trade-off between

$$
\boxed{
\text{Accuracy}
\leftrightarrow
\text{Hardware Efficiency}
}
$$

---

# 🧾 23. Expected Learning Outcomes

After completing this laboratory, students will be able to:

* Explain the operating principle of a Binary Neural Network.
* Explain binary weight and activation representations.
* Convert binary multiplication into XNOR logic.
* Implement a popcount circuit in Verilog HDL.
* Implement a complete binary neuron.
* Construct multiple parallel BNN neurons on an FPGA.
* Understand how trained BNN weights can be transferred from software to FPGA hardware.
* Analyze FPGA resource utilization.
* Compare conventional ANN and BNN hardware architectures.
* Explain why BNNs are attractive for **edge-AI FPGA accelerators**.

---

# 📘 24. References

1. M. Courbariaux, Y. Bengio, and J.-P. David, “BinaryConnect: Training Deep Neural Networks with Binary Weights During Propagations,” *Advances in Neural Information Processing Systems*, 2015.
2. I. Hubara, M. Courbariaux, D. Soudry, R. El-Yaniv, and Y. Bengio, “Binarized Neural Networks,” *Advances in Neural Information Processing Systems*, 2016.
3. M. Rastegari, V. Ordonez, J. Redmon, and A. Farhadi, “XNOR-Net: ImageNet Classification Using Binary Convolutional Neural Networks,” *European Conference on Computer Vision*, 2016.
4. S. Haykin, *Neural Networks and Learning Machines*, Pearson.
5. M. D. Ciletti, *Advanced Digital Design with the Verilog HDL*, Pearson.
6. AMD Xilinx, *Vivado Design Suite User Guide: Synthesis*.
7. IEEE Std 1364-2005, *IEEE Standard for Verilog Hardware Description Language*.

---

## 🔑 Key Concept

The essential concept of this laboratory is

$$
\boxed{
\text{Binary Input}
\rightarrow
\text{XNOR}
\rightarrow
\text{Popcount}
\rightarrow
\text{Threshold}
\rightarrow
\text{Binary Inference}
}
$$

or, from the AI-FPGA perspective,

$$
\boxed{
\text{Trained BNN}
\rightarrow
\text{Binary Weights}
\rightarrow
\text{FPGA XNOR-Popcount Accelerator}
\rightarrow
\text{Real-Time Edge-AI Inference}
}
$$

This laboratory provides a foundation for subsequent work on **quantized neural networks (QNNs), BNN image classification, binary CNN accelerators, MNIST inference, and FPGA-based edge AI**.
