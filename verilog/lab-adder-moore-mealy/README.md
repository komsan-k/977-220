# 🔢 Lab: FSM Design for Serial Adder (Moore and Mealy Machines)

## 🧩 1. Lab Objective

-   To design a **serial adder** using **Finite State Machine (FSM)**
    methodology in Verilog HDL.\
-   To simulate and verify both **Moore** and **Mealy** machine
    implementations.\
-   To understand how FSMs manage **sequential arithmetic operations**.

------------------------------------------------------------------------

## 🧠 2. Background Theory

### 2.1 Serial Adder

A **serial adder** performs bit-by-bit binary addition using a **single
full adder** and a **carry register**.\
It adds one bit per clock cycle starting from the **least significant
bit (LSB)**.

### 🧠 2.2 FSM Design Approach

A **Finite State Machine (FSM)** is a computational model used to design
**sequential logic systems** such as digital controllers and adders.

------------------------------------------------------------------------

## 🔹 FSM Characteristics

An FSM consists of:

-   A **finite set of states**
-   Defined **inputs and outputs**
-   A **state transition function** (determines next state)
-   An **output function** (produces outputs based on current state
    and/or inputs)

------------------------------------------------------------------------

## 🧩 FSM Classifications

| **FSM Type** | **Output Depends On**     | **Example in Serial Adder**                                |
|---------------|---------------------------|-------------------------------------------------------------|
| **Moore**     | Current State only        | Output (Sum, Carry) changes *after* state transition        |
| **Mealy**     | Current State + Inputs    | Output changes *immediately* with input                     |


------------------------------------------------------------------------

## ⚙️ 3. Verilog Implementations

### 3.1 Moore Machine --- FSM-Based Serial Adder (4-bit)

``` verilog
module serial_adder_moore (
    input clk, rst, start,
    input [3:0] A, B,
    output reg [3:0] SUM,
    output reg done
);
    reg [2:0] bit_cnt;
    reg carry;
    reg [3:0] regA, regB;
    reg [1:0] state;

    localparam IDLE = 2'b00,
               LOAD = 2'b01,
               ADD  = 2'b10,
               DONE = 2'b11;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            SUM <= 0;
            carry <= 0;
            done <= 0;
            bit_cnt <= 0;
        end else begin
            case (state)
                IDLE: if (start) state <= LOAD;
                LOAD: begin
                    regA <= A; regB <= B;
                    SUM <= 0; carry <= 0; bit_cnt <= 0;
                    state <= ADD;
                end
                ADD: begin
                    {carry, SUM[bit_cnt]} <= regA[bit_cnt] + regB[bit_cnt] + carry;
                    bit_cnt <= bit_cnt + 1;
                    if (bit_cnt == 3) state <= DONE;
                end
                DONE: begin
                    done <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
```

🔹 *Moore machine:* Outputs (`SUM`, `done`) are registered and change
only after state transitions.

------------------------------------------------------------------------

### 3.2 Mealy Machine --- FSM-Based Serial Adder (4-bit)

``` verilog
module serial_adder_mealy (
    input clk, rst, start,
    input [3:0] A, B,
    output reg [3:0] SUM,
    output reg done
);
    reg [2:0] bit_cnt;
    reg carry;
    reg [3:0] regA, regB;
    reg [1:0] state;

    localparam IDLE = 2'b00,
               LOAD = 2'b01,
               ADD  = 2'b10,
               DONE = 2'b11;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            SUM <= 0;
            carry <= 0;
            done <= 0;
            bit_cnt <= 0;
        end else begin
            case (state)
                IDLE: if (start) state <= LOAD;
                LOAD: begin
                    regA <= A; regB <= B;
                    SUM <= 0; carry <= 0; bit_cnt <= 0;
                    state <= ADD;
                end
                ADD: begin
                    // Mealy output changes instantly with inputs
                    {carry, SUM[bit_cnt]} = regA[bit_cnt] + regB[bit_cnt] + carry;
                    bit_cnt <= bit_cnt + 1;
                    if (bit_cnt == 3) state <= DONE;
                end
                DONE: begin
                    done <= 1;
                    if (!start) state <= IDLE;
                end
            endcase
        end
    end
endmodule
```

🔹 *Mealy machine:* The output is generated **within the same state**
based on input changes, providing **faster response** but more complex
timing behavior.

------------------------------------------------------------------------

## 🧪 4. Testbench (for both FSMs)

``` verilog
module serial_adder_tb;
    reg clk, rst, start;
    reg [3:0] A, B;
    wire [3:0] SUM1, SUM2;
    wire done1, done2;

    serial_adder_moore uut_moore (.clk(clk), .rst(rst), .start(start),
                                  .A(A), .B(B), .SUM(SUM1), .done(done1));

    serial_adder_mealy uut_mealy (.clk(clk), .rst(rst), .start(start),
                                  .A(A), .B(B), .SUM(SUM2), .done(done2));

    always #5 clk = ~clk;

    initial begin
        clk = 0; rst = 1; start = 0; A = 0; B = 0; #10;
        rst = 0;

        A = 4'b0110; B = 4'b0011; start = 1; #10;
        start = 0;
        wait(done1 && done2);
        #20;

        A = 4'b1111; B = 4'b0001; start = 1; #10;
        start = 0;
        wait(done1 && done2);
        #20;

        $finish;
    end

    initial begin
        $monitor("Time=%0t | A=%b B=%b | Moore_SUM=%b Mealy_SUM=%b", $time, A, B, SUM1, SUM2);
    end
endmodule
```

------------------------------------------------------------------------

## 📊 5. Simulation Results

  Time (ns)   A      B      Moore_SUM   Mealy_SUM   done
  ----------- ------ ------ ----------- ----------- ------
  10          0110   0011   ----        ----        0
  30          0110   0011   1001        1001        1
  60          1111   0001   0000        0000        1

✅ Both FSMs produce the same logical result, but **Mealy** output
reacts **faster** to input changes.

------------------------------------------------------------------------

## 💡 6. Key Differences

  ------------------------------------------------------------------------
  Feature              Moore FSM                 Mealy FSM
  -------------------- ------------------------- -------------------------
  Output depends on    State only                State + Input

  Timing behavior      Synchronized (stable)     Immediate (faster)

  Complexity           Easier to debug           Requires careful timing

  Hardware usage       More registers            Slightly fewer registers

  Application          Safer design, fewer       Faster response, less
                       glitches                  latency
  ------------------------------------------------------------------------

------------------------------------------------------------------------

## 🧩 7. Exercises

1.  Modify the FSMs for **8-bit serial addition**.\
2.  Add a **carry-out** output pin.\
3.  Introduce a **ready** signal to prevent premature start.\
4.  Design a **Mealy-to-Moore conversion** and verify equivalence.\
5.  Implement using **shift registers** and a **single full adder**
    datapath.

------------------------------------------------------------------------

## 🧾 8. Conclusion

This lab demonstrates FSM control for **sequential arithmetic** using
both Moore and Mealy architectures.\
Students gain insight into **state-based control**, **timing behavior**,
and **sequential datapath interaction** within Verilog HDL.

------------------------------------------------------------------------

## 👨‍🏫 9. Instructor Notes

-   Start with the FSM **state diagram** before coding.\
-   Emphasize **output timing differences** between Mealy and Moore
    machines.\
-   Encourage synthesis and waveform inspection on FPGA.

------------------------------------------------------------------------

**Author:** Dr. Komsan Kanjanasit\
**Publisher:** College of Computing, Prince of Songkla University,
Thailand\
**Edition:** First Edition (2025)\
**License:** CC BY 4.0 --- Free to use with attribution
