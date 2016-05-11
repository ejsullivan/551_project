`timescale 100ps/10ps
module SPI_tb();
	reg clk, rst_n, edg, len8_16, wrt, pos_edge, width8;
	reg[15:0] data_out, mask, match;
	reg[4:0] i;
	reg pass;
	wire SS_n, SCLK, MOSI, SPItrig, done;
	
	SPI_RX rx(.clk(clk), .rst_n(rst_n), .SS_n(SS_n), .SCLK(SCLK), .MOSI(MOSI), 
		   .edg(edg), .len8_16(len8_16), .mask(mask), .match(match), .SPItrig(SPItrig));
	SPI_mstr tx(.clk(clk), .rst_n(rst_n), .SS_n(SS_n), .SCLK(SCLK), .wrt(wrt),
		     .done(done), .data_out(data_out), .MOSI(MOSI), .pos_edge(pos_edge), .width8(width8));

	always 
		#5 clk = ~clk;
		
	initial begin
		clk = 0;
		rst_n = 0; 
		edg = 0;
		len8_16 = 0;
		mask = 0;
		match = 0;
		wrt = 0;
		pos_edge = 0;
		width8 = 0;
		data_out = 0;
		pass = 0;
		i = 0;
		
		#10;
		rst_n = 1;
		for(i = 0; i < 16; i++) begin
			data_out = (1 << i);
			pass = 0;
			match = 16'hffff;
			wrt = 1;
			#10;
			wrt = 0;
			while(done != 1) begin
				#1;
				if (SPItrig == 1) begin
					$display("ERROR: SPItrig was asserted when there was no match");
					#100;
					$finish;
				end
			end
			$display("PASS: SPItrig was asserted when there was a match");
			
			match = (1 << i);
			wrt = 1;
			#10;
			wrt = 0;
			while(done != 1) begin
				#1;
				if (SPItrig == 1 && pass != 1) begin
					$display("PASS: SPItrig was asserted when there was a match");
					pass = 1;
				end
			end
			if (pass != 1) begin
				$display("ERROR: SPItrig was  not asserted when there was a match");
				#100;
				$finish;
			end
		end
		
		len8_16 = 0;
		repeat(2) begin
			len8_16 = ~len8_16;
			for(i = 0; i < 5; i++) begin
				data_out = $random;
				pass = 0;
				mask = 0;
				wrt = 1;
				#10;
				wrt = 0;
				while(done != 1) begin
					#1;
					if (SPItrig == 1) begin
						$display("ERROR: SPItrig was asserted when there was no match");
						#100;
						$finish;
					end
				end
				$display("PASS: SPItrig was not asserted when there was no match");
				
				match = data_out;
				wrt = 1;
				#10;
				wrt = 0;
				while(done != 1) begin
					#1;
					if (SPItrig == 1 && pass != 1) begin
						$display("PASS: SPItrig was asserted when there was a match");
						pass = 1;
					end
				end
				if (pass != 1) begin
					$display("ERROR: SPItrig was not asserted when there was a match");
					#100;
					$finish;
				end
			end
		end
		
		for(i = 0; i < 10; i++) begin
			data_out = $random;
			pass = 0;
			match = ~data_out;
			mask = 0;
			wrt = 1;
			#10;
			wrt = 0;
			while(done != 1) begin
				#1;
				if (SPItrig == 1) begin
					$display("ERROR: SPItrig was asserted when there was no match");
					#100;
					$finish;
				end
			end
			$display("PASS: SPItrig was asserted when there was a match");
			
			mask = 16'hffff;
			wrt = 1;
			#10;
			wrt = 0;
			while(done != 1) begin
				#1;
				if (SPItrig == 1 && pass != 1) begin
					$display("PASS: SPItrig was asserted when there was a match");
					pass = 1;
				end
			end
			if (pass != 1) begin
				$display("ERROR: SPItrig was  not asserted when there was a match");
				#100;
				$finish;
			end
		end
		
		for (i = 0; i < 10; i++) begin
			pos_edge = 1;
			edg = 1;
			data_out = $random;
			pass = 0;
			match = ~data_out;
			mask = 0;
			wrt = 1;
			#10;
			wrt = 0;
			while(done != 1) begin
				#1;
				if (SPItrig == 1) begin
					$display("ERROR: SPItrig was asserted when there was no match");
					#100;
					$finish;
				end
			end
			$display("PASS: SPItrig was asserted when there was a match");
		end
		
		$display("ALL TESTS PASSED!!!");
		$finish;
	end
	
endmodule