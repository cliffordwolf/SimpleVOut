`timescale 1ns / 1ps

module testbench;  
	reg clk;
	wire ok_led;
	wire tmds_clk_n;
	wire tmds_clk_p;
	wire [2:0]tmds_d_n;
	wire [2:0]tmds_d_p;

	system system_i (
		.clk(clk),
		.ok_led(ok_led),
		.tmds_clk_n(tmds_clk_n),
		.tmds_clk_p(tmds_clk_p),
		.tmds_d_n(tmds_d_n),
		.tmds_d_p(tmds_d_p)
	);

	initial begin
		clk = 0;
		forever #4 clk = ~clk;
	end

	integer fd;
	initial fd = $fopen("testbench.out", "w");
	always @(posedge system_i.framebuffer.inst.clk_pixel) begin
		if (system_i.framebuffer.inst.video_enc_tvalid && system_i.framebuffer.inst.video_enc_tready) begin
			$fdisplay(fd, "## %b %d %d %d",
				system_i.framebuffer.inst.video_enc_tuser,
				system_i.framebuffer.inst.video_enc_tdata[ 0 +: 8],
				system_i.framebuffer.inst.video_enc_tdata[ 8 +: 8],
				system_i.framebuffer.inst.video_enc_tdata[16 +: 8]);
		end
	end
endmodule
