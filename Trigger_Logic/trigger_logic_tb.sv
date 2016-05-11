module trigger_logic_tb();
	
	reg clk, rst_n, armed, CHxHff5, CHxLff5;
	reg[7:0]  CHxTrigCfg;
	reg CHxTrig;
	
	trigger_logic DUT (
		.clk(clk), .rst_n(rst_n), .armed(armed), .CHxLff5(CHxLff5), .CHxHff5(CHxHff5),
		.CHxTrigCfg(CHxTrigCfg), .CHxTrig(CHxTrig)
	);
	
	always
		#5 clk = ~clk;
		
	initial begin
		clk = 0;
		rst_n = 0;
		armed = 0;
		CHxHff5 = 0;
		CHxLff5 = 0;
		CHxTrigCfg = 8'h0;
		#5;
		rst_n = 1;
		#5;
		// Test don't care trigger
		CHxTrigCfg = 8'h1;
		#5;
		if (CHxTrig == 1)
			$display("PASS: CHxTrig was asserted correctly");
		else
			$display("ERROR: CHxTrig was not asserted correctly");
		
		// Test low level trigger
		CHxTrig = 8'h2;
		CHxLff5 = 1;
		#5;
		if (CHxTrig == 1)
			$display("PASS: CHxTrig was asserted correctly");
		else
			$display("ERROR: CHxTrig was not asserted correctly");
				
		// Test high level trigger
		CHxTrig = 8'h4;
		CHxLff5 = 0;
		CHxHff5 = 1;
		#5;
		if (CHxTrig == 1)
			$display("PASS: CHxTrig was asserted correctly");
		else
			$display("ERROR: CHxTrig was not asserted correctly");
			
		// Test Negative edge trigger
		CHxTrig = 8'h8;
		CHxLff5 = 0;
		CHxHff5 = 1;
		#1;
		CHxLff5 = 1;
		#5;
		if (CHxTrig == 1)
			$display("PASS: CHxTrig was asserted correctly");
		else
			$display("ERROR: CHxTrig was not asserted correctly");
			
		// Test positive edge trigger
		CHxTrig = 0;
		CHxLff5 = 0;
		CHxHff5 = 0;
		#1;
		CHxHff5 = 1;
		#5;
		if (CHxTrig == 1)
			$display("PASS: CHxTrig was asserted correctly");
		else
			$display("ERROR: CHxTrig was not asserted correctly");
		
		$finish;
		
	end
	
endmodule