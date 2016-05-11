module RAMqueue(clk,we,waddr,raddr,wdata,rdata);

  parameter ENTRIES = 384,	// defaults to 384 for simulation, use 12288 for DE-0
            LOG2 = 9;		// Log base 2 of number of entries
  
  input clk;				// clock.
  input we;					// active high write enable
  input [LOG2-1:0] waddr;	// 9 or 14 bit wide write address
  input [LOG2-1:0] raddr;	// 9 or 14 bit wide read address
  input [7:0] wdata;		// data to write
  output reg [7:0] rdata;	// data being read

  // synopsys translate_off
  reg [7:0] mem [ENTRIES-1:0];

  always @(posedge clk) begin
    if (we)
      mem[waddr] <= wdata;
    rdata <= mem[raddr];
  end
  // synopsys translate_on

endmodule
