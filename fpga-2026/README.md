# FPGA 4-Week Course Plan

## FPGA, Verilog, Vivado, IP Integrator, and AI Haradware 

---

# 📘 Course Overview

This 4-week course introduces:

* Verilog/SystemVerilog design
* FPGA development using Vivado
* Hierarchical and IP-based FPGA systems
* AI acceleration concepts on FPGA

Target platform:

* Nexys A7 FPGA Board

Each week contains:

* 4 time slots (12 hours)
* 3 hours per slot

---

## 📚 Teaching Book
A teaching textbook is available here:

📖 *Komsan Kanjanasit, (2025), Verilog HDL and FPGA: A Practical Approach to Digital and Logic Design*  
🔗 [E-Book](https://github.com/komsan-k/verilog-fpga-ebook)

📖 *AMD Vivado™ In-Depth Tutorials*  
🔗 [Xilinx GitHub](https://github.com/Xilinx/Vivado-Design-Tutorials)

---

# 🗓️ Week 1 — Verilog / SystemVerilog Fundamentals

| Slot   | Topic                                               | Description                                       |
| ------ | --------------------------------------------------- | ------------------------------------------------- |
| Slot 1 | Verilog/SystemVerilog-1: Digital Logic Fundamentals | Logic gates, Boolean algebra, combinational logic |
| Slot 2 | Verilog/SystemVerilog-2: Combinational Design       | Multiplexer, decoder, encoder, adder/subtractor   |
| Slot 3 | Verilog/SystemVerilog-3: Sequential Design          | Flip-flops, registers, counters                   |
| Slot 4 | Verilog/SystemVerilog-4: FSM Design                 | Moore/Mealy FSM, traffic light FSM                |

---

# 🗓️ Week 2 — Vivado FPGA Design Flow

| Slot   | Topic                               | Description                              |
| ------ | ----------------------------------- | ---------------------------------------- |
| Slot 5 | Vivado-1: Simulation & Testbench    | Behavioral simulation using Vivado       |
| Slot 6 | Vivado-2: Hello FPGA                | LED blinking and FPGA programming        |
| Slot 7 | Vivado-3: FPGA Combinational Design | Implement combinational circuits on FPGA |
| Slot 8 | Vivado-4: FPGA FSM Implementation   | Deploy FSM design to Nexys A7            |

---

# 🗓️ Week 3 — Hierarchical FPGA & IP Design

| Slot   | Topic                              | Description                             |
| ------ | ---------------------------------- | --------------------------------------- |
| Slot 9 | Vivado-Hierarchy: Adder Study Case | Hierarchical 4-bit/8-bit adder design   |
| Slot 10 | Vivado-MAC Design                  | Multiply-Accumulate unit implementation |
| Slot 11 | Vivado-IP Core-1                   | AXI GPIO, UARTLite, BRAM                |
| Slot 12 | Vivado-IP Core-2                   | MicroBlaze + IP Integrator system       |

---

# 🗓️ Week 4 — AI on FPGA

| Slot   | Topic                        | Description                           |
| ------ | ---------------------------- | ------------------------------------- |
| Slot 13 | AI-FPGA: ANN (XOR Function)  | Simple neural network implementation  |
| Slot 14 | AI-FPGA: ANN (Smart Traffic) | FPGA-based smart traffic ANN          |
| Slot 15 | AI-FPGA: BNN                 | Binary Neural Network basics          |
| Slot 16 | AI-FPGA: CNN                 | Intro to CNN accelerator architecture |

---

# 🔁 Educational Flow

```text id="4tyqvy"
Week 1:
Digital Logic → Sequential Logic → FSM

Week 2:
Simulation → FPGA Implementation

Week 3:
Hierarchy → MAC → IP Integration

Week 4:
ANN → BNN → CNN
```

---

# 🎯 Suggested Mini Projects

| Week   | Mini Project            |
| ------ | ----------------------- |
| Week 1 | Traffic Light FSM       |
| Week 2 | FPGA Calculator         |
| Week 3 | UART + GPIO System      |
| Week 4 | FPGA XOR Neural Network |
| Week 5 | Mini Project |

---

# 📘 Recommended Hardware

| Hardware            | Purpose              |
| ------------------- | -------------------- |
| Nexys A7 FPGA Board | Main FPGA platform   |
| USB-UART            | Serial communication |
| LEDs / Switches     | FPGA I/O experiments |

---

# 💻 Recommended Software

| Software            | Purpose                         |
| ------------------- | ------------------------------- |
| Vivado Design Suite | FPGA synthesis & implementation |
| Vitis IDE           | Embedded software development   |
| ModelSim            | Optional HDL simulation         |

---

# 📚 Learning Outcomes

Students will be able to:

* Understand FPGA haradware
* Design digital systems using Verilog/SystemVerilog
* Simulate FPGA circuits
* Implement FPGA systems on Nexys A7
* Build hierarchical FPGA architectures
* Use Vivado IP Integrator
* Understand basic AI acceleration concepts on FPGA

---

# 🚀 Advanced Extensions

After completing this course, students can continue to:

* TinyML FPGA accelerators
* DSP architectures
* FFT processors
* CNN accelerators
* AXI DMA systems
* CPS FPGA gateways
* Digital Twin FPGA systems

---

# 📘 Conclusion

This course provides a practical introduction to FPGA system design using Verilog, Vivado, and AI-based FPGA concepts. Students progressively learn from basic digital logic to intelligent FPGA architectures suitable for modern embedded and CPS applications.

---
# 📊 Course Evaluation (100 Marks)

| Component | Marks |
|-----------|------:|
| Week 1 Assessment | 20 |
| Week 2 Assessment | 20 |
| Week 3 Assessment | 20 |
| Week 4 Assessment | 20 |
| Mini Project | 20 |
| **Total** | **100** |

---

## 🗓️ Week 1: Verilog/SystemVerilog Fundamentals (20 Marks)

| Assessment Item | Marks |
|-----------------|------:|
| Quiz (Digital Logic & Verilog Fundamentals) | 5 |
| Laboratory Completion (Combinational, Sequential & FSM Labs) | 8 |
| HDL Coding Style & Documentation | 3 |
| FPGA Demonstration & Oral Explanation | 4 |
| **Total** | **20** |

---

## 🗓️ Week 2: Vivado FPGA Design Flow (20 Marks)

| Assessment Item | Marks |
|-----------------|------:|
| Quiz (Vivado Design Flow & Simulation) | 5 |
| Laboratory Completion (Simulation & FPGA Implementation) | 8 |
| FPGA Implementation & Debugging | 3 |
| Live Demonstration | 4 |
| **Total** | **20** |

---

## 🗓️ Week 3: Hierarchical FPGA & IP Design (20 Marks)

| Assessment Item | Marks |
|-----------------|------:|
| Quiz (Hierarchy, MAC & IP Integrator) | 5 |
| Laboratory Completion (Adder, MAC & IP Labs) | 8 |
| System Integration & Design Quality | 3 |
| Demonstration & Technical Discussion | 4 |
| **Total** | **20** |

---

## 🗓️ Week 4: AI on FPGA (20 Marks)

| Assessment Item | Marks |
|-----------------|------:|
| Quiz (ANN, BNN & CNN Fundamentals) | 5 |
| Laboratory Completion (AI-FPGA Labs) | 8 |
| AI Hardware Design & Optimization | 3 |
| Final Demonstration | 4 |
| **Total** | **20** |

---

# 🎯 Mini Project (20 Marks)

Students complete **one FPGA-based project** individually or in teams (maximum **3 students**).

## Evaluation Rubric

| Criteria | Marks |
|----------|------:|
| System Design & Innovation | 4 |
| Verilog/SystemVerilog Design Quality | 4 |
| FPGA Implementation & Functionality | 4 |
| Hardware Integration & Verification | 3 |
| Demonstration & Technical Presentation | 3 |
| Report & Documentation | 2 |
| **Total** | **20** |

---

# 📈 Grade Scale

| Grade | Score |
|-------|------:|
| A | 80–100 |
| B+ | 75–79 |
| B | 70–74 |
| C+ | 65–69 |
| C | 60–64 |
| D+ | 55–59 |
| D | 50–54 |
| E | Below 50 |


