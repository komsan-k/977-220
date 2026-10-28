
# Laboratory Report Template
## Verilog/SystemVerilog-2 — Combinational Design

**Course:** 977-220 Electronics and IoT  
**Topic:** Week 1, Slot 2 — Combinational Design  
**Reference:** [GitHub Laboratory](https://github.com/komsan-k/977-220/tree/main/fpga-2026/week-1/slot-2)

**Student Name:** __________________________  
**Student ID:** __________________________  
**Date:** __________________________

---

## 1. Achievement

Describe the knowledge and practical skills gained from this laboratory.

After completing the selected tasks, I am able to:

- Implement a 4-to-1 multiplexer using the SystemVerilog `case` statement.
- Design a 2-to-4 decoder with one-hot outputs.
- Implement a 4-to-2 encoder with a single active input.
- Design and verify half-adder `SUM` and `CARRY` outputs.
- Design and verify full-adder `SUM` and `COUT` outputs.
- Develop testbenches and compare simulation results with expected truth tables.
- Use EDA Playground and EPWave to verify combinational circuits.

**Achievement Summary:**

[Write a short paragraph describing what you successfully implemented, verified, and learned.]

---

## 2. Verilog/SystemVerilog Project URL (Shared)

Provide a shared link to your completed Verilog/SystemVerilog project.


**EDA Playground Project URL:**  
[Insert URL]

Your shared project should contain:

- HDL source code for all five tasks.
- Testbench files.
- Simulation output or waveform evidence.
- A README describing the project and how to run the simulations.

---

## 3. Results

### Task 2 — 4-to-1 Multiplexer

**Objective:** Implement a 4-to-1 multiplexer using a `case` statement to select one of four inputs.

**3.1 HDL Implementation**

[Insert your Verilog/SystemVerilog code.]

**3.2 Simulation Results**

| Select S1S0 | Selected Input | Expected Output | Simulated Output | Pass/Fail |
|---|---|---|---|---|
| 00 | D0 | D0 | | |
| 01 | D1 | D1 | | |
| 10 | D2 | D2 | | |
| 11 | D3 | D3 | | |

**3.3 Waveform Screenshot**

[Insert EPWave screenshot showing D[3:0], S[1:0], and Y.]

**3.4 Verification Summary**

[Explain whether the multiplexer correctly selected the corresponding input for every select value.]

### Task 3 — 2-to-4 Decoder

**Objective:** Implement a decoder that activates exactly one output for each two-bit input.

**3.5 HDL Implementation**

[Insert your Verilog/SystemVerilog code.]

**3.6 Simulation Results**

| Input A1A0 | Expected Y3Y2Y1Y0 | Simulated Output | Pass/Fail |
|---|---|---|---|
| 00 | 0001 | | |
| 01 | 0010 | | |
| 10 | 0100 | | |
| 11 | 1000 | | |

**3.7 Waveform Screenshot**

[Insert EPWave screenshot showing A[1:0] and Y[3:0].]

**3.8 Verification Summary**

[Explain whether exactly one decoder output was active for every valid input combination.]

### Task 5 — 4-to-2 Encoder

**Objective:** Implement a simple 4-to-2 encoder assuming exactly one input is active.

**3.9 HDL Implementation**

[Insert your Verilog/SystemVerilog code.]

**3.10 Simulation Results**

| Input D3D2D1D0 | Expected Y1Y0 | Simulated Output | Pass/Fail |
|---|---|---|---|
| 0001 | 00 | | |
| 0010 | 01 | | |
| 0100 | 10 | | |
| 1000 | 11 | | |

**3.11 Waveform Screenshot**

[Insert EPWave screenshot showing D[3:0] and Y[1:0].]

**3.12 Verification Summary**

[Explain whether each one-hot input was converted into the correct binary code. Discuss why multiple active inputs are not supported by this simple encoder.]

### Task 7 — Half Adder

**Objective:** Implement and verify `SUM` and `CARRY` outputs.

**Boolean Equations:**

- `SUM = A XOR B`
- `CARRY = A AND B`

**3.13 HDL Implementation**

[Insert your Verilog/SystemVerilog code.]

**3.14 Simulation Results**

| A | B | Expected SUM | Expected CARRY | Simulated SUM | Simulated CARRY | Pass/Fail |
|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | | | |
| 0 | 1 | 1 | 0 | | | |
| 1 | 0 | 1 | 0 | | | |
| 1 | 1 | 0 | 1 | | | |

**3.15 Waveform Screenshot**

[Insert EPWave screenshot showing A, B, SUM, and CARRY.]

**3.16 Verification Summary**

[Explain how the XOR and AND operations produce the correct half-adder outputs.]

### Task 8 — Full Adder

**Objective:** Implement a full adder that adds A, B, and carry-in (`Cin`).

**Boolean Equations:**

- `SUM = A XOR B XOR Cin`
- `COUT = (A AND B) OR (Cin AND (A XOR B))`

**3.17 HDL Implementation**

[Insert your Verilog/SystemVerilog code.]

**3.18 Simulation Results**

| A | B | Cin | Expected SUM | Expected COUT | Simulated SUM | Simulated COUT | Pass/Fail |
|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | | | |
| 0 | 0 | 1 | 1 | 0 | | | |
| 0 | 1 | 0 | 1 | 0 | | | |
| 0 | 1 | 1 | 0 | 1 | | | |
| 1 | 0 | 0 | 1 | 0 | | | |
| 1 | 0 | 1 | 0 | 1 | | | |
| 1 | 1 | 0 | 0 | 1 | | | |
| 1 | 1 | 1 | 1 | 1 | | | |

**3.19 Waveform Screenshot**

[Insert EPWave screenshot showing A, B, Cin, SUM, and COUT.]

**3.20 Verification Summary**

[Explain how carry-in affects SUM and COUT, and report whether all eight combinations were verified.]


---

## 4. Discussion

Answer the following questions based on your experimental results.

**Task 2 — Multiplexer**

1. How does the `case` statement select one of four inputs?
2. What happens if the select signal changes while the data inputs remain unchanged?

**Task 3 — Decoder**

3. Why does a 2-to-4 decoder generate a one-hot output?
4. How can the decoder truth table be used to verify the circuit?

**Task 5 — Encoder**

5. How does the encoder convert a one-hot input into a binary output?
6. What happens if two input signals are active simultaneously?

**Task 7 — Half Adder**

7. Why is the XOR gate used for `SUM`?
8. Under what input condition does `CARRY` become 1?

**Task 8 — Full Adder**

9. How does the full adder differ from the half adder?
10. How does `Cin` affect the addition result?
11. Why must all eight input combinations be tested?

**General Discussion**

12. What is the role of a testbench in Verilog/SystemVerilog design?
13. How do truth tables and waveforms help verify combinational circuits?
14. What problems did you encounter, and how did you resolve them?



