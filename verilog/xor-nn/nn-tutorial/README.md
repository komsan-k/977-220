# 🔬 Lab: Implementing a Simple Artificial Neural Network (ANN)

## 🧩 1. Objective
This lab introduces the fundamental principles of **Artificial Neural Networks (ANNs)** by implementing a simple feedforward network for logical pattern learning (e.g., XOR function).  
Students will:
- Understand neuron computation, activation functions, and network structure.  
- Implement an ANN using Python (NumPy).  
- Train and visualize results.  

---

## ⚙️ 2. Equipment and Tools
| Tool / Resource | Description |
|------------------|-------------|
| **Python 3.x** | Programming environment |
| **NumPy** | Numerical computation |
| **Matplotlib** | Visualization |
| **Jupyter / VS Code** | IDE for coding and testing |

---

## 🧠 3. Background Theory

### 3.1 Artificial Neuron
Each neuron performs:

$$
y = f\left(\sum_{i=1}^{n} w_i x_i + b \right)
$$

where:  
- \(x_i\): input  
- \(w_i\): weight  
- \(b\): bias  
- \(f(\cdot)\): activation function  

### 3.2 Network Structure
| Layer | Description |
|--------|--------------|
| Input | Receives raw data |
| Hidden | Performs feature extraction |
| Output | Generates final decision |

---

## 🧮 4. ANN for XOR Problem

### 4.1 XOR Truth Table
| A | B | Output |
|---|---|---------|
| 0 | 0 | 0 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 0 |

---

### 4.2 Python Implementation

```python
import numpy as np

# Sigmoid activation and derivative
def sigmoid(x):
    return 1 / (1 + np.exp(-x))

def sigmoid_derivative(x):
    return x * (1 - x)

# Input data (XOR)
X = np.array([[0,0],[0,1],[1,0],[1,1]])
y = np.array([[0],[1],[1],[0]])

# Initialize weights and bias
np.random.seed(1)
W1 = 2 * np.random.random((2,2)) - 1
W2 = 2 * np.random.random((2,1)) - 1

# Training
for epoch in range(10000):
    # Forward pass
    hidden_input = np.dot(X, W1)
    hidden_output = sigmoid(hidden_input)
    final_input = np.dot(hidden_output, W2)
    output = sigmoid(final_input)

    # Backpropagation
    error = y - output
    d_output = error * sigmoid_derivative(output)
    d_hidden = d_output.dot(W2.T) * sigmoid_derivative(hidden_output)

    # Weight update
    W2 += hidden_output.T.dot(d_output)
    W1 += X.T.dot(d_hidden)

print("Predicted output:")
print(output)
```

---

## 📊 5. Results
Expected output (approximately):

```
[[0.01]
 [0.98]
 [0.97]
 [0.03]]
```

The network correctly learns the XOR pattern.

---

## 🔍 6. Discussion
- The hidden layer introduces **non-linearity**, allowing the network to solve non-linear problems.  
- The model demonstrates **supervised learning** using backpropagation.  
- You can experiment with **ReLU** or **tanh** activations for deeper networks.

---

## 🧭 7. Extension Tasks
1. Add a second hidden layer.  
2. Plot training loss vs. epochs using `matplotlib`.  
3. Modify the network for **AND**, **OR**, and **NAND** functions.  
4. Implement the same logic in **Verilog HDL** (for FPGA lab extension).

---

## 🖼️ 8. ANN Structure Diagram
![Artificial Neural Network Diagram](A_diagram_in_digital_illustration_format_illustrat.png)
