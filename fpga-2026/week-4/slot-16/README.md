# 🔬 Lab: AI-FPGA — Convolutional Neural Network (CNN)

## 🧩 1. Objective

* Understand the basic operation of a **Convolutional Neural Network (CNN)**.
* Learn how image pixels are processed by a convolution kernel.
* Implement a small **2D convolution accelerator** using Verilog HDL.
* Understand the roles of **convolution, activation, pooling, and classification**.
* Simulate and verify CNN arithmetic before FPGA deployment.
* Implement a simple CNN inference datapath on a **Basys 3 / Nexys A7 FPGA**.
* Introduce the concept of hardware parallelism for **edge-AI image processing**.

---

## ⚙️ 2. Equipment and Tools

| Tool / Resource                     | Description                                                 |
| ----------------------------------- | ----------------------------------------------------------- |
| **Vivado / Quartus / ModelSim**     | HDL simulation, synthesis, and implementation               |
| **FPGA Board (Basys 3 / Nexys A7)** | Hardware implementation                                     |
| **Verilog HDL**                     | CNN accelerator design                                      |
| **Waveform Viewer**                 | Verification of convolution outputs                         |
| **Switches / ROM**                  | Image or feature-map inputs                                 |
| **LEDs / 7-Segment Display**        | Output visualization                                        |
| **Python**                          | Optional CNN training, preprocessing, and weight generation |

---

# 🧠 3. Background Theory

## 3.1 Convolutional Neural Network

A CNN is a neural-network architecture commonly used for:

* image classification,
* object detection,
* pattern recognition,
* embedded vision,
* edge-AI applications.

Unlike a fully connected ANN, a CNN processes local regions of an image using small filters called **kernels**.

The basic CNN processing flow is

```text
Input Image
    │
    ▼
Convolution
    │
    ▼
Activation
    │
    ▼
Pooling
    │
    ▼
Feature Map
    │
    ▼
Classifier
    │
    ▼
Predicted Class
```

---

## 3.2 Input Image

Consider a grayscale image represented by

$$
X=
\begin{bmatrix}
x_{00} & x_{01} & x_{02} & x_{03}\
x_{10} & x_{11} & x_{12} & x_{13}\
x_{20} & x_{21} & x_{22} & x_{23}\
x_{30} & x_{31} & x_{32} & x_{33}
\end{bmatrix}.
$$

Each pixel can be represented using an 8-bit value:

$$
x_{ij}\in[0,255].
$$

In this introductory laboratory, smaller integer values are used to simplify hardware implementation and manual verification.

---

# 🧮 4. Convolution Operation

## 4.1 2D Kernel

Consider a (3\times3) convolution kernel

$$
K=
\begin{bmatrix}
k_{00} & k_{01} & k_{02}\
k_{10} & k_{11} & k_{12}\
k_{20} & k_{21} & k_{22}
\end{bmatrix}.
$$

The convolution output at one location is

$$
Y(i,j)
======

\sum_{m=0}^{2}
\sum_{n=0}^{2}
X(i+m,j+n)K(m,n).
$$

For a (3\times3) kernel, one output requires nine multiplications and accumulation.

---

## 4.2 Example Edge-Detection Kernel

A simple vertical-edge kernel is

$$
K=
\begin{bmatrix}
-1 & 0 & 1\
-1 & 0 & 1\
-1 & 0 & 1
\end{bmatrix}.
$$

This kernel responds strongly to vertical changes in image intensity.

Another commonly used kernel is

$$
K=
\begin{bmatrix}
1 & 0 & -1\
2 & 0 & -2\
1 & 0 & -1
\end{bmatrix}.
$$

The objective of this laboratory is not image-quality optimization but understanding how convolution is mapped to FPGA hardware.

---

# 🔢 5. Manual Convolution Example

Consider the image window

$$
X=
\begin{bmatrix}
1 & 2 & 3\
1 & 2 & 4\
0 & 1 & 5
\end{bmatrix}
$$

and kernel

$$
K=
\begin{bmatrix}
-1 & 0 & 1\
-1 & 0 & 1\
-1 & 0 & 1
\end{bmatrix}.
$$

Then

$$
Y
=

(1)(-1)+(2)(0)+(3)(1)
$$

$$
+(1)(-1)+(2)(0)+(4)(1)
$$

$$
+(0)(-1)+(1)(0)+(5)(1).
$$

Therefore,

$$
Y=-1+3-1+4+0+5=10.
$$

Thus,

$$
\boxed{Y=10}.
$$

This multiply-accumulate operation is the central arithmetic operation of a CNN.

---

# ⚡ 6. CNN Processing Stages

## 6.1 Convolution

The convolution stage computes

$$
z=\sum_{i=1}^{N}w_ix_i+b.
$$

For a (3\times3) kernel,

$$
N=9.
$$

---

## 6.2 Activation Function

A common activation function is ReLU:

$$
f(z)=\max(0,z).
$$

Therefore,

$$
Y=
\begin{cases}
z,&z>0\
0,&z\leq0.
\end{cases}
$$

In hardware, ReLU can be implemented using a sign comparison.

---

## 6.3 Pooling

Pooling reduces the size of the feature map.

For (2\times2) max pooling,

$$
P=
\max
\left(
x_0,x_1,x_2,x_3
\right).
$$

For example,

$$
\begin{bmatrix}
2 & 7\
3 & 5
\end{bmatrix}
$$

produces

$$
P=7.
$$

---

## 6.4 Classification

After convolution and pooling, the extracted feature can be passed to a classifier.

For this introductory lab, a simple threshold classifier is used:

$$
C=
\begin{cases}
1,&F\geq T\
0,&F<T.
\end{cases}
$$

---

# 🏗️ 7. Simplified CNN Architecture

The laboratory CNN contains:

* (3\times3) image window
* one (3\times3) kernel
* one convolution neuron
* ReLU activation
* optional pooling
* binary classification output

The architecture is

```text
3×3 Image Window
      │
      ▼
9 Parallel Multiplications
      │
      ▼
Adder Tree
      │
      ▼
Add Bias
      │
      ▼
ReLU
      │
      ▼
Feature Value
      │
      ▼
Threshold Classifier
      │
      ▼
Class Output
```

---

# 💻 8. Verilog Implementation

## 8.1 Three-by-Three Convolution Module

```verilog
module conv3x3 (
    input  signed [7:0] x0,
    input  signed [7:0] x1,
    input  signed [7:0] x2,
    input  signed [7:0] x3,
    input  signed [7:0] x4,
    input  signed [7:0] x5,
    input  signed [7:0] x6,
    input  signed [7:0] x7,
    input  signed [7:0] x8,

    output signed [15:0] conv_out
);

    parameter signed [7:0] k0 = -8'sd1;
    parameter signed [7:0] k1 =  8'sd0;
    parameter signed [7:0] k2 =  8'sd1;

    parameter signed [7:0] k3 = -8'sd1;
    parameter signed [7:0] k4 =  8'sd0;
    parameter signed [7:0] k5 =  8'sd1;

    parameter signed [7:0] k6 = -8'sd1;
    parameter signed [7:0] k7 =  8'sd0;
    parameter signed [7:0] k8 =  8'sd1;

    wire signed [15:0] p0;
    wire signed [15:0] p1;
    wire signed [15:0] p2;
    wire signed [15:0] p3;
    wire signed [15:0] p4;
    wire signed [15:0] p5;
    wire signed [15:0] p6;
    wire signed [15:0] p7;
    wire signed [15:0] p8;

    assign p0 = x0 * k0;
    assign p1 = x1 * k1;
    assign p2 = x2 * k2;
    assign p3 = x3 * k3;
    assign p4 = x4 * k4;
    assign p5 = x5 * k5;
    assign p6 = x6 * k6;
    assign p7 = x7 * k7;
    assign p8 = x8 * k8;

    assign conv_out =
        p0 + p1 + p2 +
        p3 + p4 + p5 +
        p6 + p7 + p8;

endmodule
```

---

# 🧠 9. ReLU Activation Module

```verilog
module relu (
    input  signed [15:0] data_in,
    output signed [15:0] data_out
);

    assign data_out =
        (data_in < 0) ? 16'sd0 : data_in;

endmodule
```

The module implements

$$
f(x)=\max(0,x).
$$

---

# 🔎 10. Threshold Classifier

```verilog
module cnn_classifier #(
    parameter signed [15:0] THRESHOLD = 16'sd8
)(
    input  signed [15:0] feature,
    output class_out
);

    assign class_out =
        (feature >= THRESHOLD) ? 1'b1 : 1'b0;

endmodule
```

The output represents two classes:

| Output | Class   |
| :----: | ------- |
|   `0`  | Class 0 |
|   `1`  | Class 1 |

---

# 🔗 11. Complete CNN Top Module

```verilog
module cnn_top (
    input signed [7:0] x0,
    input signed [7:0] x1,
    input signed [7:0] x2,
    input signed [7:0] x3,
    input signed [7:0] x4,
    input signed [7:0] x5,
    input signed [7:0] x6,
    input signed [7:0] x7,
    input signed [7:0] x8,

    output signed [15:0] conv_value,
    output signed [15:0] relu_value,
    output class_out
);

    conv3x3 CONV (
        .x0(x0),
        .x1(x1),
        .x2(x2),
        .x3(x3),
        .x4(x4),
        .x5(x5),
        .x6(x6),
        .x7(x7),
        .x8(x8),
        .conv_out(conv_value)
    );

    relu RELU (
        .data_in(conv_value),
        .data_out(relu_value)
    );

    cnn_classifier CLASSIFIER (
        .feature(relu_value),
        .class_out(class_out)
    );

endmodule
```

---

# 🧪 12. Testbench

```verilog
`timescale 1ns / 1ps

module tb_cnn;

    reg signed [7:0] x0;
    reg signed [7:0] x1;
    reg signed [7:0] x2;
    reg signed [7:0] x3;
    reg signed [7:0] x4;
    reg signed [7:0] x5;
    reg signed [7:0] x6;
    reg signed [7:0] x7;
    reg signed [7:0] x8;

    wire signed [15:0] conv_value;
    wire signed [15:0] relu_value;
    wire class_out;

    cnn_top uut (
        .x0(x0),
        .x1(x1),
        .x2(x2),
        .x3(x3),
        .x4(x4),
        .x5(x5),
        .x6(x6),
        .x7(x7),
        .x8(x8),
        .conv_value(conv_value),
        .relu_value(relu_value),
        .class_out(class_out)
    );

    initial begin

        $display(
            "Conv | ReLU | Class"
        );

        x0 = 1;
        x1 = 2;
        x2 = 3;

        x3 = 1;
        x4 = 2;
        x5 = 4;

        x6 = 0;
        x7 = 1;
        x8 = 5;

        #10;

        $display(
            "%d | %d | %b",
            conv_value,
            relu_value,
            class_out
        );

        #10;
        $finish;

    end

endmodule
```

---

# 📊 13. Expected Simulation Result

For

$$
X=
\begin{bmatrix}
1&2&3\
1&2&4\
0&1&5
\end{bmatrix}
$$

and

$$
K=
\begin{bmatrix}
-1&0&1\
-1&0&1\
-1&0&1
\end{bmatrix},
$$

the convolution result is

$$
Y=10.
$$

The ReLU output is therefore

$$
f(10)=10.
$$

If the classifier threshold is

$$
T=8,
$$

then

$$
10\geq8,
$$

and

$$
\boxed{\text{Class}=1}.
$$

Expected output:

| Convolution | ReLU | Class |
| ----------: | ---: | :---: |
|          10 |   10 |   1   |

---

# 🧮 14. Max-Pooling Module

A simple (2\times2) max-pooling circuit can be implemented as follows.

```verilog
module maxpool2x2 (
    input [7:0] a,
    input [7:0] b,
    input [7:0] c,
    input [7:0] d,
    output [7:0] max_out
);

    wire [7:0] max1;
    wire [7:0] max2;

    assign max1 = (a > b) ? a : b;
    assign max2 = (c > d) ? c : d;

    assign max_out =
        (max1 > max2) ? max1 : max2;

endmodule
```

This module implements

$$
P=\max(a,b,c,d).
$$

---

# 🔄 15. Sliding-Window Convolution

A real CNN processes an entire image rather than one (3\times3) window.

For a (5\times5) image and a (3\times3) kernel with stride (S=1), the output size is

$$
N_{\mathrm{out}}
================

\frac{N_{\mathrm{in}}-K}{S}+1.
$$

Therefore,

$$
N_{\mathrm{out}}
================

# \frac{5-3}{1}+1

3.

$$

The output feature map is therefore

$$
3\times3.
$$

The kernel slides across the image:

```text
Image
┌─────────────────┐
│ [3×3]           │
│                 │
│                 │
└─────────────────┘

        ↓

┌─────────────────┐
│   [3×3]         │
│                 │
│                 │
└─────────────────┘

        ↓

┌─────────────────┐
│       [3×3]     │
│                 │
│                 │
└─────────────────┘
```

---

# 🏗️ 16. FPGA CNN Datapath

A hardware convolution accelerator can be represented as

```text
Pixel Window
    │
    ├──► × K0 ─┐
    ├──► × K1 ─┤
    ├──► × K2 ─┤
    ├──► × K3 ─┤
    ├──► × K4 ─┤
    ├──► × K5 ─┤
    ├──► × K6 ─┤
    ├──► × K7 ─┤
    └──► × K8 ─┘
             │
             ▼
          Adder Tree
             │
             ▼
            ReLU
             │
             ▼
          Feature Map
```

All nine multiplications can theoretically operate in parallel.

This parallelism is one reason FPGAs are effective for CNN inference.

---

# ⚙️ 17. Sequential versus Parallel CNN Hardware

### Sequential Architecture

A single multiplier can be reused:

```text
Pixel
  │
  ▼
Multiplier
  │
  ▼
Accumulator
```

Advantages:

* low hardware utilization,
* fewer DSP slices.

Disadvantages:

* more clock cycles,
* lower throughput.

### Parallel Architecture

Nine multipliers can operate simultaneously:

```text
x0×k0 ─┐
x1×k1 ─┤
x2×k2 ─┤
x3×k3 ─┤
x4×k4 ─┼──► Adder Tree
x5×k5 ─┤
x6×k6 ─┤
x7×k7 ─┤
x8×k8 ─┘
```

Advantages:

* higher throughput,
* lower convolution latency.

Disadvantages:

* more FPGA resources.

---

# 📦 18. Fixed-Point CNN

CNN software often uses floating-point weights.

For example,

$$
K=
\begin{bmatrix}
0.25 & -0.5 & 0.25\
0.5 & 1.0 & -0.5\
0.25 & -0.5 & 0.25
\end{bmatrix}.
$$

For FPGA implementation, the coefficients may be quantized.

Using scale factor

$$
S=16,
$$

the quantized kernel becomes approximately

$$
K_q=
\begin{bmatrix}
4&-8&4\
8&16&-8\
4&-8&4
\end{bmatrix}.
$$

Then

$$
K_q=\operatorname{round}(SK).
$$

The FPGA performs integer arithmetic and later compensates for the scale.

---

# 🧠 19. CNN Training versus FPGA Inference

A practical design separates training from hardware inference.

```text
Image Dataset
     │
     ▼
Python / PyTorch
     │
     ▼
CNN Training
     │
     ▼
Weights and Biases
     │
     ▼
Quantization
     │
     ▼
Export Parameters
     │
     ▼
FPGA CNN Accelerator
     │
     ▼
Real-Time Inference
```

Training normally uses backpropagation:

$$
W^*
===

\arg\min_W
\mathcal{L}(Y,\hat{Y}).
$$

The FPGA then performs only forward inference:

$$
\hat{Y}
=======

F_{\mathrm{CNN}}(X;W^*).
$$

---

# 🆚 20. ANN versus CNN

| Characteristic     | ANN                 | CNN                     |
| ------------------ | ------------------- | ----------------------- |
| Main operation     | Fully connected MAC | Convolution MAC         |
| Input              | Feature vector      | Image / feature map     |
| Weight sharing     | No                  | Yes                     |
| Local connectivity | Limited             | Yes                     |
| Image processing   | Possible            | Highly suitable         |
| Parameters         | Often large         | Reduced through sharing |
| Parallelism        | High                | Very high               |
| FPGA suitability   | Good                | Excellent               |

The main distinction is **weight sharing**.

The same kernel is applied repeatedly across the image.

---

# 🔎 21. CNN Feature Extraction

Different kernels learn different image characteristics.

A CNN may learn:

* vertical edges,
* horizontal edges,
* corners,
* textures,
* shapes,
* object parts.

For example,

### Vertical Edge

$$
\begin{bmatrix}
-1&0&1\
-1&0&1\
-1&0&1
\end{bmatrix}
$$

### Horizontal Edge

$$
\begin{bmatrix}
-1&-1&-1\
0&0&0\
1&1&1
\end{bmatrix}.
$$

Several kernels can operate in parallel to generate multiple feature maps.

---

# 🚀 22. Multi-Filter CNN Accelerator

A more advanced architecture contains multiple convolution filters:

```text
                    ┌──► Kernel 1 ──► Feature Map 1
                    │
Input Image ────────┼──► Kernel 2 ──► Feature Map 2
                    │
                    ├──► Kernel 3 ──► Feature Map 3
                    │
                    └──► Kernel N ──► Feature Map N
```

The filters can operate in parallel on an FPGA.

This produces substantial acceleration for CNN inference.

---

# 📈 23. CNN Performance Metrics

Students should record the following FPGA implementation metrics.

| Metric              | Result |
| ------------------- | -----: |
| LUTs                |        |
| Flip-Flops          |        |
| DSP Slices          |        |
| BRAM                |        |
| Maximum Frequency   |        |
| Estimated Power     |        |
| Convolution Latency |        |
| Throughput          |        |

The convolution throughput can be approximated by

$$
\text{Throughput}
=================

\frac{\text{operations}}
{\text{execution time}}.
$$

---

# ⚡ 24. FPGA Implementation

A simple laboratory demonstration can use switches or ROM to provide the (3\times3) input window.

Because nine 8-bit pixels require many switches, ROM-based input is more practical.

Example architecture:

```text
Image ROM
   │
   ▼
3×3 Pixel Window
   │
   ▼
CNN Convolution
   │
   ▼
ReLU
   │
   ▼
Classifier
   │
   ▼
LED
```

The output LED can indicate:

```text
LED0 = 0 → Class 0

LED0 = 1 → Class 1
```

---

# 🧪 25. Lab Tasks

### Task 1 — Manual Convolution

Calculate the output of a (3\times3) convolution manually.

### Task 2 — Convolution Module

Implement the `conv3x3` module in Verilog.

### Task 3 — ReLU Activation

Implement and verify the ReLU module.

### Task 4 — CNN Classifier

Connect the feature output to a threshold classifier.

### Task 5 — Simulation

Verify the complete CNN using a testbench.

### Task 6 — Max Pooling

Add a (2\times2) max-pooling module.

### Task 7 — FPGA Synthesis

Record FPGA resource utilization.

### Task 8 — Hardware Comparison

Compare:

* sequential convolution,
* parallel convolution.

Discuss the trade-off between

$$
\boxed{
\text{Hardware Resources}
\leftrightarrow
\text{Inference Speed}
}
$$

---

# 💬 26. Discussion Points

1. What is the purpose of convolution in a CNN?
2. Why does a CNN use local connectivity?
3. What is weight sharing?
4. Why is ReLU easy to implement on FPGA?
5. What is the purpose of max pooling?
6. Why can CNNs require many multiply-accumulate operations?
7. How can FPGA DSP slices accelerate CNN computation?
8. What is the difference between sequential and parallel convolution?
9. How does weight quantization affect resource utilization?
10. Why is CNN inference suitable for edge computing?

---

# 🧠 27. Post-Lab Exercises

1. **Horizontal-Edge Kernel**
   Replace the vertical-edge kernel with a horizontal-edge kernel.

2. **Programmable Kernel**
   Store the nine kernel weights in registers or ROM.

3. **Two CNN Filters**
   Implement two kernels operating in parallel.

4. **Pipeline the Convolution**
   Add registers to the multiplier and adder stages.

5. **Five-by-Five Input Image**
   Implement sliding-window convolution over a (5\times5) image.

6. **Max Pooling**
   Add (2\times2) max pooling after convolution.

7. **8-Bit Quantized CNN**
   Implement signed INT8 weights and activations.

8. **4-Bit Quantized CNN**
   Reduce the weight precision and compare FPGA resources.

9. **CNN versus BNN**
   Replace conventional multiplication with binary XNOR-popcount operations.

10. **Multiple Output Classes**
    Extend the classifier from two classes to four classes.

---

# 🔬 28. Advanced Exercise — Small Image Classifier

Implement a simple classifier for binary (4\times4) patterns.

Possible classes include:

* vertical line,
* horizontal line,
* diagonal line,
* square.

The processing flow can be

```text
4×4 Binary Image
      │
      ▼
Convolution Filters
      │
      ▼
ReLU
      │
      ▼
Pooling
      │
      ▼
Feature Vector
      │
      ▼
ANN Classifier
      │
      ▼
Predicted Pattern
```

This combines CNN feature extraction with ANN classification.

---

# 🧠 29. Advanced Exercise — CNN with ROM

Store an image in FPGA ROM.

For example,

```verilog
reg [7:0] image_mem [0:15];
```

The memory can contain a (4\times4) grayscale image.

The controller should:

1. Read pixels from ROM.
2. Generate the convolution window.
3. Apply the CNN kernel.
4. Store the feature-map result.
5. Perform classification.

This introduces students to **memory-based streaming CNN architectures**.

---

# 🚦 30. AI-FPGA CNN Design Flow

The complete AI-FPGA workflow is

```text
Training Dataset
      │
      ▼
CNN Model
      │
      ▼
Software Training
      │
      ▼
Weights
      │
      ▼
Quantization
      │
      ▼
Hardware Mapping
      │
      ▼
Convolution Engine
      │
      ▼
FPGA
      │
      ▼
Real-Time Image Inference
```

The key computational transformation is

$$
\boxed{
\text{CNN Model}
\rightarrow
\text{Parallel MAC Hardware}
}
$$

---

# 🧾 31. Expected Learning Outcomes

After completing this laboratory, students will be able to:

* Explain the basic architecture of a CNN.
* Perform a (2)D convolution manually.
* Explain convolution kernels and feature maps.
* Implement a (3\times3) convolution engine in Verilog.
* Implement ReLU activation in hardware.
* Implement simple max pooling.
* Understand CNN weight sharing.
* Compare sequential and parallel CNN architectures.
* Analyze FPGA resource utilization.
* Explain fixed-point and quantized CNN inference.
* Understand how CNN models are mapped to FPGA hardware.
* Develop a foundation for FPGA-based **computer vision and edge AI**.

---

# 📘 32. References

1. Y. LeCun, Y. Bengio, and G. Hinton, “Deep Learning,” *Nature*, 2015.
2. I. Goodfellow, Y. Bengio, and A. Courville, *Deep Learning*, MIT Press.
3. V. Sze, Y.-H. Chen, T.-J. Yang, and J. S. Emer, “Efficient Processing of Deep Neural Networks: A Tutorial and Survey,” *Proceedings of the IEEE*, 2017.
4. M. D. Ciletti, *Advanced Digital Design with the Verilog HDL*, Pearson.
5. AMD Xilinx, *Vivado Design Suite User Guide: Synthesis*.
6. AMD Xilinx, *7 Series DSP48E1 Slice User Guide*.
7. IEEE Std 1364-2005, *IEEE Standard for Verilog Hardware Description Language*.

---

## 🔑 Key Concept

The essential CNN computation is

$$
\boxed{
\text{Pixel Window}
\rightarrow
\text{Multiply-Accumulate}
\rightarrow
\text{ReLU}
\rightarrow
\text{Pooling}
\rightarrow
\text{Feature Extraction}
}
$$

For FPGA implementation,

$$
\boxed{
\text{CNN}
\rightarrow
\text{Parallel Convolution Engine}
\rightarrow
\text{Quantized Arithmetic}
\rightarrow
\text{Real-Time Edge-AI Inference}
}
$$

This laboratory establishes the foundation for subsequent AI-FPGA work involving **multi-filter CNN accelerators, streaming image pipelines, MNIST classification, quantized CNNs, binary CNNs, systolic arrays, and real-time FPGA computer vision**.
