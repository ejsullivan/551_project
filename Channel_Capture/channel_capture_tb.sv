module channel_capture_tb();

	parameter ENTRIES = 384;	// defaults to 384 for simulation, use 12288 for DE-0
	parameter LOG2 = 9;		// Log base 2 of number of entries
	typedef enum {IDLE, WRT_SMPL, CHANDUMP, CAPT_DONE} state_t;
	
	reg clk, rst_n, wrt_smpl, run, triggered, we, start_rd;
	wire[7:0] wdata;
	wire[7:0] rdata;
	reg [LOG2-1:0] trig_pos;
	reg [5:0] TrigCfg;

	wire read_done, capture_done, armed;
	wire [LOG2-1:0] waddr, raddr;
	
	reg[LOG2 - 1:0] count = 0;
	
	RAMqueue MEM(.clk(clk), .we(we), .waddr(waddr), .raddr(raddr),
				 .wdata(wdata), .rdata(rdata)
	);

	channel_capture DUT(.clk(clk), .rst_n(rst_n), .run(run), .start_rd(start_rd),
					.triggered(triggered), .TrigCfg(TrigCfg), .read_done(read_done),
					.capture_done(capture_done), .armed(armed), .wrt_smpl(wrt_smpl),
					.trig_pos(trig_pos), .waddr(waddr), .raddr(raddr), .we(we)
	);
	
	task fill_mem;
		$readmemh("mem_input.txt", MEM.mem);
	endtask
		
	task dump_mem;
		@(negedge clk)
		start_rd = 1;
		while (!read_done) begin
			@(negedge clk)
			if (rdata == count)
				$display("PASS: rdata = 0x%x count = 0x%x", rdata, count);
			else
				$display("ERROR: rdata = 0x%x count = 0x%x", rdata, count);
			count = (count + 1) % 10'h100;
		end
	endtask
	
	always
		#5 clk = ~clk;
	
	initial begin
		clk = 0;
		rst_n = 0;
		wrt_smpl = 0;
		triggered = 0;
		trig_pos = 0;
		TrigCfg = 0;
		
		start_rd = 0;
		run = 0;
		@(posedge clk);
		rst_n = 1;
		@(posedge clk);
		fill_mem();
		@(posedge clk)
		dump_mem();
		$finish;
	end
		
endmodule

