parameter ENTRIES = 384,
          LOG2 = 9;

module cmd_cf_tb();

  reg clk;
  reg rst_n;
  reg [15:0] comm_cmd;
  reg [15:0] cmd;
  reg [7:0] ack;
  reg cmd_rdy;
  reg resp_sent;
  reg rd_done;
  reg set_capture_done;
  reg [7:0] rdataCH1, rdataCH2, rdataCH3, rdataCH4, rdataCH5;
  
  wire [7:0] resp;
  wire[7:0] rx_resp;
  reg send_resp;
  reg clr_cmd_rdy;
  reg rx_clr_rdy;
  wire strt_rd;
  wire cmd_cmplt;
  reg snd_cmd;
  wire rdy;
  wire RX;
  wire TX;
  wire [LOG2-1:0] trig_pos;
  wire [3:0] decimator;
  wire [7:0] maskL, maskH;
  wire [7:0] matchL, matchH;
  wire [7:0] baud_cntL, baud_cntH;
  wire [5:0] TrigCfg;
  wire [4:0] CH1TrigCfg, CH2TrigCfg, CH3TrigCfg, CH4TrigCfg, CH5TrigCfg; 
  wire [7:0] VIH, VIL; 

  integer count;  
  typedef enum {IDLE, CHANDUMP, WRITE, READ, POSACK, NEGACK} state_t;
  
  cmd_cfg iDUT0(.clk(clk), .rst_n(rst_n), .cmd(cmd), .cmd_rdy(cmd_rdy), .resp_sent(resp_sent),
				.rd_done(rd_done), .set_capture_done(set_capture_done), .rdataCH1(rdataCH1), 
				.rdataCH2(rdataCH2), .rdataCH3(rdataCH3), .rdataCH4(rdataCH4), .rdataCH5(rdataCH5), 
				.resp(resp), .send_resp(send_resp), .clr_cmd_rdy(clr_cmd_rdy), .strt_rd(strt_rd), .trig_pos(trig_pos), 
				.decimator(decimator), .maskL(maskL), .maskH(maskH), .matchL(matchL), .matchH(matchH),
				.baud_cntL(baud_cntL), .baud_cntH(baud_cntH), .TrigCfg(TrigCfg), .CH1TrigCfg(CH1TrigCfg), 
				.CH2TrigCfg(CH2TrigCfg), .CH3TrigCfg(CH3TrigCfg), .CH4TrigCfg(CH4TrigCfg), .CH5TrigCfg(CH5TrigCfg), 
				.VIH(VIH), .VIL(VIL));
				
  UART_Wrapper wrapper0(.clk(clk), .rst_n(rst_n), .clr_cmd_rdy_IN(clr_cmd_rdy), .cmd_rdy(cmd_rdy), .cmd(cmd),
					.send_resp(send_resp), .resp(resp), .resp_sent(resp_sent), .RX(RX), .TX(TX));
					
  CommMaster commMaster0(.clk(clk), .rst_n(rst_n), .cmd(comm_cmd), .snd_cmd(snd_cmd), .TX(RX), .cmd_cmplt(cmd_cmplt));
  
  UART_comm_mstr commMaster0(clk, rst_n, cmd, send_cmd, TX, RX, cmd_sent, resp_rdy, resp, clr_resp_rdy);

  UART_rx RX0(.clk(clk), .rst_n(rst_n), .RX(TX), .rdy(rdy), .cmd(rx_resp), .clr_ready(rx_clr_rdy));
  
always
	#5 clk = ~clk;

task write_reg;
  input[7:0] val;
  input[5:0] register;
  output[7:0] ack;
  
  comm_cmd = {2'b01, register, val};
  @(negedge clk);
  snd_cmd = 1;
  @(negedge clk);
  snd_cmd = 0;
  while(!cmd_rdy)
	@(negedge clk);
  if (cmd != comm_cmd)
	$display("ERROR: cmd does not match comm_cmd");
  else
	$display("PASS: cmd matches comm_cmd");
	
  while(!rdy)
	@(negedge clk);
  rx_clr_rdy = 1;
  @(negedge clk);
  rx_clr_rdy = 0;
  
  ack = rx_resp;
	
endtask

task dump_mem;
  input[2:0] channel;
	
  comm_cmd = {5'b10000, channel, 8'h00};
  @(negedge clk);
  snd_cmd = 1;
  @(negedge clk);
  snd_cmd = 0;
  while(!cmd_rdy)
	@(negedge clk);
  if (cmd != comm_cmd)
	$display("ERROR: cmd does not match comm_cmd");
  else
	$display("PASS: cmd matches comm_cmd");
	
endtask

task read_reg;
  input[5:0] register;
  input[5:0] expectedVal;
  output[7:0] ack;
  
  comm_cmd = {2'b00, register, 8'h00};
  @(negedge clk);
  snd_cmd = 1;
  @(negedge clk);
  snd_cmd = 0;
  while(!cmd_rdy)
	@(negedge clk);
  if (cmd != comm_cmd)
	$display("ERROR: cmd does not match comm_cmd");
  else
	$display("PASS: cmd matches comm_cmd");
	
  while(!rdy)
	@(negedge clk);
  rx_clr_rdy = 1;
  @(negedge clk);
  rx_clr_rdy = 0;
  
  if (rx_resp != expectedVal)
    $display("ERROR: read data does not match write data rx_data = 0x%h", rx_resp);
  else
    $display("PASS: read data matches write data");
  
  ack = rx_resp;
endtask
	
initial begin
  clk = 0;
  rst_n = 0;
  cmd = 16'h0000;
  cmd_rdy = 0;
  resp_sent = 0;
  send_resp = 0;
  clr_cmd_rdy = 0;
  rd_done = 0;
  set_capture_done = 0;
  rx_clr_rdy = 0;
  rdataCH1 = 8'h00;
  rdataCH2 = 8'h00;
  rdataCH3 = 8'h00;
  rdataCH4 = 8'h00;
  rdataCH5 = 8'h00;
  #15;
  rst_n = 1;
  for(count = 0; count < 17; count = count + 1) begin
    write_reg(.val(8'h01), .register(count), .ack(ack));
	if (ack == 8'ha5)
	  $display("PASS: the ack value sent after the write was correct");
	else 
	  $display("ERROR: the ack value sent after the write was not correct");
    read_reg(.register(count), .expectedVal(8'h01), .ack(ack));
  end

  write_reg(.val(8'h01), .register(8'hff), .ack(ack));
  if (ack == 8'hee)
    $display("PASS: when we try to write to an invalid register the return value is 0xee");
  else
	$display("ERROR: when we try to write to an invalid register 0xee is not returned");
	
  dump_mem(.channel(3'h1));
  assert property (@(posedge clk) iDUT0.state == CHANDUMP)
  else begin
    $display("ERROR: the next state was not CHANDUMP");
	$finish;
  end
  
  $display("PASS: the next state was CHANDUMP");
	
	
  $finish;
  
end

endmodule

