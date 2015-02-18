#!/bin/bash

set -ex

rm -f vivado.jou vivado.log
/opt/Xilinx/Vivado/2014.3/bin/vivado -mode batch -source system.tcl -tclargs synth

bash firmware.sh

/opt/Xilinx/SDK/2014.3/bin/xmd -tcl upload.tcl
rm -f usage_statistics_webtalk.{html,xml}
