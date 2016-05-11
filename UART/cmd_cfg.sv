parameter ENTRIES = 384,
          LOG2 = 9;

module cmd_cfg(
  input clk, 
  input rst_n,
  input [15:0] cmd,
  input cmd_rdy,
  input resp_sent,
  input rd_done,
  input set_capture_done,
  input [7:0] rdataCH1, rdataCH2, rdataCH3, rdataCH4, rdataCH5,
  
  output reg [7:0] resp,
  output reg send_resp,
  output reg clr_cmd_rdy,
  output reg strt_rd,
  output reg [LOG2-1:0] trig_pos,
  output reg [3:0] decimator,
  output reg [7:0] maskL, maskH,
  output reg [7:0] matchL, matchH,
  output reg [7:0] baud_cntL, baud_cntH,
  output reg [5:0] TrigCfg,
  output reg [4:0] CH1TrigCfg, CH2TrigCfg, CH3TrigCfg, CH4TrigCfg, CH5TrigCfg, 
  output reg [7:0] VIH, VIL  
);

typedef enum {IDLE, CHANDUMP, REQDUMP, WRITE, READ, NEGACK} state_t;

state_t state;
state_t nxt_state;
reg [2:0] channel;
reg [2:0] nxt_channel;

localparam posAck = 8'hA5;
localparam negAck = 8'hEE;

localparam TrigCfg_addr = 0;
localparam CH1TrigCfg_addr = 1;
localparam CH2TrigCfg_addr = 2;
localparam CH3TrigCfg_addr = 3;
localparam CH4TrigCfg_addr = 4;
localparam CH5TrigCfg_addr = 5;
localparam decimator_addr = 6;
localparam VIH_addr = 7;
localparam VIL_addr = 8;
localparam matchH_addr = 9;
localparam matchL_addr = 10;
localparam maskH_addr = 11;
localparam maskL_addr = 12;
localparam baud_cntH_addr = 13;
localparam baud_cntL_addr = 14;
localparam trig_posH_addr = 15;
localparam trig_posL_addr = 16;

localparam TrigCfg_rst = 6'h03;
localparam CH1TrigCfg_rst = 5'h01;
localparam CH2TrigCfg_rst = 5'h01;
localparam CH3TrigCfg_rst = 5'h01;
localparam CH4TrigCfg_rst = 5'h01;
localparam CH5TrigCfg_rst = 5'h01;
localparam decimator_rst = 4'h0;
localparam VIH_rst = 8'hAA;
localparam VIL_rst = 8'h55;
localparam matchH_rst = 8'h00;
localparam matchL_rst = 8'h00;
localparam maskH_rst = 8'h00;
localparam maskL_rst = 8'h00;
localparam baud_cntH_rst = 8'h06;
localparam baud_cntL_rst = 8'hC8;
localparam trig_posH_rst = 8'h00;
localparam trig_posL_rst = 8'h01;

always @(posedge clk, negedge rst_n) begin  //maybe some bit will be cleared. Need to ask.
  if (!rst_n) begin
    TrigCfg <= TrigCfg_rst;
  end
  else if (cmd_rdy && (cmd[15:14] == 2'b01) && (cmd[13:8] == TrigCfg_addr)) begin
    TrigCfg <= cmd[5:0];
  end
  else if (set_capture_done)
    TrigCfg <= TrigCfg | 8'b00100000;
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n) begin
    CH1TrigCfg <= CH1TrigCfg_rst;
  end
  else if (cmd_rdy && (cmd[15:14] == 2'b01) && (cmd[13:8] == CH1TrigCfg_addr)) begin
    CH1TrigCfg <= cmd[4:0];
  end
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n) begin
    CH2TrigCfg <= CH2TrigCfg_rst;
  end
  else if (cmd_rdy && (cmd[15:14] == 2'b01) && (cmd[13:8] == CH2TrigCfg_addr)) begin
    CH2TrigCfg <= cmd[4:0];
  end
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n) begin
    CH3TrigCfg <= CH3TrigCfg_rst;
  end
  else if (cmd_rdy && (cmd[15:14] == 2'b01) && (cmd[13:8] == CH3TrigCfg_addr)) begin
    CH3TrigCfg <= cmd[4:0];
  end
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n) begin
    CH4TrigCfg <= CH4TrigCfg_rst;
  end
  else if (cmd_rdy && (cmd[15:14] == 2'b01) && (cmd[13:8] == CH4TrigCfg_addr)) begin
    CH4TrigCfg <= cmd[4:0];
  end
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n) begin
    CH5TrigCfg <= CH5TrigCfg_rst;
  end
  else if (cmd_rdy && (cmd[15:14] == 2'b01) && (cmd[13:8] == CH5TrigCfg_addr)) begin
    CH5TrigCfg <= cmd[4:0];
  end
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n) begin
    decimator <= decimator_rst;
  end
  else if (cmd_rdy && (cmd[15:14] == 2'b01) && (cmd[13:8] == decimator_addr)) begin
    decimator <= cmd[3:0];
  end
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n) begin
    VIH <= VIH_rst;
  end
  else if (cmd_rdy && (cmd[15:14] == 2'b01) && (cmd[13:8] == VIH_addr)) begin
    VIH <= cmd[7:0];
  end
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n) begin
    VIL <= VIL_rst;
  end
  else if (cmd_rdy && (cmd[15:14] == 2'b01) && (cmd[13:8] == VIL_addr)) begin
    VIL <= cmd[7:0];
  end
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n) begin
    matchH <= matchH_rst;
  end
  else if (cmd_rdy && (cmd[15:14] == 2'b01) && (cmd[13:8] == matchH_addr)) begin
    matchH <= cmd[7:0];
  end
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n) begin
    matchL <= matchL_rst;
  end
  else if (cmd_rdy && (cmd[15:14] == 2'b01) && (cmd[13:8] == matchL_addr)) begin
    matchL <= cmd[7:0];
  end
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n) begin
    maskH <= maskH_rst;
  end
  else if (cmd_rdy && (cmd[15:14] == 2'b01) && (cmd[13:8] == maskH_addr)) begin
    maskH <= cmd[7:0];
  end
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n) begin
    maskL <= maskL_rst;
  end
  else if (cmd_rdy && (cmd[15:14] == 2'b01) && (cmd[13:8] == maskL_addr)) begin
    maskL <= cmd[7:0];
  end
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n) begin
    baud_cntH <= baud_cntH_rst;
  end
  else if (cmd_rdy && (cmd[15:14] == 2'b01) && (cmd[13:8] == baud_cntH_addr)) begin
    baud_cntH <= cmd[7:0];
  end
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n) begin
    baud_cntL <= baud_cntL_rst;
  end
  else if (cmd_rdy && (cmd[15:14] == 2'b01) && (cmd[13:8] == baud_cntL_addr)) begin
    baud_cntL <= cmd[7:0];
  end
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n) begin
    trig_pos[LOG2-1:8] <= trig_posH_rst[LOG2-9:0];
  end
  else if (cmd_rdy && (cmd[15:14] == 2'b01) && (cmd[13:8] == trig_posH_addr)) begin
    trig_pos[LOG2-1:8] <= cmd[LOG2-1:8];
  end
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n) begin
    trig_pos[7:0] <= trig_posL_rst;
  end
  else if (cmd_rdy && (cmd[15:14] == 2'b01) && (cmd[13:8] == trig_posL_addr)) begin
    trig_pos[7:0] <= cmd[7:0];
  end
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n) begin
    state <= IDLE;
    channel <= 0;
  end
  else begin
    state <= nxt_state;
    channel <= nxt_channel;
  end
end

always_comb begin
  resp = 0;
  send_resp = 0;
  clr_cmd_rdy = 0;
  nxt_state = IDLE;
  strt_rd = 0;
  nxt_channel = channel;
  
  case (state)

    IDLE: begin
      if (cmd_rdy && (cmd[15:14] == 2'b10)) begin
        if (cmd[2:0] <= 3'h5) begin
          nxt_state = REQDUMP;
          clr_cmd_rdy = 1;  
          strt_rd = 1;
          nxt_channel = cmd[2:0];
        end
        else begin
          send_resp = 1;
          nxt_state = NEGACK;
          resp = negAck;
        end
      end
      else if (cmd_rdy && (cmd[15:14] == 2'b01)) begin  //what should happen if you write to an invalid address
        send_resp = 1;
        nxt_state = WRITE;
        clr_cmd_rdy = 1;
        resp = (cmd[13:8] <= 6'h10) ? posAck : negAck;
      end
      else if (cmd_rdy && (cmd[15:14] == 2'b00)) begin
        send_resp = 1;
        nxt_state = READ;
        clr_cmd_rdy = 1;
        case (cmd[13:8])
          TrigCfg_addr: resp = TrigCfg;
          CH1TrigCfg_addr: resp = CH1TrigCfg;
          CH2TrigCfg_addr: resp = CH2TrigCfg;
          CH3TrigCfg_addr: resp = CH3TrigCfg;
          CH4TrigCfg_addr: resp = CH4TrigCfg;
          CH5TrigCfg_addr: resp = CH5TrigCfg;
          decimator_addr: resp = decimator;
          VIH_addr: resp = VIH;
          VIL_addr: resp = VIL;
          matchH_addr: resp = matchH;
          matchL_addr: resp = matchL;
          maskH_addr: resp = maskH;
          maskL_addr: resp = maskL;
          baud_cntH_addr: resp = baud_cntH;
          baud_cntL_addr: resp = baud_cntL;
          trig_posH_addr: resp = trig_pos[LOG2-1:8];
          trig_posL_addr: resp = trig_pos[7:0];
          default: resp = negAck;
        endcase
      end
      else if(cmd_rdy) begin
        nxt_state = NEGACK;
        resp = negAck;
        send_resp = 1;
      end
    end

    CHANDUMP: begin
      if (resp_sent) begin
        nxt_state = REQDUMP;
        strt_rd = 1;
      end
      else begin
        nxt_state = CHANDUMP;
      end
    end

    REQDUMP: begin
      if (rd_done) begin
        nxt_state = IDLE;
      end
      else begin
        send_resp = 1;
        nxt_state = CHANDUMP;
        case (channel)
          3'b000: resp = rdataCH1;
          3'b001: resp = rdataCH2;
          3'b010: resp = rdataCH3;
          3'b011: resp = rdataCH4;
          3'b100: resp = rdataCH5;
        endcase
      end
    end

    WRITE: begin
      if (resp_sent)
        nxt_state = IDLE;
      else
        nxt_state = WRITE;
    end

    READ: begin
      if (resp_sent)
        nxt_state = IDLE;
      else
        nxt_state = READ;
    end

    NEGACK: begin
      if (resp_sent)
        nxt_state = IDLE;
      else
        nxt_state = NEGACK;
    end

  endcase
end

endmodule
