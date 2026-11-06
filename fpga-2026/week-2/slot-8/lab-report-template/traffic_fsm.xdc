# Nexys A7-100T constraints for the traffic_fsm_rgb top module.
# Pin reference: https://github.com/Digilent/digilent-xdc/blob/master/Nexys-A7-100T-Master.xdc

# 100 MHz oscillator and active-high center button (BTNC).
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports {clk}]
create_clock -name sys_clk -period 10.000 -waveform {0.000 5.000} [get_ports {clk}]
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports {reset}]

# LD17 is active high. Yellow is produced by red and green together.
set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS33} [get_ports {led_r}]
set_property -dict {PACKAGE_PIN R11 IOSTANDARD LVCMOS33} [get_ports {led_g}]
set_property -dict {PACKAGE_PIN G14 IOSTANDARD LVCMOS33} [get_ports {led_b}]
