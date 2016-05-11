module channel_sampls(input smpl_clk,
                      input clk,
                      input CH_H, CH_L,
                      output CH_Hff5, CH_Lff5,
                      output reg [7:0] smpl
                      );

reg CH_Hff[4:0];
reg CH_Lff[4:0];

assign CH_Hff5 = CH_Hff[4];
assign CH_Lff5 = CH_Lff[4];

always @(negedge smpl_clk) begin

  CH_Hff[0] <= CH_H;
  CH_Lff[0] <= CH_L;
  
  CH_Hff[1] <= CH_Hff[0];
  CH_Lff[1] <= CH_Lff[0];
  
  CH_Hff[2] <= CH_Hff[1];
  CH_Lff[2] <= CH_Lff[1];
  
  CH_Hff[3] <= CH_Hff[2];
  CH_Lff[3] <= CH_Lff[2];
  
  CH_Hff[4] <= CH_Hff[3];
  CH_Lff[4] <= CH_Lff[3];

end

always @(posedge clk) begin
  smpl <= {CH_Hff[1], CH_Lff[1], CH_Hff[2], CH_Lff[2], CH_Hff[3], CH_Lff[3], CH_Hff[4], CH_Lff[4]};
end



endmodule
