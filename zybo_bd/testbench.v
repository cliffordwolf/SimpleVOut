
`timescale 1 ns / 1 ps

module testbench;

  reg clk;
  wire led_0;
  wire tmds_clk_n;
  wire tmds_clk_p;
  wire [2:0]tmds_d_n;
  wire [2:0]tmds_d_p;

  system system_i (
    .clk(clk),
    .led_0(led_0),
    .tmds_clk_n(tmds_clk_n),
    .tmds_clk_p(tmds_clk_p),
    .tmds_d_n(tmds_d_n),
    .tmds_d_p(tmds_d_p)
  );

  initial begin
    clk = 1;
    forever #4 clk = ~clk;
  end

  initial begin:AXI_INIT
    reg [1:0] axi_response;
    integer i;

    system_i.ps7.inst.fpga_soft_reset(~0);

    repeat (500) @(posedge clk);

    system_i.ps7.inst.fpga_soft_reset(0);

    repeat (500) @(posedge clk);

    for (i = 0; i < (1280 * 720 * 3) / 4; i = i+1) begin 
      system_i.ps7.inst.write_mem('h00112233, 'h00080000 + 4*i, 4);
    end

    system_i.ps7.inst.write_data('h43000000, 4, 'h00080000, axi_response);
  end
  
  initial begin:WRITEOUT
    integer fd;
    fd = $fopen("testbench.out", "w");
    repeat (200) @(posedge clk);
    forever begin
      @(posedge system_i.framebuffer.inst.svo_enc.clk)
      if (system_i.framebuffer.inst.svo_enc.out_axis_tvalid && system_i.framebuffer.inst.svo_enc.out_axis_tready)
        $fdisplay(fd, "## %b %d %d %d",
            system_i.framebuffer.inst.svo_enc.out_axis_tuser,
            system_i.framebuffer.inst.svo_enc.out_axis_tdata[ 0 +: 8],
            system_i.framebuffer.inst.svo_enc.out_axis_tdata[ 8 +: 8],
            system_i.framebuffer.inst.svo_enc.out_axis_tdata[16 +: 8]);
    end
  end

  initial begin:FRAMECOUNT
    integer counter;
    repeat (200) @(posedge clk);
    counter = 0;
    forever begin
      @(posedge system_i.framebuffer.inst.svo_enc.clk)
      if (system_i.framebuffer.inst.svo_enc.out_axis_tvalid &&
          system_i.framebuffer.inst.svo_enc.out_axis_tready &&
          system_i.framebuffer.inst.svo_enc.out_axis_tuser[0])
      begin
        counter = counter + 1;
        $display("%t START OF FRAME #%0d", $time, counter);
        if (counter > 2) begin
          repeat (200) @(posedge clk);
          $finish;
        end
      end
    end
  end

endmodule