#!/bin/bash
set -ex
export LC_ALL=C
/opt/Xilinx/Vivado/2014.3/bin/xvlog system.v
/opt/Xilinx/Vivado/2014.3/bin/xvlog ../svosrc/svo_tcard.v
/opt/Xilinx/Vivado/2014.3/bin/xvlog ../svosrc/svo_pong.v
/opt/Xilinx/Vivado/2014.3/bin/xvlog ../svosrc/svo_utils.v
/opt/Xilinx/Vivado/2014.3/bin/xvlog ../svosrc/svo_enc.v
/opt/Xilinx/Vivado/2014.3/bin/xvlog ../svosrc/svo_tmds.v
/opt/Xilinx/Vivado/2014.3/bin/xvlog ../svosrc/svo_openldi.v
/opt/Xilinx/Vivado/2014.3/bin/xvlog testbench.v
/opt/Xilinx/Vivado/2014.3/bin/xelab -debug wave -lib unisim -R work.testbench
