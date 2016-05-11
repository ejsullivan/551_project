module UART_rx(clk, rst_n, RX, rdy, cmd, clr_ready);
	input clk, rst_n, RX, clr_ready;
	output rdy;
	output[7:0] cmd;
	wire receiving, shift, busy, clr_busy, start, set_ready;
	wire[3:0] bit_cnt;
	
	// State machine instance
	UART_rx_SM iSM(.clk(clk), .rst_n(rst_n), .shift(shift), .receiving(receiving),
					.busy(busy), .clr_busy(clr_busy), .start(start), .bit_cnt(bit_cnt), .set_ready(set_ready));
	// Datapath instance
	UART_rx_datapath iDP(.clk(clk), .rst_n(rst_n), .start(start), .receiving(receiving),
							.shift(shift), .cmd(cmd), .RX(RX), .clr_busy(clr_busy), .busy(busy), 
							.bit_cnt(bit_cnt), .set_ready(set_ready), .clr_ready(clr_ready), .ready(rdy));
	
endmodule