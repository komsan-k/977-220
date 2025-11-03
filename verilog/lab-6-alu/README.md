# 🔬 Lab 6: Arithmetic and Logic Unit (ALU) Design in Verilog HDL

## 🧩 1. Objective
This laboratory exercise aims to **design, simulate, and verify an 8-bit Arithmetic and Logic Unit (ALU)** using Verilog HDL.  
Students will learn to:
- Implement multiple **arithmetic and logical operations** using case statements.  
- Integrate **combinational** and **behavioral modeling** techniques.  
- Verify ALU functionality using a **testbench**.  
- Observe and interpret **result flags (Zero, Carry, Overflow)**.  

---

## ⚙️ 2. Equipment and Tools
| Tool / Resource | Description |
|------------------|-------------|
| **Vivado / Quartus / ModelSim** | HDL compiler and simulator |
| **FPGA Board (Basys 3 / Nexys A7)** | Optional hardware implementation |
| **Text Editor / IDE** | VS Code, Vivado Editor |
| **System Tasks** | `$display`, `$monitor`, `$dumpfile`, `$dumpvars` |

---

## 🧠 3. Background Theory
The **Arithmetic Logic Unit (ALU)** is the **core computational unit** of a processor, responsible for performing arithmetic and logical operations.  
It combines principles from **combinational logic**, **dataflow modeling**, and **case-based selection**.

### Common ALU Operations
| Opcode | Operation | Description |
|:------:|:-----------|:-------------|
| 0000 | ADD | Addition |
| 0001 | SUB | Subtraction |
| 0010 | AND | Bitwise AND |
| 0011 | OR | Bitwise OR |
| 0100 | XOR | Bitwise XOR |
| 0101 | NOT A | Bitwise NOT |
| 0110 | INC | Increment |
| 0111 | DEC | Decrement |
| 1000 | SHL | Shift Left |
| 1001 | SHR | Shift Right |

---

### 3.1 8-bit ALU Module
```verilog
module ALU_8bit (
  input [7:0] A, B,
  input [3:0] ALU_Sel,
  output reg [7:0] ALU_Out,
  output reg CarryOut, Zero, Overflow
);
  reg [8:0] tmp; // 9 bits for carry

  always @(*) begin
    case (ALU_Sel)
      4'b0000: tmp = A + B;            // ADD
      4'b0001: tmp = A - B;            // SUB
      4'b0010: tmp = A & B;            // AND
      4'b0011: tmp = A | B;            // OR
      4'b0100: tmp = A ^ B;            // XOR
      4'b0101: tmp = ~A;               // NOT A
      4'b0110: tmp = A + 1;            // INC
      4'b0111: tmp = A - 1;            // DEC
      4'b1000: tmp = A << 1;           // SHL
      4'b1001: tmp = A >> 1;           // SHR
      default: tmp = 9'b000000000;
    endcase

    ALU_Out = tmp[7:0];
    CarryOut = tmp[8];
    Zero = (ALU_Out == 8'b00000000);
    Overflow = (A[7] == B[7]) && (ALU_Out[7] != A[7]);
  end
endmodule
```

---

### 3.2 ALU Testbench
```verilog
module tb_ALU_8bit;
  reg [7:0] A, B;
  reg [3:0] ALU_Sel;
  wire [7:0] ALU_Out;
  wire CarryOut, Zero, Overflow;

  ALU_8bit uut (.A(A), .B(B), .ALU_Sel(ALU_Sel), .ALU_Out(ALU_Out), .CarryOut(CarryOut), .Zero(Zero), .Overflow(Overflow));

  initial begin
    $dumpfile("ALU_8bit.vcd");
    $dumpvars(0, tb_ALU_8bit);

    A = 8'b00001111; B = 8'b00000101;

    for (ALU_Sel = 0; ALU_Sel < 10; ALU_Sel = ALU_Sel + 1) begin
      #10;
      $display("A=%b B=%b Sel=%b -> Out=%b Carry=%b Zero=%b Overflow=%b", A, B, ALU_Sel, ALU_Out, CarryOut, Zero, Overflow);
    end
    $finish;
  end
endmodule
```

---

### 3.3 Example Output
| ALU_Sel | Operation | A | B | Output | Carry | Zero | Overflow |
|:--------:|:-----------|:--:|:--:|:--------:|:------:|:------:|:-----------:|
| 0000 | ADD | 15 | 5 | 20 | 0 | 0 | 0 |
| 0001 | SUB | 15 | 5 | 10 | 0 | 0 | 0 |
| 0010 | AND | 15 | 5 | 5 | 0 | 0 | 0 |
| 0011 | OR  | 15 | 5 | 15 | 0 | 0 | 0 |
| 0100 | XOR | 15 | 5 | 10 | 0 | 0 | 0 |

---

## 🧮 4. Experiment Procedure
1. Create a new project in **Vivado**, **Quartus**, or **ModelSim**.  
2. Write the **ALU module** using the provided template.  
3. Develop and simulate the **testbench** for all operations.  
4. Observe and record output waveforms for each function.  
5. Modify operands and re-run the simulation to confirm correctness.  
6. *(Optional)* Implement the ALU on FPGA: connect inputs to switches, outputs to LEDs.  

---

## 📊 5. Observation Table
| A | B | ALU_Sel | Operation | ALU_Out | Carry | Zero | Overflow |
|:--:|:--:|:--:|:-----------|:----------:|:------:|:------:|:----------:|
| 00001111 | 00000101 | 0000 | ADD | 00010100 | 0 | 0 | 0 |
| 00001111 | 00000101 | 0001 | SUB | 00001010 | 0 | 0 | 0 |
| 00001111 | 00000101 | 0010 | AND | 00000101 | 0 | 0 | 0 |

---

## 💡 6. Discussion Points
- Difference between **bitwise** and **arithmetic** operations.  
- Role of **status flags** (Zero, Carry, Overflow) in ALU design.  
- Behavioral modeling using **case statements**.  
- Comparison between **clocked** and **unclocked datapaths** in hardware synthesis.  

---

## 🧠 7. Post-Lab Exercises
1. Add **NAND**, **NOR**, and **XNOR** operations to the ALU.  
2. Extend the ALU to **16-bit** and observe propagation delay.  
3. Design a **flag register** for status storage.  
4. Integrate this ALU into a **simple CPU datapath** with a control FSM.  

---

## 🧾 8. Outcome
Students will be able to:
- Implement a **combinational ALU** using Verilog HDL.  
- Use **behavioral modeling** and **case statements** for operation control.  
- Verify ALU operations through **simulation and testbench output**.  
- Understand how ALUs form the **foundation of digital processors**.  

---

## 📘 9. References
1. Samir Palnitkar, *Verilog HDL: A Guide to Digital Design and Synthesis*, Pearson  
2. Pong P. Chu, *FPGA Prototyping by Verilog Examples*, Wiley  
3. M. Morris Mano, *Digital Design: Principles and Practices*, Pearson  
4. IEEE Std 1364-2005, *Verilog Hardware Description Language*  

---

**Author:** Dr. Komsan Kanjanasit  
**Publisher:** College of Computing, Prince of Songkla University, Thailand  
**Edition:** First Edition (2025)  
**License:** CC BY 4.0 — Free to use with attribution
