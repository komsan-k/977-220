# 🔢 FSMs in Serial Adder: Moore vs. Mealy Machines

## 🧩 1. Introduction

A **Serial Adder** adds two binary numbers **bit-by-bit** over multiple
clock cycles using a **single full adder** and a **carry flip-flop**.

Since the addition process depends on previous carry and sequential bit
inputs, it is naturally implemented using a **Finite State Machine
(FSM)**.

There are two main types of FSMs used for control logic in such
designs: - **Moore Machine** - **Mealy Machine**

Both perform the same logical function (bit-by-bit addition) but differ
in **when** and **how** the outputs are updated.

------------------------------------------------------------------------

## 🧠 2. FSM Overview

  ------------------------------------------------------------------------
  Feature          Moore Machine               Mealy Machine
  ---------------- --------------------------- ---------------------------
  **Output depends Current State only          Current State + Current
  on**                                         Input

  **Output         Changes **after** state     Changes **immediately**
  timing**         transition                  when input changes

  **Response       1 clock cycle delayed       Faster (can respond in same
  time**                                       cycle)

  **Complexity**   Easier to design & debug    Requires careful timing and
                                               synchronization

  **Glitch         Low                         Higher, due to input
  sensitivity**                                dependency
  ------------------------------------------------------------------------

------------------------------------------------------------------------

## ⚙️ 3. FSM Role in Serial Adder

In both FSM types, the **control unit** determines: 1. When to **read
new bits** from inputs `A` and `B` 2. When to **perform addition** 3.
How to **store the carry** 4. When to signal that the operation is
**complete (done)**

The datapath (adder + carry register) is the same in both cases: - One
**full adder** - One **carry flip-flop** - FSM controller for sequencing

------------------------------------------------------------------------

## 🧮 4. Moore Machine Serial Adder

### 🧠 Principle

In the **Moore implementation**, outputs (such as the sum bit and the
`done` flag) depend only on the **current state**.\
Thus, output changes **only after a clock edge** when the state
transitions occur.

### 🧩 FSM States

  ------------------------------------------------------------------------
  State              Description                      Output
  ------------------ -------------------------------- --------------------
  **S0 -- Idle**     Wait for `start`                 `SUM=0`, `carry=0`,
                                                      `done=0`

  **S1 -- Load**     Load `A` and `B` into internal   ---
                     registers                        

  **S2 -- Add**      Perform one-bit addition per     `SUM` output
                     cycle                            registered

  **S3 -- Done**     Signal addition complete         `done=1`
  ------------------------------------------------------------------------

### 🧱 Moore FSM Block Diagram

                 ┌────────────┐
       Inputs ─▶ │  FSM Ctrl  │ ──▶ Control signals
                 │ (Moore)    │
                 └─────┬──────┘
                       │
                       ▼
             ┌──────────────────┐
             │  Full Adder + FF │──▶ SUM
             │ (Carry Register) │──▶ Carry
             └──────────────────┘

### ⏱️ Timing Behavior

-   The **sum output** appears **after** the clock edge (state change).\
-   This makes the system more **stable** and predictable.\
-   Suitable for **FPGA hardware synthesis** where timing control is
    critical.

------------------------------------------------------------------------

## ⚡ 5. Mealy Machine Serial Adder

### 🧠 Principle

In a **Mealy FSM**, the output depends on both the **current state** and
**current input**.\
This means that the **sum bit** can update **immediately** when new
inputs (`A`, `B`) arrive, without waiting for a clock transition.

### 🧩 FSM States

  -----------------------------------------------------------------------
  State          Description               Output Behavior
  -------------- ------------------------- ------------------------------
  **S0 -- Idle** Wait for `start`          Output undefined

  **S1 -- Add    Add `A[i] + B[i] + carry` Output changes immediately
  Bit**                                    with input

  **S2 -- Done** Assert completion flag    `done=1`
  -----------------------------------------------------------------------

### 🧱 Mealy FSM Block Diagram

                 ┌────────────┐
       Inputs ─▶ │  FSM Ctrl  │ ─┐
                 │ (Mealy)    │  │
                 └─────┬──────┘  │
                       │          ▼
                       ▼    ┌────────────┐
                           │ Full Adder │──▶ SUM, Carry
                           └────────────┘

### ⏱️ Timing Behavior

-   The **sum** output reacts **immediately** to input changes, not
    waiting for the next clock edge.\
-   This makes it **faster**, but more sensitive to glitches or
    metastability if not synchronized properly.

------------------------------------------------------------------------

## 💻 6. Example Code Snippets

### 🔹 Moore Machine

``` verilog
always @(posedge clk or posedge rst) begin
    if (rst)
        state <= IDLE;
    else begin
        case (state)
            IDLE: if (start) state <= LOAD;
            LOAD: begin
                regA <= A; regB <= B; carry <= 0;
                bit_cnt <= 0; state <= ADD;
            end
            ADD: begin
                {carry, SUM[bit_cnt]} <= regA[bit_cnt] + regB[bit_cnt] + carry;
                bit_cnt <= bit_cnt + 1;
                if (bit_cnt == 3) state <= DONE;
            end
            DONE: done <= 1;
        endcase
    end
end
```

### 🔹 Mealy Machine

``` verilog
always @(posedge clk or posedge rst) begin
    if (rst)
        state <= IDLE;
    else begin
        case (state)
            IDLE: if (start) state <= ADD;
            ADD: begin
                // Immediate output response
                {carry, SUM[bit_cnt]} = regA[bit_cnt] + regB[bit_cnt] + carry;
                bit_cnt = bit_cnt + 1;
                if (bit_cnt == 3) state <= DONE;
            end
            DONE: done <= 1;
        endcase
    end
end
```

------------------------------------------------------------------------

## 📊 7. Comparison Summary

  -------------------------------------------------------------------------
  Feature         Moore Serial Adder           Mealy Serial Adder
  --------------- ---------------------------- ----------------------------
  **Output        Current State                State + Inputs
  dependency**                                 

  **Sum timing**  After state transition (1    Immediate with inputs
                  cycle delay)                 

  **Design        Easier to debug              Slightly complex
  simplicity**                                 

  **Response      Slower but stable            Faster but timing-sensitive
  speed**                                      

  **Hardware      Preferred for FPGA/ASIC      Used for low-latency designs
  suitability**                                
  -------------------------------------------------------------------------

------------------------------------------------------------------------

## 🧩 8. Practical Insight

-   In **FPGA design**, **Moore machines** are generally preferred for
    **synchronous and stable behavior**.\
-   In **high-speed communication or control systems**, **Mealy
    machines** can reduce latency since they react instantly to input
    changes.\
-   Both FSMs can perform **identical arithmetic operations**, but their
    **output timing** differs.

------------------------------------------------------------------------

## 🧾 9. Conclusion

The **Serial Adder FSM** illustrates the difference between Moore and
Mealy design philosophies: - **Moore FSM**: Reliable and clock-driven
--- safe for synchronous circuits.\
- **Mealy FSM**: Fast and responsive --- efficient for time-sensitive
systems.

Understanding both gives designers flexibility to balance **speed,
stability, and hardware complexity** in sequential logic design.

------------------------------------------------------------------------

**Author:** Dr. Komsan Kanjanasit\
**Publisher:** College of Computing, Prince of Songkla University,
Thailand\
**Edition:** First Edition (2025)\
**License:** CC BY 4.0 --- Free to use with attribution
