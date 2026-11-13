# Expected Result Pattern for Stopwatch Simulation

This provides the **expected output pattern** for the stopwatch
simulation using the provided Verilog testbench.

------------------------------------------------------------------------

## ⏱ Testbench Timing Summary

-   `timescale 1ms/1us`
-   Clock toggles every **5 ms** → full period = **10 ms**
-   Reset (`rst`) stays high for the first **20 ms**
-   First active rising clock after reset occurs at **t = 25 ms**

Thus, the stopwatch begins counting centi-seconds at:

    t = 25 ms → mm:ss:cs = 00:00:01

------------------------------------------------------------------------

# ✅ 1. Early Counter Pattern (First 100 ms)

    Time (ms) mm:ss:cs
  ----------- ----------
           25 00:00:01
           35 00:00:02
           45 00:00:03
           55 00:00:04
           65 00:00:05
           75 00:00:06
           85 00:00:07
           95 00:00:08
          105 00:00:09
          115 00:00:10
          125 00:00:11
          ... ...

------------------------------------------------------------------------

# ⏳ 2. Approaching 1-Second Rollover

    Time (ms) Expected Output
  ----------- -----------------
          965 00:00:95
          975 00:00:96
          985 00:00:97
          995 00:00:98
     **1005** **00:01:99**
         1015 00:01:00
         1025 00:01:01
         1035 00:01:02

### ⚠️ Important Note

With this exact design:

-   **Seconds increment at `cs = 99`**, giving:

        00:01:99

-   On the next tick:

        00:01:00

You **will not** see `00:00:99`.

------------------------------------------------------------------------

# 🔄 3. General Pattern With This Testbench

-   Every **10 ms** → `cs` increments
-   Every **100 cs counts** → seconds increment
-   Every **100 seconds** → minutes increment

Console output from `$monitor` should look like:

        25 | 00:00:01
        35 | 00:00:02
        45 | 00:00:03
        ...
       995 | 00:00:98
      1005 | 00:01:99
      1015 | 00:01:00
      1025 | 00:01:01



Generated automatically for Verilog Stopwatch Simulation.
