module axiplayer(
	input clk, resetn,

	// AXI4-lite master memory interface

	output reg        axi_awvalid,
	input             axi_awready,
	output reg [31:0] axi_awaddr,
	output reg [ 2:0] axi_awprot,

	output reg        axi_wvalid,
	input             axi_wready,
	output reg [31:0] axi_wdata,
	output reg [ 3:0] axi_wstrb,

	input             axi_bvalid,
	output reg        axi_bready,

	output reg        axi_arvalid,
	input             axi_arready,
	output reg [31:0] axi_araddr,
	output reg [ 2:0] axi_arprot,

	input             axi_rvalid,
	output reg        axi_rready,
	input      [31:0] axi_rdata
);
	parameter filename = "axiplayer.txt";
	integer fd, linenr;

	reg [64*1024-1:0] buffer, token;
	integer token_len;

	task next_token;
		integer i, j;
		begin
			// find end (begin) of buffer
			for (i = 0; buffer[8*i +: 8]; i = i+1) begin end

			// remove leading whitespace
			for (i = i; i > 0 && (buffer[8*(i-1) +: 8] == " " || buffer[8*(i-1) +: 8] == "\t"); i = i-1)
				buffer[8*(i-1) +: 8] = 0;

			// scan next token
			token = "";
			token_len = $sscanf(buffer, "%s", token);

			// remove token (by length) from buffer
			for (j = 0; token[8*j +: 8] && i > 0; j = j+1) begin
				i = i-1;
				buffer[8*i +: 8] = 0;
			end

			// $display("TOKEN=`%0s' BUFFER=`%0s'", token, buffer);
		end
	endtask

	task next_num_token;
		output [31:0] num;
		integer code;
		begin
			next_token;
			code = $sscanf(token, "0x%x", num);
			if (!code) code = $sscanf(token, "%d", num);
			if (!code) begin
				$display("%m: Unexpected non-numerical token `%0s' in line %0d.", token, linenr);
				$finish;
			end
		end
	endtask

	initial begin
		axi_awvalid <= 0;
		axi_awaddr <= 0;
		axi_awprot <= 0;
		axi_wvalid <= 0;
		axi_wdata <= 0;
		axi_wstrb <= 0;
		axi_bready <= 0;

		axi_arvalid <= 0;
		axi_araddr <= 0;
		axi_arprot <= 0;
		axi_rready <= 0;

		linenr = 0;

		fd = $fopen(filename, "r");
		if (!fd) begin
			$display("%m: Failed to open `%0s'.", filename);
			$finish;
		end

		@(posedge clk);
		while (resetn !== 1'b1) @(posedge clk);

		while (!$feof(fd) && $fgets(buffer, fd))
		begin
			while (buffer[7:0] == "\r" || buffer[7:0] == "\n")
				buffer = buffer >> 8;
			// $display("LINE[%0d]=`%0s'", linenr, buffer);
			linenr = linenr + 1;

			next_token;
			if (token == "" || token == "#") begin
				// ignore empty lines and comments
			end else
			if (token == "w32") begin:w32
				reg [31:0] wdata, waddr;

				next_num_token(waddr);
				next_num_token(wdata);

				$display("%m: w32 0x%x 0x%x", waddr, wdata);

				axi_awvalid <= 1;
				axi_awaddr <= waddr;
				
				axi_wvalid <= 1;
				axi_wdata <= wdata;
				axi_wstrb <= ~0;

				axi_bready <= 1;

				@(posedge clk);
				while (axi_awvalid || axi_wvalid || axi_bready) begin
					if (axi_awready) axi_awvalid <= 0;
					if (axi_wready) axi_wvalid <= 0;
					if (axi_bvalid) axi_bready <= 0;
					@(posedge clk);
				end
			end else
			if (token == "wait") begin:\wait
				reg [31:0] i;
				next_num_token(i);
				$display("%m: wait %d", i);
				while (i > 0) begin
					@(posedge clk);
					i = i - 1;
				end
			end else begin
				$display("%m: Unkown command `%0s' in line %d.", token, linenr);
			end

			buffer = "";
		end
	end
endmodule
