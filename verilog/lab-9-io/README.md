# 🔬 Lab 8: Input/Output (I/O) Interface and Peripheral Control in Verilog HDL

## 🧩 1. Objective
This laboratory teaches students to design and simulate **I/O interface modules** and **peripheral controllers** using Verilog HDL.  
Students will learn to:
- Interface Verilog modules with physical I/O devices (**switches, LEDs, seven-segment displays**).  
- Create **GPIO controllers** and **7-segment display drivers**.  
- Implement **UART serial communication** for data transmission and reception.  
- Simulate **timing and data flow** for external interfacing.  

---

## ⚙️ 2. Equipment and Tools
| Tool / Resource | Description |
|------------------|-------------|
| **Vivado / Quartus / ModelSim** | HDL compiler and simulator |
| **FPGA Board (Basys 3 / Nexys A7)** | I/O testing platform |
| **USB UART Interface / Terminal** | Serial communication testing |
| **System Tasks** | `$display`, `$monitor`, `$dumpfile`, `$dumpvars` |

---

## 🧠 3. Background Theory

### 3.1 I/O Interface in FPGA
Input/Output (I/O) interfacing enables FPGA logic to interact with the physical world.  
Each pin can be configured as:
- **Input** — e.g., switches, buttons  
- **Output** — e.g., LEDs, seven-segment display  
- **Bidirectional** — e.g., UART, data bus  

I/O operations can be **synchronous** (clock-driven) or **asynchronous** (event-driven).  
This lab covers **GPIO**, **seven-segment display multiplexing**, and **UART transmission**.

---

### 3.2 GPIO Control Module
```verilog
module GPIO_Interface (
  input clk, rst,
  input [7:0] sw,          // Input switches
  output reg [7:0] led     // Output LEDs
);
  always @(posedge clk or posedge rst)
    if (rst)
      led <= 8'b00000000;
    else
      led <= sw;           // Direct mapping
endmodule
```

**Testbench**
```verilog
module tb_GPIO_Interface;
  reg clk, rst;
  reg [7:0] sw;
  wire [7:0] led;

  GPIO_Interface uut (.clk(clk), .rst(rst), .sw(sw), .led(led));

  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    $dumpfile("GPIO_Interface.vcd");
    $dumpvars(0, tb_GPIO_Interface);
    rst = 1; sw = 8'h00; #10;
    rst = 0; sw = 8'hA5; #20;
    sw = 8'h5A; #20;
    $finish;
  end
endmodule
```

---

### 3.3 Seven-Segment Display Driver
```verilog
module SevenSegDecoder(input [3:0] bin, output reg [6:0] seg);
  always @(*)
    case (bin)
      4'h0: seg = 7'b1000000;
      4'h1: seg = 7'b1111001;
      4'h2: seg = 7'b0100100;
      4'h3: seg = 7'b0110000;
      4'h4: seg = 7'b0011001;
      4'h5: seg = 7'b0010010;
      4'h6: seg = 7'b0000010;
      4'h7: seg = 7'b1111000;
      4'h8: seg = 7'b0000000;
      4'h9: seg = 7'b0010000;
      default: seg = 7'b1111111;
    endcase
endmodule
```

**Testbench**
```verilog
module tb_SevenSegDecoder;
  reg [3:0] bin;
  wire [6:0] seg;

  SevenSegDecoder uut (.bin(bin), .seg(seg));

  initial begin
    $dumpfile("SevenSegDecoder.vcd");
    $dumpvars(0, tb_SevenSegDecoder);
    for (bin = 0; bin < 10; bin = bin + 1)
      #10 $display("Input=%b Output(seg)=%b", bin, seg);
    $finish;
  end
endmodule
```

---

### 3.4 UART Transmitter (8-bit, 9600 Baud)
```verilog
module UART_TX #(parameter CLK_FREQ = 50000000, BAUD_RATE = 9600)
(
  input clk, rst, tx_start,
  input [7:0] data_in,
  output reg tx, tx_busy
);
  localparam BAUD_TICK = CLK_FREQ / BAUD_RATE;
  reg [15:0] baud_cnt;
  reg [3:0] bit_idx;
  reg [9:0] tx_shift;

  always @(posedge clk or posedge rst)
    if (rst) begin
      tx <= 1'b1;
      tx_busy <= 0;
      baud_cnt <= 0;
      bit_idx <= 0;
      tx_shift <= 10'b1111111111;
    end else begin
      if (tx_start && !tx_busy) begin
        tx_shift <= {1'b1, data_in, 1'b0};
        tx_busy <= 1;
        bit_idx <= 0;
      end
      if (tx_busy) begin
        if (baud_cnt == BAUD_TICK-1) begin
          baud_cnt <= 0;
          tx <= tx_shift[0];
          tx_shift <= {1'b1, tx_shift[9:1]};
          bit_idx <= bit_idx + 1;
          if (bit_idx == 10) tx_busy <= 0;
        end else
          baud_cnt <= baud_cnt + 1;
      end
    end
endmodule
```

**Testbench**
```verilog
module tb_UART_TX;
  reg clk, rst, tx_start;
  reg [7:0] data_in;
  wire tx, tx_busy;

  UART_TX uut (.clk(clk), .rst(rst), .tx_start(tx_start), .data_in(data_in), .tx(tx), .tx_busy(tx_busy));

  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    $dumpfile("UART_TX.vcd");
    $dumpvars(0, tb_UART_TX);
    rst = 1; tx_start = 0; data_in = 8'h41; #20;
    rst = 0; #10;
    tx_start = 1; #10 tx_start = 0;
    #2000 $finish;
  end
endmodule
```

---

## 🧮 4. Experiment Procedure
1. **Create Project:** Start a new Verilog project.  
2. **Implement:** GPIO, Seven-Segment Decoder, and UART modules.  
3. **Write Testbenches:** Simulate each module individually.  
4. **Observe:** I/O mapping, segment display pattern, and UART waveform.  
5. *(Optional)* **Synthesize and Test:** Map inputs to switches and outputs to LEDs or display.  

---

## 📊 5. Observation Tables

### GPIO Interface
| SW Input | LED Output |
|:----------|:-----------|
| 00000000 | 00000000 |
| 10100101 | 10100101 |
| 01011010 | 01011010 |

### UART Output Sequence (ASCII 'A' = 0x41)
| Bit Index | TX Line |
|:-----------|:--------|
| Start Bit | 0 |
| b0 | 1 |
| b1 | 0 |
| b2 | 0 |
| b3 | 0 |
| b4 | 0 |
| b5 | 1 |
| b6 | 0 |
| b7 | 0 |
| Stop Bit | 1 |

---

## 💡 6. Discussion Points
- Difference between **GPIO input/output** operations.  
- How the **seven-segment decoder** translates binary to display segments.  
- Importance of **baud rate generation** in UART communication.  
- How **synchronous control** stabilizes I/O timing on FPGA.  

---

## 🧠 7. Post-Lab Exercises
1. Combine **GPIO** and **Seven-Segment** modules to form a display interface.  
2. Extend **UART_TX** to include a **UART_RX** receiver.  
3. Implement a **binary-to-ASCII converter** for UART display.  
4. Create a **4-digit multiplexed seven-segment display driver**.  

---

## 🧾 8. Outcome
Students will be able to:
- Design and simulate **I/O interfacing modules** in Verilog HDL.  
- Understand **UART-based communication** with peripherals.  
- Drive **LEDs and displays** using combinational logic.  
- Integrate **peripheral control** within FPGA designs.  

---

## 📘 9. References
1. Samir Palnitkar, *Verilog HDL: A Guide to Digital Design and Synthesis*, Pearson  
2. Pong P. Chu, *FPGA Prototyping by Verilog Examples*, Wiley  
3. Xilinx, *Basys 3 FPGA Reference Manual*  
4. IEEE Std 1364-2005, *Verilog Hardware Description Language*  

---

**Author:** Dr. Komsan Kanjanasit  
**Publisher:** College of Computing, Prince of Songkla University, Thailand  
**Edition:** First Edition (2025)  
**License:** CC BY 4.0 — Free to use with attribution
