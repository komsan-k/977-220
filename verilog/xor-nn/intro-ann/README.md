# 🧠 Introduction to Artificial Neural Networks (ANN)

An **Artificial Neural Network (ANN)** is a computational model inspired by the structure and function of the human brain. 
It is composed of interconnected units called **neurons**, which process information collectively to perform complex tasks such as pattern recognition, prediction, and classification.

---

## 🧩 1. Basic Concept

An ANN mimics the way biological neurons transmit and process signals. Each artificial neuron receives input signals, applies a weight to each input, sums them, adds a bias, and passes the result through an activation function to produce an output.

### Mathematical Representation

$$
y = f\left( \sum_{i=1}^{n} w_i x_i + b \right)
$$

where:  
- $$x_i$$: input values  
- $$w_i$$: connection weights  
- $$b$$: bias term  
- $$f(\cdot)$$: activation function (e.g., sigmoid, ReLU, tanh)  
- $$y$$: neuron output  

---

## 🧠 2. Architecture of ANN

An ANN typically consists of three main layers:

| Layer | Description |
|-------|--------------|
| **Input Layer** | Receives the input features (e.g., pixel values, sensor readings). |
| **Hidden Layer(s)** | Performs intermediate computations; extracts abstract representations. |
| **Output Layer** | Produces the final prediction or decision (e.g., class label, value). |

Each connection between neurons carries a **weight**, which determines the influence of one neuron on another.

---

## ⚙️ 3. Learning Process

ANNs learn through a process called **training**, which adjusts weights and biases to minimize the error between predicted and actual outputs.

### Steps:

1. **Forward Propagation**  
   - Input data passes through the network layer by layer.  
   - The output is computed using the current weights.

2. **Loss Calculation**  
   - The loss function (e.g., Mean Squared Error, Cross-Entropy) measures prediction error.

3. **Backward Propagation (Backpropagation)**  
   - The error is propagated backward to update weights using gradient descent:

$$
w_{new} = w_{old} - \eta \frac{\partial L}{\partial w}
$$

where $$ \eta $$ is the learning rate.

4. **Iteration (Epochs)**  
   - The process repeats over many examples until the model converges (error minimized).

---

## ⚡ 4. Activation Functions

Activation functions introduce non-linearity, enabling the ANN to learn complex relationships.

| Function | Equation | Range | Common Use |
|-----------|-----------|--------|-------------|
| **Sigmoid** | $$ f(x) = \frac{1}{1 + e^{-x}} $$ | (0,1) | Binary classification |
| **ReLU** | $$ f(x) = \max(0,x) $$ | [0,∞) | Deep networks |
| **tanh** | \( f(x) = \tanh(x) \) | (-1,1) | Centered data |
| **Softmax** | \( f_i(x) = \frac{e^{x_i}}{\sum_j e^{x_j}} \) | (0,1) | Multi-class output |

---

## 🧩 5. Example: Simple XOR Neural Network

The XOR (exclusive OR) function cannot be solved by a single-layer perceptron, but can be learned by a two-layer ANN.

### Mathematical Model

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
1, & \text{if } x > 0 \\[4pt]
0, & \text{if } x \le 0
\end{cases}
$$

This small network learns to output 1 only when inputs \( A \) and \( B \) are different.

---

## 🧮 6. Applications of ANNs

| Domain | Example |
|---------|----------|
| **Computer Vision** | Image classification, face detection |
| **Natural Language Processing** | Chatbots, translation, sentiment analysis |
| **IoT & Edge Computing** | Sensor fusion, anomaly detection |
| **Finance** | Credit scoring, stock prediction |
| **Healthcare** | Disease diagnosis, medical imaging |

---

## 📈 7. Advantages and Limitations

### ✅ Advantages
- Can model complex, nonlinear relationships  
- Learns from examples without explicit rules  
- Performs well in large data environments  

### ⚠️ Limitations
- Requires large datasets and high computation  
- Acts as a black box (limited interpretability)  
- Sensitive to overfitting and hyperparameter settings  

---

## 🧭 8. Summary Diagram (Conceptual)

```
Input Layer → Hidden Layer(s) → Output Layer
      ↓            ↓                ↓
   [x1, x2, …] → [Weights + Activation] → [Predicted Output]
```

---
© 2025 Artificial Intelligence Educational Series
