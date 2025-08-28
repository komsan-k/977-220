
# Verilog Coding and Waveform Time Simulation using EDA Playground

---

## 📌 Objectives

- Write synthesizable Verilog modules and self-checking testbenches.
- Run simulations online with **EDA Playground** and visualize timing waveforms in **EPWave**.
- Use `timescale`, clock/reset generation, delays, `$display/$monitor`, and VCD dumping.

---

## 📚 Prerequisites

- Basic digital logic (combinational/sequential circuits).
- Verilog-2001 syntax (modules, ports, `assign`, `always`).
- A web browser to access [https://edaplayground.com/](https://edaplayground.com/)

---

## 🚀 EDA Playground: Quick Start

1. Open [https://edaplayground.com/](https://edaplayground.com/) and sign in.
2. In **Tools & Simulators**, choose a simulator like **Icarus Verilog** and check **Open EPWave after run**.
3. Create two tabs:
   - Design file (e.g., `mux2.v`)
   - Testbench file (e.g., `tb_mux2.v`)
4. Set **Top module name** to your testbench name (e.g., `tb_mux2`).
5. Click **Run**, then open **EPWave** to inspect waveforms.

---

## ✅ Best Practices for Simulation

- Add `` `timescale 1ns/1ps `` at the top of every testbench.
- For waveform output:  
  ```verilog
  $dumpfile("dump.vcd");
  $dumpvars(0, <top_tb_name>);
  ```
- Use **non-blocking** (`<=`) for sequential logic and **blocking** (`=`) for combinational logic.
- Clock generation example:  
  ```verilog
  always #5 clk = ~clk; // 10ns period
  ```

---

## 🔧 Example 1: Combinational Design (2:1 MUX)

### `mux2.v`
```verilog
module mux2 (
  input  wire a,
  input  wire b,
  input  wire sel,
  output wire y
);
  assign y = sel ? b : a;
endmodule
```

### `tb_mux2.v`
```verilog
`timescale 1ns/1ps
module tb_mux2;
  reg  a, b, sel;
  wire y;

  mux2 dut(.a(a), .b(b), .sel(sel), .y(y));

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_mux2);

    a=0; b=0; sel=0;
    $display("t=%0t  a=%0b b=%0b sel=%0b | y=%0b", $time, a,b,sel,y);

    #5 a=1;
    #5 b=1;
    #5 sel=1;
    #5 a=0; b=0;
    #5 sel=0;
    #5 $finish;
  end

  initial $monitor("t=%0t  a=%0b b=%0b sel=%0b | y=%0b", $time, a,b,sel,y);
endmodule
```

... (truncated for brevity, full content will be included in file)

... (Content truncated for brevity)
