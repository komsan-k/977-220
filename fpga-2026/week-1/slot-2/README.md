# 🔬 Lab: Verilog/SystemVerilog-2 — Combinational Design

## Multiplexer, Decoder, Encoder, and Adder/Subtractor

## 🧩 1. Objective

* Understand the design principles of **combinational digital circuits**.
* Implement multiplexers, decoders, encoders, and arithmetic circuits using **Verilog/SystemVerilog**.
* Practice multiple HDL coding styles for combinational logic.
* Create testbenches for functional verification.
* Use truth tables and Boolean equations to validate circuit behavior.
* Understand the importance of complete assignments in combinational blocks.
* Develop a foundation for larger datapaths, ALUs, processors, and FPGA accelerators.

---

## ⚙️ 2. Equipment and Tools

| Tool / Resource                                       | Description                             |
| ----------------------------------------------------- | --------------------------------------- |
| **EDA Playground**                                    | Online Verilog/SystemVerilog simulation |
| **Web Browser**                                       | Access to the online simulator          |
| **Verilog/SystemVerilog**                             | Hardware description language           |
| **Icarus Verilog / Verilator / Questa or equivalent** | Simulation engine                       |
| **EPWave**                                            | Waveform viewer                         |
| **Testbench**                                         | Functional verification environment     |

---

## 🧠 3. Background Theory

### 3.1 Combinational Logic

A combinational circuit produces outputs determined only by the current inputs.

Mathematically,

$$
Y=f(X_1,X_2,\ldots,X_n).
$$

No previous state is stored.

The basic structure is

```text
Inputs
   │
   ▼
Combinational Logic
   │
   ▼
Outputs
```

Examples include:

* multiplexers,
* decoders,
* encoders,
* comparators,
* adders,
* subtractors,
* arithmetic logic units.

---

### 3.2 Combinational HDL Modeling

Combinational circuits can be written using:

* continuous assignment,
* `always @(*)`,
* `always_comb`,
* `case`,
* `if-else`,
* structural module instantiation.

For example,

```verilog
assign Y = S ? D1 : D0;
```

or

```systemverilog
always_comb begin
    if (S)
        Y = D1;
    else
        Y = D0;
end
```

Both describe a 2-to-1 multiplexer.

---

# 🔀 4. Study Case 1 — 2-to-1 Multiplexer

## 4.1 Multiplexer Function

A multiplexer selects one of several input signals.

For a 2-to-1 multiplexer:

* Inputs: (D_0,D_1)
* Select: (S)
* Output: (Y)

The function is

$$
Y=
\begin{cases}
D_0,&S=0\
D_1,&S=1.
\end{cases}
$$

The Boolean equation is

$$
Y=\overline{S}D_0+SD_1.
$$

---

## 4.2 Truth Table

|  S  |  D0 |  D1 |  Y  |
| :-: | :-: | :-: | :-: |
|  0  |  0  |  X  |  0  |
|  0  |  1  |  X  |  1  |
|  1  |  X  |  0  |  0  |
|  1  |  X  |  1  |  1  |

`X` means don't care.

---

## 4.3 Verilog Implementation

```verilog
module mux2to1(
    input  wire D0,
    input  wire D1,
    input  wire S,
    output wire Y
);

    assign Y = S ? D1 : D0;

endmodule
```

---

## 4.4 SystemVerilog Implementation

```systemverilog
module mux2to1_sv(
    input  logic D0,
    input  logic D1,
    input  logic S,
    output logic Y
);

    always_comb begin

        if (S)
            Y = D1;
        else
            Y = D0;

    end

endmodule
```

---

# 🔀 5. Study Case 2 — 4-to-1 Multiplexer

A 4-to-1 multiplexer contains:

* four data inputs,
* two select bits,
* one output.

Let

$$
D=[D_3,D_2,D_1,D_0]
$$

and

$$
S=[S_1S_0].
$$

The output is

$$
Y=
\begin{cases}
D_0,&S=00\
D_1,&S=01\
D_2,&S=10\
D_3,&S=11.
\end{cases}
$$

---

## 5.1 Truth Table

|  S1 |  S0 | Selected Input |
| :-: | :-: | -------------- |
|  0  |  0  | D0             |
|  0  |  1  | D1             |
|  1  |  0  | D2             |
|  1  |  1  | D3             |

---

## 5.2 SystemVerilog Implementation

```systemverilog
module mux4to1(
    input  logic [3:0] D,
    input  logic [1:0] S,
    output logic Y
);

    always_comb begin

        case (S)

            2'b00: Y = D[0];
            2'b01: Y = D[1];
            2'b10: Y = D[2];
            2'b11: Y = D[3];

            default: Y = 1'b0;

        endcase

    end

endmodule
```

---

# 🔢 6. Study Case 3 — 2-to-4 Decoder

## 6.1 Decoder Function

A decoder converts an (n)-bit input into one of

$$
2^n
$$

active outputs.

For a 2-to-4 decoder:

* Input: (A_1A_0)
* Outputs: (Y_3Y_2Y_1Y_0)

Only one output is active at a time.

---

## 6.2 Truth Table

|  A1 |  A0 |  Y3 |  Y2 |  Y1 |  Y0 |
| :-: | :-: | :-: | :-: | :-: | :-: |
|  0  |  0  |  0  |  0  |  0  |  1  |
|  0  |  1  |  0  |  0  |  1  |  0  |
|  1  |  0  |  0  |  1  |  0  |  0  |
|  1  |  1  |  1  |  0  |  0  |  0  |

---

## 6.3 Boolean Equations

$$
Y_0=\overline{A_1}\overline{A_0}
$$

$$
Y_1=\overline{A_1}A_0
$$

$$
Y_2=A_1\overline{A_0}
$$

$$
Y_3=A_1A_0.
$$

---

## 6.4 Verilog Implementation

```verilog
module decoder2to4(
    input  wire [1:0] A,
    output reg  [3:0] Y
);

    always @(*) begin

        case (A)

            2'b00: Y = 4'b0001;
            2'b01: Y = 4'b0010;
            2'b10: Y = 4'b0100;
            2'b11: Y = 4'b1000;

            default: Y = 4'b0000;

        endcase

    end

endmodule
```

---

# 🔢 7. Study Case 4 — 3-to-8 Decoder

A 3-bit input can select one of eight outputs.

$$
2^3=8.
$$

For example,

```text
A = 101
```

activates

```text
Y5 = 1
```

while all other outputs remain zero.

A compact SystemVerilog implementation is

```systemverilog
module decoder3to8(
    input  logic [2:0] A,
    output logic [7:0] Y
);

    always_comb begin

        Y = 8'b00000000;
        Y[A] = 1'b1;

    end

endmodule
```

---

# 🔡 8. Study Case 5 — 4-to-2 Encoder

## 8.1 Encoder Function

An encoder performs the reverse operation of a decoder.

A 4-to-2 encoder converts one active input into a 2-bit binary code.

Inputs:

$$
D_3,D_2,D_1,D_0.
$$

Output:

$$
Y_1Y_0.
$$

---

## 8.2 Truth Table

|  D3 |  D2 |  D1 |  D0 |  Y1 |  Y0 |
| :-: | :-: | :-: | :-: | :-: | :-: |
|  0  |  0  |  0  |  1  |  0  |  0  |
|  0  |  0  |  1  |  0  |  0  |  1  |
|  0  |  1  |  0  |  0  |  1  |  0  |
|  1  |  0  |  0  |  0  |  1  |  1  |

This assumes exactly one input is active.

---

## 8.3 SystemVerilog Implementation

```systemverilog
module encoder4to2(
    input  logic [3:0] D,
    output logic [1:0] Y
);

    always_comb begin

        case (D)

            4'b0001: Y = 2'b00;
            4'b0010: Y = 2'b01;
            4'b0100: Y = 2'b10;
            4'b1000: Y = 2'b11;

            default: Y = 2'b00;

        endcase

    end

endmodule
```

---

# ⚠️ 9. Limitation of a Simple Encoder

A normal encoder assumes that only one input is active.

For example,

```text
D = 1010
```

is ambiguous because more than one input is high.

To solve this problem, a **priority encoder** is used.

---

# 🔡 10. Study Case 6 — Priority Encoder

Assume priority order

$$
D_3>D_2>D_1>D_0.
$$

Then the highest active input determines the output.

---

## 10.1 Priority Encoder Table

| Highest Active Input | Output |
| -------------------- | :----: |
| D3                   |  `11`  |
| D2                   |  `10`  |
| D1                   |  `01`  |
| D0                   |  `00`  |

---

## 10.2 SystemVerilog Implementation

```systemverilog
module priority_encoder4(
    input  logic [3:0] D,
    output logic [1:0] Y,
    output logic valid
);

    always_comb begin

        Y = 2'b00;
        valid = 1'b1;

        if (D[3])
            Y = 2'b11;

        else if (D[2])
            Y = 2'b10;

        else if (D[1])
            Y = 2'b01;

        else if (D[0])
            Y = 2'b00;

        else begin
            Y = 2'b00;
            valid = 1'b0;
        end

    end

endmodule
```

---

# ➕ 11. Study Case 7 — Half Adder

A half adder adds two single-bit inputs.

The outputs are:

$$
SUM=A\oplus B
$$

and

$$
CARRY=AB.
$$

---

## 11.1 Verilog Implementation

```verilog
module half_adder(
    input  wire A,
    input  wire B,
    output wire SUM,
    output wire CARRY
);

    assign SUM   = A ^ B;
    assign CARRY = A & B;

endmodule
```

---

## 11.2 Truth Table

|  A  |  B  | SUM | CARRY |
| :-: | :-: | :-: | :---: |
|  0  |  0  |  0  |   0   |
|  0  |  1  |  1  |   0   |
|  1  |  0  |  1  |   0   |
|  1  |  1  |  0  |   1   |

---

# ➕ 12. Study Case 8 — Full Adder

A full adder adds

$$
A+B+C_{in}.
$$

Outputs:

$$
SUM=A\oplus B\oplus C_{in}
$$

and

$$
C_{out}=AB+C_{in}(A\oplus B).
$$

---

## 12.1 Verilog Implementation

```verilog
module full_adder(
    input  wire A,
    input  wire B,
    input  wire CIN,
    output wire SUM,
    output wire COUT
);

    assign SUM = A ^ B ^ CIN;

    assign COUT =
        (A & B) |
        (CIN & (A ^ B));

endmodule
```

---

# ➖ 13. Study Case 9 — Half Subtractor

A half subtractor computes

$$
A-B.
$$

Outputs:

* Difference
* Borrow

The equations are

$$
D=A\oplus B
$$

and

$$
Borrow=\overline{A}B.
$$

---

## 13.1 Truth Table

|  A  |  B  | Difference | Borrow |
| :-: | :-: | :--------: | :----: |
|  0  |  0  |      0     |    0   |
|  0  |  1  |      1     |    1   |
|  1  |  0  |      1     |    0   |
|  1  |  1  |      0     |    0   |

---

## 13.2 Verilog Implementation

```verilog
module half_subtractor(
    input  wire A,
    input  wire B,
    output wire D,
    output wire BORROW
);

    assign D      = A ^ B;
    assign BORROW = (~A) & B;

endmodule
```

---

# ➕➖ 14. Study Case 10 — 4-Bit Adder/Subtractor

A single circuit can perform both addition and subtraction.

Use control input

$$
MODE.
$$

If

$$
MODE=0,
$$

perform

$$
A+B.
$$

If

$$
MODE=1,
$$

perform

$$
A-B.
$$

Using two's complement,

$$
A-B=A+\overline{B}+1.
$$

Therefore,

$$
B' = B \oplus MODE
$$

and

$$
C_{in}=MODE.
$$

---

# 🧠 15. Adder/Subtractor Principle

For addition:

$$
MODE=0
$$

gives

$$
B'=B
$$

and

$$
C_{in}=0.
$$

Therefore,

$$
Y=A+B.
$$

For subtraction:

$$
MODE=1
$$

gives

$$
B'=\overline{B}
$$

and

$$
C_{in}=1.
$$

Therefore,

$$
Y=A+\overline{B}+1=A-B.
$$

---

# 💻 16. Four-Bit Adder/Subtractor Module

```systemverilog
module add_sub4(
    input  logic [3:0] A,
    input  logic [3:0] B,
    input  logic       MODE,

    output logic [3:0] RESULT,
    output logic       COUT
);

    logic [3:0] B_mod;
    logic [4:0] temp;

    always_comb begin

        B_mod = B ^ {4{MODE}};

        temp =
            {1'b0, A}
            + {1'b0, B_mod}
            + MODE;

        RESULT = temp[3:0];
        COUT   = temp[4];

    end

endmodule
```

---

# 📊 17. Example Adder/Subtractor Results

| MODE |  A |  B | Operation | RESULT |
| :--: | -: | -: | --------- | -----: |
|   0  |  3 |  2 | (3+2)     |      5 |
|   0  |  7 |  5 | (7+5)     |     12 |
|   1  |  7 |  3 | (7-3)     |      4 |
|   1  |  9 |  4 | (9-4)     |      5 |

---

# 🧪 18. Testbench for 2-to-1 Multiplexer

```systemverilog
`timescale 1ns/1ps

module tb_mux2to1;

    logic D0;
    logic D1;
    logic S;

    logic Y;

    mux2to1_sv dut (
        .D0(D0),
        .D1(D1),
        .S(S),
        .Y(Y)
    );

    initial begin

        $dumpfile("dump.vcd");
        $dumpvars(0, tb_mux2to1);

        D0 = 0; D1 = 1; S = 0; #10;
        D0 = 0; D1 = 1; S = 1; #10;

        D0 = 1; D1 = 0; S = 0; #10;
        D0 = 1; D1 = 0; S = 1; #10;

        $finish;

    end

endmodule
```

---

# 🧪 19. Decoder Testbench

```systemverilog
`timescale 1ns/1ps

module tb_decoder2to4;

    logic [1:0] A;
    logic [3:0] Y;

    decoder2to4 dut (
        .A(A),
        .Y(Y)
    );

    initial begin

        $dumpfile("dump.vcd");
        $dumpvars(0, tb_decoder2to4);

        A = 2'b00; #10;
        A = 2'b01; #10;
        A = 2'b10; #10;
        A = 2'b11; #10;

        $finish;

    end

endmodule
```

Expected output:

```text
00 → 0001
01 → 0010
10 → 0100
11 → 1000
```

---

# 🧪 20. Priority Encoder Testbench

```systemverilog
`timescale 1ns/1ps

module tb_priority_encoder;

    logic [3:0] D;

    logic [1:0] Y;
    logic valid;

    priority_encoder4 dut (
        .D(D),
        .Y(Y),
        .valid(valid)
    );

    initial begin

        D = 4'b0000; #10;
        D = 4'b0001; #10;
        D = 4'b0011; #10;
        D = 4'b0111; #10;
        D = 4'b1111; #10;

        $finish;

    end

endmodule
```

Expected highest-priority outputs:

```text
0000 → valid = 0
0001 → 00
0011 → 01
0111 → 10
1111 → 11
```

---

# 🧪 21. Adder/Subtractor Testbench

```systemverilog
`timescale 1ns/1ps

module tb_add_sub4;

    logic [3:0] A;
    logic [3:0] B;
    logic MODE;

    logic [3:0] RESULT;
    logic COUT;

    add_sub4 dut (
        .A(A),
        .B(B),
        .MODE(MODE),
        .RESULT(RESULT),
        .COUT(COUT)
    );

    initial begin

        $dumpfile("dump.vcd");
        $dumpvars(0, tb_add_sub4);

        // Addition
        MODE = 0;

        A = 4'd3;
        B = 4'd2;
        #10;

        A = 4'd7;
        B = 4'd5;
        #10;

        // Subtraction
        MODE = 1;

        A = 4'd7;
        B = 4'd3;
        #10;

        A = 4'd9;
        B = 4'd4;
        #10;

        $finish;

    end

endmodule
```

---

# ✅ 22. Self-Checking Adder/Subtractor Testbench

```systemverilog
module tb_add_sub_check;

    logic [3:0] A;
    logic [3:0] B;
    logic MODE;

    logic [3:0] RESULT;
    logic COUT;

    logic [4:0] expected;

    integer i;
    integer j;

    add_sub4 dut (
        .A(A),
        .B(B),
        .MODE(MODE),
        .RESULT(RESULT),
        .COUT(COUT)
    );

    initial begin

        MODE = 0;

        for (i = 0; i < 16; i++) begin
            for (j = 0; j < 16; j++) begin

                A = i;
                B = j;

                #1;

                expected = A + B;

                if ({COUT, RESULT} !== expected)
                    $display(
                        "ADD FAIL A=%0d B=%0d",
                        A, B
                    );

            end
        end

        $display("Addition test complete.");

        $finish;

    end

endmodule
```

This demonstrates **exhaustive verification**.

---

# 🌐 23. EDA Playground Procedure

## Step 1 — Open EDA Playground

Create a new playground.

---

## Step 2 — Select Language

Choose

```text
SystemVerilog
```

for the exercises using `logic` and `always_comb`.

---

## Step 3 — Select Simulator

Choose an available simulator such as:

```text
Icarus Verilog
```

or another SystemVerilog-capable option.

---

## Step 4 — Enter DUT

Place the module under test in the design window.

---

## Step 5 — Enter Testbench

Place the testbench in the testbench window.

---

## Step 6 — Enable Waveform Dumping

Include

```systemverilog
$dumpfile("dump.vcd");
$dumpvars(0, tb);
```

where appropriate.

---

## Step 7 — Run

Click

```text
Run
```

and inspect:

* compiler messages,
* simulation output,
* EPWave waveform.

---

# 📈 24. Waveform Analysis

The waveform should show how combinational outputs react to input changes.

For example,

```text
S  ____--------____--------
D0 ____----____----____----
D1 --------________--------
Y  ____--------____--------
```

No clock is required.

When an input changes, the output changes according to the combinational logic.

---

# 🧠 25. Complete Assignment Rule

In `always_comb` or `always @(*)`, every output must receive a value for all possible conditions.

Incorrect:

```systemverilog
always_comb begin

    if (S)
        Y = D1;

end
```

This can imply memory behavior.

Correct:

```systemverilog
always_comb begin

    if (S)
        Y = D1;
    else
        Y = D0;

end
```

---

# ⚠️ 26. Default Assignment Technique

A useful coding style is

```systemverilog
always_comb begin

    Y = 1'b0;

    case (S)

        2'b00: Y = D0;
        2'b01: Y = D1;
        2'b10: Y = D2;
        2'b11: Y = D3;

    endcase

end
```

The default assignment helps avoid unintended latches.

---

# 🧠 27. `case` versus `if-else`

Use `case` when selecting among several discrete values.

Example:

```systemverilog
case (S)
    2'b00: ...
    2'b01: ...
    2'b10: ...
    2'b11: ...
endcase
```

Use `if-else` when expressing priority or conditions.

Example:

```systemverilog
if (D[3])
    ...
else if (D[2])
    ...
```

This is why a priority encoder is naturally written using `if-else`.

---

# 🔍 28. Priority Logic

In

```systemverilog
if (D[3])
    ...
else if (D[2])
    ...
else if (D[1])
    ...
```

the first true condition wins.

Therefore,

$$
D_3
$$

has the highest priority.

This is different from a normal encoder where simultaneous active inputs are not expected.

---

# 🧮 29. Carry and Borrow

In addition,

$$
C_{out}
$$

represents carry from the most significant bit.

In subtraction,

a borrow condition may indicate that

$$
A<B.
$$

When using two's complement subtraction, interpretation of carry/borrow requires care.

For unsigned subtraction, an additional comparator may be used to generate an explicit borrow flag:

```systemverilog
assign borrow = (A < B);
```

---

# ⚖️ 30. Signed versus Unsigned Arithmetic

By default, a vector such as

```systemverilog
logic [3:0] A;
```

is unsigned.

For signed arithmetic:

```systemverilog
logic signed [3:0] A;
```

The range of an unsigned 4-bit value is

$$
0\leq A\leq15.
$$

The range of a signed 4-bit two's-complement value is

$$
-8\leq A\leq7.
$$

This distinction is important for arithmetic circuits.

---

# 🧠 31. Overflow in Signed Addition

For signed addition, overflow occurs when:

* two positive numbers produce a negative result, or
* two negative numbers produce a positive result.

A common overflow equation is

$$
V=
(A_{MSB}=B_{MSB})
\land
(R_{MSB}\neq A_{MSB}).
$$

This can be added as an advanced extension to the adder/subtractor.

---

# 🧪 32. Lab Tasks

### Task 1 — 2-to-1 Multiplexer

Implement and simulate a 2-to-1 MUX.

### Task 2 — 4-to-1 Multiplexer

Use a `case` statement to select one of four inputs.

### Task 3 — 2-to-4 Decoder

Implement one-hot output decoding.

### Task 4 — 3-to-8 Decoder

Extend the decoder to three inputs.

### Task 5 — 4-to-2 Encoder

Implement the simple encoder.

### Task 6 — Priority Encoder

Allow multiple simultaneous active inputs and give priority to the highest input.

### Task 7 — Half Adder

Implement and verify `SUM` and `CARRY`.

### Task 8 — Full Adder

Add `Cin` and verify all eight combinations.

### Task 9 — Half Subtractor

Implement `DIFFERENCE` and `BORROW`.

### Task 10 — 4-Bit Adder/Subtractor

Use one control input to select addition or subtraction.

---

# 📋 33. Experimental Results

| Circuit          | Input Condition | Expected Output | Simulated Output | Pass/Fail |
| ---------------- | --------------- | --------------- | ---------------- | --------- |
| 2-to-1 MUX       |                 |                 |                  |           |
| 4-to-1 MUX       |                 |                 |                  |           |
| Decoder          |                 |                 |                  |           |
| Encoder          |                 |                 |                  |           |
| Priority Encoder |                 |                 |                  |           |
| Half Adder       |                 |                 |                  |           |
| Full Adder       |                 |                 |                  |           |
| Half Subtractor  |                 |                 |                  |           |
| Adder/Subtractor |                 |                 |                  |           |

---

# 📊 34. Decoder Verification Table

| Input | Expected Output | Simulated Output |
| :---: | :-------------: | :--------------: |
|  `00` |      `0001`     |                  |
|  `01` |      `0010`     |                  |
|  `10` |      `0100`     |                  |
|  `11` |      `1000`     |                  |

---

# 📊 35. Adder/Subtractor Verification Table

| MODE |  A |  B |         Expected Result | Simulated Result |
| :--: | -: | -: | ----------------------: | ---------------: |
|   0  |  3 |  2 |                       5 |                  |
|   0  |  7 |  5 |                      12 |                  |
|   0  | 15 |  1 |            0 with carry |                  |
|   1  |  7 |  3 |                       4 |                  |
|   1  |  9 |  4 |                       5 |                  |
|   1  |  3 |  7 | two's-complement result |                  |

---

# 💬 36. Discussion Points

1. What is a multiplexer?
2. What is the difference between a multiplexer and decoder?
3. What is the difference between a decoder and encoder?
4. Why is a priority encoder needed?
5. What is the purpose of a `case` statement?
6. Why is `if-else` useful for priority logic?
7. What is the difference between a half adder and full adder?
8. What is the purpose of carry?
9. What is the purpose of borrow?
10. How can subtraction be implemented using addition?
11. Why is two's-complement arithmetic useful?
12. What is the difference between signed and unsigned arithmetic?
13. What causes unintended latches?
14. Why is exhaustive verification useful for small combinational circuits?

---

# 🧠 37. Post-Lab Exercises

1. **8-to-1 Multiplexer**
   Extend the MUX to eight inputs.

2. **4-to-16 Decoder**
   Implement a larger one-hot decoder.

3. **8-to-3 Priority Encoder**
   Expand the priority encoder.

4. **4-Bit Ripple-Carry Adder**
   Construct the adder structurally from full adders.

5. **4-Bit Subtractor**
   Implement subtraction with borrow.

6. **Overflow Flag**
   Add signed overflow detection.

7. **Zero Flag**
   Generate

   $$
   Z=1
   $$

   when the result is zero.

8. **Negative Flag**
   For signed arithmetic, use the MSB to indicate a negative result.

9. **Comparator Integration**
   Add outputs for:

   * (A>B),
   * (A=B),
   * (A<B).

10. **Parameterized Width**
    Convert the 4-bit adder/subtractor into an (N)-bit module.

---

# 🔬 38. Advanced Exercise — Parameterized Adder/Subtractor

```systemverilog
module add_sub #(
    parameter N = 8
)(
    input  logic [N-1:0] A,
    input  logic [N-1:0] B,
    input  logic         MODE,

    output logic [N-1:0] RESULT,
    output logic         COUT
);

    logic [N-1:0] B_mod;
    logic [N:0] temp;

    always_comb begin

        B_mod = B ^ {N{MODE}};

        temp =
            {1'b0, A}
            + {1'b0, B_mod}
            + MODE;

        RESULT = temp[N-1:0];
        COUT   = temp[N];

    end

endmodule
```

This introduces **parameterized hardware design**.

---

# 🚀 39. Advanced Exercise — Mini ALU

Combine the laboratory circuits into a small ALU.

Inputs:

$$
A[3:0], B[3:0].
$$

Control:

$$
OP[2:0].
$$

Suggested operations:

|   OP  | Operation   |
| :---: | ----------- |
| `000` | (A+B)       |
| `001` | (A-B)       |
| `010` | (A\land B)  |
| `011` | (A\lor B)   |
| `100` | (A\oplus B) |
| `101` | (A>B)       |
| `110` | Pass A      |
| `111` | Pass B      |

Example:

```systemverilog
module mini_alu(
    input  logic [3:0] A,
    input  logic [3:0] B,
    input  logic [2:0] OP,

    output logic [4:0] Y
);

    always_comb begin

        case (OP)

            3'b000:
                Y = A + B;

            3'b001:
                Y = {1'b0, A - B};

            3'b010:
                Y = {1'b0, A & B};

            3'b011:
                Y = {1'b0, A | B};

            3'b100:
                Y = {1'b0, A ^ B};

            3'b101:
                Y = {4'b0000, A > B};

            3'b110:
                Y = {1'b0, A};

            3'b111:
                Y = {1'b0, B};

            default:
                Y = 5'b00000;

        endcase

    end

endmodule
```

---

# 🔄 40. Recommended EDA Playground Workflow

```text
Truth Table / Function
        │
        ▼
Write Verilog/SystemVerilog
        │
        ▼
Create Testbench
        │
        ▼
Run Simulation
        │
        ▼
Inspect Console
        │
        ▼
Open EPWave
        │
        ▼
Compare Results
        │
        ├── Incorrect → Modify HDL
        │
        └── Correct
                │
                ▼
        Complete Design
```

---

# 🧾 41. Expected Learning Outcomes

After completing this laboratory, students will be able to:

* Explain the operation of multiplexers, decoders, and encoders.
* Distinguish between normal and priority encoders.
* Implement combinational arithmetic circuits.
* Design half and full adders.
* Implement subtraction using two's complement.
* Build a combined adder/subtractor.
* Use `case`, `if-else`, and `always_comb`.
* Avoid incomplete combinational assignments.
* Create functional and self-checking testbenches.
* Verify combinational designs using EDA Playground and EPWave.
* Understand signed, unsigned, carry, borrow, and overflow concepts.
* Apply combinational blocks to more advanced datapaths and ALUs.

---

# 📘 42. References

1. M. M. Mano and M. D. Ciletti, *Digital Design*, Pearson.
2. S. Brown and Z. Vranesic, *Fundamentals of Digital Logic with Verilog Design*, McGraw-Hill.
3. M. D. Ciletti, *Advanced Digital Design with the Verilog HDL*, Pearson.
4. D. M. Harris and S. L. Harris, *Digital Design and Computer Architecture*, Morgan Kaufmann.
5. IEEE Std 1364-2005, *IEEE Standard for Verilog Hardware Description Language*.
6. IEEE Std 1800, *SystemVerilog—Unified Hardware Design, Specification, and Verification Language*.

---

## 🔑 Key Concept

The central idea of this laboratory is

$$
\boxed{
\text{Inputs}
\rightarrow
\text{Combinational Function}
\rightarrow
\text{Outputs}
}
$$

The major building blocks are

$$
\boxed{
\text{MUX}
+
\text{Decoder}
+
\text{Encoder}
+
\text{Adder/Subtractor}
}
$$

and the design workflow is

$$
\boxed{
\text{Truth Table}
\rightarrow
\text{HDL}
\rightarrow
\text{Testbench}
\rightarrow
\text{Simulation}
\rightarrow
\text{Verification}
}
$$

This laboratory provides the foundation for later work involving **comparators, ALUs, datapaths, sequential logic, FSMs, processors, FPGA implementation, and AI-hardware accelerators**.
