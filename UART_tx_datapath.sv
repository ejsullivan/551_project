module UART_tx_datapath(clk, rst_n, TX, tx_data, tx_done, load, transmitting, shift, 
						bit_cnt, set_done, clr_done);
	input clk, rst_n, load, set_done, clr_done, transmitting;
	input[7:0] tx_data;
	output TX, shift;
	output reg tx_done;
	output reg [3:0] bit_cnt;
	reg [11:0] baud_cnt;
	reg [9:0] tx_shift_reg;
	
	// bit_cnt logic
	always @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			bit_cnt <= 0;
		else
			casex ({load, shift})
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
			casex ({shift, transmitting})
				2'b0_0: baud_cnt <= baud_cnt;
				2'b0_1: baud_cnt <= baud_cnt + 1;
				2'b1_x: baud_cnt <= 0;
				default: bit_cnt <= 0;
			endcase
	end
	assign shift = (baud_cnt > 2603) ? 1 : 0;
	
	// Uart TX shift out logic
	always @(posedge clk, negedge rst_n) begin
		if (!rst_n)
			tx_shift_reg <= 9'h1ff;
		else begin
			casex({load, shift})
				2'b0_0: tx_shift_reg <= tx_shift_reg;
				2'b0_1: tx_shift_reg <= tx_shift_reg >> 1;
				2'b1_x: tx_shift_reg <= {1'b1, tx_data, 1'b0};
				default: tx_shift_reg <= 0;
			endcase
		end
	end
	assign TX = (transmitting) ? tx_shift_reg[0] : 1;	
	
	// tx_done logic
	always @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			tx_done <= 0;
		end
		else begin
			tx_done <= set_done & !clr_done;
		end
	end
endmodule