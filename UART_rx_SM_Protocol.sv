module UART_rx_SM_Protocol(clk, rst_n, shift, receiving, busy, clr_busy, start, bit_cnt, set_ready);
	input clk, rst_n, shift, busy;
	input[3:0] bit_cnt;
	output reg receiving, clr_busy, start, set_ready; 
	typedef enum reg[1:0] {IDLE, WAIT, SHIFT} state_t;
	state_t state, nxt_state;
	
	always_ff @(posedge clk, negedge rst_n)
		if(!rst_n)
			state <= IDLE;
		else
			state <= nxt_state;
	
	always_comb begin
		nxt_state = IDLE;
		receiving = 0;
		clr_busy = 0;
		start = 0;
		set_ready = 0;
		case(state)
			IDLE: begin
				if(busy) begin
					nxt_state = WAIT;
					start = 1;
					receiving = 1;
				end
				else begin
					nxt_state = IDLE;
				end
			end
			WAIT: begin
				if(shift) begin
					nxt_state = SHIFT;
				end
				else begin
					nxt_state = WAIT;
					receiving = 1;
				end
			end
			SHIFT: begin
				if(bit_cnt < 10) begin
					nxt_state = WAIT;
					receiving = 1;
				end
				else begin
					nxt_state = IDLE;
					set_ready = 1;
					clr_busy = 1;
				end
			end
		endcase
	end
	
endmodule
