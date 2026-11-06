# Nexys A7-100T constraints for the counter4 top module.
# Pin reference: https://github.com/Digilent/digilent-xdc/blob/master/Nexys-A7-100T-Master.xdc

# 100 MHz onboard oscillator.
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports {clk}]
create_clock -name sys_clk -period 10.000 -waveform {0.000 5.000} [get_ports {clk}]

# BTNC is the active-high reset. SW0 enables counting.
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports {reset}]
set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports {enable}]

# LD0 through LD3 display the count, least significant bit first.
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports {count[0]}]
set_property -dict {PACKAGE_PIN K15 IOSTANDARD LVCMOS33} [get_ports {count[1]}]
set_property -dict {PACKAGE_PIN J13 IOSTANDARD LVCMOS33} [get_ports {count[2]}]
set_property -dict {PACKAGE_PIN N14 IOSTANDARD LVCMOS33} [get_ports {count[3]}]
