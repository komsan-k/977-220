## Nexys A7 (100 MHz) — verify board variant and master XDC before use.
set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.000 -waveform {0 5} [get_ports clk]

## Inputs: SW0=A, SW1=B, BTNU=start, BTNC=rst
set_property -dict { PACKAGE_PIN J15 IOSTANDARD LVCMOS33 } [get_ports A]
set_property -dict { PACKAGE_PIN L16 IOSTANDARD LVCMOS33 } [get_ports B]
set_property -dict { PACKAGE_PIN M18 IOSTANDARD LVCMOS33 } [get_ports start]
set_property -dict { PACKAGE_PIN N17 IOSTANDARD LVCMOS33 } [get_ports rst]

## Outputs: LD0=Y, LD1=H1, LD2=H2, LD3=done
set_property -dict { PACKAGE_PIN H17 IOSTANDARD LVCMOS33 } [get_ports Y]
set_property -dict { PACKAGE_PIN K15 IOSTANDARD LVCMOS33 } [get_ports H1]
set_property -dict { PACKAGE_PIN J13 IOSTANDARD LVCMOS33 } [get_ports H2]
set_property -dict { PACKAGE_PIN N14 IOSTANDARD LVCMOS33 } [get_ports done]
