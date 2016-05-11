module UART_rx_datapath(clk, rst_n, start, receiving, shift, cmd,
						RX, clr_busy, busy, bit_cnt, set_ready, clr_ready, ready);

	input clk, rst_n, start, receiving, RX, clr_busy, set_ready, clr_ready;
	output reg shift, busy, ready;
	output reg[7:0] cmd;
	output reg[3:0] bit_cnt;
	reg[9:0] shift_reg;
	reg[11:0] baud_cnt;
	reg rx_in1, rx_in2;
	
	// bit_cnt logic
	always @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			bit_cnt <= 0;
		else
			casex({start, shift})
				2'b0_0: bit_cnt <= bit_cnt;
				2'b0_1: bit_cnt <= bit_cnt + 1;
				2'b1_x: bit_cnt <= 0;
				default: bit_cnt <= 0;
			endcase
	end
	
	// baud_cnt logic
	always @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			baud_cnt <= 0;
		else
			casex({shift, receiving})
				2'b0_0: baud_cnt <= baud_cnt;
				2'b0_1: baud_cnt <= baud_cnt + 1;
				2'b1_x: baud_cnt <= 0;
			endcase
	end
	
	// shift logic
	always_comb begin
		// Wait for 1.5 cycles
		if(bit_cnt == 0)
			if(baud_cnt == 3906)
				shift = 1;
			else	
				shift = 0;
		// Wait for 1 cycle
		else
			if(baud_cnt == 2604)
				shift = 1;
			else
				shift = 0;
	end	
	
	// RX shift in logic
	always @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			shift_reg <= 0;
		else	
			casex(shift)
				1'b0: shift_reg <= shift_reg;
				1'b1: shift_reg <= {RX, shift_reg[9:1]};
			endcase			
	end
	
	// cmd logic
	always @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			cmd <= 0;
		else
			casex(bit_cnt)
				9: cmd <= shift_reg[8:1];
				default: cmd <= cmd;
			endcase
	end
	
	// busy logic
	/*always @(negedge RX, posedge clr_busy, negedge rst_n) begin
		if(!rst_n)
			busy <= 0;
		else if(!RX)
			busy <= 1;
		else
			busy <= 0;
	end*/
	
	always @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			busy <= 0;
		else if(rx_in2 & !rx_in1)
			busy <= 1;
		else if (clr_busy)
			busy <= 0;
		else
			busy <= busy;
	end
	
	always @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			rx_in1 <= 0;
			rx_in2 <= 0;
		end
		else begin
			rx_in1 <= RX;
			rx_in2 <= rx_in1;
		end	
	end
	
	// set ready and clear ready logic
	always @(posedge clk, negedge rst_n) begin
		if (!rst_n)
			ready <= 0;
		else if(clr_ready)
			ready <= 0;
		else if(set_ready)
			ready <= 1;
		else
			ready <= ready;
	end
	
endmodule



















