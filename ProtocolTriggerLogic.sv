module ProtocolTriggerLogic(TrigCfg, clk, rst_n, CH1L, CH2L, CH3L, baud_cntH, baud_cntL,
				maskH, maskL, matchH, matchL, protTrig);


input [3:0] TrigCfg;
input clk, rst_n;
input CH1L, CH2L, CH3L;
input [7:0] maskH;
input [7:0] maskL;
input [7:0] matchH;
input [7:0] matchL;
input [7:0] baud_cntH;
input [7:0] baud_cntL;

output protTrig;


wire SPItrig;
wire UARTtrig;
wire protTrigSPI;
wire protTrigUART;

SPI_RX spiDut(.clk(clk), .rst_n(rst_n), .SS_n(CH1L), .SCLK(CH2L), .MOSI(CH3L), .edg(TrigCfg[3]), .len8_16(TrigCfg[2]),
	      .mask({maskH, maskL}), .match({matchH, matchL}), .SPItrig(SPItrig));

UART_rx_Protocol Uart_rxDut(.clk(clk), .rst_n(rst_n), .RX(CH1L), .baud_cnt({baud_cntH, baud_cntL}), .mask(maskL), .match(matchL), .UARTtrig(UARTtrig));

assign protTrigSPI = SPItrig | TrigCfg[1];
assign protTrigUART = UARTtrig | TrigCfg[0];

assign protTrig = protTrigSPI & protTrigUART;


endmodule
