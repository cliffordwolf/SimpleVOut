
#########################################################
# Clock (125 MHz)                                       #
#########################################################

set_property PACKAGE_PIN L16 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports clk]


#########################################################
# Zybo Switches/Buttons/LEDs                            #
#########################################################

set_property PACKAGE_PIN G15 [get_ports {sw[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[0]}]

set_property PACKAGE_PIN P15 [get_ports {sw[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[1]}]

set_property PACKAGE_PIN W13 [get_ports {sw[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[2]}]

set_property PACKAGE_PIN T16 [get_ports {sw[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[3]}]

# set_property PACKAGE_PIN R18 [get_ports {btn[0]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {btn[0]}]

# set_property PACKAGE_PIN P16 [get_ports {btn[1]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {btn[1]}]

set_property PACKAGE_PIN V16 [get_ports {btn[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn[2]}]

set_property PACKAGE_PIN Y16 [get_ports {btn[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn[3]}]

set_property PACKAGE_PIN M14 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]

set_property PACKAGE_PIN M15 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]

set_property PACKAGE_PIN G14 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]

set_property PACKAGE_PIN D18 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]


#########################################################
# External Gamepad
#########################################################

set_property PACKAGE_PIN V20 [get_ports {btn[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn[0]}]

set_property PACKAGE_PIN W20 [get_ports {btn[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn[1]}]


#########################################################
# TMDS (DVI, HDMI)                                      #
#########################################################

set_property PACKAGE_PIN H17 [get_ports tmds_clk_n]
set_property IOSTANDARD TMDS_33 [get_ports tmds_clk_n]

set_property PACKAGE_PIN H16 [get_ports tmds_clk_p]
set_property IOSTANDARD TMDS_33 [get_ports tmds_clk_p]

set_property PACKAGE_PIN D20 [get_ports {tmds_d_n[0]}]
set_property IOSTANDARD TMDS_33 [get_ports {tmds_d_n[0]}]

set_property PACKAGE_PIN D19 [get_ports {tmds_d_p[0]}]
set_property IOSTANDARD TMDS_33 [get_ports {tmds_d_p[0]}]

set_property PACKAGE_PIN B20 [get_ports {tmds_d_n[1]}]
set_property IOSTANDARD TMDS_33 [get_ports {tmds_d_n[1]}]

set_property PACKAGE_PIN C20 [get_ports {tmds_d_p[1]}]
set_property IOSTANDARD TMDS_33 [get_ports {tmds_d_p[1]}]

set_property PACKAGE_PIN A20 [get_ports {tmds_d_n[2]}]
set_property IOSTANDARD TMDS_33 [get_ports {tmds_d_n[2]}]

set_property PACKAGE_PIN B19 [get_ports {tmds_d_p[2]}]
set_property IOSTANDARD TMDS_33 [get_ports {tmds_d_p[2]}]


#########################################################
# OpenLDI (aka LVDS)                                    #
#########################################################

set_property PACKAGE_PIN V18 [get_ports {openldi_clk_n}]
set_property IOSTANDARD LVCMOS33 [get_ports {openldi_clk_n}]

set_property PACKAGE_PIN V17 [get_ports {openldi_clk_p}]
set_property IOSTANDARD LVCMOS33 [get_ports {openldi_clk_p}]

set_property PACKAGE_PIN U15 [get_ports {openldi_a_n[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {openldi_a_n[0]}]

set_property PACKAGE_PIN U14 [get_ports {openldi_a_p[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {openldi_a_p[0]}]

set_property PACKAGE_PIN T15 [get_ports {openldi_a_n[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {openldi_a_n[1]}]

set_property PACKAGE_PIN T14 [get_ports {openldi_a_p[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {openldi_a_p[1]}]

set_property PACKAGE_PIN R14 [get_ports {openldi_a_n[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {openldi_a_n[2]}]

set_property PACKAGE_PIN P14 [get_ports {openldi_a_p[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {openldi_a_p[2]}]


#########################################################
# VGA                                                   #
#########################################################

set_property PACKAGE_PIN M19 [get_ports {vga_r[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_r[0]}]

set_property PACKAGE_PIN L20 [get_ports {vga_r[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_r[1]}]

set_property PACKAGE_PIN J20 [get_ports {vga_r[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_r[2]}]

set_property PACKAGE_PIN G20 [get_ports {vga_r[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_r[3]}]

set_property PACKAGE_PIN F19 [get_ports {vga_r[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_r[4]}]

set_property PACKAGE_PIN H18 [get_ports {vga_g[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_g[0]}]

set_property PACKAGE_PIN N20 [get_ports {vga_g[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_g[1]}]

set_property PACKAGE_PIN L19 [get_ports {vga_g[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_g[2]}]

set_property PACKAGE_PIN J19 [get_ports {vga_g[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_g[3]}]

set_property PACKAGE_PIN H20 [get_ports {vga_g[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_g[4]}]

set_property PACKAGE_PIN F20 [get_ports {vga_g[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_g[5]}]

set_property PACKAGE_PIN P20 [get_ports {vga_b[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_b[0]}]

set_property PACKAGE_PIN M20 [get_ports {vga_b[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_b[1]}]

set_property PACKAGE_PIN K19 [get_ports {vga_b[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_b[2]}]

set_property PACKAGE_PIN J18 [get_ports {vga_b[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_b[3]}]

set_property PACKAGE_PIN G19 [get_ports {vga_b[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_b[4]}]

set_property PACKAGE_PIN P19 [get_ports vga_hs]
set_property IOSTANDARD LVCMOS33 [get_ports vga_hs]

set_property PACKAGE_PIN R19 [get_ports vga_vs]
set_property IOSTANDARD LVCMOS33 [get_ports vga_vs]
