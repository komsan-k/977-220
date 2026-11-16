## LD17 — Vehicle Traffic Light
set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS33} [get_ports {vehicle_r}]
set_property -dict {PACKAGE_PIN R11 IOSTANDARD LVCMOS33} [get_ports {vehicle_g}]
set_property -dict {PACKAGE_PIN G14 IOSTANDARD LVCMOS33} [get_ports {vehicle_b}]

## LD16 — Pedestrian Signal
set_property -dict {PACKAGE_PIN N15 IOSTANDARD LVCMOS33} [get_ports {ped_r}]
set_property -dict {PACKAGE_PIN M16 IOSTANDARD LVCMOS33} [get_ports {ped_g}]
set_property -dict {PACKAGE_PIN R12 IOSTANDARD LVCMOS33} [get_ports {ped_b}]
