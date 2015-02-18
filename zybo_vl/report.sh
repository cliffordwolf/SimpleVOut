#!/bin/bash
set -ex
export LC_ALL=C
rm -f report.log
/opt/Xilinx/Vivado/2014.3/bin/vivado -nojournal -log report.log -mode batch -source report.tcl
rm -f usage_statistics_webtalk.{html,xml}
python report.py report.log
