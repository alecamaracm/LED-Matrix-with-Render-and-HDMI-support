module mediaDataGatherer(input clk133,
								input requestNewMedia,
								input [39:0]writeData,
								output reg [4:0]debugOut,
								
								//FLASH PINS
								output reg FLASH_CLK,		
								output reg FLASH_CS,
								input FLASH_SO,
								inout FLASH_HOLD,
								inout FLASH_SI,
								inout FLASH_WP);

						
assign FLASH_HOLD=(x4Enabled==1'b1)?1'bZ:1'b1;
assign FLASH_WP=(x4Enabled==1'b1)?1'bZ:1'b1;
assign FLASH_SI=(x4Enabled==1'b1)?1'bZ:FLASH_SI_OUT;

reg FLASH_SI_OUT=1'b0;

wire x4Enabled;
assign x4Enabled=(state==readX4_1||state==readX4_2||state==readX4_3||state==readX4_4);

reg [4:0]state=idle;

localparam idle=5'd0,
				fetchVars=5'd1,
								
				
				sendByte1=5'd2,
				sendByte2=5'd3,
				sendByte25=5'd4,
				sendByte3=5'd5,
				
				
				
				
				startReadRow=5'd6,
				readPage2=5'd7,
				readPage3=5'd8,
				readPage4=5'd9,
				readPage5=5'd10,
				
				getFeature1=5'd11,
				getFeature2=5'd12,
				getFeature3=5'd13,
				getFeature4=5'd14,
				
				
				receiveByte1=5'd15,
				receiveByte2=5'd16,
				receiveByte3=5'd17,
				
				readReadRow1=5'd18,
				readReadRow2=5'd19,
				readReadRow3=5'd20,
				readReadRow4=5'd21,
				
				readX4_1=5'd22,
				readX4_2=5'd23,
				readX4_3=5'd24,
				readX4_4=5'd25,
				
				PREfetchHeaderVars=5'd26,			
				fetchHeaderVars=5'd27;
				
				
reg [8:0]xStart=0;
reg [6:0]yStart=0;
reg [15:0]mediaID=0;
reg [4:0]headerRow;
reg [7:0]positionInRow;
reg [31:0]counter;

reg [4:0]stateAfterSendByte;
reg [4:0]stateAfterReceiveByte;
reg [7:0]byteToOutput;
reg [2:0]byteCounter;

reg [4:0]stateAfterReadRow;
reg [15:0]rowToRead;

reg [7:0]receivedByte;


initial begin
	debugOut=5'b00000;
end

wire clk1;
	
Downclocker downclocker1sec(clk133,clk1,32'd133);	


RawRowBuffer RAWrowBuffer(RAWrowBufferAddress,clk133,RAWrowBufferIN,RAWrowBufferWREN,RAWrowBufferOUT);

reg [10:0]RAWrowBufferAddress;
reg [7:0]RAWrowBufferIN;
reg RAWrowBufferWREN=1'b0;
wire [7:0]RAWrowBufferOUT;


ReceiveRowBuffer rowBuffer(rowBufferAddress,clk133,rowBufferIN,rowBufferWREN,rowBufferOUT);

reg [7:0]rowBufferAddress;
reg [15:0]rowBufferIN;
reg rowBufferWREN=1'b0;
wire [15:0]rowBufferOUT;


reg [9:0]stepDown=0;



/////////////////////////
reg [3:0]mediaType;
reg [11:0]startingFlashRow;
reg [11:0]mediaWidth;
reg [11:0]mediaHeight;
reg [15:0]frameNumber;
reg [7:0]waitTime;


/////////////////////
	
always @(posedge clk133)
begin	
	
	if(state==idle)
	begin		
		FLASH_CS<=1'b1;
		if(requestNewMedia==1'b1)
		begin
			state<=fetchVars;
		end	
	end
	
	
	if(stepDown<13)
	begin
		stepDown=stepDown+1;
	end
	else
	begin
		stepDown=0;
		case (state)
			idle:
			begin
				FLASH_CS<=1'b1;
				if(requestNewMedia==1'b1)
				begin					
					state<=fetchVars;
				end
				else
				begin
					//debugOut=5'b11111;
				end
			end
			
			fetchVars:
			begin
				xStart<=writeData[15:7];
				yStart<=writeData[6:0];
				mediaID<=writeData[31:16];
				
				headerRow<=(writeData[31:16])/249;
				positionInRow<=(writeData[31:16])%249;
				
				rowToRead<={11'd0,headerRow};
				state<=startReadRow;
				stateAfterReadRow<=PREfetchHeaderVars;				
			end
			
			PREfetchHeaderVars:
			begin
				RAWrowBufferAddress<=(positionInRow*8)+0;				
				RAWrowBufferWREN=1'b0;
				counter<=0;
				state<=fetchHeaderVars;
			end
			
			fetchHeaderVars:
			begin
				case(counter)
					0:
					begin						
						mediaType<=RAWrowBufferOUT[7:4];
					startingFlashRow[11:8]<=RAWrowBufferOUT[3:0];
					end
					1:
					begin
						startingFlashRow[7:0]<=RAWrowBufferOUT[7:0];
					end
					
					2:
					begin
						mediaWidth[11:4]<=RAWrowBufferOUT[7:0];
						debugOut<=RAWrowBufferOUT[4:0];
					end
					3:
					begin
						mediaWidth[3:0]<=RAWrowBufferOUT[7:4];
						mediaHeight[11:8]<=RAWrowBufferOUT[3:0];
					end
					4:
					begin
						mediaHeight[7:0]<=RAWrowBufferOUT[7:0];
					end
					5:
					begin
						frameNumber[15:8]<=RAWrowBufferOUT[7:0];			
					end
					6:
					begin
						frameNumber[7:0]<=RAWrowBufferOUT[7:0];	
					end
					7:
					begin
						
						waitTime[7:0]<=RAWrowBufferOUT[7:0];
						state<=idle;
					end
				endcase
				
				counter<=counter+1;
				RAWrowBufferAddress<=RAWrowBufferAddress+1;
			end
			
			
			startReadRow:
			begin
				
				state<=sendByte1;
				
				FLASH_CS<=1'b0;
				
				stateAfterSendByte<=readPage2;			
				byteToOutput<=8'h13;
				counter<=32'd0;
			end
			
			readPage2:
			begin
				state<=sendByte1;
				stateAfterSendByte<=readPage3;			
				byteToOutput<=8'h00;
				counter<=32'd0;
			end
			
			readPage3:
			begin
				state<=sendByte1;
				stateAfterSendByte<=readPage4;		 	
				byteToOutput<=rowToRead[15:8]; //Row MSB
				counter<=32'd0;
			end
			
			readPage4:
			begin
				state<=sendByte1;
				stateAfterSendByte<=readPage5;			
				byteToOutput<=rowToRead[7:0]; //Row LSB
				counter<=32'd0;
			end
			
			readPage5:
			begin
				FLASH_CS<=1'b1;
				state<=getFeature1;
			end
			
			
			
			getFeature1:
			begin
				FLASH_CS<=1'b0;
				
				state<=sendByte1;
				stateAfterSendByte<=getFeature2;					
				byteToOutput<=8'h0F;
				//byteToOutput<=8'h9F;
				counter<=32'd0;
			end
			
			getFeature2:
			begin
				FLASH_CS<=1'b0;
				
				state<=sendByte1;
				stateAfterSendByte<=getFeature3;					
				byteToOutput<=8'hA0;
				//byteToOutput<=8'h00;
				counter<=32'd0;
			end
			
			getFeature3:
			begin
				FLASH_CS<=1'b0;
				
				state<=receiveByte1;
				stateAfterReceiveByte<=getFeature4;
				counter<=32'd0;
			end
			

			
			getFeature4:
			begin
				FLASH_CS<=1'b1;	
				
				if(receivedByte[0]==1'b1) //Request still in progress
				begin					
					state<=getFeature1;					
				end
				else
				begin
					if(counter>1000)
					begin										
					state<=readReadRow1;
					counter=0;
					end 
					else
					begin
					counter=counter+1;
					end
				end
			end
			
			
			
			
			
			readReadRow1:
			begin
				FLASH_CS<=1'b0;

				state<=sendByte1;
				stateAfterSendByte<=readReadRow2;			
				byteToOutput<=8'h6B;
				
			end
			
			readReadRow2:
			begin
				state<=sendByte1;
				stateAfterSendByte<=readReadRow3;			
				byteToOutput<=8'h00;
			end
			
			readReadRow3:
			begin
				state<=sendByte1;
				stateAfterSendByte<=readReadRow4;		 	
				byteToOutput<=8'h00; 
			end
			
			readReadRow4:
			begin
				state<=sendByte1;
				stateAfterSendByte<=readX4_1;			
				byteToOutput<=8'h00; 
			end
						
			readX4_1:
			begin
				FLASH_CLK<=1'b0;	
				
				counter<=32'd0;			
				state<=readX4_2;
			end	
			
			readX4_2:
			begin				
				RAWrowBufferWREN<=1'b0;				
				RAWrowBufferIN[7]<=FLASH_HOLD;
				RAWrowBufferIN[6]<=FLASH_WP;
				RAWrowBufferIN[5]<=FLASH_SO;
				RAWrowBufferIN[4]<=FLASH_SI;
				
				FLASH_CLK<=1'b1;
				state<=readX4_3;
			end
			
			readX4_3:
			begin
				FLASH_CLK<=1'b0;
				state<=readX4_4;
			end
			
			readX4_4:
			begin				
				RAWrowBufferAddress=counter; //Blocking
										
				RAWrowBufferIN[3]<=FLASH_HOLD;
				RAWrowBufferIN[2]<=FLASH_WP;
				RAWrowBufferIN[1]<=FLASH_SO;
				RAWrowBufferIN[0]<=FLASH_SI;
				
				
				if(counter>=2000)
				begin
					FLASH_CLK=1'b0;
					RAWrowBufferWREN=1'b0; //We don´t really care if this last byte is being save, we only use up to 1998 bytes per row
					state<=stateAfterReadRow;
				end
				else
				begin
					FLASH_CLK<=1'b1;
					RAWrowBufferWREN<=1'b1;
					counter=counter+1;
					state<=readX4_2;
				end
			end
			
				
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			receiveByte1:
			begin
				FLASH_CLK<=1'b0;	
				
				byteCounter=3'b111;
				state<=receiveByte2;
			end
		
			receiveByte2:
			begin		
				receivedByte[byteCounter]=FLASH_SO; //Blocking
				FLASH_CLK=1'b1;
							
				state<=receiveByte3;			
			end			
			
			receiveByte3:
			begin					
				FLASH_CLK<=1'b0;
				
				if(byteCounter==3'b000)
				begin
					state<=stateAfterReceiveByte;
				end
				else
				begin
					state<=receiveByte2;
					byteCounter<=byteCounter-1;
				end		
			end	
			
			
			
			
			sendByte1:
			begin

				FLASH_CLK<=1'b0;	
								
				byteCounter=3'b111;
				state<=sendByte2;
			end
		
			sendByte2:
			begin		
				FLASH_SI_OUT<=byteToOutput[byteCounter];
				state<=sendByte25;			
			end
			
			sendByte25:
			begin		
				FLASH_CLK=1'b1;
											
				state<=sendByte3;			
			end
			
			sendByte3:
			begin					
				FLASH_CLK=1'b0;
				
				if(byteCounter==3'b000)
				begin
					state<=stateAfterSendByte;
				end
				else
				begin
					state<=sendByte2;
					byteCounter<=byteCounter-1;
				end		
			end	
		endcase
	end
	
	




end

								


endmodule