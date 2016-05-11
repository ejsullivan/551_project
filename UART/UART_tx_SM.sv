module UART_tx_SM(clk, rst_n, trmt, bit_cnt, load, transmitting, shift, set_done, clr_done);
	input clk, rst_n, trmt, shift;
	input[3:0] bit_cnt;
	output load, transmitting, set_done, clr_done;
	typedef enum reg[1:0] {IDLE, TRANSMITTING, SHIFT} state_t;
	state_t state, nxt_state;
	reg load, transmitting, set_done, clr_done;
	
	always_ff @(posedge clk, negedge rst_n)
		if(!rst_n)
			state <= IDLE;
		else
			state <= nxt_state;
	
	always_comb begin
		nxt_state = IDLE;
		load = 1'b0;
		clr_done = 1'b0;
		transmitting = 1'b0;
		set_done = 1'b0;
		case(state)
			IDLE: begin
				if (trmt) begin
					nxt_state = TRANSMITTING;
					load = 1'b1;
					clr_done = 1'b1;
					transmitting = 1'b1;
				end
				else
					nxt_state = IDLE;
			end
			TRANSMITTING: begin
				if (shift) begin
					nxt_state = SHIFT;
					if (bit_cnt < 9)
						transmitting = 1'b1;
				end
				else begin
					nxt_state = TRANSMITTING;
					transmitting = 1'b1;
				end
			end
			SHIFT: begin
				if (bit_cnt < 10) begin
					nxt_state = TRANSMITTING;
					transmitting = 1'b1;
				end
				else begin
					nxt_state = IDLE;
					set_done = 1'b1;
				end
			end
		endcase
	end
	
endmodule
