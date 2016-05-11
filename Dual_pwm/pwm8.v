module pwm8(duty, clk, rst_n, PWM_sig);
	input[7:0] duty;
	input clk, rst_n;
	output reg PWM_sig;
	reg[7:0] count;
	
	always @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			count <= 8'h00;
			PWM_sig <= 1'b1;
		end
		else begin
			count <= count + 1;
			if (count == 8'hff && duty != 8'h00)
				PWM_sig <= 1'b1;
			else if (count == duty)
				PWM_sig <= 1'b0;
			else
				PWM_sig <= PWM_sig;
		end
	end
endmodule