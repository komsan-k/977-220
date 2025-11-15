# Verilog Stopwatch Simulation (BCD Counter)

This provides instructions for simulating a **BCD-based
stopwatch** (minute / second / centi-second) using Verilog.
It includes:
- BCD counter module
- Stopwatch top module
- Simulation testbench
- Instructions for running the simulation

------------------------------------------------------------------------

## 1. BCD Counter Module

Save as **`bcd_counter.v`**:

``` verilog
module bcd_counter (
    input clk,
    input rst,
    output reg [3:0] tens,
    output reg [3:0] ones
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ones <= 0;
            tens <= 0;
        end else begin
            if (ones == 9) begin
                ones <= 0;
                if (tens == 9)
                    tens <= 0;
                else
                    tens <= tens + 1;
            end else begin
                ones <= ones + 1;
            end
        end
    end
endmodule
```

------------------------------------------------------------------------

## 2. Stopwatch Top Module
<!---
Save as **`stopwatch.v`**:

``` verilog
module stopwatch (
    input  clk,
    input  rst,
    output [3:0] min_tens,
    output [3:0] min_ones,
    output [3:0] sec_tens,
    output [3:0] sec_ones,
    output [3:0] cs_tens,
    output [3:0] cs_ones
);

    wire [3:0] cs_tens_int, cs_ones_int;
    reg  cs_rollover;

    bcd_counter u_cs (
        .clk (clk),
        .rst (rst),
        .tens(cs_tens_int),
        .ones(cs_ones_int)
    );

    always @(*) begin
        cs_rollover = (cs_tens_int == 9 && cs_ones_int == 9);
    end

    assign cs_tens = cs_tens_int;
    assign cs_ones = cs_ones_int;

    reg sec_clk;
    always @(posedge clk or posedge rst) begin
        if (rst)
            sec_clk <= 0;
        else
            sec_clk <= cs_rollover;
    end

    wire [3:0] sec_tens_int, sec_ones_int;
    reg  sec_rollover;

    bcd_counter u_sec (
        .clk (sec_clk),
        .rst (rst),
        .tens(sec_tens_int),
        .ones(sec_ones_int)
    );

    always @(*) begin
        sec_rollover = (sec_tens_int == 9 && sec_ones_int == 9);
    end

    assign sec_tens = sec_tens_int;
    assign sec_ones = sec_ones_int;

    reg min_clk;
    always @(posedge clk or posedge rst) begin
        if (rst)
            min_clk <= 0;
        else
            min_clk <= sec_rollover;
    end

    bcd_counter u_min (
        .clk (min_clk),
        .rst (rst),
        .tens(min_tens),
        .ones(min_ones)
    );

endmodule
```
<---
------------------------------------------------------------------------

## 3. Testbench for Simulation

Save as **`tb_stopwatch.v`**:

``` verilog
`timescale 1ms/1us

module tb_stopwatch;

    reg clk;
    reg rst;

    wire [3:0] min_tens, min_ones;
    wire [3:0] sec_tens, sec_ones;
    wire [3:0] cs_tens,  cs_ones;

    stopwatch dut (
        .clk      (clk),
        .rst      (rst),
        .min_tens (min_tens),
        .min_ones (min_ones),
        .sec_tens (sec_tens),
        .sec_ones (sec_ones),
        .cs_tens  (cs_tens),
        .cs_ones  (cs_ones)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1;
        #20;
        rst = 0;

        #200000;
        $finish;
    end

    initial begin
        $display("   time |   mm:ss:cs");
        $monitor("%6t |   %0d%0d:%0d%0d:%0d%0d",
                 $time,
                 min_tens, min_ones,
                 sec_tens, sec_ones,
                 cs_tens,  cs_ones);
    end

endmodule
```

------------------------------------------------------------------------

## 4. Simulation Instructions

1.  Open Vivado, ModelSim, or another Verilog simulator.
2.  Create a new simulation project.
3.  Add the files:
    -   `bcd_counter.v`
    -   `stopwatch.v`
    -   `tb_stopwatch.v` (testbench)
4.  Set `tb_stopwatch` as **top module**.
5.  Compile / Elaborate.
6.  Run simulation for **200,000 ms** (200 seconds).
7.  View waveforms:
    -   centi-second counter (`cs_tens`, `cs_ones`)
    -   seconds counter (`sec_tens`, `sec_ones`)
    -   minute counter (`min_tens`, `min_ones`)
8.  Observe correct rollovers:
    -   Every 100 centi-sec → +1 sec
    -   Every 100 sec → +1 min

------------------------------------------------------------------------

## 5. Notes

-   This simulation uses a simplified stopwatch that counts **00--99**
    for all counters.
-   You may modify the logic to restrict seconds/minutes to **59** for a
    realistic stopwatch.


