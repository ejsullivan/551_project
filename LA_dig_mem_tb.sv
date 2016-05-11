`timescale 1ns / 1ps
module LA_dig_mem_tb();
			
parameter ENTRIES = 384;	// defaults to 384 for simulation, use 12288 for DE-0
parameter LOG2 = 9;			
		
//typedef enum {IDLE, WRT_SMPL, CHANDUMP, CAPT_DONE} state_t;
		
//// Interconnects to DUT/support defined as type wire /////
wire clk400MHz,locked;			// PLL output signals to DUT
wire clk;						// 100MHz clock generated at this level from clk400MHz
wire VIH_PWM,VIL_PWM;			// connect to PWM outputs to monitor
wire CH1L,CH1H,CH2L,CH2H,CH3L;	// channel data inputs from AFE model
wire CH3H,CH4L,CH4H,CH5L,CH5H;	// channel data inputs from AFE model
wire RX,TX;						// interface to host
wire cmd_sent,resp_rdy;			// from master UART, monitored in test bench
wire [7:0] resp;				// from master UART, reponse received from DUT
wire tx_prot;					// UART signal for protocol triggering
wire SS_n,SCLK,MOSI;			// SPI signals for SPI protocol triggering
wire CH1L_mux,CH1H_mux;         // output of muxing logic for CH1 to enable testing of protocol triggering
wire CH2L_mux,CH2H_mux;			// output of muxing logic for CH2 to enable testing of protocol triggering
wire CH3L_mux,CH3H_mux;			// output of muxing logic for CH3 to enable testing of protocol triggering

////// Stimulus is declared as type reg ///////
reg REF_CLK, RST_n;
reg [15:0] host_cmd;			// command host is sending to DUT
reg send_cmd;					// asserted to initiate sending of command
reg clr_resp_rdy;				// asserted to knock down resp_rdy
reg [1:0] clk_div;				// counter used to derive 100MHz clk from clk400MHz
reg strt_tx;					// kick off unit used for protocol triggering
reg [7:0] memDump [ENTRIES-1:0];
reg[7:0] ack;
reg pos_edge, length;
integer i;
/////////////////////////////////////////////////////////////
// Channel Dumps can be written to file to aid in testing //
///////////////////////////////////////////////////////////
// setup file pointers here if going to do that

// DO THIS we can check the wave form with the python script!

///////////////////////////
// Define command bytes //
/////////////////////////
// May or may not want to make some localparams to represent command bytes to LA core

/////////////////////////////////
localparam UART_triggering = 1'b1;	// set to true if testing UART based triggering
localparam SPI_triggering = 1'b0;	// set to true if testing SPI based triggering

///// Instantiate Analog Front End model (provides stimulus to channels) ///////
AFE iAFE(.smpl_clk(clk400MHz),.VIH_PWM(VIH_PWM),.VIL_PWM(VIL_PWM),
         .CH1L(CH1L),.CH1H(CH1H),.CH2L(CH2L),.CH2H(CH2H),.CH3L(CH3L),
         .CH3H(CH3H),.CH4L(CH4L),.CH4H(CH4H),.CH5L(CH5L),.CH5H(CH5H));
		 
//// Mux for muxing in protocol triggering for CH1 /////
assign {CH1H_mux,CH1L_mux} = (UART_triggering) ? {2{tx_prot}} :		// assign to output of UART_tx used to test UART triggering
                             (SPI_triggering) ? {2{SS_n}}: 			// assign to output of SPI SS_n if SPI triggering
				             {CH1H,CH1L};

//// Mux for muxing in protocol triggering for CH2 /////
assign {CH2H_mux,CH2L_mux} = (SPI_triggering) ? {2{SCLK}}: 			// assign to output of SPI SCLK if SPI triggering
				             {CH2H,CH2L};	

//// Mux for muxing in protocol triggering for CH3 /////
assign {CH3H_mux,CH3L_mux} = (SPI_triggering) ? {2{MOSI}}: 			// assign to output of SPI MOSI if SPI triggering
				             {CH3H,CH3L};					  
	 
////// Instantiate DUT ////////
LA_dig iDUT(.clk400MHz(clk400MHz),.RST_n(RST_n),.locked(locked),
            .VIH_PWM(VIH_PWM),.VIL_PWM(VIL_PWM),.CH1L(CH1L_mux),.CH1H(CH1H_mux),
			.CH2L(CH2L_mux),.CH2H(CH2H_mux),.CH3L(CH3L_mux),.CH3H(CH3H_mux),.CH4L(CH4L),
			.CH4H(CH4H),.CH5L(CH5L),.CH5H(CH5H),.RX(RX), .TX(TX), .LED());

///// Instantiate PLL to provide 400MHz clk from 50MHz ///////
pll8x iPLL(.ref_clk(REF_CLK),.RST_n(RST_n),.out_clk(clk400MHz),.locked(locked));

///// It is useful to have a 100MHz clock at this level similar //////
///// to main system clock (clk).  So we will create one        //////
always @(posedge clk400MHz, negedge locked)
  if (~locked)
    clk_div <= 2'b00;
  else
    clk_div <= clk_div+1;
assign clk = clk_div[1];

//// Instantiate Master UART (mimics host commands) //////
UART_comm_mstr iMSTR(.clk(clk), .rst_n(RST_n), .RX(TX), .TX(RX),
                     .cmd(host_cmd), .send_cmd(send_cmd),
					 .cmd_sent(cmd_sent), .resp_rdy(resp_rdy),
					 .resp(resp), .clr_resp_rdy(clr_resp_rdy));
					 
////////////////////////////////////////////////////////////////
// Instantiate transmitter as source for protocol triggering //
//////////////////////////////////////////////////////////////
UART_tx iTX(.clk(clk), .rst_n(RST_n), .TX(tx_prot), .trmt(strt_tx),
        .tx_data(8'h96), .tx_done(done_uart));
					 
////////////////////////////////////////////////////////////////////
// Instantiate SPI transmitter as source for protocol triggering //
//////////////////////////////////////////////////////////////////
SPI_mstr iSPI(.clk(clk),.rst_n(RST_n),.SS_n(SS_n),.SCLK(SCLK),.wrt(strt_tx),.done(done),
              .data_out(16'hbeef),.MOSI(MOSI),.pos_edge(pos_edge),.width8(length));

task write_reg;
  input[7:0] val;
  input[5:0] register;
  output[7:0] ack;
  
  host_cmd = {2'b01, register, val};
  @(negedge clk);
  send_cmd = 1;
  @(negedge clk);
  send_cmd = 0;
  while(!iDUT.cmd_rdy)
	@(negedge clk);
  if (iDUT.cmd != host_cmd)
	$display("ERROR: cmd does not match comm_cmd cmd = 0x%x host_cmd = 0x%x", iDUT.cmd, host_cmd);
  else
	$display("PASS: cmd matches host_cmd. cmd = 0x%x host_cmd = 0x%x", iDUT.cmd, host_cmd);
	
  while(!resp_rdy)
	@(negedge clk);
  clr_resp_rdy = 1;
  @(negedge clk);
  clr_resp_rdy = 0;
  
  ack = resp;
endtask

task read_reg;
	input[5:0] register;
	input[5:0] expectedVal;
	output[7:0] ack;

	host_cmd = {2'b00, register, 8'h00};
	@(negedge clk);
	send_cmd = 1;
	@(negedge clk);
	send_cmd = 0;
	while(!iDUT.cmd_rdy)
		@(negedge clk);
	if (iDUT.iCOMM.cmd != host_cmd)
		$display("ERROR: cmd does not match host_cmd. cmd = 0x%x host_cmd = 0x%x", iDUT.cmd, host_cmd);
	else
		$display("PASS: cmd matches comm_cmd");
		
	while(!resp_rdy)
		@(negedge clk);
	clr_resp_rdy = 1;
	@(negedge clk);
	clr_resp_rdy = 0;

	//if (resp != expectedVal)
		//$display("ERROR: read data does not match write data rx_data = 0x%h", resp);
	//else
		//$display("PASS: read data matches write data");

	ack = resp;
endtask

task fill_mem;
	input[2:0] channel;

	case(channel) 
		0: $readmemh("mem_input.txt", iDUT.iRAMCH1.mem);
		1: $readmemh("mem_input.txt", iDUT.iRAMCH2.mem);
		2: $readmemh("mem_input.txt", iDUT.iRAMCH3.mem);
		3: $readmemh("mem_input.txt", iDUT.iRAMCH4.mem);
		4: $readmemh("mem_input.txt", iDUT.iRAMCH5.mem);
		default: $display("ERROR: invalid channel");
	endcase
	
endtask

task dump_mem;
	input[2:0] channel;
	host_cmd = {5'b10000, channel, 8'h00};
	@(negedge clk);
	send_cmd = 1;
	@(negedge clk);
	send_cmd = 0;
	while(!iDUT.iCOMM.cmd_rdy)
		@(negedge clk);
	if (iDUT.iCOMM.cmd != host_cmd)
		$display("ERROR: cmd does not match comm_cmd iDUT.iCOMM.cmd = 0x%x host_cmd = 0x%x", iDUT.iCOMM.cmd, host_cmd);
	else
		$display("PASS: cmd matches comm_cmd");
	
	for(i = 0; i < ENTRIES; i = i + 1) begin
		clr_resp_rdy = 0;
		while(!resp_rdy) begin
			@(negedge clk);
			//$display("WAITING");
		end
		$display("memDump[%d] = 0x%x", i, resp);
		memDump[i] = resp;
		clr_resp_rdy = 1;
		@(negedge clk);
	end
	$writememh("output.txt", memDump);
endtask

task check_mem;
	int i;
	for(i = 0; i < ENTRIES; i = i + 1) begin
		if (memDump[i] != i % 16'h100)
			$display("ERROR: memDump[%d] is not the correct val", i);
		else
			$display("PASS: memDump[%d] is correct", i);
	end
endtask
			
task test_mem_dump;
	int i;
	fill_mem(.channel(0));
	force iDUT.iDIG.chanCapDut.state = iDUT.iDIG.chanCapDut.CAPT_DONE;
	for(i = 0; i < 5; i++) begin
		dump_mem(.channel(i));
		check_mem();
	end	
endtask
	
initial begin
	REF_CLK = 0; 
	RST_n = 0;
	host_cmd = 0;			// command host is sending to DUT
	send_cmd = 0;					// asserted to initiate sending of command
	clr_resp_rdy = 0;				// asserted to knock down resp_rdy
	clk_div = 0;				// counter used to derive 100MHz clk from clk400MHz
	strt_tx = 0;
	@(negedge REF_CLK);
	RST_n = 1;
	@(negedge REF_CLK);
	@(negedge clk);
	@(negedge clk);
	@(negedge clk);
	
	test_mem_dump();
	
	$finish;
end

always
  #100 REF_CLK = ~REF_CLK;

///// Perhaps put some basic tasks in a separate file to keep your test bench less cluttered /////
//`include "tb_tasks.v"

endmodule	
