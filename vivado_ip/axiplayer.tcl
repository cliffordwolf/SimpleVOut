
########################################################
## Create IP: AXI Player

create_project -ip -in_memory
set ip [ipx::create_core clifford.at ip axiplayer 1.0]

set_property display_name "AXI Player" $ip
set_property description "AXI Player" $ip
set_property supported_families {zynq Production} $ip
set_property taxonomy {{/SimpleVO}} $ip

file delete -force ip/axiplayer
file mkdir ip/axiplayer
file copy axiplayer.v ip/axiplayer/

set_property root_directory ip/axiplayer $ip

foreach fgn {verilog:synthesis verilog:simulation} {
	set fg [ipx::add_file_group -type $fgn {} $ip]
	set_property model_name axiplayer $fg
	ipx::add_file axiplayer.v $fg
}

ipx::import_top_level_hdl -top_level_hdl_file axiplayer.v $ip

set intf [ipx::add_bus_interface clk $ip]
set_property abstraction_type_vlnv xilinx.com:signal:clock_rtl:1.0 $intf
set_property bus_type_vlnv xilinx.com:signal:clock:1.0 $intf
set_property interface_mode slave $intf
set_property physical_name clk [ipx::add_port_map CLK $intf]

set intf [ipx::add_bus_interface reset $ip]
set_property abstraction_type_vlnv xilinx.com:signal:reset_rtl:1.0 $intf
set_property bus_type_vlnv xilinx.com:signal:reset:1.0 $intf
set_property interface_mode slave $intf
set_property physical_name resetn [ipx::add_port_map RST $intf]

set intf [ipx::add_bus_interface axi $ip]
set_property abstraction_type_vlnv xilinx.com:interface:aximm_rtl:1.0 $intf
set_property bus_type_vlnv xilinx.com:interface:aximm:1.0 $intf
set_property interface_mode master $intf

foreach it {
	{axi_awvalid	AWVALID}
	{axi_awready	AWREADY}
	{axi_awaddr	AWADDR}
	{axi_awprot	AWPROT}

	{axi_wvalid	WVALID}
	{axi_wready	WREADY}
	{axi_wdata	WDATA}
	{axi_wstrb	WSTRB}

	{axi_bvalid	BVALID}
	{axi_bready	BREADY}

	{axi_arvalid	ARVALID}
	{axi_arready	ARREADY}
	{axi_araddr	ARADDR}
	{axi_arprot	ARPROT}

	{axi_rvalid	RVALID}
	{axi_rready	RREADY}
	{axi_rdata	RDATA}
} {
	set_property physical_name [lindex $it 0] [ipx::add_port_map [lindex $it 1] $intf]
}

set_property value axi [ipx::add_bus_parameter ASSOCIATED_BUSIF [ipx::get_bus_interfaces clk]]

ipx::add_address_space axiplayer $ip
set_property master_address_space_ref axiplayer [ipx::get_bus_interfaces axi]
set_property range 4G [ipx::get_address_spaces axiplayer]

set_property -dict {
	display_name {Script Filename}
	value_format string
	value_resolve_type user
	value axiplayer.txt
} [ipx::add_user_parameter filename $ip]

ipx::create_xgui_files $ip
ipx::check_integrity $ip
ipx::save_core $ip
close_project

