
connect_hw_server
open_hw_target [lindex [get_hw_targets] 0]

create_hw_cfgmem -hw_device [lindex [get_hw_devices] 1] -mem_dev  [lindex [get_cfgmem_parts {s25fl128s-3.3v-qspi-x4-single}] 0]
set cfgmem [get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 1]]

set_property -dict {
	PROGRAM.BLANK_CHECK 0
	PROGRAM.ERASE 1
	PROGRAM.CFG_PROGRAM 1
	PROGRAM.VERIFY 1
} $cfgmem
refresh_hw_device [lindex [get_hw_devices] 1]

set_property -dict {
	PROGRAM.ADDRESS_RANGE {use_file}
	PROGRAM.FILES {boot.bin}
} $cfgmem

program_hw_cfgmem -hw_cfgmem $cfgmem

