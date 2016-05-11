module trigger_logic_Overall(CH1Trig, CH2Trig, CH3Trig, CH4Trig, CH5Trig, protTrig, armed, set_capture_done, rst_n, clk, triggered);

input CH1Trig, CH2Trig, CH3Trig, CH4Trig, CH5Trig, protTrig;
input armed, set_capture_done;
input clk, rst_n;
output reg triggered;

logic trig_set;
logic n1, n2, nxt_state;


always_ff @(posedge clk, negedge rst_n) begin
  if(!rst_n)
    triggered <= 0;
  else
    triggered <= nxt_state;
end

always_comb begin
  trig_set = CH1Trig & CH2Trig & CH3Trig & CH4Trig & CH5Trig & protTrig;
  n1 = armed & trig_set;
  n2 = ~(n1 | triggered);
  nxt_state = ~(n2 | set_capture_done);
end

endmodule
