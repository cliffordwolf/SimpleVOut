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

module simplehdmi (
	input clk,
	input resetn,
	output frame_irq,

	// video clocks
	input clk_pixel,
	input clk_5x_pixel,
	input locked,

	// config interface: axi4-lite slave
	input         cfg_axi_awvalid,
	output        cfg_axi_awready,
	input  [ 7:0] cfg_axi_awaddr,
	input         cfg_axi_wvalid,
	output        cfg_axi_wready,
	input  [31:0] cfg_axi_wdata,
	output        cfg_axi_bvalid,
	input         cfg_axi_bready,
	input         cfg_axi_arvalid,
	output        cfg_axi_arready,
	input  [ 7:0] cfg_axi_araddr,
	output        cfg_axi_rvalid,
	input         cfg_axi_rready,
	output [31:0] cfg_axi_rdata,

	// memory interface: axi4 read-only master
	output [31:0] mem_axi_araddr,
	output [ 7:0] mem_axi_arlen,
	output [ 2:0] mem_axi_arsize,
	output [ 2:0] mem_axi_arprot,
	output [ 1:0] mem_axi_arburst,
	output        mem_axi_arvalid,
	input         mem_axi_arready,
	input  [63:0] mem_axi_rdata,
	input         mem_axi_rvalid,
	output        mem_axi_rready,

	// output signals
	output       tmds_clk_n,
	output       tmds_clk_p,
	output [2:0] tmds_d_n,
	output [2:0] tmds_d_p,
	output       ok_led
);
	parameter SVO_MODE             =   "640x480";
	parameter SVO_FRAMERATE        =   60;
	parameter SVO_BITS_PER_PIXEL   =   24;
	parameter SVO_BITS_PER_RED     =    8;
	parameter SVO_BITS_PER_GREEN   =    8;
	parameter SVO_BITS_PER_BLUE    =    8;
	parameter SVO_BITS_PER_ALPHA   =    0;

	localparam [SVO_BITS_PER_PIXEL-1:0] white_pixval = ~0;

	wire vdma_tvalid;
	wire vdma_tready;
	wire [SVO_BITS_PER_PIXEL-1:0] vdma_tdata;
	wire [0:0] vdma_tuser;

	wire video_tvalid;
	wire video_tready;
	wire [SVO_BITS_PER_PIXEL-1:0] video_tdata;
	wire [0:0] video_tuser;

	wire term_in_tvalid;
	wire term_in_tready;
	wire [7:0] term_in_tdata;

	wire term_out_tvalid;
	wire term_out_tready;
	wire [1:0] term_out_tdata;
	wire [0:0] term_out_tuser;

	wire video_enc_tvalid, video_enc_tready;
	wire [SVO_BITS_PER_PIXEL-1:0] video_enc_tdata;
	wire [3:0] video_enc_tuser;

	wire [2:0] tmds_d;
	wire [2:0] tmds_serdes_shift1;
	wire [2:0] tmds_serdes_shift2;
	wire [2:0] tmds_d0, tmds_d1, tmds_d2, tmds_d3, tmds_d4;
	wire [2:0] tmds_d5, tmds_d6, tmds_d7, tmds_d8, tmds_d9;

	reg [3:0] locked_clk_q;
	reg [3:0] resetn_clk_pixel_q;

	always @(posedge clk)
		locked_clk_q <= {locked_clk_q, locked};

	always @(posedge clk_pixel)
		resetn_clk_pixel_q <= {resetn_clk_pixel_q, resetn};

	wire clk_resetn = resetn && locked_clk_q[3];
	wire clk_pixel_resetn = locked && resetn_clk_pixel_q[3];

	svo_vdma #( `SVO_PASS_PARAMS ) svo_vdma (
		.clk(clk),
		.oclk(clk_pixel),
		.resetn(clk_resetn),
		.frame_irq(frame_irq),

		.cfg_axi_awvalid(cfg_axi_awvalid),
		.cfg_axi_awready(cfg_axi_awready),
		.cfg_axi_awaddr(cfg_axi_awaddr),
		.cfg_axi_wvalid(cfg_axi_wvalid),
		.cfg_axi_wready(cfg_axi_wready),
		.cfg_axi_wdata(cfg_axi_wdata),
		.cfg_axi_bvalid(cfg_axi_bvalid),
		.cfg_axi_bready(cfg_axi_bready),
		.cfg_axi_arvalid(cfg_axi_arvalid),
		.cfg_axi_arready(cfg_axi_arready),
		.cfg_axi_araddr(cfg_axi_araddr),
		.cfg_axi_rvalid(cfg_axi_rvalid),
		.cfg_axi_rready(cfg_axi_rready),
		.cfg_axi_rdata(cfg_axi_rdata),

		.mem_axi_araddr(mem_axi_araddr),
		.mem_axi_arlen(mem_axi_arlen),
		.mem_axi_arsize(mem_axi_arsize),
		.mem_axi_arprot(mem_axi_arprot),
		.mem_axi_arburst(mem_axi_arburst),
		.mem_axi_arvalid(mem_axi_arvalid),
		.mem_axi_arready(mem_axi_arready),
		.mem_axi_rdata(mem_axi_rdata),
		.mem_axi_rvalid(mem_axi_rvalid),
		.mem_axi_rready(mem_axi_rready),

		.out_axis_tvalid(vdma_tvalid),
		.out_axis_tready(vdma_tready),
		.out_axis_tdata(vdma_tdata),
		.out_axis_tuser(vdma_tuser),

		.term_axis_tvalid(term_in_tvalid),
		.term_axis_tready(term_in_tready),
		.term_axis_tdata(term_in_tdata)
	);

	svo_term #( `SVO_PASS_PARAMS ) svo_term (
		.clk(clk),
		.oclk(clk_pixel),
		.resetn(clk_resetn),

		.in_axis_tvalid(term_in_tvalid),
		.in_axis_tready(term_in_tready),
		.in_axis_tdata(term_in_tdata),

		.out_axis_tvalid(term_out_tvalid),
		.out_axis_tready(term_out_tready),
		.out_axis_tdata(term_out_tdata),
		.out_axis_tuser(term_out_tuser)
	);

	svo_overlay #( `SVO_PASS_PARAMS ) svo_overlay (
		.clk(clk_pixel),
		.resetn(clk_pixel_resetn),
		.enable(1'b1),

		.in_axis_tvalid(vdma_tvalid),
		.in_axis_tready(vdma_tready),
		.in_axis_tdata(vdma_tdata),
		.in_axis_tuser(vdma_tuser),

		.over_axis_tvalid(term_out_tvalid),
		.over_axis_tready(term_out_tready),
		.over_axis_tdata(white_pixval),
		.over_axis_tuser({term_out_tdata == 2'b10, term_out_tuser}),

		.out_axis_tvalid(video_tvalid),
		.out_axis_tready(video_tready),
		.out_axis_tdata(video_tdata),
		.out_axis_tuser(video_tuser)
	);

	svo_enc #( `SVO_PASS_PARAMS ) svo_enc (
		.clk(clk_pixel),
		.resetn(clk_pixel_resetn),

		.in_axis_tvalid(video_tvalid),
		.in_axis_tready(video_tready),
		.in_axis_tdata(video_tdata),
		.in_axis_tuser(video_tuser),

		.out_axis_tvalid(video_enc_tvalid),
		.out_axis_tready(video_enc_tready),
		.out_axis_tdata(video_enc_tdata),
		.out_axis_tuser(video_enc_tuser)
	);

	reg ok_led_q;
	reg [7:0] ok_counter;

	always @(posedge clk_pixel) begin
		if (!clk_pixel_resetn || !video_enc_tvalid) begin
			ok_led_q <= 0;
			ok_counter <= 0;
		end else if (video_enc_tuser[0]) begin
			if (&ok_counter)
				ok_led_q <= 1;
			ok_counter <= ok_counter + 1;
		end
	end

	assign video_enc_tready = 1;
	assign ok_led = ok_led_q;

	OBUFDS tmds_bufds [3:0] (
		.I({clk_pixel, tmds_d}),
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
		.CLK(clk_5x_pixel),
		.CLKDIV(clk_pixel),
		.D1(tmds_d0),
		.D2(tmds_d1),
		.D3(tmds_d2),
		.D4(tmds_d3),
		.D5(tmds_d4),
		.D6(tmds_d5),
		.D7(tmds_d6),
		.D8(tmds_d7),
		.OCE(1'b1),
		.RST(~clk_pixel_resetn),
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
		.CLK(clk_5x_pixel),
		.CLKDIV(clk_pixel),
		.D1(1'b0),
		.D2(1'b0),
		.D3(tmds_d8),
		.D4(tmds_d9),
		.D5(1'b0),
		.D6(1'b0),
		.D7(1'b0),
		.D8(1'b0),
		.OCE(1'b1),
		.RST(~clk_pixel_resetn),
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
		.clk(clk_pixel),
		.resetn(clk_pixel_resetn),
		.de(!video_enc_tuser[3]),
		.ctrl(video_enc_tuser[2:1]),
		.din(video_enc_tdata[23:16]),
		.dout({tmds_d9[0], tmds_d8[0], tmds_d7[0], tmds_d6[0], tmds_d5[0],
		       tmds_d4[0], tmds_d3[0], tmds_d2[0], tmds_d1[0], tmds_d0[0]})
	);

	svo_tmds svo_tmds_1 (
		.clk(clk_pixel),
		.resetn(clk_pixel_resetn),
		.de(!video_enc_tuser[3]),
		.ctrl(2'b0),
		.din(video_enc_tdata[15:8]),
		.dout({tmds_d9[1], tmds_d8[1], tmds_d7[1], tmds_d6[1], tmds_d5[1],
		       tmds_d4[1], tmds_d3[1], tmds_d2[1], tmds_d1[1], tmds_d0[1]})
	);

	svo_tmds svo_tmds_2 (
		.clk(clk_pixel),
		.resetn(clk_pixel_resetn),
		.de(!video_enc_tuser[3]),
		.ctrl(2'b0),
		.din(video_enc_tdata[7:0]),
		.dout({tmds_d9[2], tmds_d8[2], tmds_d7[2], tmds_d6[2], tmds_d5[2],
		       tmds_d4[2], tmds_d3[2], tmds_d2[2], tmds_d1[2], tmds_d0[2]})
	);
endmodule
