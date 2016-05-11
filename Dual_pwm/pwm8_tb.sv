module pwm8_tb;
	reg[7:0] duty;
	reg clk, rst_n;
	wire PWM_sig;
	
	pwm8 DUT(.duty(duty), .clk(clk), .rst_n(rst_n), .PWM_sig(PWM_sig));
	
	initial begin
		duty = 8'hff;
		clk = 1'b0;
		rst_n = 1'b0;
		#5;
		rst_n = 1'b1;
		#10000;
		duty = 8'hbf;
		#10000;
		duty = 8'h7f;
		#10000;
		duty = 8'h3f;
		#10000;
		duty = 8'h00;
		#10000;
		$finish;
	end
	
	always 
		#5 clk = ~clk;
		
endmodule 