#!/bin/bash
set -ex
export LC_ALL=C
/opt/Xilinx/Vivado/2014.3/bin/vivado -nojournal -nolog -mode batch -source upload.tcl
rm -f usage_statistics_webtalk.{html,xml}
