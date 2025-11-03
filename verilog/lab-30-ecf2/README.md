# 🔬 Lab 30: Evolutionary FPGA Ecosystem (ECF²) — Self-Evolving and Self-Reconfiguring Cyber-Physical Intelligence

## 🧩 1. Objective

Students will design and evaluate a self-evolving FPGA swarm that adapts both behavior and architecture through embedded genetic algorithms (GA).  
They will:

- Implement genetic encoding of FPGA parameters (DNA vectors).  
- Simulate mutation, crossover, and selection processes in Verilog.  
- Enable on-chip reconfiguration of logic modules based on fitness.  
- Demonstrate generational improvement of performance (reward, stability, or accuracy).  

---

## ⚙️ 2. Equipment and Tools

| Tool / Resource | Description |
|:----------------|:-------------|
| **FPGA Board (PYNQ-Z2 / Zybo Z7 / Nexys A7)** | Adaptive hardware agent |
| **Vivado / Vitis HLS** | RTL & HLS design |
| **Python + Flask** | Evolution controller & monitoring |
| **MQTT / UART** | Swarm communication |
| **Sensors / Actuators** | Fitness measurement sources |
| **Node-RED / Dashboard** | Evolution visualization |

---

## 🧠 3. Background Theory

### 3.1 Evolutionary Hardware Concept

Each FPGA module contains **genetic material** — configuration bits or parameter sets defining logic behavior.  
Evolution proceeds through:  

- **Mutation:** Random perturbation of configuration bits.  
- **Crossover:** Combining genetic traits from two parent agents.  
- **Selection:** Favoring configurations that achieve higher fitness.  

### 3.2 Genetic Representation

A chromosome encodes hardware parameters as:  

\[ Chromosome = [W_1, W_2, T_1, T_2, L] \]

where:  
- W = weights, T = thresholds, L = logic structure.  

### 3.3 Fitness Function

Fitness is measured by hardware performance metrics such as reward, error, or latency:  

\[ F = \frac{Performance}{Error + Latency} \]

This provides a **quantitative score** for selection and reproduction.  

---

## ⚙️ 4. Verilog Implementation

### 4.1 Chromosome Register
```verilog
module DNA_Register (
  input clk, rst,
  input [31:0] new_gene,
  input update,
  output reg [31:0] gene
);
  always @(posedge clk or posedge rst)
    if (rst) gene <= 32'hABCDEFFF;
    else if (update) gene <= new_gene;
endmodule
```

### 4.2 Mutation Engine
```verilog
module Mutation (
  input clk, rst,
  input [31:0] parent_gene,
  input [7:0] mutation_rate,
  output reg [31:0] mutated_gene
);
  wire [31:0] random_mask = {$random} & 32'h0000FFFF;
  always @(posedge clk or posedge rst)
    if (rst) mutated_gene <= 0;
    else mutated_gene <= parent_gene ^ (random_mask & {32{mutation_rate[0]}});
endmodule
```

### 4.3 Crossover Engine
```verilog
module Crossover (
  input clk, rst,
  input [31:0] geneA, geneB,
  output reg [31:0] child_gene
);
  always @(posedge clk or posedge rst)
    if (rst) child_gene <= 0;
    else child_gene <= {geneA[31:16], geneB[15:0]};
endmodule
```

### 4.4 Fitness Evaluator
```verilog
module Fitness (
  input clk, rst,
  input [7:0] sensor,
  input [31:0] gene,
  output reg [15:0] fitness
);
  always @(posedge clk or posedge rst)
    if (rst) fitness <= 0;
    else fitness <= (sensor * gene[7:0]) >> 4;  // Simplified reward metric
endmodule
```

### 4.5 Evolutionary Controller (Top-Level)
```verilog
module ECF2_Controller (
  input clk, rst,
  input [7:0] sensor,
  output [31:0] next_gene
);
  wire [31:0] parentA, parentB, mutant, child;
  wire [15:0] fitA, fitB;

  DNA_Register dnaA(.clk(clk), .rst(rst), .new_gene(32'hABCDE111), .update(0), .gene(parentA));
  DNA_Register dnaB(.clk(clk), .rst(rst), .new_gene(32'hBCDEA222), .update(0), .gene(parentB));

  Fitness fA(.clk(clk), .rst(rst), .sensor(sensor), .gene(parentA), .fitness(fitA));
  Fitness fB(.clk(clk), .rst(rst), .sensor(sensor), .gene(parentB), .fitness(fitB));

  Crossover cross(.clk(clk), .rst(rst), .geneA(parentA), .geneB(parentB), .child_gene(child));
  Mutation mut(.clk(clk), .rst(rst), .parent_gene(child), .mutation_rate(8'd1), .mutated_gene(next_gene));
endmodule
```

---

## ☁️ 5. Evolution Control (Python)
```python
import random, time, requests

population = [{"gene": random.getrandbits(32), "fitness": 0} for _ in range(6)]

def evaluate(ind):
    return random.uniform(0.8, 1.2) * bin(ind["gene"]).count("1")

for gen in range(10):
    for ind in population:
        ind["fitness"] = evaluate(ind)
    population.sort(key=lambda x: x["fitness"], reverse=True)
    parentA, parentB = population[0], population[1]
    child = (parentA["gene"] & 0xFFFF0000) | (parentB["gene"] & 0x0000FFFF)
    mutation = child ^ random.randint(0, 0xFFFF)
    population[-1]["gene"] = mutation
    print(f"Gen {gen}: Best Fitness = {population[0]['fitness']:.2f}")
    time.sleep(1)
```

---

## 🧮 6. Experiment Procedure

1. Program FPGA with **ECF2_Controller**.  
2. Connect a physical sensor (e.g., LDR, temperature) as fitness input.  
3. Run the Python script to monitor **gene evolution**.  
4. Observe generational improvement in stability, accuracy, or power usage.  
5. Optionally use **partial reconfiguration** to dynamically load evolved modules.  

---

## 📊 7. Observation Table

| Generation | Gene A | Gene B | Child Gene | Fitness | Mutation Rate | Behavior |
|:-------------|:-------------|:-------------|:-------------|:-------------|:-------------|:-------------|
| 1 | 0xABCDE111 | 0xBCDEA222 | 0xABCDA222 | 230 | 1% | Baseline |
| 3 | 0xABCD3333 | 0xBDEF5555 | 0xABEF5555 | 295 | 2% | Evolving |
| 5 | 0xAACF6666 | 0xBAF77777 | 0xAAF77777 | 340 | 3% | Improving |
| 10 | 0xAAFF8888 | 0xBBF99999 | 0xABF99999 | 410 | 1% | Converged |

---

## 💡 8. Discussion Points

- How do **mutation and crossover rates** influence convergence speed?  
- Compare **on-chip evolution** vs **software-based adaptation**.  
- Discuss **partial reconfiguration** as a biological analog of cell mutation.  
- Can **genetic drift** or **overfitting** occur in hardware evolution?  

---

## 🧠 9. Post-Lab Exercises

- Extend to **multi-agent evolution** with inter-FPGA communication.  
- Integrate **digital-twin validation** (from Lab 25) for fitness feedback.  
- Add **blockchain-based genealogy** (Lab 27) for evolutionary tracking.  
- Implement **neural-encoded chromosomes** for neuro-evolution.  
- Use **real-time bitstream mutation** for true adaptive reconfiguration.  

---

## 🧾 10. Outcome

Students will be able to:

- Implement **genetic algorithms** and **self-adaptive evolution** in FPGA logic.  
- Use **sensors** as dynamic fitness evaluators.  
- Observe **real-time generational improvements** in hardware.  
- Understand **CPS 11.0 – Evolving Cyber-Physical Intelligence (ECF²)**.  

---

## 📘 11. References

- Thompson, A., *Hardware Evolution: Darwinian Design of Electronic Circuits*, IEEE 1997.  
- Mittal, S., *Evolutionary FPGA Architectures for Adaptive CPS*, IEEE Access 2025.  
- Xilinx, *UG909 – Partial Reconfiguration User Guide*.  
- Koza, J., *Genetic Programming: On the Programming of Computers by Means of Natural Selection*.  
- Lee & Seshia, *Embedded Systems: A Cyber-Physical Systems Approach*.  

---

✅ **Author:** Dr. Komsan Kanjanasit  
**Publisher:** College of Computing, Prince of Songkla University, Thailand  
**Edition:** 1st Edition (2025)  
**License:** CC BY-NC 4.0  
