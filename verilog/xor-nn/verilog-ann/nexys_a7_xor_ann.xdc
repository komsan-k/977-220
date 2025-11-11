# nexys_a7_xor_ann.xdc (snippet)
# Map switches SW0, SW1 to inputs A, B; LED0 to Y
# Uncomment and adjust to your board constraints

## CLOCK not required (purely combinational)
## set_property -dict { PACKAGE_PIN W5   IOSTANDARD LVCMOS33 } [get_ports {CLK}]

set_property -dict { PACKAGE_PIN V17  IOSTANDARD LVCMOS33 } [get_ports {A}]   ;# SW0
set_property -dict { PACKAGE_PIN V16  IOSTANDARD LVCMOS33 } [get_ports {B}]   ;# SW1
set_property -dict { PACKAGE_PIN U16  IOSTANDARD LVCMOS33 } [get_ports {Y}]   ;# LED0
