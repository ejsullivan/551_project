module UART_rx_Protocol(clk, rst_n, RX, baud_cnt, mask, match, UARTtrig);
	input clk, rst_n, RX;
	input [15:0] baud_cnt;
	input[7:0] mask, match;
	output UARTtrig;
	wire rdy;
	wire [7:0] cmd;
	wire receiving, shift, busy, clr_busy, start, set_ready;
	wire clr_ready;
	wire[3:0] bit_cnt;
	
	// State machine instance
	UART_rx_SM_Protocol iSM(.clk(clk), .rst_n(rst_n), .shift(shift), .receiving(receiving),
					.busy(busy), .clr_busy(clr_busy), .start(start), .bit_cnt(bit_cnt), .set_ready(set_ready));
	// Datapath instance
	UART_rx_datapath_Protocol iDP(.clk(clk), .rst_n(rst_n), .start(start), .receiving(receiving),
							.shift(shift), .cmd(cmd), .RX(RX), .clr_busy(clr_busy), .busy(busy), 
							.bit_cnt(bit_cnt), .set_ready(set_ready), .ready(rdy), .clr_ready(clr_ready),
							.baud_cntA(baud_cnt));
							
	data_comp dataCompUart(.serial_data(cmd), .mask(mask), .match(match), .serial_vld(rdy), .prot_trig(UARTtrig));

	assign clr_ready = rdy ? 1'b1 : 1'b0;
	
endmodule
