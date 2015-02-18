
create_project -part xc7z010clg400-2 -in_memory

read_verilog ../svosrc/svo_tcard.v
read_verilog ../svosrc/svo_pong.v
read_verilog ../svosrc/svo_utils.v
read_verilog ../svosrc/svo_enc.v
read_verilog ../svosrc/svo_tmds.v
read_verilog ../svosrc/svo_openldi.v
read_xdc report.xdc

synth_design -top svo_enc
report_timing

synth_design -top svo_tmds
report_timing

synth_design -top svo_tcard
report_timing

synth_design -top svo_pong
report_timing

