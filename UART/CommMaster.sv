module CommMaster(clk, rst_n, cmd, snd_cmd, TX, cmd_cmplt);
	input clk, rst_n, snd_cmd;
	input[15:0] cmd;
	output TX;
	output reg cmd_cmplt;
	reg tx_done, sel, trmt;
	wire[7:0] tx_data;
	reg[7:0] low_bytes;
	
	typedef enum reg[1:0] {IDLE, SEND_HIGH, SEND_LOW, CMD_SENT} state_t;
	state_t state, nxt_state;
	
	UART_tx txUart(.clk(clk), .rst_n(rst_n), .trmt(trmt), .tx_data(tx_data), .tx_done(tx_done), .TX(TX));
	
	// State machine registers
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			state <= IDLE;
		else
			state <= nxt_state;
	end
	
	// State machine nxt_state logic
	always_comb begin
		sel = 0;
		trmt = 0;
		nxt_state = IDLE;
		cmd_cmplt = 0;
		
		case(state)
			IDLE: begin
				if(snd_cmd) begin
					trmt = 1;
					sel = 1;
					nxt_state = SEND_HIGH;
				end
				else	
					nxt_state = IDLE;
			end
			SEND_HIGH: begin
				if(!tx_done)
					nxt_state = SEND_HIGH;
				else begin
					trmt = 1;
					nxt_state = SEND_LOW;
				end
			end
			SEND_LOW: begin
				if(!tx_done)
					nxt_state = SEND_LOW;
				else begin
					cmd_cmplt = 1;
					nxt_state = CMD_SENT;
				end
			end
			CMD_SENT: begin
				if(!snd_cmd) begin
					cmd_cmplt = 1;
					nxt_state = CMD_SENT;
				end
				else begin
					trmt = 1;
					sel = 1;
					nxt_state = SEND_HIGH;
				end
			end
		endcase
		
	end
	
	// Store the low byte on a snd_cmd to be sent later
	always @(posedge clk, negedge rst_n) begin
		if(snd_cmd)
			low_bytes <= cmd[7:0];
		else
			low_bytes <= low_bytes;
	end
	
	assign tx_data = sel ? cmd[15:8] : low_bytes;

endmodule