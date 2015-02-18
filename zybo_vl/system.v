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

`define MODE_640_480_60
// `define MODE_800_480_75
// `define MODE_1024_768_60
// `define MODE_1920_1080_60
`define SINGLE_ENDED_LDI

module system (
	// 125 MHz clock
	input clk,

	output [4:0] vga_r,
	output [5:0] vga_g,
	output [4:0] vga_b,
	output vga_hs,
	output vga_vs,

	output tmds_clk_n,
	output tmds_clk_p,
	output [2:0] tmds_d_n,
	output [2:0] tmds_d_p,

	output openldi_clk_n,
	output openldi_clk_p,
	output [2:0] openldi_a_n,
	output [2:0] openldi_a_p,

	input [3:0] sw,
	input [3:0] btn,
	output [3:0] led
);


	// --------------------------------------------------------------------
	// SimpleVOut Configuration
	// --------------------------------------------------------------------

`ifdef MODE_640_480_60
	parameter SVO_MODE             =   "640x480R";
	parameter SVO_FRAMERATE        =   60;
	parameter SVO_BITS_PER_PIXEL   =   18;
	parameter SVO_BITS_PER_RED     =    6;
	parameter SVO_BITS_PER_GREEN   =    6;
	parameter SVO_BITS_PER_BLUE    =    6;
	parameter SVO_BITS_PER_ALPHA   =    0;
`endif

`ifdef MODE_800_480_75
	parameter SVO_MODE             =   "800x480R";
	parameter SVO_FRAMERATE        =   75;
	parameter SVO_BITS_PER_PIXEL   =   18;
	parameter SVO_BITS_PER_RED     =    6;
	parameter SVO_BITS_PER_GREEN   =    6;
	parameter SVO_BITS_PER_BLUE    =    6;
	parameter SVO_BITS_PER_ALPHA   =    0;
`endif

`ifdef MODE_1024_768_60
	parameter SVO_MODE             =   "1024x768R";
	parameter SVO_FRAMERATE        =   60;
	parameter SVO_BITS_PER_PIXEL   =   18;
	parameter SVO_BITS_PER_RED     =    6;
	parameter SVO_BITS_PER_GREEN   =    6;
	parameter SVO_BITS_PER_BLUE    =    6;
	parameter SVO_BITS_PER_ALPHA   =    0;
`endif

`ifdef MODE_1920_1080_60
	parameter SVO_MODE             =   "1920x1080R";
	parameter SVO_FRAMERATE        =   60;
	parameter SVO_BITS_PER_PIXEL   =   18;
	parameter SVO_BITS_PER_RED     =    6;
	parameter SVO_BITS_PER_GREEN   =    6;
	parameter SVO_BITS_PER_BLUE    =    6;
	parameter SVO_BITS_PER_ALPHA   =    0;
`endif


	// --------------------------------------------------------------------
	// PLLs for various clocks (also used as reset generator)
	// --------------------------------------------------------------------

	// reset stays active until PLLs are locked
	reg resetn;

	// For   640x480 @ 60 Hz this should be  23.5 MHz
	// For   800x480 @ 75 Hz this should be  35.7 MHz
	// For  1024x768 @ 60 Hz this should be  56.0 MHz
	// For 1920x1080 @ 60 Hz this should be 138.5 MHz
	wire pixel_clk;

	// TMDS bit clock is 5x pixel_clk (DDR)
	wire tmds_clk;

	// OpenLDI bit clock is 7x pixel_clk (SDR)
	wire openldi_clk;

	wire pixel_clk_unbuf;
	wire tmds_clk_unbuf;
	wire openldi_clk_unbuf;
	wire resetn_unbuf;

	// Note: the VCO freqency range is 800 MHz - 1866 MHz
	// See also: Xilinx UG472 (7 Series FPGAs Clocking Resources User Guide)

`ifdef MODE_640_480_60
	wire pll_locked_1;
	wire pll_feedback_1;

	PLLE2_BASE #(
		.CLKFBOUT_MULT(13),
		.CLKOUT0_DIVIDE(70),
		.CLKOUT0_DUTY_CYCLE(0.5),
		.CLKOUT0_PHASE(0.0),
		.CLKOUT1_DIVIDE(14),
		.CLKOUT1_DUTY_CYCLE(0.5),
		.CLKOUT1_PHASE(0.0),
		.CLKOUT2_DIVIDE(10),
		.CLKOUT2_DUTY_CYCLE(0.5),
		.CLKOUT2_PHASE(0.0)
	) PLL_1 (
		.CLKIN1(clk),
		.CLKOUT0(pixel_clk_unbuf),
		.CLKOUT1(tmds_clk_unbuf),
		.CLKOUT2(openldi_clk_unbuf),
		.CLKFBOUT(pll_feedback_1),
		.CLKFBIN(pll_feedback_1),
		.PWRDWN(1'b0),
		.LOCKED(pll_locked_1),
		.RST(1'b0)
	);

	assign resetn_unbuf = pll_locked_1;
`endif

`ifdef MODE_800_480_75
	wire pll_locked_1;
	wire pll_feedback_1;

	PLLE2_BASE #(
		.CLKFBOUT_MULT(10),
		.CLKOUT0_DIVIDE(35),
		.CLKOUT0_DUTY_CYCLE(0.5),
		.CLKOUT0_PHASE(0.0),
		.CLKOUT1_DIVIDE(7),
		.CLKOUT1_DUTY_CYCLE(0.5),
		.CLKOUT1_PHASE(0.0),
		.CLKOUT2_DIVIDE(5),
		.CLKOUT2_DUTY_CYCLE(0.5),
		.CLKOUT2_PHASE(0.0)
	) PLL_1 (
		.CLKIN1(clk),
		.CLKOUT0(pixel_clk_unbuf),
		.CLKOUT1(tmds_clk_unbuf),
		.CLKOUT2(openldi_clk_unbuf),
		.CLKFBOUT(pll_feedback_1),
		.CLKFBIN(pll_feedback_1),
		.PWRDWN(1'b0),
		.LOCKED(pll_locked_1),
		.RST(1'b0)
	);

	assign resetn_unbuf = pll_locked_1;
`endif

`ifdef MODE_1024_600_60
	wire clk_tmp;
	wire pll_locked_1;
	wire pll_feedback_1;
	wire pll_locked_2;
	wire pll_feedback_2;

	MMCME2_BASE #(
		.CLKFBOUT_MULT_F(9.8),
		.CLKOUT0_DIVIDE_F(8.0),
		.CLKOUT0_DUTY_CYCLE(0.5),
		.CLKOUT0_PHASE(0.0)
	) PLL_3 (
		.CLKIN1(clk),
		.CLKOUT0(clk_tmp),
		.CLKFBOUT(pll_feedback_1),
		.CLKFBIN(pll_feedback_1),
		.PWRDWN(1'b0),
		.LOCKED(pll_locked_1),
		.RST(1'b0)
	);

	PLLE2_BASE #(
		.CLKFBOUT_MULT(10),
		.CLKOUT0_DIVIDE(35),
		.CLKOUT0_DUTY_CYCLE(0.5),
		.CLKOUT0_PHASE(0.0),
		.CLKOUT1_DIVIDE(7),
		.CLKOUT1_DUTY_CYCLE(0.5),
		.CLKOUT1_PHASE(0.0),
		.CLKOUT2_DIVIDE(5),
		.CLKOUT2_DUTY_CYCLE(0.5),
		.CLKOUT2_PHASE(0.0)
	) PLL_1 (
		.CLKIN1(clk_tmp),
		.CLKOUT0(pixel_clk_unbuf),
		.CLKOUT1(tmds_clk_unbuf),
		.CLKOUT2(openldi_clk_unbuf),
		.CLKFBOUT(pll_feedback_2),
		.CLKFBIN(pll_feedback_2),
		.PWRDWN(1'b0),
		.LOCKED(pll_locked_2),
		.RST(!pll_locked_1)
	);

	assign resetn_unbuf = pll_locked_1 && pll_locked_2;
`endif

`ifdef MODE_1024_768_60
	wire pll_locked_1;
	wire pll_feedback_1;

	wire pll_locked_2;
	wire pll_feedback_2;

	wire pll_locked_3;
	wire pll_feedback_3;

	PLLE2_BASE #(
		.CLKFBOUT_MULT(9),
		.CLKOUT0_DIVIDE(20),
		.CLKOUT0_DUTY_CYCLE(0.5),
		.CLKOUT0_PHASE(0.0)
	) PLL_1 (
		.CLKIN1(clk),
		.CLKOUT0(pixel_clk_unbuf),
		.CLKFBOUT(pll_feedback_1),
		.CLKFBIN(pll_feedback_1),
		.PWRDWN(1'b0),
		.LOCKED(pll_locked_1),
		.RST(1'b0)
	);

	MMCME2_BASE #(
		.CLKFBOUT_MULT_F(20),
		.CLKOUT1_DIVIDE(4),
		.CLKOUT1_DUTY_CYCLE(0.5),
		.CLKOUT1_PHASE(0.0)
	) PLL_2 (
		.CLKIN1(pixel_clk_unbuf),
		.CLKOUT1(tmds_clk_unbuf),
		.CLKFBOUT(pll_feedback_2),
		.CLKFBIN(pll_feedback_2),
		.PWRDWN(1'b0),
		.LOCKED(pll_locked_2),
		.RST(!pll_locked_1)
	);

	MMCME2_BASE #(
		.CLKFBOUT_MULT_F(21),
		.CLKOUT1_DIVIDE(3),
		.CLKOUT1_DUTY_CYCLE(0.5),
		.CLKOUT1_PHASE(0.0)
	) PLL_3 (
		.CLKIN1(pixel_clk_unbuf),
		.CLKOUT1(openldi_clk_unbuf),
		.CLKFBOUT(pll_feedback_3),
		.CLKFBIN(pll_feedback_3),
		.PWRDWN(1'b0),
		.LOCKED(pll_locked_3),
		.RST(!pll_locked_1)
	);

	assign resetn_unbuf = pll_locked_1 && pll_locked_2 && pll_locked_3;
`endif

`ifdef MODE_1920_1080_60
	wire pll_locked_1;
	wire pll_feedback_1;

	wire pll_locked_2;
	wire pll_feedback_2;

	MMCME2_BASE #(
		.CLKFBOUT_MULT_F(11.08),
		.CLKOUT1_DIVIDE(10),
		.CLKOUT1_DUTY_CYCLE(0.5),
		.CLKOUT1_PHASE(0.0),
		.CLKOUT2_DIVIDE(2),
		.CLKOUT2_DUTY_CYCLE(0.5),
		.CLKOUT2_PHASE(0.0)
	) PLL_1 (
		.CLKIN1(clk),
		.CLKOUT1(pixel_clk_unbuf),
		.CLKOUT2(tmds_clk_unbuf),
		.CLKFBOUT(pll_feedback_1),
		.CLKFBIN(pll_feedback_1),
		.PWRDWN(1'b0),
		.LOCKED(pll_locked_1),
		.RST(1'b0)
	);

	PLLE2_BASE #(
		.CLKFBOUT_MULT(7),
		.CLKOUT0_DIVIDE(1),
		.CLKOUT0_DUTY_CYCLE(0.5),
		.CLKOUT0_PHASE(0.0)
	) PLL_2 (
		.CLKIN1(pixel_clk_unbuf),
		.CLKOUT0(openldi_clk_unbuf),
		.CLKFBOUT(pll_feedback_2),
		.CLKFBIN(pll_feedback_2),
		.PWRDWN(1'b0),
		.LOCKED(pll_locked_2),
		.RST(!pll_locked_1)
	);

	assign resetn_unbuf = pll_locked_1 && pll_locked_2;
`endif

	BUFG pixel_clk_buf (
		.O(pixel_clk),
		.I(pixel_clk_unbuf)
	);
	
	BUFG tmds_clk_buf (
		.O(tmds_clk),
		.I(tmds_clk_unbuf)
	);

	BUFG openldi_clk_buf (
		.O(openldi_clk),
		.I(openldi_clk_unbuf)
	);

	reg [5:0] resetcnt;
	reg [3:0] resetn_buf;

	always @(posedge pixel_clk) begin
		resetcnt <= resetn_unbuf ? (resetcnt ? resetcnt-1 : 0) : ~0;
		resetn_buf <= {resetn_buf, ~|resetcnt};
		resetn = resetn_buf[3];
	end


	// --------------------------------------------------------------------
	// Video pipeline
	// --------------------------------------------------------------------

	wire video_tcard_tvalid, video_tcard_tready;
	wire [17:0] video_tcard_tdata;
	wire [0:0] video_tcard_tuser;

	wire video_pong_tvalid, video_pong_tready;
	wire [17:0] video_pong_tdata;
	wire [0:0] video_pong_tuser;

	wire video_enc_tvalid, video_enc_tready;
	wire [17:0] video_enc_tdata;
	wire [3:0] video_enc_tuser;

	svo_tcard #( `SVO_PASS_PARAMS ) svo_tcard (
		.clk(pixel_clk),
		.resetn(resetn),

		.out_axis_tvalid(video_tcard_tvalid),
		.out_axis_tready(video_tcard_tready),
		.out_axis_tdata(video_tcard_tdata),
		.out_axis_tuser(video_tcard_tuser)
	);

	wire [3:0] pong_auto_btn;

	svo_pong #( `SVO_PASS_PARAMS ) svo_pong (
		.clk(pixel_clk),
		.resetn(resetn),
		.resetn_game(sw[1]),
		.enable(sw[0]),

		.btn({sw[3] ? pong_auto_btn[3:2] : btn[3:2], sw[2] ? pong_auto_btn[1:0] : btn[1:0]}),
		.auto_btn(pong_auto_btn),

		.in_axis_tvalid(video_tcard_tvalid),
		.in_axis_tready(video_tcard_tready),
		.in_axis_tdata(video_tcard_tdata),
		.in_axis_tuser(video_tcard_tuser),

		.out_axis_tvalid(video_pong_tvalid),
		.out_axis_tready(video_pong_tready),
		.out_axis_tdata(video_pong_tdata),
		.out_axis_tuser(video_pong_tuser)
	);

	svo_enc #( `SVO_PASS_PARAMS ) svo_enc (
		.clk(pixel_clk),
		.resetn(resetn),

		.in_axis_tvalid(video_pong_tvalid),
		.in_axis_tready(video_pong_tready),
		.in_axis_tdata(video_pong_tdata),
		.in_axis_tuser(video_pong_tuser),

		.out_axis_tvalid(video_enc_tvalid),
		.out_axis_tready(video_enc_tready),
		.out_axis_tdata(video_enc_tdata),
		.out_axis_tuser(video_enc_tuser)
	);

	assign video_enc_tready = 1;


	// --------------------------------------------------------------------
	// VGA output signals (via R-2R network)
	// --------------------------------------------------------------------

	assign vga_r = video_enc_tdata[5:1];
	assign vga_g = video_enc_tdata[11:6];
	assign vga_b = video_enc_tdata[17:13];
	assign vga_hs = video_enc_tuser[1];
	assign vga_vs = video_enc_tuser[2];


	// --------------------------------------------------------------------
	// TMDS (DVI/HDMI) output signals
	// --------------------------------------------------------------------

	wire [2:0] tmds_d;
	wire [2:0] tmds_serdes_shift1;
	wire [2:0] tmds_serdes_shift2;
	wire [2:0] tmds_d0, tmds_d1, tmds_d2, tmds_d3, tmds_d4;
	wire [2:0] tmds_d5, tmds_d6, tmds_d7, tmds_d8, tmds_d9;

	OBUFDS tmds_bufds [3:0] (
		.I({pixel_clk, tmds_d}),
		.O({tmds_clk_p, tmds_d_p}),
		.OB({tmds_clk_n, tmds_d_n})
	);

	OSERDESE2 #(
		.DATA_RATE_OQ("DDR"),
		.DATA_RATE_TQ("SDR"),
		.DATA_WIDTH(10),
		.INIT_OQ(1'b0),
		.INIT_TQ(1'b0),
		.SERDES_MODE("MASTER"),
		.SRVAL_OQ(1'b0),
		.SRVAL_TQ(1'b0),
		.TBYTE_CTL("FALSE"),
		.TBYTE_SRC("FALSE"),
		.TRISTATE_WIDTH(1)
	) tmds_serdes_lo [2:0] (
		.OFB(),
		.OQ(tmds_d),
		.SHIFTOUT1(),
		.SHIFTOUT2(),
		.TBYTEOUT(),
		.TFB(),
		.TQ(),
		.CLK(tmds_clk),
		.CLKDIV(pixel_clk),
		.D1(tmds_d0),
		.D2(tmds_d1),
		.D3(tmds_d2),
		.D4(tmds_d3),
		.D5(tmds_d4),
		.D6(tmds_d5),
		.D7(tmds_d6),
		.D8(tmds_d7),
		.OCE(1'b1),
		.RST(~resetn),
		.SHIFTIN1(tmds_serdes_shift1),
		.SHIFTIN2(tmds_serdes_shift2),
		.T1(1'b0),
		.T2(1'b0),
		.T3(1'b0),
		.T4(1'b0),
		.TBYTEIN(1'b0),
		.TCE(1'b0)
	);

	OSERDESE2 #(
		.DATA_RATE_OQ("DDR"),
		.DATA_RATE_TQ("SDR"),
		.DATA_WIDTH(10),
		.INIT_OQ(1'b0),
		.INIT_TQ(1'b0),
		.SERDES_MODE("SLAVE"),
		.SRVAL_OQ(1'b0),
		.SRVAL_TQ(1'b0),
		.TBYTE_CTL("FALSE"),
		.TBYTE_SRC("FALSE"),
		.TRISTATE_WIDTH(1)
	) tmds_serdes_hi [2:0] (
		.OFB(),
		.OQ(),
		.SHIFTOUT1(tmds_serdes_shift1),
		.SHIFTOUT2(tmds_serdes_shift2),
		.TBYTEOUT(),
		.TFB(),
		.TQ(),
		.CLK(tmds_clk),
		.CLKDIV(pixel_clk),
		.D1(1'b0),
		.D2(1'b0),
		.D3(tmds_d8),
		.D4(tmds_d9),
		.D5(1'b0),
		.D6(1'b0),
		.D7(1'b0),
		.D8(1'b0),
		.OCE(1'b1),
		.RST(~resetn),
		.SHIFTIN1(1'b0),
		.SHIFTIN2(1'b0),
		.T1(1'b0),
		.T2(1'b0),
		.T3(1'b0),
		.T4(1'b0),
		.TBYTEIN(1'b0),
		.TCE(1'b0)
	);

	svo_tmds svo_tmds_0 (
		.clk(pixel_clk),
		.resetn(resetn),
		.de(!video_enc_tuser[3]),
		.ctrl(video_enc_tuser[2:1]),
		.din({video_enc_tdata[17:12], 2'b0}),
		.dout({tmds_d9[0], tmds_d8[0], tmds_d7[0], tmds_d6[0], tmds_d5[0],
		       tmds_d4[0], tmds_d3[0], tmds_d2[0], tmds_d1[0], tmds_d0[0]})
	);

	svo_tmds svo_tmds_1 (
		.clk(pixel_clk),
		.resetn(resetn),
		.de(!video_enc_tuser[3]),
		.ctrl(2'b0),
		.din({video_enc_tdata[11:6], 2'b0}),
		.dout({tmds_d9[1], tmds_d8[1], tmds_d7[1], tmds_d6[1], tmds_d5[1],
		       tmds_d4[1], tmds_d3[1], tmds_d2[1], tmds_d1[1], tmds_d0[1]})
	);

	svo_tmds svo_tmds_2 (
		.clk(pixel_clk),
		.resetn(resetn),
		.de(!video_enc_tuser[3]),
		.ctrl(2'b0),
		.din({video_enc_tdata[5:0], 2'b0}),
		.dout({tmds_d9[2], tmds_d8[2], tmds_d7[2], tmds_d6[2], tmds_d5[2],
		       tmds_d4[2], tmds_d3[2], tmds_d2[2], tmds_d1[2], tmds_d0[2]})
	);


	// --------------------------------------------------------------------
	// OpenLDI (LVDS Display Interface) output signals
	// --------------------------------------------------------------------

	wire [2:0] openldi_a0, openldi_a1, openldi_a2, openldi_a3, openldi_a4, openldi_a5, openldi_a6;

`ifdef SINGLE_ENDED_LDI
	OSERDESE2 #(
		.DATA_RATE_OQ("SDR"),
		.DATA_RATE_TQ("SDR"),
		.DATA_WIDTH(7),
		.INIT_OQ(1'b0),
		.INIT_TQ(1'b0),
		.SERDES_MODE("MASTER"),
		.SRVAL_OQ(1'b0),
		.SRVAL_TQ(1'b0),
		.TBYTE_CTL("FALSE"),
		.TBYTE_SRC("FALSE"),
		.TRISTATE_WIDTH(1)
	) openldi_serdes_array[7:0] (
		.OFB(),
		.OQ({openldi_clk_p, openldi_clk_n, openldi_a_p, openldi_a_n}),
		.SHIFTOUT1(),
		.SHIFTOUT2(),
		.TBYTEOUT(),
		.TFB(),
		.TQ(),
		.CLK(openldi_clk),
		.CLKDIV(pixel_clk),
		.D1({2'b10, openldi_a0, ~openldi_a0}),
		.D2({2'b10, openldi_a1, ~openldi_a1}),
		.D3({2'b01, openldi_a2, ~openldi_a2}),
		.D4({2'b01, openldi_a3, ~openldi_a3}),
		.D5({2'b01, openldi_a4, ~openldi_a4}),
		.D6({2'b10, openldi_a5, ~openldi_a5}),
		.D7({2'b10, openldi_a6, ~openldi_a6}),
		.D8(),
		.OCE(1'b1),
		.RST(~resetn),
		.SHIFTIN1(1'b0),
		.SHIFTIN2(1'b0),
		.T1(1'b0),
		.T2(1'b0),
		.T3(1'b0),
		.T4(1'b0),
		.TBYTEIN(1'b0),
		.TCE(1'b0)
	);
`else
	wire openldi_c;
	wire [2:0] openldi_a;

	OBUFDS openldi_bufds [3:0] (
		.I({openldi_c, openldi_a}),
		.O({openldi_clk_p, openldi_a_p}),
		.OB({openldi_clk_n, openldi_a_n})
	);

	OSERDESE2 #(
		.DATA_RATE_OQ("SDR"),
		.DATA_RATE_TQ("SDR"),
		.DATA_WIDTH(7),
		.INIT_OQ(1'b0),
		.INIT_TQ(1'b0),
		.SERDES_MODE("MASTER"),
		.SRVAL_OQ(1'b0),
		.SRVAL_TQ(1'b0),
		.TBYTE_CTL("FALSE"),
		.TBYTE_SRC("FALSE"),
		.TRISTATE_WIDTH(1)
	) openldi_serdes [3:0] (
		.OFB(),
		.OQ({openldi_c, openldi_a}),
		.SHIFTOUT1(),
		.SHIFTOUT2(),
		.TBYTEOUT(),
		.TFB(),
		.TQ(),
		.CLK(openldi_clk),
		.CLKDIV(pixel_clk),
		.D1({1'b1, openldi_a0}),
		.D2({1'b1, openldi_a1}),
		.D3({1'b0, openldi_a2}),
		.D4({1'b0, openldi_a3}),
		.D5({1'b0, openldi_a4}),
		.D6({1'b1, openldi_a5}),
		.D7({1'b1, openldi_a6}),
		.D8(),
		.OCE(1'b1),
		.RST(~resetn),
		.SHIFTIN1(1'b0),
		.SHIFTIN2(1'b0),
		.T1(1'b0),
		.T2(1'b0),
		.T3(1'b0),
		.T4(1'b0),
		.TBYTEIN(1'b0),
		.TCE(1'b0)
	);
`endif

	svo_openldi svo_openldi (
		.clk(pixel_clk),
		.resetn(resetn),
		.hs(video_enc_tuser[1]),
		.vs(video_enc_tuser[2]),
		.de(!video_enc_tuser[3]),
		.r(video_enc_tdata[5:0]),
		.g(video_enc_tdata[11:6]),
		.b(video_enc_tdata[17:12]),
		.a0({openldi_a0[0], openldi_a1[0], openldi_a2[0], openldi_a3[0], openldi_a4[0], openldi_a5[0], openldi_a6[0]}),
		.a1({openldi_a0[1], openldi_a1[1], openldi_a2[1], openldi_a3[1], openldi_a4[1], openldi_a5[1], openldi_a6[1]}),
		.a2({openldi_a0[2], openldi_a1[2], openldi_a2[2], openldi_a3[2], openldi_a4[2], openldi_a5[2], openldi_a6[2]})
	);


	// --------------------------------------------------------------------
	// Status bar for continous pixel stream
	// --------------------------------------------------------------------

	reg [5:0] ok_counter;
	reg [3:0] ok_status;

	always @(posedge pixel_clk) begin
		if (video_pong_tvalid) begin
			if (video_pong_tuser && video_pong_tready) begin
				if (ok_counter == 60) begin
					ok_counter <= 0;
					ok_status <= ok_status << 1 | 1;
				end else
					ok_counter <= ok_counter + 1;
			end
		end else begin
			ok_counter <= 0;
			ok_status <= 0;
		end
	end

	assign led = { ok_status[0], ok_status[1], ok_status[2], ok_status[3] };
endmodule
