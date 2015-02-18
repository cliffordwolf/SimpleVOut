
########################################################
## Create IP cores

if ![file exists ../vivado_ip/ip] {
	set old_pwd [pwd]
	cd ../vivado_ip
	source build.tcl
	cd $old_pwd
}


########################################################
## Create top-level block design

create_project -part xc7z010clg400-2 -in_memory
# save_project_as -force system_prj

set_property ip_repo_paths "[pwd]/../vivado_ip/ip" [current_fileset]
update_ip_catalog -rebuild

create_bd_design system

create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7 ps7
set_property CONFIG.PCW_IMPORT_BOARD_PRESET {zynq_def.xml} [get_bd_cells ps7]
set_property CONFIG.PCW_USE_S_AXI_HP0 1 [get_bd_cells ps7]
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 \
	-config {make_external "FIXED_IO, DDR" Master "Disable" Slave "Disable"} [get_bd_cells ps7]

create_bd_cell -type ip -vlnv clifford.at:ip:simplehdmi framebuffer
set_property -dict "
	CONFIG.SVO_MODE    1280x720R
	CONFIG.SVO_FRAMERATE      60
	CONFIG.SVO_BITS_PER_PIXEL 24
	CONFIG.SVO_BITS_PER_RED    8
	CONFIG.SVO_BITS_PER_GREEN  8
	CONFIG.SVO_BITS_PER_BLUE   8
	CONFIG.SVO_BITS_PER_ALPHA  0
" [get_bd_cells framebuffer]

create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz clk_wiz
set_property -dict "
	CONFIG.PRIMITIVE {PLL}
	CONFIG.USE_RESET {false}
	CONFIG.CLKOUT1_USED {true}
	CONFIG.CLKOUT2_USED {true}
	CONFIG.CLKOUT1_REQUESTED_OUT_FREQ [expr "double([get_property CONFIG.FREQ_HZ [get_bd_pins framebuffer/clk_pixel]])/1e6"]
	CONFIG.CLKOUT2_REQUESTED_OUT_FREQ [expr "double([get_property CONFIG.FREQ_HZ [get_bd_pins framebuffer/clk_5x_pixel]])/1e6"]
" [get_bd_cells clk_wiz]

create_bd_port -dir I -type clk clk
set_property CONFIG.FREQ_HZ 125000000 [get_bd_ports clk]

create_bd_port -dir O tmds_clk_n
create_bd_port -dir O tmds_clk_p
create_bd_port -dir O -from 2 -to 0 tmds_d_n
create_bd_port -dir O -from 2 -to 0 tmds_d_p

create_bd_port -dir O led_0
# create_bd_port -dir O led_1
# create_bd_port -dir O led_2
# create_bd_port -dir O led_3

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/framebuffer/mem" Clk "Auto"}  [get_bd_intf_pins ps7/S_AXI_HP0]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/ps7/M_AXI_GP0" Clk "Auto"}  [get_bd_intf_pins framebuffer/cfg]

connect_bd_net [get_bd_ports clk] [get_bd_pins clk_wiz/clk_in1]
connect_bd_net [get_bd_pins framebuffer/resetn] [get_bd_pins ps7/FCLK_RESET0_N]
connect_bd_net [get_bd_pins framebuffer/locked] [get_bd_pins clk_wiz/locked]
connect_bd_net [get_bd_pins framebuffer/clk_pixel] [get_bd_pins clk_wiz/clk_out1]
connect_bd_net [get_bd_pins framebuffer/clk_5x_pixel] [get_bd_pins clk_wiz/clk_out2]

connect_bd_net [get_bd_pins framebuffer/ok_led] [get_bd_ports led_0]

foreach it {tmds_clk_n tmds_clk_p tmds_d_n tmds_d_p} {
	connect_bd_net [get_bd_ports $it] [get_bd_pins framebuffer/$it]
}

set_property -dict {offset 0x00000000 range 512M} [get_bd_addr_segs {framebuffer/mem/SEG_ps7_HP0_DDR_LOWOCM}]
set_property -dict {offset 0x43000000 range  64k} [get_bd_addr_segs {ps7/Data/SEG_framebuffer_Reg}]

regenerate_bd_layout
validate_bd_design


########################################################
## Synthesis or Simulation

read_xdc system.xdc

generate_target all [get_files system.bd]
write_hwdef -force -file system.hdf

if {$argv == "test"} {
	save_project_as -force testbench_prj
	add_files -fileset sim_1 testbench.v
	set_property top testbench [get_filesets sim_1]
	update_compile_order -fileset sim_1

	launch_simulation
	close_wave_config
	open_wave_config testbench.wcfg

	restart
	run 500 us
}

if {$argv == "synth"} {
	synth_design -top system

	opt_design
	place_design
	route_design

	report_timing -warn_on_violation
	write_bitstream -force system.bit
}

