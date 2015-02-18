/*
 *  SVO - Simple Video Out FPGA Core
 *
 *  Copyright (C) 2014  Clifford Wolf <clifford@clifford.at>
 *  
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *  
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

`timescale 1ns / 1ps
`include "../svosrc/svo_defines.vh"

module testbench;
	reg clk = 0;
	always #4 clk = ~clk;

	wire [4:0] vga_r;
	wire [5:0] vga_g;
	wire [4:0] vga_b;
	wire vga_hs;
	wire vga_vs;

	wire tmds_clk_n;
	wire tmds_clk_p;
	wire tmds_d_n2, tmds_d_n1, tmds_d_n0;
	wire tmds_d_p2, tmds_d_p1, tmds_d_p0;

	wire openldi_clk_n;
	wire openldi_clk_p;
	wire openldi_a_n2, openldi_a_n1, openldi_a_n0;
	wire openldi_a_p2, openldi_a_p1, openldi_a_p0;

	system system (
		.clk(clk),

		.vga_r(vga_r),
		.vga_g(vga_g),
		.vga_b(vga_b),
		.vga_hs(vga_hs),
		.vga_vs(vga_vs),

		.tmds_clk_n(tmds_clk_n),
		.tmds_clk_p(tmds_clk_p),
		.tmds_d_n({tmds_d_n2, tmds_d_n1, tmds_d_n0}),
		.tmds_d_p({tmds_d_p2, tmds_d_p1, tmds_d_p0}),

		.openldi_clk_n(openldi_clk_n),
		.openldi_clk_p(openldi_clk_p),
		.openldi_a_n({openldi_a_n2, openldi_a_n1, openldi_a_n0}),
		.openldi_a_p({openldi_a_p2, openldi_a_p1, openldi_a_p0}),

		.sw(4'b0000),
		.btn(4'b0000)
	);

	integer i;
	initial begin
		$dumpfile("testbench.vcd");
		$dumpvars(2, testbench);
		$dumpvars(0, testbench.system.svo_tcard);
		$dumpvars(0, testbench.system.svo_pong);
		$dumpvars(0, testbench.system.svo_enc);
		$dumpvars(0, testbench.system.svo_tmds_0);
		$dumpvars(0, testbench.system.svo_tmds_1);
		$dumpvars(0, testbench.system.svo_tmds_2);
		$dumpvars(0, testbench.system.svo_openldi);
		for (i=0; i<100; i=i+1) begin
			$display("%dk clk cycles %t", i, $time);
			repeat (1000) @(posedge clk);
		end
		$finish;
	end
endmodule
