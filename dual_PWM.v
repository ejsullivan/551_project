module dual_PWM(clk, rst_n, VIH, VIL, VIH_PWM, VIL_PWM);
	input clk, rst_n;
	input[7:0] VIH, VIL;
	output VIH_PWM, VIL_PWM;
	
	pwm8 VIH_module(.duty(VIH), .clk(clk), .rst_n(rst_n), .PWM_sig(VIH_PWM));
	pwm8 VIL_module(.duty(VIL), .clk(clk), .rst_n(rst_n), .PWM_sig(VIL_PWM));

endmodule