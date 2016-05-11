module channel_capture(clk, rst_n, run, start_rd, triggered, /*TrigCfg*/ capture_done_IN, read_done, capture_done, armed, wrt_smpl, trig_pos, waddr, raddr, we);

parameter ENTRIES = 384,	// defaults to 384 for simulation, use 12288 for DE-0
          LOG2 = 9;		// Log base 2 of number of entries

input clk, rst_n, wrt_smpl, run, triggered, start_rd;
input [LOG2-1:0] trig_pos;
/*input [5:0] TrigCfg;*/
input capture_done_IN;
output reg read_done, capture_done, armed, we;
output reg [LOG2-1:0] waddr, raddr;
reg [LOG2-1:0] trig_cnt, smpl_cnt, trig_cnt_nxt, smpl_cnt_nxt;

typedef enum {IDLE, WRT_SMPL, CHANDUMP, CAPT_DONE} state_t;

reg [LOG2-1:0] waddr_nxt, raddr_nxt;
reg armed_nxt;
state_t state, nxt_state;

always_ff @(posedge clk, negedge rst_n) begin
  if (!rst_n) begin
    state <= IDLE;
    trig_cnt <= 0;
    smpl_cnt <= 0;
    waddr <= 0;
    armed <= 0;
    raddr <= 0;
  end
  else begin
    state <= nxt_state;
    trig_cnt <= trig_cnt_nxt;
    smpl_cnt <= smpl_cnt_nxt;
    waddr <= waddr_nxt;
    armed <= armed_nxt;
    raddr <= raddr_nxt;
  end
end

always_comb begin
  trig_cnt_nxt = trig_cnt;
  smpl_cnt_nxt = smpl_cnt;
  read_done = 0;
  capture_done = 0;
  armed_nxt = armed;
  we = 0;
  waddr_nxt = waddr;
  raddr_nxt = raddr;
  nxt_state = IDLE;

  case (state)

    IDLE: begin
      if (run) begin
        nxt_state = WRT_SMPL;
        smpl_cnt_nxt = 0;
        trig_cnt_nxt = 0;
      end
	  else
		nxt_state = IDLE;
    end

    CHANDUMP: begin
      if (start_rd) begin
        if (raddr + 1 == waddr || (waddr == 0 && raddr == ENTRIES - 1)) begin
          read_done = 1;
          nxt_state = IDLE;
        end
        else begin
          raddr_nxt = (raddr + 1 == ENTRIES) ? 0 : raddr + 1;
          nxt_state = CHANDUMP;
        end
      end
      else begin
        nxt_state = CHANDUMP;
      end

    end
      
    WRT_SMPL: begin
      if (wrt_smpl) begin
        we = 1;
        waddr_nxt = (waddr + 1 == ENTRIES) ? 0 : waddr + 1;
        if (triggered) begin
          trig_cnt_nxt = trig_cnt + 1;
          if (trig_cnt == trig_pos) begin
            nxt_state = CAPT_DONE;
            capture_done = 1;
            armed_nxt = 0;
          end
          else begin
            nxt_state = WRT_SMPL;
          end
        end
        else begin
          nxt_state = WRT_SMPL;
          smpl_cnt_nxt = smpl_cnt + 1;
          if (smpl_cnt + 1 + trig_pos == ENTRIES) begin
            armed_nxt = 1;
          end
        end
      end
      else begin
        nxt_state = WRT_SMPL;
      end
    end

    CAPT_DONE:
      /*if (TrigCfg[5]) begin
        nxt_state = CAPT_DONE;
      end*/
	  if (start_rd) begin
        raddr_nxt = (raddr + 1 == ENTRIES) ? 0 : raddr + 1;
        nxt_state = CHANDUMP;
      end
	  else if (/*TrigCfg[5]*/ capture_done_IN) begin
        nxt_state = CAPT_DONE;
      end
      else begin
        nxt_state = IDLE;
      end

  endcase
  



end

endmodule
