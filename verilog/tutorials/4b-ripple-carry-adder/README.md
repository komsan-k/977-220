# 🔬 4-bit Ripple Carry Adder --- Instantiation and Explanation

## 🧩 1. Full Adder Module (Building Block)

``` verilog
module FullAdder(
  input  a, b, cin,
  output sum, cout
);
  assign sum  = a ^ b ^ cin;
  assign cout = (a & b) | (b & cin) | (a & cin);
endmodule
```

This **Full Adder** handles 1-bit addition with carry propagation.

------------------------------------------------------------------------

## 🧮 2. 4-bit Ripple Carry Adder Module (Instantiation Example)

``` verilog
module RippleCarryAdder4(
  input  [3:0] A, B,
  input        Cin,
  output [3:0] Sum,
  output       Cout
);

  wire c1, c2, c3; // Internal carry wires

  // Instantiate 4 Full Adders
  FullAdder FA0 (.a(A[0]), .b(B[0]), .cin(Cin), .sum(Sum[0]), .cout(c1));
  FullAdder FA1 (.a(A[1]), .b(B[1]), .cin(c1),  .sum(Sum[1]), .cout(c2));
  FullAdder FA2 (.a(A[2]), .b(B[2]), .cin(c2),  .sum(Sum[2]), .cout(c3));
  FullAdder FA3 (.a(A[3]), .b(B[3]), .cin(c3),  .sum(Sum[3]), .cout(Cout));

endmodule
```

------------------------------------------------------------------------

## ⚙️ 3. Explanation of Instantiation

  Element                  Description
  ------------------------ ---------------------------------------------------
  **FullAdder**            The module being instantiated (1-bit adder)
  **FA0, FA1, FA2, FA3**   Instance names for each 1-bit adder
  **.a(A\[0\])**           Connects signal A\[0\] to input a of the instance
  **c1, c2, c3**           Internal wires carrying intermediate carries
  **Cout**                 Final carry-out from the MSB Full Adder

------------------------------------------------------------------------

## 📊 4. Carry Propagation Diagram

    A0 ─┐     ┌───────────────┐
    B0 ─┼──▶  │ FullAdder FA0 │── C1 ─▶
    Cin─┘     │   (LSB)       │
              └───────┬───────┘
                      │
    A1 ─┐     ┌───────┴───────┐
    B1 ─┼──▶  │ FullAdder FA1 │── C2 ─▶
    C1 ─┘     │               │
              └───────┬───────┘
                      │
    A2 ─┐     ┌───────┴───────┐
    B2 ─┼──▶  │ FullAdder FA2 │── C3 ─▶
    C2 ─┘     │               │
              └───────┬───────┘
                      │
    A3 ─┐     ┌───────┴───────┐
    B3 ─┼──▶  │ FullAdder FA3 │──▶ Cout
    C3 ─┘     │   (MSB)       │
              └───────────────┘

------------------------------------------------------------------------

## 🧠 5. Summary

-   **Instantiation** means using one module as a sub-block inside
    another.
-   Each **FullAdder** performs a 1-bit addition with a carry.
-   Carries **ripple** from least significant bit (LSB) to most
    significant bit (MSB).
-   The final `Cout` represents the **overflow or final carry-out** from
    the MSB adder.

------------------------------------------------------------------------

## 🧪 6. Suggested Testbench 

``` verilog
module tb_RippleCarryAdder4;
  reg [3:0] A, B;
  reg Cin;
  wire [3:0] Sum;
  wire Cout;

  RippleCarryAdder4 uut (.A(A), .B(B), .Cin(Cin), .Sum(Sum), .Cout(Cout));

  initial begin
    $monitor("A=%b B=%b Cin=%b => Sum=%b Cout=%b", A, B, Cin, Sum, Cout);
    A=4'b0001; B=4'b0010; Cin=0; #10;
    A=4'b1010; B=4'b0101; Cin=0; #10;
    A=4'b1111; B=4'b0001; Cin=0; #10;
    A=4'b1111; B=4'b1111; Cin=1; #10;
    $finish;
  end
endmodule
```

------------------------------------------------------------------------

