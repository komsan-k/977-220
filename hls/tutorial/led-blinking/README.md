# 🔬 Lab: LED Blinking with HLS on Nexys A7

## 🧠 Objective
Design and implement a **hardware LED blinker** using **High-Level Synthesis (HLS)** on the **Nexys A7 (Artix-7)** FPGA.  
This lab demonstrates how to write C/C++ code in **Vitis HLS**, generate Verilog RTL, and integrate it into a **Vivado** project.

---

## ⚙️ Requirements
- **Hardware:** Digilent Nexys A7 (Artix-7 50T or 100T)
- **Software:** Xilinx Vivado + Vitis HLS (2020.2 or newer)
- **Clock:** 100 MHz onboard oscillator
- **Target LED:** LED0 (H17)

---

## 🧩 Design Overview
We will create an **HLS function** that toggles an LED at a defined period.  
The function will:
- Use a **free-running control interface** (`ap_ctrl_none`)
- Count clock cycles and toggle LED output
- Accept `enable` and `period_cycles` inputs
- Drive a single LED output

---

## 💻 HLS Top Function (`led_blink_hls.cpp`)
```cpp
#include <ap_int.h>
#include <stdint.h>

void led_blink_hls(bool enable,
                   ap_uint<32> period_cycles,
                   ap_uint<1>  &led_out)
{
#pragma HLS INTERFACE ap_none      port=enable
#pragma HLS INTERFACE ap_none      port=period_cycles
#pragma HLS INTERFACE ap_none      port=led_out
#pragma HLS INTERFACE ap_ctrl_none port=return

    static ap_uint<32> cnt = 0;
    static ap_uint<1>  led = 0;

#pragma HLS RESET variable=cnt
#pragma HLS RESET variable=led

    if (!enable) {
        cnt = 0;
        led = 0;
    } else {
        if (cnt >= period_cycles) {
            cnt = 0;
            led = ~led;
        } else {
            cnt++;
        }
    }

    led_out = led;
}
```

---

## 🧪 Simulation Testbench (`tb_led_blink.cpp`)
```cpp
#include <iostream>
#include "ap_int.h"

void led_blink_hls(bool enable, ap_uint<32> period_cycles, ap_uint<1> &led_out);

int main() {
    ap_uint<1> led = 0;
    bool enable = true;
    const ap_uint<32> period = 10;
    for (int i = 0; i < 50; ++i) {
        led_blink_hls(enable, period, led);
        std::cout << i << ": led=" << (int)led << "\n";
    }
    return 0;
}
```

Run **C Simulation** in **Vitis HLS** to verify LED toggling.

---

## 🔧 Vivado Integration (Top-Level Wrapper)

```verilog
module top_led_hls (
    input  wire        clk_100mhz,
    input  wire [7:0]  sw,
    output wire [7:0]  led
);
    wire ap_rst_n = 1'b1;
    wire [31:0] PERIOD = {24'd0, sw} * 32'd1_000_000;
    wire led0;
    wire enable = 1'b1;

    led_blink_hls u_hls (
        .ap_clk        (clk_100mhz),
        .ap_rst_n      (ap_rst_n),
        .enable        (enable),
        .period_cycles (PERIOD),
        .led_out       (led0)
    );

    assign led[0] = led0;
    assign led[7:1] = 7'b0;
endmodule
```

---

## 📍 XDC Constraints (`nexys_a7_led_hls.xdc`)
```xdc
## Clock (100 MHz)
set_property -dict { PACKAGE_PIN W5 IOSTANDARD LVCMOS33 } [get_ports clk_100mhz]
create_clock -add -name sys_clk_pin -period 10.000 [get_ports clk_100mhz]

## LED0
set_property -dict { PACKAGE_PIN H17 IOSTANDARD LVCMOS33 } [get_ports {led[0]}]

## Switches
set_property -dict { PACKAGE_PIN J15 IOSTANDARD LVCMOS33 } [get_ports {sw[0]}]
set_property -dict { PACKAGE_PIN L16 IOSTANDARD LVCMOS33 } [get_ports {sw[1]}]
set_property -dict { PACKAGE_PIN M13 IOSTANDARD LVCMOS33 } [get_ports {sw[2]}]
set_property -dict { PACKAGE_PIN R15 IOSTANDARD LVCMOS33 } [get_ports {sw[3]}]
set_property -dict { PACKAGE_PIN R17 IOSTANDARD LVCMOS33 } [get_ports {sw[4]}]
set_property -dict { PACKAGE_PIN T18 IOSTANDARD LVCMOS33 } [get_ports {sw[5]}]
set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports {sw[6]}]
set_property -dict { PACKAGE_PIN R13 IOSTANDARD LVCMOS33 } [get_ports {sw[7]}]
```

---

## 🧱 Implementation Steps

1. **Vitis HLS**
   - Import `led_blink_hls.cpp` and run **C Simulation**.
   - Run **C Synthesis** with 10 ns clock.
   - Export RTL as Verilog.

2. **Vivado**
   - Create a new RTL project for the **Nexys A7**.
   - Add the HLS-exported Verilog files and `top_led_hls.v`.
   - Add XDC constraints.
   - Run **Synthesis → Implementation → Bitstream**.
   - Program FPGA.

3. **Demo**
   - LED0 blinks at adjustable rate.
   - Toggle switches to change blink speed.

---

## 🧰 Troubleshooting

| Issue | Cause | Solution |
|-------|--------|-----------|
| LED not blinking | Reset not tied or clock missing | Tie `ap_rst_n = 1` and check XDC clock |
| Blink too fast/slow | Wrong period | Adjust `PERIOD` multiplier |
| Synthesis errors | Port name mismatch | Match exported HLS port names |

---

## 🧩 Lab Exercises

1. Modify the design to blink **all 8 LEDs** in sequence.  
2. Use `ap_ctrl_hs` and control `start` signal from switches.  
3. Create an **AXI-Lite** version to set `period` dynamically via MicroBlaze.  
4. Optimize HLS design using pragmas (`PIPELINE`, `UNROLL`).  
5. Measure resource utilization difference between versions.

---

## 📘 Deliverables
- `led_blink_hls.cpp` and `tb_led_blink.cpp` source files  
- Synthesis report screenshots (Vitis + Vivado)  
- Bitstream and hardware test photo/video  
- Lab questions and answers

---

**Author:** Dr. Komsan Kanjanasit  
**Institution:** College of Computing, Prince of Songkla University, Thailand  
**License:** Educational / MIT  
