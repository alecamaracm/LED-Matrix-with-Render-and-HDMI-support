module matrixPresenter(input clk66,
		output reg [2:0] matrixColor1,
		output reg[2:0] matrixColor2,
		output reg[4:0]matrixRow,
		output reg matrixClk,
		output reg matrixLatch,
		output OE,
		output [4:0] currentRow,  //Physical row (The one sent to the matrix)
		output [1:0] currentPaneOUT,
		output reg requestNewLine,
		input requestInProgress,
		input [15:0]colorData1,
		input [15:0]colorData2,
		output [7:0]currentRowBufferAddress,
		output reg debugOut,
		input test,
		output [4:0]stateOUT,
		input [7:0]brightness);  //Color data of the current pixel. Whithin the same row, if currentColumn is changed, this value should be available in the next clock cycle
		  
		  
		 
wire clkDown;

assign OE=~(~matrixOE && dutyCycleCounter<brightness && paneEnabled);

reg paneEnabled;

reg rightDutyCycle;

reg matrixOE;
Downclocker downclocker1sec(clk50,clkDown,32'd50);


assign currentRowBufferAddress=countColumn/4;

/*reg [2:0]matrixColor1;
reg [2:0]matrixColor2;*/

assign stateOUT=currentPaneDelay;
assign currentPaneOUT=currentPane;


reg [4:0]countRow;
reg [9:0]countColumn;

reg [4:0]state;
localparam reset=5'd0,writeRow=5'd1,waiting=5'd2,st1=5'd3,st2=5'd4,st3=5'd5,st4=5'd6,st5=5'd7,st32=5'd8,requestRow=5'd9,waitingForRow=5'd10;

reg [5:0]latchCount;


reg [1:0]currentPane=0;

reg [15:0]currentPaneDelay=0;
localparam basePaneTime=((maxColumns*2)+3)+300;

localparam maxColumns=128*6;
localparam maxRows=32;

reg [3:0]writeState;
localparam write0=4'd0,write1=4'd1;

assign currentRow=countRow;


reg [1:0]displayingPane=0;

reg[7:0]dutyCycleCounter=0;

reg clkCycle=0;

always @(posedge clk66)
begin	
	dutyCycleCounter<=dutyCycleCounter+8'd1;
	
	case (displayingPane)
		2'b00:
		begin
			paneEnabled<=dutyCycleCounter[0]==1'b1;
		end
		default:
			paneEnabled<=1'b1;
	
	endcase
	
end

always @(posedge clk66)
begin

	if(clkCycle==1'b0)
	begin
		debugOut=(currentPane==0);
		case (state)
		
			reset:
			begin
				state<=writeRow;
				countRow<=5'd0;
				countColumn<=5'd0;
				matrixOE<=1'b1; //Matrix off			
			end
			
			writeRow:
			begin	
					
					case (writeState)
					
						write0:
						begin				
												
								matrixColor1[0]<=colorData1[15-(countColumn%4)*3];
								matrixColor1[1]<=colorData1[14-(countColumn%4)*3];
								matrixColor1[2]<=colorData1[13-(countColumn%4)*3];		
							
								matrixColor2[0]<=colorData2[15-(countColumn%4)*3];
								matrixColor2[1]<=colorData2[14-(countColumn%4)*3];
								matrixColor2[2]<=colorData2[13-(countColumn%4)*3];

							/*		matrixColor1<=0;
								matrixColor2<=0;*/
							
							writeState<=write1;
							
							matrixClk<=1'b1;
						end	
						write1:
						begin
							matrixClk<=1'b0;
							writeState<=write0;
							
							if(countColumn>=(maxColumns-1))
							begin							
								state<=st1;
							end
							else
							begin
								countColumn<=countColumn+10'd1;	
							end
						end					
					endcase
			end
			

			
			st1:
			begin			
				matrixOE<=1'b1; //Disable matrix
				
				state<=st2;
			end	
		
			st2:
			begin			
				matrixLatch<=1;
				matrixRow<=countRow;	
				state<=st3;
			end	
			
			st3:
			begin			
				matrixOE<=1'b1; //Disable matrix
				
				state<=st4;
			end	
			
			st4:
			begin			
				matrixOE<=1'b1; //Disable matrix
				
				state<=st5;
			end	
			
			st5:
			begin			
				matrixLatch<=0;
				matrixOE<=1'b0;
				state<=waiting;
				displayingPane<=currentPane;
				currentPaneDelay<=32'd0;
			end
			
			
			waiting:
			begin				
				//debugOut=!debugOut;
				
					
				if(currentPaneDelay<100+(basePaneTime*((2**currentPane)-1)))
				begin
					currentPaneDelay<=currentPaneDelay+32'd1;
				end	
				else
				begin
					
					if(countRow>=(maxRows-1))
					begin //All the rows have been shown, time to change the pane

						if(currentPane<3) //3 means 4 panes
						begin
							currentPane<=currentPane+1;
						end
						else
						begin
							currentPane<=0;
						end
						
						countRow<=5'd0;
					end
					else
					begin
						countRow<=countRow+5'd1;				
					end
					
					state<=requestRow;
					countColumn<=5'd0;
				end		
			end
			
			requestRow:
			begin
				requestNewLine=1'b1;
				if(requestInProgress==1'b1) //The SRAM module is working on the request
				begin
					state<=waitingForRow;
				end
				else
				begin
					state<=requestRow; //Stay in the same state
				end		
			end
			
			waitingForRow:
			begin
				requestNewLine=1'b0;
				if(requestInProgress==1'b0) //The SRAM module has finished the request
				begin
					state<=writeRow;
				end
				else
				begin
					state<=waitingForRow; //Stay in the same state
				end
			end
			
		
		endcase
		clkCycle<=1'b1;
	end
	else
	begin
		clkCycle<=1'b0;
	end
	



end

		
		
		
endmodule