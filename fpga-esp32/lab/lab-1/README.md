# 🔗 Nexys A7 ↔ ESP32 UART Interface

A simple UART link between a **Nexys A7 FPGA (Artix-7)** and an **ESP32 MCU** that lets the ESP32 control FPGA LEDs and read FPGA switch states.

---

## 🧠 Overview

**Protocol:** 115200 baud, 8-N-1  
**Direction:**
- **ESP32 → FPGA**
  - `0x55 <byte>` – Set LEDs to `<byte>`
  - `0xAA` – Request switch state
- **FPGA → ESP32**
  - `0x53 <byte>` – Reply with current 8-bit switch state

```
ESP32 (TX2=17, RX2=16)  <---UART--->  Nexys A7 (Pmod pins or other 3.3 V IO)
             GND  --------------------  GND
```

---

## ⚙️ Hardware Connections

| ESP32 Pin | Function | Nexys A7 Pin | Notes |
|------------|-----------|--------------|-------|
| GPIO17 (TX2) | UART TX | FPGA RX | Cross-connect TX↔RX |
| GPIO16 (RX2) | UART RX | FPGA TX | Cross-connect RX↔TX |
| GND | Ground | GND | Common reference |

> Use short wires and optional 220–470 Ω series resistors.  
> Power both boards separately over USB.

---

## 🧩 FPGA Design (Verilog)

### 🏗️ Top Module – `nexys_a7_uart_top.v`

```verilog
// Verilog code here (see full version in ChatGPT response)
```

### 🕓 Baud Generator – `baudgen_115200_from_100m.v`

```verilog
// Verilog code here
```

### 💬 UART Transmitter and Receiver

```verilog
// Verilog code here
```

### 📍 Constraints Example (XDC)

```xdc
# 100 MHz clock
set_property -dict {PACKAGE_PIN W5 IOSTANDARD LVCMOS33} [get_ports clk_100mhz]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk_100mhz]

# UART pins (replace with actual Pmod pins)
set_property -dict {PACKAGE_PIN <FPGA_RX_PIN> IOSTANDARD LVCMOS33} [get_ports uart_rx_i]
set_property -dict {PACKAGE_PIN <FPGA_TX_PIN> IOSTANDARD LVCMOS33} [get_ports uart_tx_o]
```

---

## 💻 ESP32 (Arduino Code)

```cpp
// ESP32 Arduino code (see full version in ChatGPT response)
```

---

## 🧪 Test Procedure

1. **Synthesize & Program FPGA**
   - Add all Verilog files to a Vivado project.
   - Apply proper XDC constraints.
   - Generate bitstream and program the Nexys A7.

2. **Flash ESP32**
   - Upload the Arduino sketch.
   - Connect TX2 → RX, RX2 → TX, and GND ↔ GND.

3. **Run**
   - Open Serial Monitor @115200 baud.
   - LEDs on FPGA sweep pattern set by ESP32.
   - Toggling FPGA switches prints their binary states.

---

## 🧰 Troubleshooting

| Symptom | Possible Cause | Fix |
|----------|----------------|-----|
| No data | TX/RX mis-wired or no common GND | Cross TX↔RX and tie grounds |
| Garbled output | Baud mismatch | Ensure 115200 on both sides |
| No response | Wrong FPGA pins | Verify XDC matches wiring |
| Intermittent noise | Long wires | Shorten or add series resistors |

---

## 🧾 Summary

| Component | Tool / Environment |
|------------|--------------------|
| FPGA Design | Vivado 2020.2+ (Artix-7) |
| ESP32 Firmware | Arduino IDE / PlatformIO |
| Interface | UART @ 115200 bps |
| Features | ESP32 controls LEDs, reads switches |

---

**Author:** Dr. Komsan Kanjanasit  
**License:** MIT / Educational Use  
**Institution:** College of Computing, Prince of Songkla University, Thailand  
