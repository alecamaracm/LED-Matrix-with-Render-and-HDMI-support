module Downclocker(input clk,
						output out_clk,
						input [31:0]maxCount);
				
reg out_clkR;	
assign out_clk=out_clkR;
	
reg [31:0]count;

always @(posedge clk)
begin
	if(count>maxCount)
	begin
		count=32'd0;
		out_clkR=~out_clkR;
	end
	else
	begin
		count=count+32'd1;
	end
end				
			
						
endmodule