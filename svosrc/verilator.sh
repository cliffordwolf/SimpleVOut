#!/bin/bash
set -ex
verilator -exe --trace -Wno-fatal --cc verilator.v svo_tcard.v svo_pong.v svo_utils.v svo_enc.v verilator.cc
make -C obj_dir/ -f Vverilator.mk
./obj_dir/Vverilator | pv -l -w 60 > testbench.out
python out2ppm.py testbench.out
