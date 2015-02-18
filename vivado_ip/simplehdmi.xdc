set_property ASYNC_REG 1 [get_cells -hierarchical -filter {
	NAME =~ */svo_vdma/fifo/sync_*_ptr_*_reg[*] ||
	NAME =~ */svo_vdma/?resetn_q_reg[*] ||
	NAME =~ */svo_term/oresetn_q_reg[*] ||
	NAME =~ */svo_term/mem_st*_B?_reg[*] ||
	NAME =~ */svo_term/request_remove_line_syn?_reg ||
	NAME =~ */resetn_clk_pixel_q[*] ||
	NAME =~ */locked_clk_q_reg[*]
}]

set_false_path -to [get_pins -hierarchical -filter {
	NAME =~ */svo_vdma/fifo/sync_*_ptr_0_reg[*]/D ||
	NAME =~ */svo_vdma/?resetn_q_reg[0]/D ||
	NAME =~ */svo_term/oresetn_q_reg[0]/D ||
	NAME =~ */svo_term/mem_st*_B1_reg[*]/D ||
	NAME =~ */svo_term/request_remove_line_syn1_reg/D ||
	NAME =~ */resetn_clk_pixel_q[0]/D ||
	NAME =~ */locked_clk_q_reg[0]/D
}]
