# Combinational Logic Design in Verilog

## Introduction to Combinational Logic
Combinational logic refers to digital circuits whose outputs are determined solely by the current values of their inputs. These circuits do not have memory or feedback loops, and their outputs change immediately when the inputs change. Combinational logic is foundational in digital electronics and is used to implement arithmetic operations, data routing, encoding, decoding, and more.

## Basic Logic Gates
The fundamental building blocks of combinational logic are the basic logic gates:
- **AND gate**: output is high only if all inputs are high.
- **OR gate**: output is high if at least one input is high.
- **NOT gate**: output is the inverse of the input.
- **NAND, NOR, XOR, XNOR**: combinations and extensions of basic gates.

### Verilog Examples
```verilog
module and_gate(input a, input b, output y);
  assign y = a & b;
endmodule
```

```verilog
module xor_gate(input a, input b, output y);
  assign y = a ^ b;
endmodule
```

## Boolean Algebra and Simplification
Boolean algebra provides a mathematical framework for describing and optimizing logic circuits. Key laws include:
- **Identity Law**: A + 0 = A, A * 1 = A
- **Null Law**: A + 1 = 1, A * 0 = 0
- **Complement Law**: A + A' = 1, A * A' = 0
- Distributive, Associative, and De Morgan’s Laws

Simplification of logic expressions leads to reduced gate count, lower power, and better performance.

## Common Combinational Circuits

### Multiplexers
A multiplexer selects one of several inputs to pass to the output based on select lines.
```verilog
module mux2to1(input a, input b, input sel, output y);
  assign y = sel ? b : a;
endmodule
```

### Decoders
A decoder activates exactly one output line based on input values.
```verilog
module decoder2to4(input [1:0] in, output [3:0] out);
  assign out = 1 << in;
endmodule
```

### Encoders and Priority Encoders
Encoders convert active input lines into binary codes. Priority encoders give precedence to the highest-order input.

### Comparators
Comparators determine the relative magnitude of binary numbers.

### Adders and Subtractors
- **Half Adder**: sum and carry outputs for two inputs.
- **Full Adder**: includes carry-in and carry-out.
```verilog
module full_adder(input a, b, cin, output sum, cout);
  assign sum = a ^ b ^ cin;
  assign cout = (a & b) | (b & cin) | (a & cin);
endmodule
```

## Design Examples

### 4-bit Ripple Carry Adder
Uses four full adders connected in series.

### 4x1 Multiplexer Using Case Statement
```verilog
module mux4to1(input [1:0] sel, input [3:0] in, output reg y);
  always @(*) begin
    case (sel)
      2'b00: y = in[0];
      2'b01: y = in[1];
      2'b10: y = in[2];
      2'b11: y = in[3];
    endcase
  end
endmodule
```

### BCD to 7-Segment Display Decoder
Maps binary-coded decimal to seven-segment display outputs.

## Modeling Techniques
- **Dataflow Modeling**: Efficient for arithmetic circuits.
- **Behavioral Modeling**: Useful for conditional logic, e.g., case statements and if-else constructs.
- **Structural Modeling**: Emphasizes module interconnection.

## Design Optimization and Synthesis Tips
- Avoid unnecessary logic duplication.
- Combine similar functions into shared logic.
- Use generate loops for repeated instances.

## Simulation and Testbenches
```verilog
module test_adder;
  reg [3:0] a, b;
  reg cin;
  wire [3:0] sum;
  wire cout;

  adder4bit uut(.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

  initial begin
    a = 4'b0001; b = 4'b0010; cin = 0;
    #10 a = 4'b1111; b = 4'b0001;
    #10 $finish;
  end
endmodule
```

## Common Mistakes and Debugging
- Forgetting default cases in case statements.
- Incorrect bit-width assignments.
- Mixing blocking and non-blocking assignments in combinational circuits.

## Summary
Combinational logic is the foundation of digital systems. Using Verilog, designers can implement, simulate, and synthesize a wide range of combinational circuits efficiently. This chapter introduced basic gates, common modules, design examples, and modeling styles.

## Exercises
1. Design a 4-bit binary comparator in Verilog.
2. Write a Verilog module for a 2-to-4 line decoder with enable.
3. Implement an 8-bit adder/subtractor with a control signal.
4. Create a testbench for a 4x1 multiplexer.
5. Modify a full-adder to use behavioral modeling with case statements.

