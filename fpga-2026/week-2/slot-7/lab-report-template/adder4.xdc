# Digilent Nexys A7-100T constraints for the adder4 top module.
# Board pin reference: https://github.com/Digilent/digilent-xdc/blob/master/Nexys-A7-100T-Master.xdc

# A[3:0] = SW3 through SW0, with SW0 as the least significant bit.
set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports {A[0]}]
set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS33} [get_ports {A[1]}]
set_property -dict {PACKAGE_PIN M13 IOSTANDARD LVCMOS33} [get_ports {A[2]}]
set_property -dict {PACKAGE_PIN R15 IOSTANDARD LVCMOS33} [get_ports {A[3]}]

# B[3:0] = SW7 through SW4, with SW4 as the least significant bit.
set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVCMOS33} [get_ports {B[0]}]
set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS33} [get_ports {B[1]}]
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports {B[2]}]
set_property -dict {PACKAGE_PIN R13 IOSTANDARD LVCMOS33} [get_ports {B[3]}]

# SUM[4:0] = LD4 through LD0, with LD4 showing the carry-out.
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports {SUM[0]}]
set_property -dict {PACKAGE_PIN K15 IOSTANDARD LVCMOS33} [get_ports {SUM[1]}]
set_property -dict {PACKAGE_PIN J13 IOSTANDARD LVCMOS33} [get_ports {SUM[2]}]
set_property -dict {PACKAGE_PIN N14 IOSTANDARD LVCMOS33} [get_ports {SUM[3]}]
set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33} [get_ports {SUM[4]}]
