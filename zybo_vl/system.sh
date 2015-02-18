#!/bin/bash
set -ex
export LC_ALL=C
rm -f vivado.jou vivado.log
/opt/Xilinx/Vivado/2014.3/bin/vivado -mode batch -source system.tcl
# /opt/Xilinx/SDK/2014.3/bin/bootgen -w -image bootgen.bif -o boot.bin
/opt/Xilinx/Vivado/2014.3/bin/vivado -nojournal -nolog -mode batch -source upload.tcl
rm -f usage_statistics_webtalk.{html,xml}
