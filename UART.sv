module UART(clk, rst_n, RX, rdy, cmd, clr_ready, trmt, tx_data, tx_done, TX);
	input clk, rst_n, RX, clr_ready, trmt;
	input[7:0] tx_data;
	output TX, tx_done;
	output rdy;
	output[7:0] cmd;
	
	UART_tx txUart(.clk(clk), .rst_n(rst_n), .trmt(trmt), .tx_data(tx_data), .tx_done(tx_done), .TX(TX));
	UART_rx rxUart(.clk(clk), .rst_n(rst_n), .RX(TX), .rdy(rdy), .cmd(cmd), .clr_ready(clr_ready));

endmodule