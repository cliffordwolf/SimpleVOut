
verbose

xload hw firmware.sdk/hw/hwdef.xml
source firmware.sdk/hw/ps7_init.tcl

xconnect arm hw -cable type xilinx_tcf url TCP:127.0.0.1:3121
set_cur_target 64
set_cur_system
reset_zynqpl
xdisconnect 64
xdisconnect 352
set_cur_system_target

xfpga -cable type xilinx_tcf url TCP:127.0.0.1:3121 -f system.bit
xfpga_isconfigured -cable type xilinx_tcf url TCP:127.0.0.1:3121

xconnect arm hw -cable type xilinx_tcf url TCP:127.0.0.1:3121
set_cur_target 64
set_cur_system
xzynqresetstatus 64
ps7_init
ps7_post_config
xclearzynqresetstatus 64
xreset 64 0x80
# xdownload 64 firmware.elf
xdownload 64 firmware.sdk/app/Release/app.elf
xsafemode 64 off
xremove 64 all
xcontinue 64 0x100000 -status_on_stop

