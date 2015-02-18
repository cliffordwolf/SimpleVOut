
#########################################################
# Clock (125 MHz)                                       #
#########################################################

set_property PACKAGE_PIN L16 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 8.000 -name sys_clk_pin -waveform {0.000 4.000} -add [get_ports clk]


#########################################################
# Zybo Switches/Buttons/LEDs                            #
#########################################################

set_property PACKAGE_PIN M14 [get_ports {led_0}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_0}]

# set_property PACKAGE_PIN M15 [get_ports {led_1}]
# set_property IOSTANDARD LVCMOS33 [get_ports {led_1}]
# 
# set_property PACKAGE_PIN G14 [get_ports {led_2}]
# set_property IOSTANDARD LVCMOS33 [get_ports {led_2}]
# 
# set_property PACKAGE_PIN D18 [get_ports {led_3}]
# set_property IOSTANDARD LVCMOS33 [get_ports {led_3}]


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


