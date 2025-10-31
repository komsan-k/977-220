# 🔬 Lab 1: Fundamentals of Verilog HDL

## 🧩 1. Objective
This laboratory introduces the **core syntax and structure of Verilog HDL**, enabling students to:
- Understand module-based digital design.
- Write simple gate-level, dataflow, and behavioral models.
- Simulate and verify circuits using testbenches.
- Compare simulation and synthesis perspectives.

---

## ⚙️ 2. Equipment and Tools
| Tool / Resource | Description |
|-----------------|--------------|
| **Vivado / Quartus / ModelSim** | For coding and simulation |
| **Nexys A7 / Basys 3 FPGA Board** | Optional for synthesis |
| **Text Editor or IDE** | VS Code, Vivado Editor, etc. |
| **Computer with HDL Simulator** | Required for waveform observation |

---

## 🧠 3. Background Theory

### 3.1 Verilog HDL Overview
Verilog is a **Hardware Description Language (HDL)** for modeling and simulating digital systems. It supports multiple abstraction levels:
- **Gate-Level Modeling**
- **Dataflow Modeling**
- **Behavioral Modeling**

The basic unit of design is the **module**, which defines inputs, outputs, internal signals, and functionality.

```verilog
module AND_gate(input a, b, output y);
  assign y = a & b;
endmodule
```

---

### 3.2 Modeling Approaches

| Modeling Style | Description | Example |
|----------------|--------------|----------|
| **Gate-level** | Uses logic primitives like `and`, `or`, `not`. | `and (y, a, b);` |
| **Dataflow** | Uses `assign` for continuous logic. | `assign y = a & b;` |
| **Behavioral** | Uses procedural blocks (`always`, `initial`). | `always @(posedge clk) q <= d;` |

---

### 3.3 Simulation Concepts
- **Testbench:** Verifies functionality by applying stimulus.
- **Delay Control (`#`)**: Simulates time behavior.
- **Event Control (`@`)**: Triggers on signal changes.
- **System Tasks:** `$display`, `$monitor`, `$dumpvars`.

Example Testbench:
```verilog
module tb_AND_gate;
  reg a, b;
  wire y;

  AND_gate uut (.a(a), .b(b), .y(y));

  initial begin
    a=0; b=0;
    #10 a=1;
    #10 b=1;
    #10 $finish;
  end
endmodule
```

---

## 🧮 4. Experiment Procedure

### Step 1: Create the Design Module
1. Open your HDL editor.
2. Write the following Verilog module:
```verilog
module AND_gate(input a, b, output y);
  assign y = a & b;
endmodule
```

### Step 2: Create a Testbench
1. Create a new file `tb_AND_gate.v`.
2. Paste the testbench code shown in Section 3.3.
3. Run the simulation in ModelSim or Vivado.

### Step 3: Observe Simulation
- Record outputs for each time step.
- Verify that `y` behaves as logical AND of `a` and `b`.

### Step 4: Extend the Experiment
1. Replace `AND_gate` with an **OR** gate and **XOR** gate design.
2. Add behavioral logic with a clock signal using:
```verilog
always @(posedge clk) count <= count + 1;
```

---

## 📊 5. Observations

| Time (ns) | a | b | y |
|------------|---|---|---|
| 0 | 0 | 0 | 0 |
| 10 | 1 | 0 | 0 |
| 20 | 1 | 1 | 1 |

Record the waveform screenshot and label signal transitions.

---

## 💡 6. Discussion
1. What is the difference between `assign` and procedural assignments (`=` / `<=`)?
2. How does the simulator interpret event control `@(posedge clk)`?
3. Why are `initial` blocks not synthesizable?
4. What is the significance of the “non-blocking” assignment in sequential logic?

---

## 🧠 7. Post-Lab Exercises
1. Design and simulate:
   - A **2-to-1 multiplexer** using dataflow modeling.  
   - A **3-bit counter** using behavioral modeling.
2. Modify your testbench to use `$monitor` and `$dumpfile`.
3. Compare results between simulation and synthesis.
4. Identify non-synthesizable constructs and rewrite them.

---

## 🧾 8. Outcome
After completing this lab, students will be able to:
- Define and instantiate Verilog modules.  
- Use gate-level, dataflow, and behavioral modeling.  
- Develop and execute testbenches.  
- Differentiate between simulation and synthesis constraints.

---

## 📘 9. Reference Materials
- IEEE 1364-2005: *Verilog HDL Standard*  
- Samir Palnitkar, *Verilog HDL: A Guide to Digital Design and Synthesis*, 2nd Ed.  
- Digilent, *Nexys A7 Reference Manual*  
- Xilinx, *Vivado Design Suite User Guide*
