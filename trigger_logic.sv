module trigger_logic(
	input clk, 
	input rst_n,
	input armed,
	input CHxLff5,
	input CHxHff5,
	input[4:0] CHxTrigCfg,
	
	output CHxTrig
	);
	
	reg dontCare, lowLevel, highLevel, negativeEdge, positiveEdge;
	reg negEdgeTrig, posEdgeTrig;
	
	// Positive edge
	always_ff @(posedge CHxHff5, negedge rst_n) begin
		if(!rst_n)
			positiveEdge <= 0;
		else if(!armed)
			positiveEdge <= 1;
		else
			positiveEdge <= 0;
	end
	
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			posEdgeTrig <= 0;
		else	
			posEdgeTrig <= positiveEdge;
	end
	
	// Negative edge
	always_ff @(negedge CHxLff5, negedge rst_n) begin
		if(!rst_n)
			negativeEdge <= 0;
		else if(armed)
			negativeEdge <= 1;
		else
			negativeEdge <= 0;
	end
	
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			negEdgeTrig <= 0;
		else
			negEdgeTrig <= negativeEdge;
	end
	
	// High Level
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			highLevel <= 0;
		else
			highLevel <= CHxHff5;
	end
	
	// Low Level
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			lowLevel <= 0;
		else
			lowLevel <= CHxLff5;
	end

	assign CHxTrig = CHxTrigCfg[0] || (lowLevel & CHxTrigCfg[1]) || (highLevel && CHxTrigCfg[2]) || 
					 (negEdgeTrig && CHxTrigCfg[3]) || (posEdgeTrig && CHxTrigCfg[4]);
	
endmodule