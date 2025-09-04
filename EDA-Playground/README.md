
# Verilog Coding and Waveform Time Simulation using EDA Playground

---

## 📌 Objectives
- Write synthesizable Verilog modules and self-checking testbenches.
- Run simulations online with **EDA Playground** and visualize timing waveforms in **EPWave**.
- Use `timescale`, clock/reset generation, delays, `$display/$monitor`, and VCD dumping.

## 📚 Prerequisites
- Basic digital logic (combinational/sequential circuits).
- Verilog-2001 syntax (modules, ports, `assign`, `always`).
- A web browser to access [EDA Playground](https://edaplayground.com/).

## 🚀 EDA Playground: Quick Start
1. Open [EDA Playground](https://edaplayground.com/). (Sign in to save your work.)
2. In **Tools & Simulators**, choose a simulator (e.g., **Icarus Verilog**) and check **Open EPWave after run**.
3. Create two files (tabs): one for the design (e.g., `mux2.v`) and one for the testbench (e.g., `tb_mux2.v`).
4. Set **Top module name** to your testbench (e.g., `tb_mux2`).
5. Click **Run**. After simulation, click **Open EPWave** to inspect waveforms.

## ✅ Best Practices for Simulation
- Put `` `timescale 1ns/1ps `` at the top of every testbench.
- Use `$dumpfile("dump.vcd"); $dumpvars(0, <top_tb_name>);` for waveform dumping.
- Use non-blocking (`<=`) assignments in sequential logic and blocking (`=`) in combinational logic.
- Generate clocks with: `always #5 clk = ~clk;` (100 MHz).

## 🔧 Example 1: 2:1 MUX (Combinational Logic)
### mux2.v
```verilog
module mux2 (
  input wire a,
  input wire b,
  input wire sel,
  output wire y
);
  assign y = sel ? b : a;
endmodule
```
### tb_mux2.v
```verilog
`timescale 1ns/1ps
module tb_mux2;
  reg a, b, sel;
  wire y;

  mux2 dut(.a(a), .b(b), .sel(sel), .y(y));

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_mux2);

    a=0; b=0; sel=0;
    $display("t=%0t a=%0b b=%0b sel=%0b | y=%0b", $time, a,b,sel,y);

    #5 a=1;
    #5 b=1;
    #5 sel=1;
    #5 a=0; b=0;
    #5 sel=0;
    #5 $finish;
  end

  initial $monitor("t=%0t a=%0b b=%0b sel=%0b | y=%0b", $time, a,b,sel,y);
endmodule
```
### 🔍 EPWave Insights
- When `sel=0`, `y=a`; when `sel=1`, `y=b`.
- Observe transitions every 5ns.

## 🔢 Example 2: Synchronous 4-bit Counter
### counter.v
```verilog
module counter (
  input wire clk,
  input wire rst_n,
  output reg [3:0] q
);
  always @(posedge clk) begin
    if (!rst_n) q <= 4'd0;
    else q <= q + 4'd1;
  end
endmodule
```
### tb_counter.v
```verilog
`timescale 1ns/1ps
module tb_counter;
  reg clk = 1'b0;
  reg rst_n = 1'b0;
  wire [3:0] q;

  always #5 clk = ~clk;

  counter dut(.clk(clk), .rst_n(rst_n), .q(q));

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_counter);

    #12 rst_n = 1'b1;
    #200 $finish;
  end

  initial $monitor("t=%0t rst_n=%0b q=%0d", $time, rst_n, q);
endmodule
```

## ⚖️ Example 3: Blocking vs Non-Blocking
### swap_blocking.v and swap_nonblocking.v
```verilog
module swap_blocking(input clk, output reg x, output reg y);
  initial begin x = 1'b0; y = 1'b1; end
  always @(posedge clk) begin
    x = y;
    y = x;
  end
endmodule

module swap_nonblocking(input clk, output reg x, output reg y);
  initial begin x = 1'b0; y = 1'b1; end
  always @(posedge clk) begin
    x <= y;
    y <= x;
  end
endmodule
```
### tb_swap.v
```verilog
`timescale 1ns/1ps
module tb_swap;
  reg clk = 0; always #5 clk = ~clk;
  wire xb, yb, xn, yn;

  swap_blocking u1(.clk(clk), .x(xb), .y(yb));
  swap_nonblocking u2(.clk(clk), .x(xn), .y(yn));

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_swap);
    #80 $finish;
  end
endmodule
```

## 🔁 Example 4: D Flip-Flop with Async Reset
### dff.v
```verilog
module dff (
  input wire clk,
  input wire arst_n,
  input wire d,
  output reg q
);
  always @(posedge clk or negedge arst_n) begin
    if (!arst_n) q <= 1'b0;
    else q <= d;
  end
endmodule
```
### tb_dff.v
```verilog
`timescale 1ns/1ps
module tb_dff;
  reg clk = 0; always #5 clk = ~clk;
  reg arst_n = 0;
  reg d = 0;
  wire q;

  dff dut(.clk(clk), .arst_n(arst_n), .d(d), .q(q));

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_dff);

    #7 arst_n = 1;
    #6 d = 1;
    #20 d = 0;
    #20 $finish;
  end

  initial $monitor("t=%0t arst_n=%0b d=%0b q=%0b", $time, arst_n, d, q);
endmodule
```

## 📈 Waveform Tips
- Use the EPWave viewer: add signals → zoom → measure.
- Ensure `$dumpfile` and `$dumpvars` are included and top module name matches.

