# 🧪 Verilog HDL Lab: XOR with a Two‑Layer Artificial Neural Network

This lab implements a **2–2–1 ANN** with **step activations** in Verilog to realize the XOR logic.

## ✨ Design Idea
- Hidden neuron **H1** approximates **OR**: `H1 = step(A + B − 0.5)`  
- Hidden neuron **H2** approximates **AND**: `H2 = step(A + B − 1.5)`  
- Output neuron: `Y = step( 1·H1 − 2·H2 − 0.5 )`  

All neurons use fixed‑point **Q4.4** scaling (scale = 16).  
Thresholds are encoded as biases: `−0.5 → −8`, `−1.5 → −24`.  
Weights: `1 → +16`, `−2 → −32`.

## 📁 Files
- `activation_step.v` — step activation `y = (x > 0)`  
- `neuron.v` — generic perceptron with 2 inputs (fixed‑point)  
- `xor_ann.v` — top module wiring two hidden neurons + one output neuron  
- `tb_xor_ann.v` — simulation testbench (Icarus/ModelSim)  
- `nexys_a7_xor_ann.xdc` — optional constraint snippet (SW0=A, SW1=B, LED0=Y)

## ▶️ Simulate (Icarus Verilog)
```bash
iverilog -g2012 -o sim.vvp activation_step.v neuron.v xor_ann.v tb_xor_ann.v
vvp sim.vvp
# Expected:
# A B | H1 H2 | Y
# 0 0 |  0  0 | 0
# 0 1 |  1  0 | 1
# 1 0 |  1  0 | 1
# 1 1 |  1  1 | 0
```

## 🛠️ Synthesize on FPGA (Vivado, Nexys A7)
1. Create project, add `activation_step.v`, `neuron.v`, `xor_ann.v`.  
2. Add constraints from `nexys_a7_xor_ann.xdc` (map SW0→A, SW1→B, LED0→Y).  
3. Set `xor_ann` as top and **Generate Bitstream**.  
4. Flip switches and observe LED: `Y = A ⊕ B`.

## 🔍 Notes
- The design is **purely combinational**—no clock needed.  
- To explore pipelining, register each neuron’s sum and output.  
- You can tweak weights/biases to realize other logic (AND/OR/NAND).

---

Made for quick classroom demos of how **ANNs can implement logic** using weighted sums + thresholds.
