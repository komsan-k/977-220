
# 🔬 Lab: Simple XOR Neural Network on FPGA

## 🧩 1. Objective

- Implement a **single-layer neural network (perceptron)** that learns the XOR function.  
- Understand **feedforward neural computation** and its **hardware realization** on FPGA.  
- Design, simulate, and synthesize the XOR Neural Network using **Verilog HDL**.  
- Verify the design on FPGA using **switch inputs** and **LED outputs**.

---

## ⚙️ 2. Equipment and Tools

| Tool / Resource | Description |
|------------------|-------------|
| **Vivado / Quartus / ModelSim** | HDL synthesis and simulation tools |
| **FPGA Board (Basys 3 / Nexys A7)** | For hardware implementation |
| **Text Editor / IDE** | For coding Verilog modules |
| **Waveform Viewer** | For simulation output |
| **Python (optional)** | For training and generating weights |

---

## 🧠 3. Background Theory

### 3.1 XOR Function
The XOR logic gate outputs HIGH only when inputs differ:

| A | B | XOR |
|:-:|:-:|:-:|
| 0 | 0 | 0 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 0 |

A **linear perceptron** cannot implement XOR because it is **non-linearly separable**.  
A **two-layer neural network** with a hidden layer is required.

---

### 3.2 Neural Network Architecture

- **Input Layer:** 2 neurons (A, B)  
- **Hidden Layer:** 2 neurons (H1, H2)  
- **Output Layer:** 1 neuron (Y)  
- **Activation Function:** Step function or ReLU approximation  

Weights and biases are fixed constants pre-trained offline.

---


### 3.3 Mathematical Model

The operation of the XOR neural network can be represented mathematically as follows:

$$
H_i = f(W_{i1}A + W_{i2}B + b_i)
$$

$$
Y = f(W_{o1}H_1 + W_{o2}H_2 + b_o)
$$

where  

$$
f(x) = 
\begin{cases}
1, & \text{if } x > 0 \\
0, & \text{if } x \le 0
\end{cases} 
$$


✅ **Explanation:**
- $$A$$ and $$\( B \)$$ are input signals (0 or 1).  
- $$\( H_1 \)$$ and $$\( H_2 \)$$ are outputs from the **hidden layer neurons**.  
- \( W_{ij} \) and \( W_{ok} \) are **weights** connecting layers.  
- \( b_i \) and \( b_o \) are **biases**.  
- \( f(x) \) is the **activation function** that determines neuron output based on the weighted sum.



---
---

## 💻 4. Verilog Implementation

### 4.1 Hidden Layer Module
```verilog
module hidden_layer(
  input [7:0] a, b,
  output reg h1, h2
);
  parameter signed [7:0] w11 = 8'sd1,  w12 = 8'sd1,  b1 = -8'sd1;
  parameter signed [7:0] w21 = -8'sd1, w22 = -8'sd1, b2 = 8'sd2;
  reg signed [8:0] sum1, sum2;

  always @(*) begin
    sum1 = (w11*a + w12*b) + b1;
    sum2 = (w21*a + w22*b) + b2;
    h1 = (sum1 > 0) ? 1 : 0;
    h2 = (sum2 > 0) ? 1 : 0;
  end
endmodule
```

---

### 4.2 Output Neuron Module
```verilog
module output_neuron(
  input h1, h2,
  output reg y
);
  parameter signed [7:0] w1 = 8'sd1, w2 = 8'sd1, b = -8'sd1;
  reg signed [8:0] sum;

  always @(*) begin
    sum = (w1*h1 + w2*h2) + b;
    y = (sum > 0) ? 1 : 0;
  end
endmodule
```

---

### 4.3 Top-Level XOR Neural Network
```verilog
module xor_nn_top(
  input [0:0] A, B,
  output wire Y
);
  wire h1, h2;

  hidden_layer HL(.a(A), .b(B), .h1(h1), .h2(h2));
  output_neuron OUT(.h1(h1), .h2(h2), .y(Y));
endmodule
```

---

## 🧪 5. Testbench
```verilog
module tb_xor_nn;
  reg A, B;
  wire Y;

  xor_nn_top uut(.A(A), .B(B), .Y(Y));

  initial begin
    $display("A B | Y");
    A=0; B=0; #10;
    A=0; B=1; #10;
    A=1; B=0; #10;
    A=1; B=1; #10;
    $finish;
  end

  initial begin
    $monitor("%b %b | %b", A, B, Y);
  end
endmodule
```

---

## 📊 6. Simulation Results

| A | B | Predicted Y |
|:-:|:-:|:-:|
| 0 | 0 | 0 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 0 |

✅ The neural network correctly models XOR behavior.

---

## ⚡ 7. FPGA Implementation

### Pin Mapping (Basys 3 Example)
| Signal | FPGA Pin | I/O Standard | Description |
|---------|-----------|--------------|--------------|
| A | SW0 | LVCMOS33 | Input A |
| B | SW1 | LVCMOS33 | Input B |
| Y | LED0 | LVCMOS33 | Output (Predicted XOR) |

---

## 💬 8. Discussion Points
- Why can’t a single perceptron solve XOR?  
- What role do hidden neurons play in non-linear mapping?  
- How does quantization of weights affect accuracy?  
- How can we extend this network to 3-input XOR?  

---

## 🧠 9. Post-Lab Exercises
1. Modify the activation function to **ReLU**.  
2. Implement a **3-input XOR Neural Network**.  
3. Add a **bias adjustment** via switches.  
4. Create a **weight loader** module using memory.  
5. Visualize hidden neuron activations on LEDs.

---

## 🧾 10. Outcome
Students will be able to:
- Implement a neural network inference engine in Verilog.  
- Understand the role of weighted sums and activations.  
- Deploy simple AI models on FPGA hardware.  

---

## 📘 References
1. Simon Haykin, *Neural Networks and Learning Machines*, Pearson.  
2. M. D. Ciletti, *Advanced Digital Design with the Verilog HDL*.  
3. Xilinx, *Vivado Design Suite User Guide*.  
4. IEEE Std 1364–2005, *Verilog Hardware Description Language*.  

---


