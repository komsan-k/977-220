# 🔬 Lab: AI-FPGA — Artificial Neural Network for XOR Function

## 🧩 1. Objective

* Understand why the **XOR function cannot be solved by a single-layer perceptron**.
* Implement a small **two-layer Artificial Neural Network (ANN)** for XOR classification.
* Understand the concepts of **weighted sum, bias, hidden layer, and activation function**.
* Implement ANN inference using **Verilog HDL**.
* Simulate and verify the XOR neural network using a testbench.
* Deploy the ANN on an FPGA using **switches as inputs** and an **LED as the predicted output**.
* Introduce the basic workflow of **AI model training → fixed weights → FPGA inference**.

---

## ⚙️ 2. Equipment and Tools

| Tool / Resource                     | Description                                   |
| ----------------------------------- | --------------------------------------------- |
| **Vivado / Quartus / ModelSim**     | HDL simulation, synthesis, and implementation |
| **FPGA Board (Basys 3 / Nexys A7)** | Hardware implementation platform              |
| **Verilog HDL**                     | ANN inference engine implementation           |
| **Waveform Viewer**                 | Simulation verification                       |
| **FPGA Switches**                   | XOR input signals                             |
| **FPGA LEDs**                       | ANN prediction output                         |
| **Python**                          | Optional ANN training and weight generation   |

---

## 🧠 3. Background Theory

### 3.1 XOR Function

The Exclusive-OR, or XOR, function produces logic `1` when the two binary inputs are different.

|  A  |  B  | XOR |
| :-: | :-: | :-: |
|  0  |  0  |  0  |
|  0  |  1  |  1  |
|  1  |  0  |  1  |
|  1  |  1  |  0  |

Mathematically,

$$
Y=A\oplus B.
$$

The XOR problem is important in neural-network education because it demonstrates the limitation of a single linear classifier.

---

### 3.2 Why a Single Perceptron Cannot Solve XOR

A single perceptron computes

$$
Y=f(W_1A+W_2B+b)
$$

where (W_1) and (W_2) are weights and (b) is the bias.

A single perceptron can only create one linear decision boundary. However, the XOR input classes are not linearly separable.

The samples

$$
(0,0),;(1,1)
$$

belong to Class 0, while

$$
(0,1),;(1,0)
$$

belong to Class 1.

No single straight line can completely separate these two classes.

Therefore,

$$
\boxed{\text{XOR requires a hidden layer}}
$$

for a conventional feedforward neural-network solution.

---

## 🏗️ 4. ANN Architecture

The neural network used in this laboratory contains:

* **Input layer:** 2 neurons
* **Hidden layer:** 2 neurons
* **Output layer:** 1 neuron
* **Activation function:** Step function

The architecture is

```text
       A ─────┬────────► H1 ─────┐
              │                  │
              │                  ├────► Y
              │                  │
       B ─────┴────────► H2 ─────┘
```

or

$$
2\text{-input}
\rightarrow
2\text{-hidden neurons}
\rightarrow
1\text{-output}.
$$

---

## 🧮 5. Mathematical Model

### 5.1 Hidden Layer

The hidden neurons compute

$$
H_1=f(W_{11}A+W_{12}B+b_1)
$$

and

$$
H_2=f(W_{21}A+W_{22}B+b_2).
$$

The activation function is

$$
f(x)=
\begin{cases}
1,&x>0\
0,&x\leq0.
\end{cases}
$$

---

### 5.2 Output Layer

The output neuron computes

$$
Y=f(W_{o1}H_1+W_{o2}H_2+b_o).
$$

Thus, the complete network is

$$
[A,B]
\rightarrow
[H_1,H_2]
\rightarrow
Y.
$$

---

## 🧠 6. Fixed Weights for XOR

One convenient realization of XOR uses the hidden neurons as OR and NAND functions.

Define

$$
H_1=\operatorname{OR}(A,B)
$$

and

$$
H_2=\operatorname{NAND}(A,B).
$$

The output becomes

$$
Y=\operatorname{AND}(H_1,H_2).
$$

This produces

$$
A\oplus B
=========

(A\lor B)\land\neg(A\land B).
$$

A neural realization can use the following weights.

### Hidden Neuron (H_1)

$$
H_1=f(A+B-0.5).
$$

Therefore,

$$
W_{11}=1,\qquad
W_{12}=1,\qquad
b_1=-0.5.
$$

### Hidden Neuron (H_2)

$$
H_2=f(-A-B+1.5).
$$

Therefore,

$$
W_{21}=-1,\qquad
W_{22}=-1,\qquad
b_2=1.5.
$$

### Output Neuron

$$
Y=f(H_1+H_2-1.5).
$$

Therefore,

$$
W_{o1}=1,\qquad
W_{o2}=1,\qquad
b_o=-1.5.
$$

---

## ⚡ 7. Integer Scaling for FPGA

Fractional biases such as

$$
-0.5,\quad1.5
$$

can be inconvenient in basic Verilog implementations.

Multiply all weights and biases by two.

Then,

$$
H_1=f(2A+2B-1)
$$

$$
H_2=f(-2A-2B+3)
$$

and

$$
Y=f(2H_1+2H_2-3).
$$

This transformation maintains the same decision boundaries while using only integer arithmetic.

Therefore, the FPGA ANN can operate without floating-point arithmetic.

---

# 💻 8. Verilog Implementation

## 8.1 Hidden Layer Module

```verilog
module xor_hidden_layer(
    input  wire A,
    input  wire B,
    output reg  H1,
    output reg  H2
);

    reg signed [4:0] sum1;
    reg signed [4:0] sum2;

    always @(*) begin

        // H1 = f(2A + 2B - 1)
        sum1 = 2*$signed({1'b0, A})
             + 2*$signed({1'b0, B})
             - 1;

        // H2 = f(-2A - 2B + 3)
        sum2 = -2*$signed({1'b0, A})
             - 2*$signed({1'b0, B})
             + 3;

        H1 = (sum1 > 0) ? 1'b1 : 1'b0;
        H2 = (sum2 > 0) ? 1'b1 : 1'b0;

    end

endmodule
```

The hidden layer generates two intermediate nonlinear features.

---

## 8.2 Output Neuron Module

```verilog
module xor_output_neuron(
    input  wire H1,
    input  wire H2,
    output reg  Y
);

    reg signed [4:0] sum;

    always @(*) begin

        // Y = f(2H1 + 2H2 - 3)
        sum = 2*$signed({1'b0, H1})
            + 2*$signed({1'b0, H2})
            - 3;

        Y = (sum > 0) ? 1'b1 : 1'b0;

    end

endmodule
```

---

## 8.3 Complete ANN Top Module

```verilog
module xor_ann_top(
    input  wire A,
    input  wire B,
    output wire Y,
    output wire H1,
    output wire H2
);

    xor_hidden_layer hidden (
        .A(A),
        .B(B),
        .H1(H1),
        .H2(H2)
    );

    xor_output_neuron output_layer (
        .H1(H1),
        .H2(H2),
        .Y(Y)
    );

endmodule
```

The complete signal flow is

```text
       A ──────┐
               │
               ▼
          ┌─────────┐
       B ─► Hidden  │
          │ Layer   │
          └────┬────┘
               │
            H1, H2
               │
               ▼
          ┌─────────┐
          │ Output  │
          │ Neuron  │
          └────┬────┘
               │
               ▼
               Y
```

---

# 🧪 9. Testbench

```verilog
`timescale 1ns / 1ps

module tb_xor_ann;

    reg A;
    reg B;

    wire H1;
    wire H2;
    wire Y;

    xor_ann_top uut (
        .A(A),
        .B(B),
        .H1(H1),
        .H2(H2),
        .Y(Y)
    );

    initial begin

        $display("A B | H1 H2 | Y");
        $display("----------------");

        A = 0; B = 0;
        #10;

        A = 0; B = 1;
        #10;

        A = 1; B = 0;
        #10;

        A = 1; B = 1;
        #10;

        $finish;

    end

    initial begin

        $monitor(
            "%b %b |  %b  %b | %b",
            A,
            B,
            H1,
            H2,
            Y
        );

    end

endmodule
```

---

# 📊 10. Expected Simulation Results

The expected behavior is

|  A  |  B  | (H_1) | (H_2) | ANN Output (Y) | XOR |
| :-: | :-: | :---: | :---: | :------------: | :-: |
|  0  |  0  |   0   |   1   |        0       |  0  |
|  0  |  1  |   1   |   1   |        1       |  1  |
|  1  |  0  |   1   |   1   |        1       |  1  |
|  1  |  1  |   1   |   0   |        0       |  0  |

Thus,

$$
\boxed{Y=A\oplus B}.
$$

The ANN correctly reproduces the XOR truth table.

---

# 🔍 11. Manual ANN Calculation

Consider

$$
A=0,\qquad B=1.
$$

### Step 1 — Hidden Neuron (H_1)

$$
z_1=2A+2B-1
$$

$$
z_1=2(0)+2(1)-1=1.
$$

Because

$$
z_1>0,
$$

we obtain

$$
H_1=1.
$$

### Step 2 — Hidden Neuron (H_2)

$$
z_2=-2A-2B+3
$$

$$
z_2=-2(0)-2(1)+3=1.
$$

Therefore,

$$
H_2=1.
$$

### Step 3 — Output Neuron

$$
z_o=2H_1+2H_2-3
$$

$$
z_o=2(1)+2(1)-3=1.
$$

Therefore,

$$
Y=1.
$$

Hence,

$$
\boxed{0\oplus1=1}.
$$

---

# ⚡ 12. FPGA Implementation

## 12.1 Suggested I/O Mapping

For a simple FPGA demonstration:

| Signal | FPGA Resource | Description     |
| ------ | ------------- | --------------- |
| `A`    | SW0           | ANN input A     |
| `B`    | SW1           | ANN input B     |
| `H1`   | LED1          | Hidden neuron 1 |
| `H2`   | LED2          | Hidden neuron 2 |
| `Y`    | LED0          | ANN prediction  |

This allows students to observe not only the final output but also the hidden-neuron activations.

---

## 12.2 Example FPGA Operation

When

```text
SW1 SW0
 B   A

 0   0
```

the output is

```text
LED0 = 0
```

When

```text
SW1 SW0
 B   A

 1   0
```

the output is

```text
LED0 = 1
```

When

```text
SW1 SW0
 B   A

 0   1
```

the output is

```text
LED0 = 1
```

When

```text
SW1 SW0
 B   A

 1   1
```

the output is

```text
LED0 = 0
```

Therefore, LED0 directly displays the neural-network prediction.

---

# 🔄 13. ANN Training and FPGA Inference

In a practical AI-FPGA system, model training and inference are usually separated.

```text
Training Data
     │
     ▼
Python / ML Framework
     │
     ▼
ANN Training
     │
     ▼
Weights + Biases
     │
     ▼
Quantization
     │
     ▼
Verilog Constants / Memory
     │
     ▼
FPGA ANN Inference
     │
     ▼
Prediction
```

For XOR, the training dataset is

$$
\mathcal{D}=
{
(0,0,0),
(0,1,1),
(1,0,1),
(1,1,0)
}.
$$

The software training stage finds weights and biases that minimize a loss function such as

$$
W^*,b^*
=======

\arg\min_{W,b}
\mathcal{L}(Y,\hat{Y}).
$$

The trained values are then transferred to the FPGA.

In this laboratory, the weights are already provided, so the FPGA performs only

$$
\boxed{\text{Inference}}.
$$

---

# 🧮 14. Hardware Interpretation of a Neuron

A neuron can be interpreted as a hardware datapath consisting of

```text
Input
 │
 ▼
Multiply by Weight
 │
 ▼
Adder
 │
 ▼
Add Bias
 │
 ▼
Activation Function
 │
 ▼
Neuron Output
```

Mathematically,

$$
z=\sum_iw_ix_i+b
$$

followed by

$$
y=f(z).
$$

For the XOR ANN, the arithmetic is sufficiently small that it can be implemented primarily with LUT-based combinational logic.

---

# 📦 15. Fixed-Point and Quantized ANN Concept

Large neural networks often use real-valued weights such as

$$
0.25,;-0.81,;1.42.
$$

An FPGA implementation may quantize these values.

For example, using a scale factor

$$
S=16,
$$

a floating-point weight

$$
w=0.75
$$

becomes

$$
W_q=\operatorname{round}(16\times0.75)=12.
$$

The FPGA performs

$$
z_q=\sum_iW_{q,i}X_i+B_q
$$

using integer arithmetic.

This laboratory uses simple integer weights as an introductory example of **quantized neural-network inference**.

---

# 🆚 16. Logic XOR versus ANN XOR

The XOR function can clearly be implemented directly using

```verilog
assign Y = A ^ B;
```

This direct implementation is much simpler than a neural network.

However, the objective of this laboratory is not to replace an XOR gate with an ANN.

Instead, XOR is used because it provides the smallest useful example that demonstrates:

* nonlinear classification,
* hidden neurons,
* weighted sums,
* biases,
* activation functions,
* neural-network inference,
* FPGA implementation of AI computation.

Therefore,

$$
\boxed{
\text{XOR is a teaching model for AI hardware}
}
$$

rather than a practical reason to use a neural network for a two-input logic operation.

---

# 📈 17. ANN Computation Flow

The complete computation can be represented as

```text
                  INPUT LAYER
                 ┌─────┬─────┐
                 │  A  │  B  │
                 └──┬──┴──┬──┘
                    │     │
             ┌──────┘     └──────┐
             ▼                   ▼
        ┌─────────┐          ┌─────────┐
        │Neuron H1│          │Neuron H2│
        │Weighted │          │Weighted │
        │  Sum    │          │  Sum    │
        └────┬────┘          └────┬────┘
             │                   │
             └─────────┬─────────┘
                       ▼
                  ┌──────────┐
                  │ Output   │
                  │ Neuron Y │
                  └────┬─────┘
                       │
                       ▼
                  XOR Prediction
```

---

# 🧪 18. Lab Tasks

### Task 1 — XOR Analysis

Write the XOR truth table and explain why it is not linearly separable.

### Task 2 — Manual ANN Calculation

Calculate (H_1), (H_2), and (Y) manually for all four input combinations.

### Task 3 — Verilog Simulation

Implement:

* hidden-layer module,
* output-neuron module,
* top-level ANN module.

Verify the waveform using the provided testbench.

### Task 4 — FPGA Synthesis

Synthesize the ANN using Vivado or another FPGA development environment.

Record:

| FPGA Metric       | Result |
| ----------------- | -----: |
| LUTs              |        |
| Flip-Flops        |        |
| DSP Slices        |        |
| BRAM              |        |
| Maximum Frequency |        |
| Estimated Power   |        |

### Task 5 — FPGA Deployment

Connect:

$$
A\rightarrow SW0
$$

$$
B\rightarrow SW1
$$

and

$$
Y\rightarrow LED0.
$$

Verify all four XOR combinations.

### Task 6 — Hidden Neuron Observation

Connect (H_1) and (H_2) to additional LEDs and explain the hidden-layer behavior.

---

# 💬 19. Discussion Points

1. Why cannot a single perceptron solve XOR?
2. Why does adding a hidden layer solve the problem?
3. What is the role of the bias in each neuron?
4. What happens if the activation threshold is changed?
5. Why are trained weights normally stored as constants during FPGA inference?
6. What is the difference between training and inference?
7. Why is fixed-point arithmetic attractive for FPGA-based AI?
8. Would using floating-point arithmetic improve this small XOR model?
9. Why is direct XOR logic more efficient than an ANN for this specific problem?
10. Why is XOR nevertheless useful for learning neural-network hardware design?

---

# 🧠 20. Post-Lab Exercises

1. **Change the Activation Function**
   Modify the threshold activation used by the hidden neurons.

2. **Programmable Weights**
   Replace constant weights with FPGA switch inputs.

3. **Weight ROM**
   Store weights and biases in ROM.

4. **Pipelined ANN**
   Add registers between the hidden and output layers.

5. **Three-Input Classification**
   Extend the network to three binary inputs.

6. **Python Training**
   Train a (2)-(2)-(1) XOR ANN using Python and compare the learned weights with the manually designed weights.

7. **Fixed-Point Quantization**
   Train the ANN using floating-point values and quantize the weights to:

   * 8 bits,
   * 4 bits,
   * 2 bits.

8. **ANN versus BNN**
   Compare this ANN implementation with a Binary Neural Network implementation.

9. **Resource Analysis**
   Compare LUT, DSP, and register utilization for different numerical precisions.

10. **7-Segment Output**
    Display the predicted class `0` or `1` on a seven-segment display.

---

# 🚀 21. Advanced Exercise — Train XOR in Python

A simple neural network can be trained offline and its weights exported to the FPGA.

The training process is

```text
XOR Dataset
    │
    ▼
ANN Model
    │
    ▼
Forward Propagation
    │
    ▼
Loss Calculation
    │
    ▼
Backpropagation
    │
    ▼
Weight Update
    │
    ▼
Trained ANN
    │
    ▼
Weight Quantization
    │
    ▼
FPGA
```

Students can investigate whether the trained network produces weights similar to the manually selected XOR solution.

The FPGA remains responsible only for the forward calculation

$$
\hat{Y}=F(X;W,b).
$$

---

# 🔬 22. Extension — Parallel ANN Hardware

The two hidden neurons can operate simultaneously because they receive the same inputs.

```text
                  ┌──► H1 ──┐
A, B ─────────────┤         ├──► Y
                  └──► H2 ──┘
```

This illustrates an important advantage of FPGA-based AI:

$$
\boxed{\text{Parallel Neural Computation}}
$$

Unlike a sequential software processor, independent neurons can be mapped to separate hardware resources and evaluated concurrently.

This concept becomes increasingly important for larger ANN and CNN accelerators.

---

# 🧾 23. Expected Learning Outcomes

After completing this laboratory, students will be able to:

* Explain the XOR classification problem.
* Explain why XOR is not linearly separable.
* Describe the purpose of a neural-network hidden layer.
* Calculate weighted sums and activation outputs.
* Implement a small ANN using Verilog HDL.
* Simulate and verify neural-network inference.
* Deploy ANN logic on an FPGA.
* Distinguish between neural-network training and inference.
* Explain the use of fixed-point arithmetic for FPGA AI.
* Analyze FPGA resources used by a small ANN.
* Understand the foundation of **AI hardware acceleration**.

---

# 📘 24. References

1. S. Haykin, *Neural Networks and Learning Machines*, Pearson.
2. I. Goodfellow, Y. Bengio, and A. Courville, *Deep Learning*, MIT Press.
3. M. D. Ciletti, *Advanced Digital Design with the Verilog HDL*, Pearson.
4. AMD Xilinx, *Vivado Design Suite User Guide: Synthesis*.
5. AMD Xilinx, *7 Series DSP48E1 Slice User Guide*.
6. IEEE Std 1364-2005, *IEEE Standard for Verilog Hardware Description Language*.

---

## 🔑 Key Concept

The main concept demonstrated in this laboratory is

$$
\boxed{
[A,B]
\rightarrow
\text{Weighted Sum}
\rightarrow
\text{Hidden Layer}
\rightarrow
\text{Activation}
\rightarrow
\text{Output Neuron}
\rightarrow
Y
}
$$

For XOR,

$$
\boxed{
\text{Two-Layer ANN}
\rightarrow
\text{Nonlinear Classification}
\rightarrow
\text{FPGA Inference}
}
$$

This laboratory establishes the foundation for subsequent AI-FPGA laboratories involving **multi-neuron ANN accelerators, Binary Neural Networks, Quantized Neural Networks, ANN-based smart controllers, CNN accelerators, and FPGA edge-AI systems**.
