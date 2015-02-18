
########################################################
## Create IP: Simple TMDS (HDMI) Framebuffer

create_project -part xc7z010 -ip -in_memory
set ip [ipx::create_core clifford.at ip simplehdmi 1.0]

set_property display_name "Simple HDMI Framebuffer" $ip
set_property description {SimpleVO-based HDMI Framebuffer} $ip
set_property supported_families {zynq Production} $ip
set_property taxonomy {{/SimpleVO}} $ip

file delete -force ip/simplehdmi
file mkdir ip/simplehdmi/bd
file copy simplehdmi.v ip/simplehdmi/
file copy simplehdmi.xdc ip/simplehdmi/
file copy simplehdmi_bd.tcl ip/simplehdmi/bd/bd.tcl
file copy ../svosrc/svo_enc.v ip/simplehdmi/
file copy ../svosrc/svo_vdma.v ip/simplehdmi/
file copy ../svosrc/svo_term.v ip/simplehdmi/
file copy ../svosrc/svo_tmds.v ip/simplehdmi/
file copy ../svosrc/svo_utils.v ip/simplehdmi/
file copy ../svosrc/svo_defines.vh ip/simplehdmi/

set_property root_directory ip/simplehdmi $ip

foreach fgn {verilog:synthesis verilog:simulation} {
	set fg [ipx::add_file_group -type $fgn {} $ip]
	set_property model_name simplehdmi $fg
	ipx::add_file svo_enc.v $fg
	ipx::add_file svo_vdma.v $fg
	ipx::add_file svo_term.v $fg
	ipx::add_file svo_tmds.v $fg
	ipx::add_file svo_utils.v $fg
	ipx::add_file svo_defines.vh $fg
	ipx::add_file simplehdmi.xdc $fg
	ipx::add_file simplehdmi.v $fg
}

set fg [ipx::add_file_group -type block_diagram {} $ip]
ipx::add_file bd/bd.tcl $fg

# set_property library_name simplehdmi [ipx::get_files \
#	-filter {NAME =~ *.v || NAME =~ *.vh || NAME =~ *.xdc} \
#	-of_objects [ipx::get_file_groups -of_objects [ipx::current_core]]]

ipx::import_top_level_hdl -top_level_hdl_file simplehdmi.v $ip
ipx::add_model_parameters_from_hdl -top_level_hdl_file simplehdmi.v $ip
# ipx::infer_bus_interfaces $ip


#####################################
# config interface: axi4-lite slave

set intf [ipx::add_bus_interface cfg $ip]
set_property abstraction_type_vlnv xilinx.com:interface:aximm_rtl:1.0 $intf
set_property bus_type_vlnv xilinx.com:interface:aximm:1.0 $intf
set_property interface_mode slave $intf

foreach it {
	{cfg_axi_awvalid  AWVALID}
	{cfg_axi_awready  AWREADY}
	{cfg_axi_awaddr   AWADDR}
	{cfg_axi_wvalid   WVALID}
	{cfg_axi_wready   WREADY}
	{cfg_axi_wdata    WDATA}
	{cfg_axi_bvalid   BVALID}
	{cfg_axi_bready   BREADY}
	{cfg_axi_arvalid  ARVALID}
	{cfg_axi_arready  ARREADY}
	{cfg_axi_araddr   ARADDR}
	{cfg_axi_rvalid   RVALID}
	{cfg_axi_rready   RREADY}
	{cfg_axi_rdata    RDATA}
} {
	set_property physical_name [lindex $it 0] [ipx::add_port_map [lindex $it 1] $intf]
}

#ipx::add_memory_map cfg $ip
#set_property slave_memory_map_ref cfg $intf


#####################################
# memory interface: axi4 read-only master

set intf [ipx::add_bus_interface mem $ip]
set_property abstraction_type_vlnv xilinx.com:interface:aximm_rtl:1.0 $intf
set_property bus_type_vlnv xilinx.com:interface:aximm:1.0 $intf
set_property interface_mode master $intf

foreach it {
	{mem_axi_araddr   ARADDR}
	{mem_axi_arlen    ARLEN}
	{mem_axi_arsize   ARSIZE}
	{mem_axi_arprot   ARPROT}
	{mem_axi_arburst  ARBURST}
	{mem_axi_arvalid  ARVALID}
	{mem_axi_arready  ARREADY}
	{mem_axi_rdata    RDATA}
	{mem_axi_rvalid   RVALID}
	{mem_axi_rready   RREADY}
} {
	set_property physical_name [lindex $it 0] [ipx::add_port_map [lindex $it 1] $intf]
}

set_property -dict {range 4G width 32} [ipx::add_address_space mem $ip]
set_property master_address_space_ref mem $intf


#####################################
# clocks

foreach it {clk clk_pixel clk_5x_pixel} {
	set intf [ipx::add_bus_interface $it $ip]
	set_property -dict {
		abstraction_type_vlnv xilinx.com:signal:clock_rtl:1.0
		bus_type_vlnv xilinx.com:signal:clock:1.0
		interface_mode slave
	} $intf
	set_property physical_name $it [ipx::add_port_map CLK $intf]
}

set_property value {cfg:mem} [ipx::add_bus_parameter ASSOCIATED_BUSIF [ipx::get_bus_interfaces clk]]


#####################################
# svo parameters

# gawk '! /^#/ { print $1; }' ../svosrc/modes.txt | fmt
set modes "{320x200 320x240 352x288 384x288 480x320 640x480 768x576 768x576 800x480
800x600 854x480 1024x576 1024x600 1024x768 1152x768 1152x864 1280x1024
1280x720 1280x768 1280x800 1280x854 1280x960 1366x768 1400x1050
1440x1080 1440x900 1440x960 1600x1200 1600x900 1680x1050 1920x1080
1920x1200 2048x1080 2048x1536 2560x1080 2560x1440 2560x1600 2560x2048
3840x2160 4096x2160 320x200R 320x240R 352x288R 384x288R 480x320R 640x480R
768x576R 768x576R 800x480R 800x600R 854x480R 1024x576R 1024x600R 1024x768R
1152x768R 1152x864R 1280x1024R 1280x720R 1280x768R 1280x800R 1280x854R
1280x960R 1366x768R 1400x1050R 1440x1080R 1440x900R 1440x960R 1600x1200R
1600x900R 1680x1050R 1920x1080R 1920x1200R 2048x1080R 2048x1536R
2560x1080R 2560x1440R 2560x1600R 2560x2048R 3840x2160R 4096x2160R 64x48T}"

set_property -dict "
	display_name SVO_MODE
	value_resolve_type user
	value [get_property value [ipx::get_hdl_parameters SVO_MODE]]
	value_validation_type list
	value_validation_list $modes
" [ipx::add_user_parameter SVO_MODE $ip]

foreach i {
	SVO_FRAMERATE
	SVO_BITS_PER_PIXEL
	SVO_BITS_PER_RED
	SVO_BITS_PER_GREEN
	SVO_BITS_PER_BLUE
	SVO_BITS_PER_ALPHA
} {
	set_property -dict "
		display_name $i
		value_resolve_type user
		value [get_property value [ipx::get_hdl_parameters $i]]
	" [ipx::add_user_parameter $i $ip]
}


#####################################
# package IP

ipx::create_xgui_files $ip
ipx::check_integrity $ip
ipx::save_core $ip
close_project

