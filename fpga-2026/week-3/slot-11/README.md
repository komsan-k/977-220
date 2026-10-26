# Topic 11: Vivado-7 —Fixed-Point Arithmetic and Pipelined Multipliers

## 1. Overview

This lab follows the unsigned multiplier study and prepares students for multiply–accumulate (MAC) design. Implement signed fixed-point multiplication, rescale the product, apply rounding and saturation, and introduce pipeline registers with correctly aligned valid signals.

The core exercise uses **signed 8-bit operands with four fractional bits**. Training or software calculations may use floating-point numbers, but the FPGA stores scaled integers.

## 2. Objectives

- Interpret two's-complement fixed-point numbers and calculate their range.
- Determine product width and fractional-bit position.
- Distinguish truncation, rounding, wraparound, and saturation.
- Implement combinational and pipelined fixed-point multipliers.
- Verify numerical accuracy, valid-signal alignment, reset behavior, and throughput.
- Inspect Vivado resource utilization and constrained timing reports.

## 3. Equipment and Prerequisites

| Resource | Purpose |
| --- | --- |
| Vivado and Vivado Simulator | RTL design, simulation, synthesis, and implementation |
| Nexys A7 or equivalent board | Optional hardware demonstration |
| Board clock, reset button, switches, and LEDs | Hardware input/output |
| Official board XDC | Physical pin and clock constraints |

Students should understand signed binary arithmetic, multipliers, registers, nonblocking assignments, and testbenches. Record the selected board and tool version. The simulation exercise is independent of board hardware.

## 4. Fixed-Point Representation

An integer encoding X represents a real value x through

$$
x=X\,2^{-F},\qquad X\approx x\,2^F.
$$

Here **W = 8 total bits, including the sign bit**, and **F = 4 fractional bits**. In this lab, the name **Q3.4** means one sign bit, three remaining integer bits, and four fractional bits. Other references count the sign bit differently; always state W and F explicitly.

The representable range and spacing are

$$
-8\leq x\leq7.9375,\qquad \Delta=2^{-4}=0.0625.
$$

| Real value | Signed integer X | Eight-bit encoding |
| ---: | ---: | --- |
| 0 | 0 | `00000000` |
| 0.5 | 8 | `00001000` |
| 1.0 | 16 | `00010000` |
| 1.5 | 24 | `00011000` |
| -1.0 | -16 | `11110000` |
| -2.25 | -36 | `11011100` |
| 7.9375 | 127 | `01111111` |
| -8.0 | -128 | `10000000` |

## 5. Product Scaling and Width

For encoded operands A and B,

$$
x=A/16,\qquad y=B/16,\qquad xy=(AB)/256.
$$

An exact 8 × 8 signed product uses a **16-bit signed result with eight fractional bits**. Returning to an eight-bit, four-fractional-bit output requires dividing the raw integer product by 16, then checking the output range.

For example, 1.5 × 2.0 gives encoded inputs 24 and 32:

$$
P_{\mathrm{raw}}=24\times32=768,\qquad Y=768/16=48,
$$

so the output represents 48/16 = 3.0.

Use signed declarations for both operands and signed intermediate signals. An arithmetic right shift (`>>>`) sign-extends a signed left operand; applying it to an unsigned expression does not provide the intended signed arithmetic.

## 6. Quantization Policy

### 6.1 Arithmetic-Shift Truncation

The optional truncation mode uses

$$
Y_{\mathrm{trunc}}=\left\lfloor P_{\mathrm{raw}}/16\right\rfloor.
$$

This is rounding toward negative infinity, not toward zero. For example, a raw product of -1 becomes -1 after an arithmetic right shift by four, representing -0.0625.

### 6.2 Round to Nearest, Ties Away from Zero

The default mode uses

$$
Y_{\mathrm{round}}=
\begin{cases}
\lfloor(P_{\mathrm{raw}}+8)/16\rfloor,& P_{\mathrm{raw}}\geq0,\\
-\lfloor(-P_{\mathrm{raw}}+8)/16\rfloor,& P_{\mathrm{raw}}<0.
\end{cases}
$$

The magnitude calculation uses a wider signed intermediate to avoid overflow when negating the most-negative input value. This rounding rule is not ties-to-even.

### 6.3 Saturation

After rescaling, clamp the encoded result:

$$
Y_{\mathrm{sat}}=\min(127,\max(-128,Y)).
$$

The saturation flag indicates that the **quantized integer** exceeded this range. A real result slightly outside the output range can round back into range without setting the flag. Saturation is distinct from simply keeping eight low bits, which produces wraparound.

## 7. Pipeline Architecture and Timing Contract

```mermaid
flowchart LR
    I[Signed inputs and valid] --> R[Operand registers]
    R --> M[Multiply and product register]
    M --> Q[Quantize and output register]
```

The implementation contains three register banks. If inputs are accepted at rising edge **k**, the product register updates at edge **k+1**, and the quantized result with `valid_out = 1` appears just after edge **k+2**. Thus acceptance-to-output latency is **two clock periods**, with output on the third relevant rising edge. This explicit edge convention avoids ambiguity when counting pipeline stages.

| Rising edge | Action for a sample accepted at k |
| --- | --- |
| k | Capture operands and input valid |
| k+1 | Register their full product |
| k+2 | Register rounded/saturated output and output valid |

Once filled, the pipeline can accept and produce one sample per clock. A low `valid_in` creates an invalid slot, or bubble; it does not stall the pipeline. There is no `ready` signal or backpressure. Consumers must ignore `P` and `saturated` whenever `valid_out` is zero. A synchronous active-high reset clears all in-flight samples.

Registers separate multiplication from quantization. They do not automatically divide a large multiplication into several smaller combinational operations. Physical DSP mapping and timing must be checked in Vivado.

## 8. RTL Implementation

Save the following as SystemVerilog **Design Sources**.

### 8.1 `fxp_quantize.sv`

```systemverilog
module fxp_quantize #(
    parameter bit ROUND_NEAREST = 1'b1
)(
    input  logic signed [15:0] raw_product,
    output logic signed [7:0]  result,
    output logic              saturated
);
    logic signed [16:0] wide_product;
    logic signed [16:0] scaled;

    always_comb begin
        wide_product = {raw_product[15], raw_product};

        if (ROUND_NEAREST) begin
            if (wide_product >= 17'sd0)
                scaled = (wide_product + 17'sd8) >>> 4;
            else
                scaled = -(((-wide_product) + 17'sd8) >>> 4);
        end else begin
            scaled = wide_product >>> 4;
        end

        saturated = 1'b0;
        if (scaled > 17'sd127) begin
            result = 8'sh7F;
            saturated = 1'b1;
        end else if (scaled < -17'sd128) begin
            result = 8'sh80;
            saturated = 1'b1;
        end else begin
            result = scaled[7:0];
        end
    end
endmodule
```

### 8.2 `fxp_multiplier_comb.sv`

```systemverilog
module fxp_multiplier_comb #(
    parameter bit ROUND_NEAREST = 1'b1
)(
    input  logic signed [7:0] A, B,
    output wire  signed [7:0] P,
    output wire              saturated
);
    wire signed [15:0] raw_product;
    assign raw_product = A * B;

    fxp_quantize #(.ROUND_NEAREST(ROUND_NEAREST)) Q (
        .raw_product(raw_product), .result(P), .saturated(saturated)
    );
endmodule
```

### 8.3 `fxp_multiplier_pipeline.sv`

```systemverilog
module fxp_multiplier_pipeline #(
    parameter bit ROUND_NEAREST = 1'b1
)(
    input  logic              clk,
    input  logic              rst,
    input  logic              valid_in,
    input  logic signed [7:0] A, B,
    output logic              valid_out,
    output logic signed [7:0] P,
    output logic              saturated
);
    logic signed [7:0] a_reg, b_reg;
    logic signed [15:0] product_reg;
    logic valid_operands, valid_product;
    wire signed [7:0] quantized;
    wire quantized_sat;

    fxp_quantize #(.ROUND_NEAREST(ROUND_NEAREST)) Q (
        .raw_product(product_reg),
        .result(quantized), .saturated(quantized_sat)
    );

    always_ff @(posedge clk) begin
        if (rst) begin
            a_reg <= '0;
            b_reg <= '0;
            product_reg <= '0;
            P <= '0;
            saturated <= 1'b0;
            valid_operands <= 1'b0;
            valid_product <= 1'b0;
            valid_out <= 1'b0;
        end else begin
            a_reg <= A;
            b_reg <= B;
            valid_operands <= valid_in;

            product_reg <= a_reg * b_reg;
            valid_product <= valid_operands;

            P <= quantized;
            saturated <= quantized_sat;
            valid_out <= valid_product;
        end
    end
endmodule
```

All arithmetic data and valid signals advance together. Nonblocking assignments ensure that each stage uses the previous contents of the preceding register bank.

## 9. Expected Numerical Results

The following values use the default nearest-rounding policy.

| A encoded | B encoded | Real inputs | Raw product | Output encoded | Output real | Saturated |
| ---: | ---: | --- | ---: | ---: | ---: | --- |
| 24 | 32 | 1.5 × 2.0 | 768 | 48 | 3.0 | No |
| -36 | 24 | -2.25 × 1.5 | -864 | -54 | -3.375 | No |
| 1 | 8 | 0.0625 × 0.5 | 8 | 1 | 0.0625 | No |
| -1 | 8 | -0.0625 × 0.5 | -8 | -1 | -0.0625 | No |
| 1 | 1 | 0.0625 × 0.0625 | 1 | 0 | 0 | No |
| -1 | 1 | -0.0625 × 0.0625 | -1 | 0 | 0 | No |
| 64 | 64 | 4.0 × 4.0 | 4096 | 127 | 7.9375 | Yes |
| -128 | 32 | -8.0 × 2.0 | -4096 | -128 | -8.0 | Yes |
| -128 | -128 | -8.0 × -8.0 | 16384 | 127 | 7.9375 | Yes |

With shift truncation instead, raw product -1 produces encoded output -1. Quantization error should be calculated against the exact real product, with saturated and unsaturated samples reported separately.

## 10. Self-Checking Simulation

Save as `tb_fxp_multiplier.sv` under **Simulation Sources**. This checks the default rounding policy against an integer reference, tests every signed eight-bit operand pair, inserts bubbles, and resets the pipeline with samples in flight.

```systemverilog
`timescale 1ns/1ps
module tb_fxp_multiplier;
    logic clk = 1'b0;
    always #5 clk = ~clk;

    logic rst = 1'b1;
    logic valid_in = 1'b0;
    logic signed [7:0] A = '0, B = '0;
    wire valid_out, saturated;
    wire signed [7:0] P;
    wire comb_sat;
    wire signed [7:0] comb_P;

    fxp_multiplier_pipeline DUT (
        .clk(clk), .rst(rst), .valid_in(valid_in), .A(A), .B(B),
        .valid_out(valid_out), .P(P), .saturated(saturated)
    );
    fxp_multiplier_comb COMB (
        .A(A), .B(B), .P(comb_P), .saturated(comb_sat)
    );

    integer expected[0:2];
    bit expected_sat[0:2];
    bit expected_valid[0:2];
    integer received = 0;
    integer exhaustive_start_count;
    integer a_value, b_value;

    function automatic integer reference_scaled(input integer a, b);
        integer raw;
        begin
            raw = a * b;
            if (raw >= 0)
                reference_scaled = (raw + 8) / 16;
            else
                reference_scaled = -((-raw + 8) / 16);
        end
    endfunction

    function automatic integer clamp(input integer value);
        begin
            if (value > 127) clamp = 127;
            else if (value < -128) clamp = -128;
            else clamp = value;
        end
    endfunction

    // Blocking assignments are used only in this testbench scoreboard.
    always @(posedge clk) begin : CHECKER
        integer j, scaled;
        if (rst) begin
            for (j = 0; j < 3; j = j + 1) begin
                expected[j] = 0;
                expected_sat[j] = 0;
                expected_valid[j] = 0;
            end
            #1;
            if ((valid_out !== 1'b0) || (P !== 8'sd0) ||
                (saturated !== 1'b0))
                $fatal(1, "Reset failed");
        end else begin
            for (j = 2; j > 0; j = j - 1) begin
                expected[j] = expected[j-1];
                expected_sat[j] = expected_sat[j-1];
                expected_valid[j] = expected_valid[j-1];
            end
            scaled = reference_scaled($signed(A), $signed(B));
            expected[0] = clamp(scaled);
            expected_sat[0] = (scaled > 127) || (scaled < -128);
            expected_valid[0] = valid_in;

            #1; // Sample after DUT nonblocking updates.
            if (valid_out !== expected_valid[2])
                $fatal(1, "Valid alignment failed");
            if (expected_valid[2]) begin
                if (($signed(P) !== expected[2]) ||
                    (saturated !== expected_sat[2]))
                    $fatal(1, "Pipeline value or saturation mismatch");
                received = received + 1;
            end
            if (valid_in) begin
                if (($signed(comb_P) !== expected[0]) ||
                    (comb_sat !== expected_sat[0]))
                    $fatal(1, "Combinational reference mismatch");
            end
        end
    end

    task automatic drive(input integer a, b, input bit valid);
        begin
            @(negedge clk);
            A = a;
            B = b;
            valid_in = valid;
        end
    endtask

    initial begin
        repeat (3) @(negedge clk);
        rst = 1'b0;

        drive(24, 32, 1);
        drive(-36, 24, 1);
        drive(0, 0, 0); // Bubble.
        drive(1, 8, 1);
        drive(-1, 8, 1);
        drive(64, 64, 1);
        drive(-128, 32, 1);
        drive(-128, -128, 1);

        // Flush pending work with synchronous reset.
        @(negedge clk);
        rst = 1'b1;
        valid_in = 1'b0;
        repeat (2) @(negedge clk);
        rst = 1'b0;
        exhaustive_start_count = received;

        for (a_value = -128; a_value <= 127; a_value = a_value + 1)
            for (b_value = -128; b_value <= 127; b_value = b_value + 1)
                drive(a_value, b_value, 1);

        // Drain all accepted samples; invalid slots are not results.
        repeat (5) drive(0, 0, 0);
        @(negedge clk);
        if ((received - exhaustive_start_count) != 65536)
            $fatal(1, "Wrong exhaustive output count: %0d",
                   received - exhaustive_start_count);
        $display("PASS: exhaustive arithmetic and pipeline checks completed");
        $finish;
    end
endmodule
```

Run **Run All**; the simulation needs slightly more than 655 microseconds at the testbench's 10 ns clock period. The checker automatically rejects wrong values, saturation flags, or output-valid timing. Earlier directed samples that complete before reset also contribute to `received`.

To test truncation, instantiate both cores with `ROUND_NEAREST = 0` and change the reference function to floor division. For negative raw values, an integer expression is `-((-raw + 15) / 16)`; ordinary signed division by 16 alone truncates toward zero and is not the same reference.

## 11. Vivado Procedure

1. Create an RTL project named `topic11_fixed_point_multiplier` for the selected board or part.
2. Add the three RTL files as SystemVerilog design sources.
3. Add the testbench as a simulation source and set it as the simulation top.
4. Run behavioral simulation to completion and record the console result.
5. Inspect `A`, `B`, `valid_in`, `product_reg`, `valid_product`, `P`, `valid_out`, and `saturated` in the waveform viewer.
6. Trace a directed sample across edges k, k+1, and k+2.
7. For hardware, add the wrapper below as the synthesis top and apply the board constraints.
8. Run synthesis and implementation; inspect DSP, LUT, register, and timing reports.
9. Generate the bitstream and program the FPGA.

## 12. Optional Nexys A7 Hardware Wrapper

Save as `fixed_point_top.sv`. The example uses 16 switches for raw signed operands, ten LEDs, the board clock, and a reset button.

```systemverilog
module fixed_point_top (
    input  wire        CLK100MHZ,
    input  wire        BTNC,
    input  wire [15:0] SW,
    output wire [9:0]  LED
);
    // Declaration initializers provide FPGA startup values in Vivado.
    (* ASYNC_REG = "TRUE" *) logic rst_meta = 1'b0;
    (* ASYNC_REG = "TRUE" *) logic rst_sync = 1'b0;
    (* ASYNC_REG = "TRUE" *) logic [15:0] sw_meta = '0;
    (* ASYNC_REG = "TRUE" *) logic [15:0] sw_sync = '0;
    wire signed [7:0] product;
    wire output_valid, sat;

    always_ff @(posedge CLK100MHZ) begin
        rst_meta <= BTNC;
        rst_sync <= rst_meta;
        sw_meta <= SW;
        sw_sync <= sw_meta;
    end

    fxp_multiplier_pipeline MULT (
        .clk(CLK100MHZ), .rst(rst_sync), .valid_in(1'b1),
        .A(sw_sync[7:0]), .B(sw_sync[15:8]),
        .valid_out(output_valid), .P(product), .saturated(sat)
    );

    assign LED[7:0] = product;
    assign LED[8] = sat;
    assign LED[9] = output_valid;
endmodule
```

| Board resource | Meaning |
| --- | --- |
| SW7–SW0 | Signed encoded operand A |
| SW15–SW8 | Signed encoded operand B |
| LED7–LED0 | Signed encoded result |
| LED8 | Saturation flag |
| LED9 | Output-valid flag |
| BTNC | Synchronous reset after synchronization |

Two-flop synchronization reduces metastability risk for individual switches but does not make a changing multi-bit operand atomic. Keep switches steady before reading the LEDs. The wrapper continuously processes the synchronized values; it is a static demonstration, not a coherent high-speed input interface. Add a debounced capture handshake for an event-driven extension. A held reset button clears the pipeline; this wrapper does not implement button debouncing.

Use the official Nexys A7 XDC for the exact board variant and the wrapper's port names. Apply package pins and I/O standards for every port. Include a 100 MHz clock constraint once, avoiding duplication if supplied by the project:

```tcl
create_clock -name sys_clk -period 10.000 [get_ports CLK100MHZ]
```

Static switches and LED outputs are not synchronous external interfaces. Document how these asynchronous/static paths are constrained or excluded for the board demonstration; do not interpret unconstrained I/O paths as verified interfaces. Limit any clock-domain-crossing exceptions to the intended asynchronous entry paths, preserving timing analysis between synchronizer stages and through the arithmetic core.

## 13. Experiments

### Experiment A: Signed Number Interpretation

Encode 1.5, -2.25, 0.5, and -8.0. Show each raw integer and two's-complement pattern. Explain why the same bit pattern has different meanings when treated as signed or unsigned.

### Experiment B: Quantization and Saturation

Complete the table using simulation or hardware. Interpret all result bits as signed encoded integers.

| Input A | Input B | Exact real product | Output real | Absolute error | Saturated |
| ---: | ---: | ---: | ---: | ---: | --- |
| 1.5 | 2.0 | 3.0 | | | |
| -2.25 | 1.5 | -3.375 | | | |
| 0.0625 | 0.5 | 0.03125 | | | |
| -0.0625 | 0.0625 | -0.00390625 | | | |
| 4.0 | 4.0 | 16.0 | | | |

Repeat with arithmetic-shift truncation. Discuss directional bias, tie handling, and the difference between quantization error and saturation error.

### Experiment C: Pipeline Verification

1. Apply at least four valid samples on consecutive cycles.
2. Confirm the output sequence and edge-k+2 timing.
3. Insert a bubble and confirm the corresponding invalid output slot.
4. Assert reset with samples in flight and confirm that those samples are discarded.
5. Show that one valid output per clock is possible after filling the pipeline.

### Experiment D: Resources and Timing

Record implemented results rather than inventing performance values.

| Metric | Pipelined core / wrapper | Registered comparison, optional |
| --- | ---: | ---: |
| LUTs | | |
| Flip-flops | | |
| DSP blocks | | |
| Target clock period | | |
| Worst setup slack | | |
| Worst hold slack | | |
| Core acceptance-to-output periods | 2 | |
| Initiation interval, cycles | 1 | |

For a fair registered comparison, retain input registers but remove `product_reg`, placing multiplication and quantization between the input and output registers. Its output for a sample accepted at k appears at k+1. Update its scoreboard accordingly. Use the same device, quantization policy, target clock, and synthesis settings.

The unregistered combinational module is a functional reference, not a directly comparable register-to-register Fmax benchmark. Additional register banks may improve timing by separating operations, but actual gains depend on synthesis and routing. A 10 ns clock constraint is a target, not proof of successful 100 MHz operation. Check setup and hold closure and all relevant timing paths.

## 14. Throughput, Latency, and MAC Preparation

Latency is the delay for one accepted sample to reach the output. Throughput is the sustained output rate. With an initiation interval of one cycle, the theoretical peak is one result per clock after filling, provided the implementation meets timing and the downstream consumer accepts every valid sample.

A future MAC adds a product to an accumulator:

$$
S_{n+1}=S_n+A_nB_n.
$$

Preserving the full raw product retains eight fractional bits. Before accumulation, choose a wider accumulator, sign-extend the product, and define overflow, reset, enable, and pipeline-valid behavior. For a sum of K signed 16-bit products, a conservative accumulator width is

$$
W_{\mathrm{acc}}=16+\lceil\log_2 K\rceil
$$

with eight fractional bits, assuming no additional initial accumulator magnitude. Rescaling each product before accumulation discards precision earlier; compare that choice with rounding once after the complete sum.

## 15. Troubleshooting and Discussion

| Symptom | Check |
| --- | --- |
| Negative operands produce large positive results | Signed declarations, casts, and intermediate expressions |
| Result differs by a factor of 16 | Product scaling and fractional-bit count |
| Small negative values differ between models | Floor truncation versus division toward zero |
| Output wraps sign at large products | Saturation before narrowing to eight bits |
| Correct values on wrong cycles | Valid-signal pipeline and acceptance-edge definition |
| Reset leaves old valid samples | Every valid register must be cleared |
| Hardware differs while toggling switches | Multi-bit coherence, synchronization, and settling |

Discuss:

1. Why does the raw product have eight fractional bits?
2. Why is a 17-bit intermediate used by the quantizer?
3. How do nearest rounding and shift truncation differ for negative inputs?
4. Why is saturation tested before keeping eight result bits?
5. Why does a bubble advance rather than stall the pipeline?
6. Why can throughput improve without reducing latency?
7. Which operations lie between each pair of pipeline registers?
8. What must change when the multiplier is connected to an accumulator?

## 16. Submission

- RTL modules, testbench, and any board wrapper or constraints.
- Encoding calculations and completed numerical-results table.
- Exhaustive-test console result and waveforms for latency, bubbles, and reset.
- Resource/timing report with tool version, device, and constraint assumptions.
- Discussion answers and a proposed MAC accumulator format.

## 17. References

1. AMD, [Vivado Synthesis User Guide (UG901): Multipliers](https://docs.amd.com/r/en-US/ug901-vivado-synthesis/Multipliers).
2. AMD, [UG901: Multipliers Implementation](https://docs.amd.com/r/en-US/ug901-vivado-synthesis/Multipliers-Implementation).
3. AMD, [Vivado Logic Simulation User Guide (UG900)](https://docs.amd.com/r/en-US/ug900-vivado-logic-simulation).
4. AMD, [Vivado Using Constraints User Guide (UG903)](https://docs.amd.com/r/en-US/ug903-vivado-using-constraints).
5. Digilent, [Nexys A7 Reference Manual](https://digilent.com/reference/programmable-logic/nexys-a7/reference-manual).

**Learning outcome:** Implement a signed fixed-point multiplier with explicitly defined numerical behavior, sample timing, and interface validity, providing a foundation for MAC and ANN hardware.
