module UART_tx(clk, rst_n, trmt, tx_data, tx_done, TX);
	input clk, rst_n, trmt;
	input[7:0] tx_data;
	output TX, tx_done;
	wire load, transmitting, shift, set_done, clr_done;
	wire[3:0] bit_cnt;
	
	// State Machine Instance
	UART_tx_SM iSM(.clk(clk), .rst_n(rst_n), .trmt(trmt), .bit_cnt(bit_cnt), .load(load), .transmitting(transmitting), .shift(shift), .set_done(set_done), .clr_done(clr_done));
	// Datapath Instance
	UART_tx_datapath iDP(.clk(clk), .rst_n(rst_n), .TX(TX), .tx_data(tx_data), .tx_done(tx_done), .load(load), .transmitting(transmitting), .shift(shift), 
						.bit_cnt(bit_cnt), .set_done(set_done), .clr_done(clr_done));

endmodule