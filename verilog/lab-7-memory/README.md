# 🔬 Lab 7: Memory Elements — RAM and ROM Design in Verilog HDL

## 🧩 1. Objective
Students will learn to:
- Design and simulate **combinational (ROM)** and **sequential (RAM)** memory modules.  
- Implement **synchronous read/write control**.  
- Understand **memory addressing, initialization, and behavioral modeling**.  
- Verify memory operations with **testbenches and waveform analysis**.  

---

## ⚙️ 2. Equipment and Tools
| Tool / Resource | Description |
|------------------|-------------|
| **Vivado / Quartus / ModelSim** | HDL compiler & simulator |
| **FPGA Board (Basys 3 / Nexys A7)** | For on-board testing |
| **Text Editor / IDE** | VS Code or Vivado Editor |
| **System Tasks** | `$readmemh`, `$readmemb`, `$display`, `$monitor`, `$dumpfile` |

---

## 🧠 3. Background Theory

### 3.1 Memory Classification
| Type | Access | Read/Write Control | Example Use |
|------|---------|-------------------|--------------|
| **ROM** | Fixed | Read-only | Lookup tables, constants |
| **RAM** | Random | Read & write | Buffers, registers, stack |

**Verilog Modeling Styles:**
- **Behavioral:** High-level description using arrays.  
- **Dataflow:** Rarely used (bit-level).  
- **Structural:** Used when instantiating IP cores.  

---

### 3.2 8 × 8 ROM Design
```verilog
module ROM_8x8(input [2:0] addr, output reg [7:0] data);
  always @(*)
    case (addr)
      3'b000: data = 8'b00000000;
      3'b001: data = 8'b00000001;
      3'b010: data = 8'b00000010;
      3'b011: data = 8'b00000100;
      3'b100: data = 8'b00001000;
      3'b101: data = 8'b00010000;
      3'b110: data = 8'b00100000;
      3'b111: data = 8'b01000000;
      default: data = 8'b00000000;
    endcase
endmodule
```

**Testbench**
```verilog
module tb_ROM_8x8;
  reg [2:0] addr;
  wire [7:0] data;

  ROM_8x8 uut (.addr(addr), .data(data));

  initial begin
    $dumpfile("ROM_8x8.vcd");
    $dumpvars(0, tb_ROM_8x8);
    for (addr = 0; addr < 8; addr = addr + 1) begin
      #10;
      $display("Address=%b -> Data=%b", addr, data);
    end
    $finish;
  end
endmodule
```

---

### 3.3 8 × 8 RAM Design (Synchronous Write, Asynchronous Read)
```verilog
module RAM_8x8 (
  input clk, we,
  input [2:0] addr,
  input [7:0] din,
  output reg [7:0] dout
);
  reg [7:0] mem [7:0];

  always @(posedge clk)
    if (we)
      mem[addr] <= din;

  always @(*)
    dout = mem[addr];
endmodule
```

**Testbench**
```verilog
module tb_RAM_8x8;
  reg clk, we;
  reg [2:0] addr;
  reg [7:0] din;
  wire [7:0] dout;

  RAM_8x8 uut (.clk(clk), .we(we), .addr(addr), .din(din), .dout(dout));

  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    $dumpfile("RAM_8x8.vcd");
    $dumpvars(0, tb_RAM_8x8);
    we = 1; addr = 0; din = 8'hAA; #10;
    addr = 1; din = 8'h55; #10;
    addr = 2; din = 8'h0F; #10;
    we = 0; addr = 0; #10;
    addr = 1; #10;
    addr = 2; #10;
    $finish;
  end
endmodule
```

---

### 3.4 RAM Initialization from File
You can initialize memory from a file using `$readmemh` (hex) or `$readmemb` (binary):

```verilog
module ROM_FileInit(input [3:0] addr, output reg [7:0] data);
  reg [7:0] rom [15:0];
  initial $readmemh("init_ROM.hex", rom);
  always @(*) data = rom[addr];
endmodule
```

**Example file (init_ROM.hex):**
```
00
11
22
33
44
55
66
77
88
99
AA
BB
CC
DD
EE
FF
```

---

### 3.5 Simple Register File (4 × 8)
```verilog
module RegFile_4x8(
  input clk, we,
  input [1:0] addr_wr, addr_rd,
  input [7:0] data_in,
  output [7:0] data_out
);
  reg [7:0] mem [3:0];
  assign data_out = mem[addr_rd];

  always @(posedge clk)
    if (we)
      mem[addr_wr] <= data_in;
endmodule
```

---

## 🧮 4. Experiment Procedure
1. **Create Project:** Start a new project in your HDL tool.  
2. **Design Modules:** Implement the ROM, RAM, and Register File.  
3. **Write Testbenches:** Simulate and verify read/write operations.  
4. **File Initialization:** Add `$readmemh` to load ROM contents.  
5. *(Optional)* **FPGA Test:** Map address lines to switches and data to LEDs.  

---

## 📊 5. Observation Tables

### RAM Write/Read Operation
| Cycle | Addr | WE | DIN | DOUT |
|:------|:-----|:--:|:----:|:----:|
| 1 | 000 | 1 | 10101010 | X |
| 2 | 000 | 0 | ---- | 10101010 |
| 3 | 001 | 1 | 01010101 | X |

---

## 💡 6. Discussion Points
- Differences between **ROM**, **RAM**, and **Register Files**.  
- Concept of **synchronous write / asynchronous read**.  
- How `$readmemh` simplifies **testbench initialization**.  
- Memory inference in **FPGA synthesis** (Block RAM vs Distributed RAM).  

---

## 🧠 7. Post-Lab Exercises
1. Design a **16×8 RAM** using parameterized arrays.  
2. Modify the ROM to generate a **sine lookup table**.  
3. Implement a **dual-port RAM** with two independent address ports.  
4. Design a **FIFO buffer** using RAM as storage.  

---

## 🧾 8. Outcome
Students will be able to:
- Model and simulate **ROM** and **RAM** using Verilog HDL.  
- Perform **synchronous** and **asynchronous** memory operations.  
- Use **file-based initialization** for memory contents.  
- Understand **memory structures** in FPGA-based embedded systems.  

---

## 📘 9. References
1. Samir Palnitkar, *Verilog HDL: A Guide to Digital Design and Synthesis*, Pearson  
2. Pong P. Chu, *FPGA Prototyping by Verilog Examples*, Wiley  
3. Xilinx Vivado, *Block RAM and Memory Inference Guide*  
4. IEEE Std 1364-2005, *Verilog Hardware Description Language*  

---

**Author:** Dr. Komsan Kanjanasit  
**Publisher:** College of Computing, Prince of Songkla University, Thailand  
**Edition:** First Edition (2025)  
**License:** CC BY 4.0 — Free to use with attribution
