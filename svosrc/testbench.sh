#!/bin/bash
set -ex
iverilog -o testbench testbench.v svo_tcard.v svo_pong.v svo_term.v svo_utils.v svo_enc.v
./testbench | pv -l -w 60 > testbench.out
python out2ppm.py testbench.out
