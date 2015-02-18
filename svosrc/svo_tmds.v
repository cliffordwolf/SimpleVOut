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

module svo_tmds (
	input clk, resetn, de,
	input [1:0] ctrl,
	input [7:0] din,
	output reg [9:0] dout
);
	function [3:0] count_set_bits;
		input [9:0] bits;
		integer i;
		begin
			count_set_bits = 0;
			for (i = 0; i < 9; i = i+1)
				count_set_bits = count_set_bits + bits[i];
		end
	endfunction

	function [3:0] count_transitions;
		input [7:0] bits;
		integer i;
		begin
			count_transitions = 0;
			for (i = 0; i < 7; i = i+1)
				count_transitions = count_transitions + (bits[i] != bits[i+1]);
		end
	endfunction

	wire [7:0] din_xor;
	assign din_xor[0] = din[0];
	assign din_xor[1] = din[1] ^ din_xor[0];
	assign din_xor[2] = din[2] ^ din_xor[1];
	assign din_xor[3] = din[3] ^ din_xor[2];
	assign din_xor[4] = din[4] ^ din_xor[3];
	assign din_xor[5] = din[5] ^ din_xor[4];
	assign din_xor[6] = din[6] ^ din_xor[5];
	assign din_xor[7] = din[7] ^ din_xor[6];

	wire [7:0] din_xnor;
	assign din_xnor[0] = din[0];
	assign din_xnor[1] = din[1] ^~ din_xnor[0];
	assign din_xnor[2] = din[2] ^~ din_xnor[1];
	assign din_xnor[3] = din[3] ^~ din_xnor[2];
	assign din_xnor[4] = din[4] ^~ din_xnor[3];
	assign din_xnor[5] = din[5] ^~ din_xnor[4];
	assign din_xnor[6] = din[6] ^~ din_xnor[5];
	assign din_xnor[7] = din[7] ^~ din_xnor[6];

	reg signed [7:0] cnt;
	reg [9:0] dout_buf, dout_buf2, m;

	always @(posedge clk) begin
		if (!resetn) begin
			cnt <= 0;
		end else if (!de) begin
			cnt <= 0;
			case (ctrl)
				2'b00: dout_buf <= 10'b1101010100;
				2'b01: dout_buf <= 10'b0010101011;
				2'b10: dout_buf <= 10'b0101010100;
				2'b11: dout_buf <= 10'b1010101011;
			endcase
		end else begin
			m = count_transitions(din_xor) < count_transitions(din_xnor) ? {2'b01, din_xor} : {2'b00, din_xnor};
			if ((count_set_bits(m[7:0]) > 4) == (cnt > 0)) m = {1'b1, m[8], ~m[7:0]};
			cnt <= cnt + count_set_bits(m) - 5;
			dout_buf <= m;
		end

		// add two additional ff stages, give synthesis retime some slack to work with
		dout_buf2 <= dout_buf;
		dout <= dout_buf2;
	end
endmodule
