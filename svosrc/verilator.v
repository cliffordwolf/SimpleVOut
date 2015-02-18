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
`include "svo_defines.vh"

module top(clk, resetn, out_axis_tvalid, out_axis_tready, out_axis_tdata, out_axis_tuser);
	`SVO_DEFAULT_PARAMS;

	input clk, resetn;

	wire s1_axis_tvalid;
	wire s1_axis_tready;
	wire [17:0] s1_axis_tdata;
	wire [0:0] s1_axis_tuser;

	wire s2_axis_tvalid;
	wire s2_axis_tready;
	wire [17:0] s2_axis_tdata;
	wire [0:0] s2_axis_tuser;

	wire [3:0] btn;

	output out_axis_tvalid;
	input out_axis_tready;
	output [17:0] out_axis_tdata;
	output [3:0] out_axis_tuser;

	svo_tcard #( `SVO_PASS_PARAMS ) svo_tcard (
		.clk(clk),
		.resetn(resetn),

		.out_axis_tvalid(s1_axis_tvalid),
		.out_axis_tready(s1_axis_tready),
		.out_axis_tdata(s1_axis_tdata),
		.out_axis_tuser(s1_axis_tuser)
	);

	svo_pong #( `SVO_PASS_PARAMS ) svo_pong (
		.clk(clk),
		.resetn(resetn),
		.resetn_game(1'b1),
		.enable(1'b1),

		.btn(btn),
		.auto_btn(btn),

		.in_axis_tvalid(s1_axis_tvalid),
		.in_axis_tready(s1_axis_tready),
		.in_axis_tdata(s1_axis_tdata),
		.in_axis_tuser(s1_axis_tuser),

		.out_axis_tvalid(s2_axis_tvalid),
		.out_axis_tready(s2_axis_tready),
		.out_axis_tdata(s2_axis_tdata),
		.out_axis_tuser(s2_axis_tuser)
	);

	svo_enc #( `SVO_PASS_PARAMS ) svo_enc (
		.clk(clk),
		.resetn(resetn),

		.in_axis_tvalid(s2_axis_tvalid),
		.in_axis_tready(s2_axis_tready),
		.in_axis_tdata(s2_axis_tdata),
		.in_axis_tuser(s2_axis_tuser),

		.out_axis_tvalid(out_axis_tvalid),
		.out_axis_tready(out_axis_tready),
		.out_axis_tdata(out_axis_tdata),
		.out_axis_tuser(out_axis_tuser)
	);
endmodule
