
########################################################
## Create IP cores

source simplehdmi.tcl
source axiplayer.tcl


########################################################
## Create top-level block design

create_project -part xc7z010clg400-2 -in_memory

set_property ip_repo_paths "[pwd]/ip" [current_fileset]
update_ip_catalog -rebuild

create_bd_design system

create_bd_cell -type ip -vlnv clifford.at:ip:simplehdmi framebuffer
set_property -dict {
	CONFIG.SVO_MODE {64x48T}
	CONFIG.SVO_FRAMERATE 13333
} [get_bd_cells framebuffer]

create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz clk_wiz
set_property -dict {
	CONFIG.PRIMITIVE {PLL}
	CONFIG.USE_RESET {false}
	CONFIG.CLKOUT1_USED {true}
	CONFIG.CLKOUT2_USED {true}
	CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {50}
	CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {250}
} [get_bd_cells clk_wiz]

create_bd_port -dir I -type clk clk
set_property CONFIG.FREQ_HZ 125000000 [get_bd_ports clk]

create_bd_port -dir O tmds_clk_n
create_bd_port -dir O tmds_clk_p
create_bd_port -dir O -from 2 -to 0 tmds_d_n
create_bd_port -dir O -from 2 -to 0 tmds_d_p
create_bd_port -dir O ok_led

connect_bd_net [get_bd_ports clk] [get_bd_pins clk_wiz/clk_in1]
connect_bd_net [get_bd_pins framebuffer/locked] [get_bd_pins clk_wiz/locked]
connect_bd_net [get_bd_pins framebuffer/clk_pixel] [get_bd_pins clk_wiz/clk_out1]
connect_bd_net [get_bd_pins framebuffer/clk_5x_pixel] [get_bd_pins clk_wiz/clk_out2]

foreach it {tmds_clk_n tmds_clk_p tmds_d_n tmds_d_p ok_led} {
	connect_bd_net [get_bd_ports $it] [get_bd_pins framebuffer/$it]
}

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 axi_bram_ctrl_0
apply_bd_automation -rule xilinx.com:bd_rule:bram_cntlr -config {BRAM "New Blk_Mem_Gen"}  [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA]
apply_bd_automation -rule xilinx.com:bd_rule:bram_cntlr -config {BRAM "Blk_Mem_Gen of BRAM_PORTA"}  [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTB]

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0
set_property -dict {CONFIG.NUM_SI {2}} [get_bd_cells axi_interconnect_0]

create_bd_cell -type ip -vlnv clifford.at:ip:axiplayer:1.0 axiplayer_0
set_property CONFIG.filename "[pwd]/axiplayer.txt" [get_bd_cells axiplayer_0]

connect_bd_net [get_bd_ports clk] [get_bd_pins {
	axiplayer_0/clk
	clk_wiz/clk_in1
	axi_interconnect_0/ACLK
	axi_interconnect_0/S00_ACLK
	axi_interconnect_0/M00_ACLK
	axi_interconnect_0/M01_ACLK
	axi_interconnect_0/S01_ACLK
	axi_bram_ctrl_0/s_axi_aclk
	framebuffer/clk
}]

connect_bd_net [get_bd_pins clk_wiz/locked] [get_bd_pins {
	axi_bram_ctrl_0/s_axi_aresetn
	axi_interconnect_0/ARESETN
	axi_interconnect_0/M00_ARESETN
	axi_interconnect_0/M01_ARESETN
	axi_interconnect_0/S00_ARESETN
	axi_interconnect_0/S01_ARESETN
	axiplayer_0/resetn
	framebuffer/resetn
}]

connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/S00_AXI] [get_bd_intf_pins framebuffer/mem]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/S01_AXI] [get_bd_intf_pins axiplayer_0/axi]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M00_AXI] [get_bd_intf_pins framebuffer/cfg]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M01_AXI] [get_bd_intf_pins axi_bram_ctrl_0/S_AXI]

assign_bd_address
set_property -dict {offset 0xA0000000 range 64K} [get_bd_addr_segs */SEG_axi_bram_ctrl_0_Mem0]
set_property -dict {offset 0xB0000000 range  4K} [get_bd_addr_segs */SEG_framebuffer_Reg]

regenerate_bd_layout
validate_bd_design


########################################################
## Simulation

make_wrapper -files [get_files system.bd] -top
generate_target all [get_files system.bd]
add_files -fileset sim_1 testbench.v
update_compile_order -fileset sim_1
save_project_as -force testbench

launch_simulation
open_wave_config testbench.wcfg
restart
run 500 us

