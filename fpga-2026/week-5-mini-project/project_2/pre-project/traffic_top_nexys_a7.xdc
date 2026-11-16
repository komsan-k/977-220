## Nexys A7 — traffic_top constraints
## 100 MHz onboard oscillator
set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports {clk}]
create_clock -add -name sys_clk -period 10.000 -waveform {0 5} [get_ports {clk}]

## Push buttons: BTNC = synchronous active-high reset; BTNU = pedestrian request
set_property -dict { PACKAGE_PIN N17 IOSTANDARD LVCMOS33 } [get_ports {rst}]
set_property -dict { PACKAGE_PIN M18 IOSTANDARD LVCMOS33 } [get_ports {ped_button}]

## LD17 RGB: R17=N16, G17=R11, B17=G14
## CAUTION: 'yellow' drives BLUE channel; XDC cannot make yellow from a single port.
set_property -dict { PACKAGE_PIN N16 IOSTANDARD LVCMOS33 } [get_ports {red}]
set_property -dict { PACKAGE_PIN G14 IOSTANDARD LVCMOS33 } [get_ports {yellow}]
set_property -dict { PACKAGE_PIN R11 IOSTANDARD LVCMOS33 } [get_ports {green}]

## LD16 RGB: R16=N15, G16=M16
set_property -dict { PACKAGE_PIN M16 IOSTANDARD LVCMOS33 } [get_ports {ped_walk}]
set_property -dict { PACKAGE_PIN N15 IOSTANDARD LVCMOS33 } [get_ports {ped_stop}]

