# 🔬 Lab 10: System-on-Chip (SoC) Integration and Memory-Mapped I/O Design in Verilog HDL

## 🧩 1. Objective
Students will design, integrate, and simulate a **miniature System-on-Chip (SoC)** that includes CPU, memory, and peripheral subsystems.  
You will learn to:
- Connect multiple Verilog modules into a **complete SoC architecture**.  
- Implement a **memory-mapped I/O bus** for peripherals (GPIO, UART, Timer).  
- Coordinate CPU control with **address decoding** and **peripheral access**.  
- Simulate **data transactions** between CPU, memory, and devices.  

---

## ⚙️ 2. Equipment and Tools
| Tool / Resource | Description |
|------------------|-------------|
| **Vivado / Quartus / ModelSim** | HDL compiler & simulator |
| **FPGA Board (Basys 3 / Nexys A7)** | Hardware validation |
| **Serial Terminal (HTerm / TeraTerm)** | UART communication test |
| **System Tasks** | `$display`, `$monitor`, `$dumpfile`, `$readmemh` |

---

## 🧠 3. Background Theory

### 3.1 System Architecture
A simplified SoC consists of:
- **CPU Core** – Executes instructions and generates address/data.  
- **Memory System** – Stores instructions and data.  
- **Peripheral Block** – GPIO, UART, timers, etc.  
- **Bus Interface / Address Decoder** – Routes read/write requests.  

### Memory-Mapped I/O
Each peripheral is assigned a **unique address range** in memory, allowing the CPU to access devices using normal `LOAD` and `STORE` instructions.  

---

## 🧩 4. SoC Block Diagram
```
 ┌────────────────────────────────────────────┐
 │                 Mini SoC                  │
 │ ┌──────────┐   ┌────────┐   ┌──────────┐ │
 │ │  CPU     │→→│ Address │→→│ Memory    │ │
 │ │ (Control │   │ Decode │   │ + I/O Map │ │
 │ │  + ALU)  │   └────────┘   └─────┬────┘ │
 │ │          │←──────────────┐       │      │
 │ └──────────┘               │       │
 │                            │       │
 │                         ┌──▼──┐  ┌─▼───┐
 │                         │GPIO │  │UART │
 │                         └─────┘  └─────┘
 └────────────────────────────────────────────┘
```

---

## ⚙️ 5. Verilog Modules

### 5.1 Bus and Address Decoder
```verilog
module AddressDecoder(
  input [7:0] addr,
  output reg sel_ram, sel_gpio, sel_uart
);
  always @(*) begin
    sel_ram  = 0; sel_gpio = 0; sel_uart = 0;
    case (addr[7:4])
      4'h0: sel_ram  = 1;   // 0x00–0x0F → RAM
      4'h1: sel_gpio = 1;   // 0x10–0x1F → GPIO
      4'h2: sel_uart = 1;   // 0x20–0x2F → UART
      default: ;
    endcase
  end
endmodule
```

---

### 5.2 RAM (16×8)
```verilog
module RAM16x8(
  input clk, we,
  input [3:0] addr,
  input [7:0] din,
  output reg [7:0] dout
);
  reg [7:0] mem [15:0];
  always @(posedge clk)
    if (we) mem[addr] <= din;
  always @(*) dout = mem[addr];
endmodule
```

---

### 5.3 GPIO Peripheral
```verilog
module GPIO8(
  input clk, rst, we,
  input [7:0] din,
  output reg [7:0] led
);
  always @(posedge clk or posedge rst)
    if (rst) led <= 8'h00;
    else if (we) led <= din;
endmodule
```

---

### 5.4 UART Peripheral (Transmitter)
```verilog
module UART_Peripheral(
  input clk, rst, we,
  input [7:0] din,
  output tx
);
  wire tx_busy;
  UART_TX #(50000000, 9600) txmod (
    .clk(clk), .rst(rst), .tx_start(we),
    .data_in(din), .tx(tx), .tx_busy(tx_busy)
  );
endmodule
```

---

### 5.5 Top-Level SoC Integration
```verilog
module MiniSoC(input clk, rst);
  reg [7:0] addr, data_in;
  wire [7:0] data_out;
  reg we;
  wire sel_ram, sel_gpio, sel_uart;
  wire [7:0] ram_dout;
  wire tx;
  wire [7:0] led;

  AddressDecoder dec(.addr(addr), .sel_ram(sel_ram), .sel_gpio(sel_gpio), .sel_uart(sel_uart));
  RAM16x8 ram(.clk(clk), .we(we & sel_ram), .addr(addr[3:0]), .din(data_in), .dout(ram_dout));
  GPIO8 gpio(.clk(clk), .rst(rst), .we(we & sel_gpio), .din(data_in), .led(led));
  UART_Peripheral uart(.clk(clk), .rst(rst), .we(we & sel_uart), .din(data_in), .tx(tx));

  assign data_out = sel_ram ? ram_dout : 8'h00;

  // Example transaction
  initial begin
    addr = 8'h10; data_in = 8'hA5; we = 1; #20 we = 0;   // Write to GPIO
    addr = 8'h20; data_in = 8'h48; we = 1; #20 we = 0;   // Send UART byte
  end
endmodule
```

---

## 🧮 6. Experiment Procedure
1. Create a new project and add all modules (**Address Decoder**, **RAM**, **GPIO**, **UART**).  
2. Integrate them into the **MiniSoC** top-level module.  
3. Simulate read/write transactions and observe signals.  
4. Verify correct **address decoding** and **device responses**.  
5. *(Optional)* Test on FPGA using **switches** as inputs and **LEDs** for outputs.  

---

## 📊 7. Observation Table
| Address | Peripheral | Write Data (DIN) | Read Data (DOUT) | Device Action |
|:---------|:------------|:----------------:|:----------------:|:----------------------------|
| 0x00 | RAM | 0x55 | 0x55 | Stored in RAM cell 0 |
| 0x10 | GPIO | 0xA5 | — | LEDs display A5h |
| 0x20 | UART | 0x48 | — | Transmitted ASCII 'H' |

---

## 💡 8. Discussion Points
- How does **address decoding** enable multiple devices on one bus?  
- Why use **memory-mapped I/O** instead of dedicated I/O instructions?  
- Discuss timing differences between **RAM** and **peripheral access**.  
- How can this design be expanded with **interrupts** or **DMA**?  

---

## 🧠 9. Post-Lab Exercises
1. Add a **timer module** mapped at address `0x30` to generate a 1 Hz tick.  
2. Implement a **UART receiver** to complete full-duplex communication.  
3. Integrate the **Lab 9 CPU** to access the SoC via bus transactions.  
4. Design an **interrupt controller** for peripheral events.  
5. Extend the design to a **Harvard architecture** with separate program/data memory.  

---

## 🧾 10. Outcome
Students will be able to:
- Implement a **System-on-Chip (SoC)** architecture in Verilog HDL.  
- Apply **memory-mapped I/O** to interface peripherals.  
- Simulate **multi-module data transactions** and verify bus logic.  
- Understand how **modular components** form modern FPGA-based SoCs.  

---

## 📘 11. References
1. Samir Palnitkar, *Verilog HDL: A Guide to Digital Design and Synthesis*, Pearson  
2. Pong P. Chu, *FPGA Prototyping by Verilog Examples*, Wiley  
3. David Harris & Sarah Harris, *Digital Design and Computer Architecture*, Morgan Kaufmann  
4. Xilinx, *Designing with AXI Interfaces*  

---

**Author:** Dr. Komsan Kanjanasit  
**Publisher:** College of Computing, Prince of Songkla University, Thailand  
**Edition:** First Edition (2025)  
**License:** CC BY 4.0 — Free to use with attribution
