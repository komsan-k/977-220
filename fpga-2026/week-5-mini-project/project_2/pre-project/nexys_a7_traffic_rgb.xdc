## Nexys A7 RGB LEDs — pins transcribed from supplied schematic
## LD17: vehicle traffic signal; LD16: pedestrian signal
## Active-high outputs; yellow = red + green simultaneously.
## Change port names to match your Verilog top-level module.

## LD17 vehicle traffic RGB
set_property -dict { PACKAGE_PIN N16 IOSTANDARD LVCMOS33 } [get_ports {vehicle_r}]
set_property -dict { PACKAGE_PIN R11 IOSTANDARD LVCMOS33 } [get_ports {vehicle_g}]
set_property -dict { PACKAGE_PIN G14 IOSTANDARD LVCMOS33 } [get_ports {vehicle_b}]

## LD16 pedestrian RGB
set_property -dict { PACKAGE_PIN N15 IOSTANDARD LVCMOS33 } [get_ports {ped_r}]
set_property -dict { PACKAGE_PIN M16 IOSTANDARD LVCMOS33 } [get_ports {ped_g}]
set_property -dict { PACKAGE_PIN R12 IOSTANDARD LVCMOS33 } [get_ports {ped_b}]

## The image does not specify clock, reset or pedestrian-button pins.
## Add their verified Nexys A7 constraints separately.
