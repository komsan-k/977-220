# Topic 11: Vivado-7 — Fixed-Point Multipliers

**Course:** 977-220 Electronics and IoT — FPGA Design  
**Tools:** AMD Vivado, Vivado Simulator, Verilog HDL  
**Target board:** Nexys A7 (optional hardware activity)  
**Prerequisite:** Topic 10 — Multiplier Study Case

> **Scope:** This is a beginner-friendly **combinational** laboratory. It uses simple Verilog (`wire`, `reg`, `assign`, and `always @(*)`). **No pipeline, clock, reset, registers, or valid signals are required for the multiplier.**

## 1. Overview

A multiplier computes the product of two binary numbers. In an FPGA, decimal fractions can be represented using **fixed-point numbers**, which are stored as scaled integers. This laboratory introduces signed 8-bit fixed-point multiplication, product scaling, and output saturation. It prepares students for the next topic: Multiply–Accumulate (MAC) Design.

The central datapath is:

```text
  Signed A[7:0] ──┐
                  ├──► Signed Multiplier ──► RAW[15:0]
  Signed B[7:0] ──┘                              │
                                               ▼
                                      Arithmetic Shift >>> 4
                                               │
                                               ▼
                                        Range Check
                                               │
                                               ▼
                                    P[7:0], SATURATED
```

All outputs are **combinational**: they change after the input signals and combinational logic have settled. There is no clock-cycle latency specification.

## 2. Learning Objectives

After completing this laboratory, students should be able to:

1. Explain signed two's-complement fixed-point representation.
2. Convert real values to 8-bit fixed-point encoded integers.
3. Implement an 8 × 8 signed multiplier using the Verilog `*` operator.
4. Explain why the full raw product requires 16 bits.
5. Scale a fixed-point product using the arithmetic right shift `>>>`.
6. Apply saturation to prevent output wraparound.
7. Simulate and verify a combinational multiplier in Vivado.
8. Inspect the RTL schematic and synthesis resource utilization.

## 3. Equipment and Prerequisites

| Resource | Purpose |
|---|---|
| Vivado Design Suite | Create, simulate, synthesize, and implement Verilog designs |
| Vivado Simulator (XSim) | Check multiplication results |
| Nexys A7 FPGA board (optional) | Display results using switches and LEDs |
| Official board master XDC | Assign FPGA pins to switches and LEDs |

Students should already know binary arithmetic, signed numbers, basic Verilog modules, and testbenches. A clock is **not** required for this combinational design.

## 4. Fixed-Point Representation (Signed Q3.4)

A fixed-point number is stored as an integer with a predefined number of fractional bits:

$$
x = \frac{X}{2^F}.
$$

For this laboratory:

- **W = 8 bits:** total signed width, including the sign bit.
- **F = 4 bits:** number of fractional bits.
- **Q3.4:** one sign bit, three non-sign integer bits, and four fractional bits (this naming convention is stated explicitly to avoid ambiguity).

Therefore,

$$
x=\frac{X}{16}, \qquad -8 \leq x \leq 7.9375,
$$

with resolution

$$
\Delta=\frac{1}{16}=0.0625.
$$

| Real value | Encoded signed integer | 8-bit two's-complement binary |
|---:|---:|---|
| 0.0 | 0 | `00000000` |
| 0.5 | 8 | `00001000` |
| 1.0 | 16 | `00010000` |
| 1.5 | 24 | `00011000` |
| 2.0 | 32 | `00100000` |
| -1.0 | -16 | `11110000` |
| -2.25 | -36 | `11011100` |
| -8.0 | -128 | `10000000` |

**Example:** The real value 1.5 is stored as `24` because `1.5 × 16 = 24`.

## 5. Fixed-Point Multiplication

### 5.1 Product width

For two signed Q3.4 operands:

$$
x=\frac{A}{16},\qquad y=\frac{B}{16}.
$$

Their product is

$$
xy=\frac{AB}{256}.
$$

The **full signed 8 × 8 product is 16 bits**, with **eight fractional bits**. To return to four fractional bits, shift the raw product right by four:

$$
Y_{\mathrm{scaled}} = P_{\mathrm{raw}}\mathbin{\texttt{>>>}}4.
$$

Because the raw product is signed, this is an **arithmetic right shift**. It rounds downward for negative values rather than truncating toward zero.

### 5.2 Worked example

Multiply 1.5 by 2.0:

$$
A=1.5\times16=24,\qquad B=2.0\times16=32.
$$

$$
P_{\mathrm{raw}}=24\times32=768.
$$

$$
Y_{\mathrm{scaled}}=768\mathbin{\texttt{>>>}}4=48.
$$

The final real result is

$$
y=\frac{48}{16}=3.0.
$$

### 5.3 Why saturation is needed

An 8-bit signed output can store only integers from -128 to 127. If the scaled result is outside that range, **saturation** clamps it:

$$
Y=\begin{cases}
127,&Y_{\mathrm{scaled}}>127,\\
-128,&Y_{\mathrm{scaled}}<-128,\\
Y_{\mathrm{scaled}},&\text{otherwise}.
\end{cases}
$$

For example, 4.0 × 4.0 = 16.0 is outside the Q3.4 output range. The saturated output is `127`, representing 7.9375, and the saturation flag becomes 1.

**This basic lab uses arithmetic-shift truncation and saturation.** Rounding to nearest is not implemented, keeping the Verilog short and easy to follow.

## 6. Simple Verilog Implementation

### 6.1 Example A — Basic signed multiplier (`signed_multiplier.v`)

Start with the full 16-bit raw product:

```verilog
module signed_multiplier(
    input  wire signed [7:0] A,
    input  wire signed [7:0] B,
    output wire signed [15:0] PRODUCT
);

    assign PRODUCT = A * B;

endmodule
```

This module has no clock or pipeline. It produces a signed 16-bit integer product. Since each input has four fractional bits, the raw product has eight fractional bits.

### 6.2 Example B — Fixed-point multiplier with saturation (`fixed_point_multiplier.v`)

This is the **main module** for simulation and FPGA implementation:

```verilog
module fixed_point_multiplier(
    input  wire signed [7:0] A,
    input  wire signed [7:0] B,
    output reg  signed [7:0] P,
    output reg               SATURATED
);

    wire signed [15:0] raw_product;
    wire signed [15:0] scaled_product;

    // 8-bit signed x 8-bit signed = 16-bit signed
    assign raw_product = A * B;

    // Q3.4 x Q3.4 -> Q3.4 (arithmetic-shift truncation)
    assign scaled_product = raw_product >>> 4;

    // Clamp the result to the signed 8-bit range
    always @(*) begin
        SATURATED = 1'b0;

        if (scaled_product > 16'sd127) begin
            P = 8'sh7F;       // +127
            SATURATED = 1'b1;
        end
        else if (scaled_product < -16'sd128) begin
            P = 8'sh80;       // -128
            SATURATED = 1'b1;
        end
        else begin
            P = scaled_product[7:0];
        end
    end

endmodule
```

**Explanation:**

- `A * B` calculates the full signed product.
- `>>> 4` converts the product back to four fractional bits.
- `always @(*)` describes combinational comparison and selection, **not a register**.
- `SATURATED = 1` indicates that the scaled integer exceeded the 8-bit signed range.
- There are **no pipeline stages**, `clk`, `rst`, `valid_in`, or `valid_out` signals.

## 7. Expected Results

The following results use arithmetic-shift truncation and saturation:

| A encoded | B encoded | Real input values | Raw product | Scaled result before saturation | Output `P` | Output real value | SATURATED |
|---:|---:|---|---:|---:|---:|---:|:---:|
| 24 | 32 | 1.5 × 2.0 | 768 | 48 | 48 | 3.0 | 0 |
| -36 | 24 | -2.25 × 1.5 | -864 | -54 | -54 | -3.375 | 0 |
| 1 | 8 | 0.0625 × 0.5 | 8 | 0 | 0 | 0.0 | 0 |
| -1 | 8 | -0.0625 × 0.5 | -8 | -1 | -1 | -0.0625 | 0 |
| 1 | 1 | 0.0625 × 0.0625 | 1 | 0 | 0 | 0.0 | 0 |
| -1 | 1 | -0.0625 × 0.0625 | -1 | -1 | -1 | -0.0625 | 0 |
| 64 | 64 | 4.0 × 4.0 | 4096 | 256 | 127 | 7.9375 | 1 |
| -128 | 32 | -8.0 × 2.0 | -4096 | -256 | -128 | -8.0 | 1 |
| -128 | -128 | -8.0 × -8.0 | 16384 | 1024 | 127 | 7.9375 | 1 |

**Important:** The small negative example `-1 × 1` has a raw product of `-1`. Arithmetic right shift gives `-1`, not zero. This is the expected behavior of the selected truncation policy.

## 8. Simple Verilog Testbench

Save as **`tb_fixed_point_multiplier.v`** under *Simulation Sources*:

```verilog
`timescale 1ns / 1ps

module tb_fixed_point_multiplier;

    reg  signed [7:0] A;
    reg  signed [7:0] B;
    wire signed [7:0] P;
    wire              SATURATED;

    fixed_point_multiplier uut (
        .A(A),
        .B(B),
        .P(P),
        .SATURATED(SATURATED)
    );

    initial begin
        $display("  A    B    P    SAT");
        $monitor("%4d %4d %4d    %b", A, B, P, SATURATED);

        A =  8'sd24; B =  8'sd32; #10;  // 1.5 * 2.0
        A = -8'sd36; B =  8'sd24; #10;  // -2.25 * 1.5
        A =  8'sd1;  B =  8'sd8;  #10;  // small positive
        A = -8'sd1;  B =  8'sd8;  #10;  // small negative
        A =  8'sd1;  B =  8'sd1;  #10;
        A = -8'sd1;  B =  8'sd1;  #10;
        A =  8'sd64; B =  8'sd64; #10;  // positive saturation
        A =  8'sh80; B =  8'sd32; #10;  // -128 * 32
        A =  8'sh80; B =  8'sh80; #10;  // -128 * -128

        $finish;
    end

endmodule
```

**Simulation procedure:**

1. Add `fixed_point_multiplier.v` to *Design Sources*.
2. Add `tb_fixed_point_multiplier.v` to *Simulation Sources*.
3. Select `tb_fixed_point_multiplier` as the simulation top.
4. Choose **Run Simulation → Run Behavioral Simulation**.
5. Run for at least **90 ns** and display `A`, `B`, `P`, and `SATURATED`.
6. Compare each simulated output with the expected-results table.
7. Capture a waveform screenshot and record any mismatches.

> The testbench is intentionally simple: it applies input vectors and displays results. Students must verify the outputs against the table. It does not automatically assert PASS or FAIL.

## 9. FPGA Implementation (Nexys A7)

The Nexys A7 has sufficient switches to provide both 8-bit operands. Use LEDs to show the signed 8-bit result and the saturation flag.

### 9.1 FPGA top module (`fixed_point_top.v`)

```verilog
module fixed_point_top(
    input  wire [15:0] SW,
    output wire [8:0]  LED
);

    wire signed [7:0] product;
    wire saturated;

    fixed_point_multiplier MULT (
        .A(SW[7:0]),
        .B(SW[15:8]),
        .P(product),
        .SATURATED(saturated)
    );

    assign LED[7:0] = product;
    assign LED[8]   = saturated;

endmodule
```

### 9.2 Switch and LED assignment

| FPGA resource | Purpose |
|---|---|
| SW7–SW0 | Encoded signed operand A (8 bits) |
| SW15–SW8 | Encoded signed operand B (8 bits) |
| LED7–LED0 | Encoded signed product P (8 bits) |
| LED8 | Saturation flag |

**Example:** For A = 1.5 and B = 2.0, set SW7–SW0 to `00011000` (24) and SW15–SW8 to `00100000` (32). The expected LED7–LED0 result is `00110000` (48), with LED8 = 0.

### 9.3 XDC constraints

Use the **official master XDC for the exact Nexys A7 board variant**. Enable the pins for SW0–SW15 and LED0–LED8, and match the top-level port names `SW[0]` through `SW[15]` and `LED[0]` through `LED[8]`.

Do **not** invent pin assignments. The exact FPGA package pins and I/O standards must be taken from the board documentation.

**No clock constraint is needed for this purely combinational top module.** A meaningful input-to-output timing analysis requires an explicit external timing model; unconstrained timing paths should not be treated as verified.

### 9.4 Hardware procedure

1. Set `fixed_point_top` as the synthesis top.
2. Add and verify the board XDC file.
3. Run **Synthesis** and **Implementation**.
4. Generate the bitstream and program the FPGA.
5. Set the switches for at least five test cases.
6. Record the LED outputs and compare them with the simulation results.

Since the circuit is combinational, changing a switch changes the output after propagation and switch-settling time. During multi-switch changes, intermediate LED patterns may briefly appear. Wait for all switches to settle before recording a result.

## 10. Vivado RTL and Resource Analysis

### 10.1 RTL schematic

Select **RTL Analysis → Open Elaborated Design → Schematic**.

Identify:

- The signed multiplication operation.
- The arithmetic right-shift operation.
- The positive and negative saturation comparisons.
- The selection of the final 8-bit output.

**Figure 1 — RTL schematic:** [Insert screenshot.]

### 10.2 Synthesis resource utilization

Select **Run Synthesis → Open Synthesized Design → Report Utilization**.

| Resource | Observed utilization | Notes |
|---|---:|---|
| LUTs | | |
| Flip-flops / registers | | Expected to be zero for the multiplier logic |
| DSP blocks | | Depends on synthesis mapping |
| I/O ports | | Top-level hardware wrapper uses 16 inputs + 9 outputs |
| BRAM | | Not required by the design |

**Figure 2 — Utilization report:** [Insert screenshot.]

**Interpretation:** Synthesis may implement multiplication using dedicated DSP resources or LUT-based logic. Actual utilization depends on the FPGA, optimization, and Vivado settings. Record the tool-reported numbers; do not assume a particular DSP count.

**Timing note:** The multiplier has no sequential clock path, so a register-to-register Fmax is not defined. If timing is studied, report a properly constrained input-to-output delay or compare synthesis path estimates with clearly stated limitations.

## 11. Laboratory Tasks

### Task 1 — Fixed-Point Encoding

Convert **1.5, -2.25, 0.5, and -8.0** to signed 8-bit Q3.4 values. Show the encoded integer and two's-complement binary pattern.

### Task 2 — Basic Signed Multiplication

Implement `signed_multiplier.v` using the `*` operator. Test positive, negative, and zero inputs. Explain the 16-bit result width.

### Task 3 — Fixed-Point Scaling

Implement `raw_product >>> 4` and explain why the output again has four fractional bits.

### Task 4 — Saturation

Complete `fixed_point_multiplier.v` and verify positive and negative saturation. Explain the difference between saturation and wraparound.

### Task 5 — Simulation

Simulate **at least five different input pairs**, including positive, negative, small-magnitude, and overflow cases. Include a waveform screenshot.

### Task 6 — RTL Schematic

Open the elaborated design and identify the multiplier, shift, comparison, and output-selection logic. Include a schematic screenshot.

### Task 7 — FPGA Implementation 

Use switches for both operands and LEDs for the output and saturation flag. Record at least five hardware test cases with photographs or an observation table.

### Task 8 — Resource Analysis

Record LUT, flip-flop, DSP, and I/O utilization from the Vivado synthesis report. Explain why this combinational design does not require pipeline registers.

## 12. Laboratory Report Template

**Student name:** ____________________  
**Student ID:** ____________________  
**Board / FPGA part:** ____________________  
**Vivado version:** ____________________  
**Date:** ____________________

### 12.1 Achievement

Write 5–8 sentences describing the design, fixed-point representation, simulation, FPGA test (if performed), and learning outcomes.

### 12.2 Verilog Source Code

Attach or paste:

- `signed_multiplier.v`
- `fixed_point_multiplier.v`
- `tb_fixed_point_multiplier.v`
- `fixed_point_top.v` (if hardware was used)

### 12.3 Simulation Results

| Test | A (encoded) | B (encoded) | Expected P | Observed P | Expected SAT | Observed SAT | Pass/Fail |
|---:|---:|---:|---:|---:|:---:|:---:|---|
| 1 | 24 | 32 | 48 | | 0 | | |
| 2 | -36 | 24 | -54 | | 0 | | |
| 3 | 1 | 8 | 0 | | 0 | | |
| 4 | -1 | 8 | -1 | | 0 | | |
| 5 | 64 | 64 | 127 | | 1 | | |
| 6 | -128 | 32 | -128 | | 1 | | |

**Figure 3 — Simulation waveform:** [Insert screenshot.]

### 12.4 RTL and Synthesis

**Figure 4 — Elaborated RTL schematic:** [Insert screenshot.]  
**Figure 5 — Vivado utilization report:** [Insert screenshot.]

| Resource | Measured count |
|---|---:|
| LUTs | |
| Flip-flops | |
| DSP blocks | |
| I/O ports | |
| BRAM | |

### 12.5 FPGA Verification 

**Figure 6 — FPGA hardware test:** [Insert photograph with switch and LED states.]  
**XDC source:** [State board reference and constraints used.]

| A | B | Expected P | LED result | SAT | Pass/Fail |
|---:|---:|---:|---|:---:|---|
| 24 | 32 | 48 | | 0 | |
| -36 | 24 | -54 | | 0 | |
| 64 | 64 | 127 | | 1 | |
| [custom] | [custom] | | | | |
| [custom] | [custom] | | | | |

### 12.6 Discussion

Answer using your actual calculations, code, simulation, and synthesis results:

1. What is the difference between integer and fixed-point multiplication?
2. Why does an 8 × 8 signed multiplication require a 16-bit raw product?
3. Why is the raw product shifted right by four bits?
4. How does `>>>` differ from `>>` for signed negative values?
5. Why does a small negative product sometimes produce -1 after shifting?
6. What happens if the scaled product exceeds the signed 8-bit range?
7. What is the purpose of the `SATURATED` output?
8. Why is no clock required for this combinational multiplier?
9. What hardware resources did Vivado use to implement multiplication?
10. How could the multiplier be extended into a multiply–accumulate (MAC) circuit?

## 13. Preparation for Topic 12 — Multiply–Accumulate (MAC)

A MAC circuit performs

$$
ACC_{\mathrm{next}}=ACC+A\times B.
$$

In this laboratory, the multiplier is combinational. In the next topic, a register can be introduced **for the accumulator**, so that it retains the running sum between clock edges. To avoid unnecessary precision loss, a MAC design should consider accumulating the **full 16-bit raw products** in a wider register before final scaling.



## 15. References

1. AMD, [Vivado Design Suite User Guide: Synthesis (UG901)](https://docs.amd.com/r/en-US/ug901-vivado-synthesis).
2. AMD, [Vivado Design Suite User Guide: Logic Simulation (UG900)](https://docs.amd.com/r/en-US/ug900-vivado-logic-simulation).
3. Digilent, [Nexys A7 Reference Manual](https://digilent.com/reference/programmable-logic/nexys-a7/reference-manual).
4. M. M. Mano and M. D. Ciletti, *Digital Design*.

---

**Key learning outcome:** Students can implement and verify a **simple, combinational signed fixed-point multiplier** in Verilog, including scaling and saturation, before advancing to sequential MAC design.
