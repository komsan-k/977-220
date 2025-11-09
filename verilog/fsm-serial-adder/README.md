# 🔢 FSM Design for Serial Adder

## 🧩 1. Introduction

A **Serial Adder** is a **sequential circuit** that adds **two binary
numbers bit-by-bit** over multiple clock cycles using a **single full
adder** and a **flip-flop** to store the carry between additions.

Unlike a **parallel adder**, which adds all bits simultaneously, the
**serial adder** uses: - One **full adder** circuit - One **D
flip-flop** for carry storage - A **finite state machine (FSM)** to
control operations

This makes it **hardware-efficient** and ideal for FPGA-based
educational labs.

------------------------------------------------------------------------

## 🧠 2. Concept of Serial Addition

  Signal   Description
  -------- -------------------------------------
  `A`      Serial input of operand A
  `B`      Serial input of operand B
  `Cin`    Initial carry input
  `Clk`    Clock pulse for bit-by-bit addition
  `Sum`    Serial sum output
  `Cout`   Carry output from MSB

Each clock cycle performs **one bit addition** and stores the carry in a
flip-flop.

------------------------------------------------------------------------

## ⚙️ 3. Operation Principle

Formulas per clock cycle:

    Sum_i = A_i ⊕ B_i ⊕ C_i
    Carry_(i+1) = (A_i · B_i) + (B_i · C_i) + (A_i · C_i)

The **carry flip-flop** holds the carry for the next cycle, and the FSM
ensures proper sequencing of these operations.

------------------------------------------------------------------------

## 🔄 4. FSM States and Behavior

  ------------------------------------------------------------------------
  State             Description                     Outputs
  ----------------- ------------------------------- ----------------------
  **S0 -- Idle**    Wait for start signal; carry =  Sum = 0, Carry = 0
                    0                               

  **S1 -- Add Bit** Perform bit addition            Sum = A ⊕ B ⊕ Carry

  **S2 -- Store     Save carry in flip-flop         Carry = Cout
  Carry**                                           

  **S3 -- Done**    Stop after N bits               Sum valid, Carry final
  ------------------------------------------------------------------------

------------------------------------------------------------------------

## 📈 5. State Transition Diagram

            ┌───────────┐
            │   S0      │  (Idle)
            │ Carry=0   │
            └───┬───▲───┘
                │Start
                ▼
            ┌───────────┐
            │   S1      │  (Add Bit)
            │ Sum,Cout  │
            └───┬───▲───┘
                │Clk↑
                ▼
            ┌───────────┐
            │   S2      │  (Store Carry)
            │ Carry<=Cout│
            └───┬───▲───┘
                │More bits?
                │ Yes
                ▼
            ┌───────────┐
            │   S3      │  (Done)
            │ Output Sum │
            └───────────┘

------------------------------------------------------------------------

## 🧮 6. Example Timing Sequence

For A = 1011, B = 1101, Cin = 0

  Clock   A_i   B_i   Carry_in   Sum_i   Carry_out
  ------- ----- ----- ---------- ------- -----------
  1       1     1     0          0       1
  2       1     0     1          0       1
  3       0     1     1          0       1
  4       1     1     1          1       1

**Result:** Sum = 1000 (LSB first), Carry = 1 → Output = 10001

------------------------------------------------------------------------

## 💻 7. FSM-Based Verilog Model

``` verilog
module serial_adder_fsm (
    input clk, rst, start,
    input A, B,
    output reg Sum,
    output reg Done
);
    reg Carry;
    reg [2:0] bit_count;

    typedef enum reg [1:0] {S0, S1, S2, S3} state_t;
    state_t current_state, next_state;

    // Sequential logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= S0;
            Carry <= 0;
            bit_count <= 0;
        end else begin
            current_state <= next_state;
            if (current_state == S2)
                Carry <= (A & B) | (A & Carry) | (B & Carry);
            if (current_state == S1)
                bit_count <= bit_count + 1;
        end
    end

    // Combinational logic
    always @(*) begin
        case (current_state)
            S0: begin
                Done = 0;
                if (start) next_state = S1; else next_state = S0;
            end
            S1: begin
                Sum = A ^ B ^ Carry;
                next_state = S2;
            end
            S2: begin
                if (bit_count == 3'd4)
                    next_state = S3;
                else
                    next_state = S1;
            end
            S3: begin
                Done = 1;
                next_state = S0;
            end
        endcase
    end
endmodule
```

------------------------------------------------------------------------

## 🔧 8. Hardware Architecture

          ┌────────────┐
     A ──▶│            │
     B ──▶│ Full Adder │──▶ Sum (output)
          │            │
          └─────┬──────┘
                │
             Carry_out
                │
             ┌──▼──┐
             │ DFF │ (Carry Register)
             └──┬──┘
                │
                └──▶ Back to Full Adder Carry_in

-   **FSM Controller** manages sequencing.\
-   **Full Adder** performs bit addition.\
-   **Carry Register** stores carry for the next cycle.

------------------------------------------------------------------------

## 📊 9. Advantages

  Feature                  Description
  ------------------------ -----------------------------------------
  **Hardware Efficient**   Uses one full adder instead of multiple
  **FSM Controlled**       Predictable sequence and easy debugging
  **Scalable**             Extendable to any bit width
  **FPGA Friendly**        Low LUT and resource usage

------------------------------------------------------------------------

## 🧾 10. Summary

-   FSM controls the sequence of bit-by-bit addition.\
-   The carry is stored and propagated each clock cycle.\
-   The serial adder combines **datapath (adder + carry)** with
    **control logic (FSM)**.\
-   Excellent example of **control-datapath integration** in digital
    design.

------------------------------------------------------------------------

**Author:** Dr. Komsan Kanjanasit\
**Publisher:** College of Computing, Prince of Songkla University,
Thailand\
**Edition:** First Edition (2025)\
**License:** CC BY 4.0 --- Free to use with attribution
