
create_project -part xc7z010clg400-2 -in_memory

read_verilog system.v
read_verilog ../svosrc/svo_tcard.v
read_verilog ../svosrc/svo_pong.v
read_verilog ../svosrc/svo_utils.v
read_verilog ../svosrc/svo_enc.v
read_verilog ../svosrc/svo_tmds.v
read_verilog ../svosrc/svo_openldi.v
read_xdc system.xdc

synth_design -top system
opt_design
place_design
route_design

report_timing_summary -warn_on_violation

write_bitstream -force system.bit

