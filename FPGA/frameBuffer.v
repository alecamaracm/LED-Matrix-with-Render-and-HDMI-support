module frameBuffer(
		input clk133,
		input clk133_180,
		output reg [12:0] SDRAM_A,
		output reg [1:0] SDRAM_BA,
		inout [15:0] SDRAM_DQ,
		output reg SDRAM_CASn,
		output SDRAM_CKE,
		output SDRAM_CLK,
		output SDRAM_CSn,
		output SDRAM_DQMH,
		output SDRAM_DQML,
		output reg SDRAM_RASn,
		output reg SDRAM_WEn,
		
				
		//Output communication
		input requestNewLine,
		output reg ReadRequestInProgress,
		
		input [4:0]currentMatrixRow,
		input [1:0]currentMatrixPane,	
		input [7:0]rowBuffAddrIN,
		
		//Row output buffers
		output [15:0]matrixRowBuffer1,
		output [15:0]matrixRowBuffer2,
		
		
		//WRITING
		input requestNewWrite,
		output reg writeInProgress,
		input [39:0]writeData,
		output [4:0]debugg,
		
		//Media requests
		input requestNewMedia,
		//FLASH PINS
		output FLASH_CLK,		
		output FLASH_CS,
		inout FLASH_SO,
		inout FLASH_HOLD,
		inout FLASH_SI,
		inout FLASH_WP);



//assign matrixRowBuffer1={256{9'b100010001}};
//assign matrixRowBuffer2={256{9'b000101001}};

		
//assign SDRAM_DQMH=(state==writingWHOLEROWWRITEALL || state==writingWHOLEROWWRITE ||state==readingRow)?1'b0:1'b1;
//assign SDRAM_DQML=(state==writingSingleEnd)?1'b1:1'b0;
//assign SDRAM_DQMH=(state==writingSingleEnd)?1'b1:1'b0;


assign SDRAM_DQML=1'b0;
assign SDRAM_DQMH=1'b0;


assign SDRAM_CSn=CS;
assign SDRAM_CKE=1'b1;
assign SDRAM_CLK=clk133_180; //180º after our clock

assign SDRAM_DQ=(state==writingCHOOSE || state==writingWHOLEROWACTIVE || state==writingWHOLEROWWRITE|| state==writingWHOLEROWWRITEALL || state==writingWHOLEROWEnd || state==writingWHOLEROWPrecharge ||
						state==writingSingleWRITE || state==writingSingleEnd || state==writingSinglePrecharge)?dataToOutput:16'bZZZZZZZZZZZZZZZZ;
reg [15:0]dataToOutput;
		

assign debugg=debugMediaOut;
wire [4:0]debugMediaOut;

MATRIX_ROW_BUFFER rowBuffer1(rowBuff1Addr,clk133,rowBuff1DataIn,rowBuff1Wren,rowBuff1DataOut);
MATRIX_ROW_BUFFER_2 rowBuffer2(rowBuff1Addr,clk133,rowBuff1DataIn,rowBuff2Wren,rowBuff2DataOut);

mediaDataGatherer flashGatherer(clk133,
								requestNewMedia,
								writeData,
								debugMediaOut,
								
								//FLASH PINS
								FLASH_CLK,		
								FLASH_CS,
								FLASH_SO,
								FLASH_HOLD,
								FLASH_SI,
								FLASH_WP);


reg [7:0]rowBuff1AddrREG;
wire [7:0]rowBuff1Addr=(state==readingRow || state==readingEnd)?rowBuff1AddrREG:rowBuffAddrIN;

assign matrixRowBuffer1=rowBuff1DataOut;
assign matrixRowBuffer2=rowBuff2DataOut;
//assign matrixRowBuffer2=rowBuff2DataOut;
//assign matrixRowBuffer1=16'b1000100011100110;
//assign matrixRowBuffer2=16'b1000100011100110;

reg [15:0]rowBuff1DataIn;

wire rowBuff1Wren;
assign rowBuff1Wren=(state==readingRow && readingSecondHalf==1'b0);
wire rowBuff2Wren;
assign rowBuff2Wren=(state==readingRow && readingSecondHalf==1'b1);


wire [15:0]rowBuff1DataOut;
wire [15:0]rowBuff2DataOut;


reg readingSecondHalf=0;

reg [15:0]tempRead;


reg [4:0]state=reset;

reg CS=1'b1;

reg [15:0]timeToWait=0;
reg [15:0]waitCount=0;

reg [11:0]rowReaderCount=12'd0;

reg [7:0]counter;

reg [4:0]stateAfterWait=reset;


reg readingFirstPassDone;

localparam  reset=5'd0,
				initializePRECHARGE=5'd1,
				
				waiter=5'd2,
				
				initializeAUTOREFRESH1=5'd3,
				initializeAUTOREFRESH2=5'd4,				
				initializeREGISTER=5'd5,
				
				idle=5'd6,
				readingStart=5'd7,
				readingStartRead=5'd8,
				readingRow=5'd9,
				readingEnd=5'd10,
				readingPrecharge=5'd11,
				readingDispose=5'd12,
				
				writingCHOOSE=5'd13,	
				
				writingWHOLEROWACTIVE=5'd14,				
				writingWHOLEROWWRITE=5'd15,
				writingWHOLEROWWRITEALL=5'd16,
				writingWHOLEROWEnd=5'd17,
				writingWHOLEROWPrecharge=5'd18,
				
				
				writingSingleACTIVE=5'd19,
				writingSingleWRITE=5'd20,
				writingSingleEnd=5'd21,
				writingSinglePrecharge=5'd22,
				
			
				writingSingleStartRead=5'd23,
				writingSingleReading=5'd24,
				writingSingleReadingEnd=5'd25,
							
				writingDispose=5'd26,
				
				STUCK=5'd31;

//CS,RAS,CAS,WE states: ({SDRAM_RASn,SDRAM_CASn,SDRAM_WEn})
localparam req_NOP=3'b111,
				req_ACT=3'b011,
				req_READ=3'b101,
				req_WRITE=3'b100,
				req_TERMINATE=3'b110,
				req_PRECHARGE=3'b010,
				req_REFRESH=3'b001,
				req_REGISTER=3'b000;
				
				

		
always @(posedge clk133)
begin
		
	case (state)
		
		reset:
		begin
			CS<=1'b1; //DISABLED, give enough time to start up (Min. 100us)
			ReadRequestInProgress<=1'b0;
			writeInProgress<=1'b0;
			
			timeToWait<=16'd50000;
			stateAfterWait<=initializePRECHARGE;	
			state<=waiter;		
		end
		
		initializePRECHARGE:
		begin	
			CS<=1'b0; //COMMAND INPUT ENABLED
			SDRAM_A[10]<=1'b1; //All banks to be precharged
			{SDRAM_RASn,SDRAM_CASn,SDRAM_WEn}<=req_PRECHARGE;
			
			timeToWait<=16'd3;  //2 cycles should in theory be enough
			stateAfterWait<=initializeAUTOREFRESH1;	
			state<=waiter;
		end
		
		initializeAUTOREFRESH1:
		begin
			CS<=1'b0; //COMMAND INPUT ENABLED		
			{SDRAM_RASn,SDRAM_CASn,SDRAM_WEn}<=req_REFRESH;
			
			timeToWait<=16'd9;
			stateAfterWait<=initializeAUTOREFRESH2;	
			state<=waiter;
		end
		
		initializeAUTOREFRESH2:
		begin
			CS<=1'b0; //COMMAND INPUT ENABLED
			{SDRAM_RASn,SDRAM_CASn,SDRAM_WEn}<=req_REFRESH;
			
			timeToWait<=16'd9;
			stateAfterWait<=initializeREGISTER;	
			state<=waiter;
		end
		
		initializeREGISTER:
		begin
			CS<=1'b0; //COMMAND INPUT ENABLED
			{SDRAM_RASn,SDRAM_CASn,SDRAM_WEn}<=req_REGISTER;
			SDRAM_A[11:10]<=2'b00; //Reserved, but must be 00
			SDRAM_A[9]<=1'b0; //BURST mode (0:Burst, 1:Single)
			SDRAM_A[8:7]<=2'b00; //00 --> Standard operation
			SDRAM_A[6:4]<=3'b010; //CAS latency (010: 2 cycles, 011: 3 cycles)
			SDRAM_A[3]<=1'b0; //Burst type (0: Sequential, 1: Interleaved)
			SDRAM_A[2:0]<=3'b111; //Burst length (111: Full page)
			
			timeToWait<=16'd3;  //2 cycles should be enough
			stateAfterWait<=idle;	
			state<=waiter;		
		end
		
		
		
		idle:
		begin
			CS<=1'b1; //DISABLED
			
	
			
			//See if a new row is needed by the matrix (More priority than writing to the buffer)
			if(requestNewLine==1'b1)
			begin
				ReadRequestInProgress<=1'b1;
				readingFirstPassDone<=1'b0;
				readingSecondHalf<=1'b0;
				rowReaderCount<=12'd0;
				writeInProgress<=1'b0;
				state<=readingStart;
				waitCount<=0;
			end
			else if(requestNewWrite==1'b1)
			begin
				state<=writingCHOOSE;
				waitCount<=0;
			end
		end
		
		readingStart:
		begin		//Activate row in needed bank (pane)			
			CS<=1'b0; //COMMAND INPUT ENABLED
			{SDRAM_RASn,SDRAM_CASn,SDRAM_WEn}<=req_ACT;
			SDRAM_A[12:7]<=6'd0;
		
			SDRAM_A[6:0]<={readingFirstPassDone,readingSecondHalf,currentMatrixRow};
			
			
			SDRAM_BA<=currentMatrixPane;
			
			timeToWait<=16'd3;  //2 cycles should be enough
			stateAfterWait<=readingStartRead;	
			state<=waiter;
		end
		
		readingStartRead:
		begin
			CS=1'b0; //COMMAND INPUT ENABLED
			{SDRAM_RASn,SDRAM_CASn,SDRAM_WEn}<=req_READ;
			SDRAM_A[7:0]<=8'd0; //Starting column
			SDRAM_A[10]<=1'b1; //Auto precharge enabled (1:Close after read, 0:Keep opened)
			SDRAM_BA<=currentMatrixPane;
			
			
			
			timeToWait<=16'd2;  //Wait 2 cycles here, as we have a CAS of 2
			stateAfterWait<=readingRow;	
			state<=waiter;
		end
		
		readingRow:
		begin			
			rowBuff1DataIn<=SDRAM_DQ;
			rowBuff1AddrREG<=rowReaderCount;
			
			if((readingFirstPassDone==1'b0 && rowReaderCount>=12'd96)||(readingFirstPassDone==1'b1 && rowReaderCount>=12'd192))
			begin
				state<=readingEnd;
			end
			else
			begin
				rowReaderCount<=rowReaderCount+8'd1;
			end
		end
		
		readingEnd:
		begin
			CS<=1'b0; //COMMAND INPUT ENABLED
			{SDRAM_RASn,SDRAM_CASn,SDRAM_WEn}<=req_TERMINATE;
									
			timeToWait<=16'd5;  //Wait 2 cycles here, as we have a CAS of 2 (To wait until all the data has been outputed)
			stateAfterWait<=readingPrecharge;	
			state<=waiter;
			
	
		end
		
		readingPrecharge:
		begin
			CS<=1'b0; //COMMAND INPUT ENABLED
			SDRAM_A[10]<=1'b1; //All banks to be precharged
			{SDRAM_RASn,SDRAM_CASn,SDRAM_WEn}<=req_PRECHARGE;
			
			timeToWait<=16'd15;  //2 cycles should in theory be enough
			stateAfterWait<=readingDispose;	
			state<=waiter;			
		end
		
		readingDispose:
		begin
			if(readingFirstPassDone==1'b0) //Now we are going to do the second row
			begin
				readingFirstPassDone<=1'b1;
				state<=readingStart;
			end
			else
			begin  //We are finished
				if(readingSecondHalf==1'b0)
				begin
					rowReaderCount<=12'd0;
					readingFirstPassDone<=1'b0;
					readingSecondHalf<=1'b1;
					state<=readingStart;
				end
				else
				begin
					ReadRequestInProgress<=1'b0;
					state<=idle;
				end
			end
	
		end
		
		
			
		
		waiter:
		begin
			CS<=1'b1; //DISABLED
			
			if(waitCount>=(timeToWait-1))
			begin
				state<=stateAfterWait;
				waitCount<=16'd0; //Counter is ready for the next time it is used
			end
			else waitCount<=waitCount+16'd1;
		end
		
		//////////////////////////////////////////
		

		writingCHOOSE:
		begin
			if(writeData[35:32]==4'b1111)  //Whole row mode
			begin //Write the whole row to sth
				state<=writingWHOLEROWACTIVE;
				//state<=STUCK;
				counter=0;
				writeInProgress<=1'b1;
			end
			else if(writeData[35:32]==4'b1001)  //Whole row mode
			begin //Write the whole row to sth
				state<=writingSingleACTIVE;
				//state<=STUCK;
				counter=0;
				writeInProgress<=1'b1;
			end
			else
			begin
				stateAfterWait<=writingDispose;
				timeToWait<=16'd15;  //2 cycles should in theory be enough
				state<=waiter;
			end
		end
		
		
		writingWHOLEROWACTIVE:   //[17:12] --> Row
		begin			
			CS<=1'b0; //COMMAND INPUT ENABLED
			{SDRAM_RASn,SDRAM_CASn,SDRAM_WEn}<=req_ACT;
			SDRAM_A[12:8]<=8'd0;
			
			//SDRAM_A[7:0]=0;
			SDRAM_A[7:0]<=writeData[31:24];
			SDRAM_BA<=counter; //Counter is the current bank
			
			timeToWait<=16'd3;  //2 cycles should be enough
			stateAfterWait<=writingWHOLEROWWRITE;	
			state<=waiter;
		end
		
		writingWHOLEROWWRITE:
		begin
			CS<=1'b0; //COMMAND INPUT ENABLED
			{SDRAM_RASn,SDRAM_CASn,SDRAM_WEn}<=req_WRITE;
			SDRAM_A[7:0]<=8'd0; //Starting columnz
			SDRAM_A[10]<=1'b1; //Auto precharge enabled (1:Close after read, 0:Keep opened)
			SDRAM_BA<=counter;
			
			rowReaderCount<=12'd1;	
			dataToOutput<={{4{writeData[8+counter],writeData[4+counter],writeData[0+counter]}},4'b0000};
			
			state<=writingWHOLEROWWRITEALL;
		end
		
		writingWHOLEROWWRITEALL:
		begin
			CS<=1'b1;  //COMMAND INPUT DISBALED, we are writing in burst
			
			dataToOutput<={{4{writeData[8+counter],writeData[4+counter],writeData[0+counter]}},4'b0000};	
			//dataToOutput[15]=(rowReaderCount[1]==1'b1 );
			
			if(rowReaderCount>=12'd95)
			begin
				state<=writingWHOLEROWEnd;
			end
			else
			begin
				rowReaderCount<=rowReaderCount+8'd1;
			end
		end
		
		writingWHOLEROWEnd:
		begin
			CS<=1'b0; //COMMAND INPUT ENABLED
			{SDRAM_RASn,SDRAM_CASn,SDRAM_WEn}<=req_TERMINATE;
									
			timeToWait<=16'd5;  //Wait 2 cycles here, as we have a CAS of 2 (To wait until all the data has been outputed)
			state<=waiter;	
			stateAfterWait<=writingWHOLEROWPrecharge;	
		end
		
		
		writingWHOLEROWPrecharge:
		begin
			CS<=1'b0; //COMMAND INPUT ENABLED
			SDRAM_A[10]<=1'b1; //All banks to be precharged
			{SDRAM_RASn,SDRAM_CASn,SDRAM_WEn}<=req_PRECHARGE;
			
			if(counter>=3)
			begin
				stateAfterWait<=writingDispose;
			end
			else
			begin
				counter<=counter+1;
				stateAfterWait<=writingWHOLEROWACTIVE;
			end
			
			timeToWait<=16'd15;  //2 cycles should in theory be enough
			state<=waiter;
		end
		
		
		
		
		
		
		
		writingSingleACTIVE:   //[17:12] --> Row
		begin			
			CS<=1'b0; //COMMAND INPUT ENABLED
			{SDRAM_RASn,SDRAM_CASn,SDRAM_WEn}<=req_ACT;
			SDRAM_A[12:8]<=8'd0;
			
			//SDRAM_A[7:0]=0;
			SDRAM_A[7:0]<=writeData[31:24];
			SDRAM_BA<=counter; //Counter is the current bank
			
			timeToWait<=16'd3;  //2 cycles should be enough
			stateAfterWait<=writingSingleStartRead;	
			state<=waiter;
		end
		
		writingSingleStartRead:
		begin
			CS=1'b0; //COMMAND INPUT ENABLED
			{SDRAM_RASn,SDRAM_CASn,SDRAM_WEn}<=req_READ;
			SDRAM_A[7:0]<={1'b0,writeData[23:17]}; //Starting column
			SDRAM_A[10]<=1'b1; //Auto precharge enabled (1:Close after read, 0:Keep opened)
			SDRAM_BA<=counter;		
			
			
			timeToWait<=16'd2;  //Wait 2 cycles here, as we have a CAS of 2
			stateAfterWait<=writingSingleReading;	
			state<=waiter;
		end
		
		writingSingleReading:
		begin			
			tempRead<=SDRAM_DQ;	
			state<=writingSingleReadingEnd;
		end
		
		writingSingleReadingEnd:
		begin
			CS<=1'b0; //COMMAND INPUT ENABLED
			{SDRAM_RASn,SDRAM_CASn,SDRAM_WEn}<=req_TERMINATE;
				
			case(writeData[16:15])
				2'b00:
				begin
					tempRead[15]<=writeData[8+counter];
					tempRead[14]<=writeData[4+counter];
					tempRead[13]<=writeData[0+counter];
				end
				2'b01:
				begin
					tempRead[12]<=writeData[8+counter];
					tempRead[11]<=writeData[4+counter];
					tempRead[10]<=writeData[0+counter];
				end
				2'b10:
				begin
					tempRead[9]<=writeData[8+counter];
					tempRead[8]<=writeData[4+counter];
					tempRead[7]<=writeData[0+counter];
				end
				2'b11:
				begin
					tempRead[6]<=writeData[8+counter];
					tempRead[5]<=writeData[4+counter];
					tempRead[4]<=writeData[0+counter];
				end
			endcase 
			
			
			timeToWait<=16'd5;  //Wait 2 cycles here, as we have a CAS of 2 (To wait until all the data has been outputed)
			state<=waiter;	
			stateAfterWait<=writingSingleWRITE;	
		end
		
		writingSingleWRITE:
		begin
			CS<=1'b0; //COMMAND INPUT ENABLED
			{SDRAM_RASn,SDRAM_CASn,SDRAM_WEn}<=req_WRITE;
			SDRAM_A[7:0]<={1'b0,writeData[23:17]}; //Starting columnz
			SDRAM_A[10]<=1'b1; //Auto precharge enabled (1:Close after read, 0:Keep opened)
			SDRAM_BA<=counter;
			
			dataToOutput<=tempRead;
			
			state<=writingSingleEnd;
		end
		
		writingSingleEnd:
		begin
			CS<=1'b0; //COMMAND INPUT ENABLED
			{SDRAM_RASn,SDRAM_CASn,SDRAM_WEn}<=req_TERMINATE;
									
			timeToWait<=16'd5;  //Wait 2 cycles here, as we have a CAS of 2 (To wait until all the data has been outputed)
			state<=waiter;	
			stateAfterWait<=writingSinglePrecharge;	
		end
		
		
		writingSinglePrecharge:
		begin
			CS<=1'b0; //COMMAND INPUT ENABLED
			SDRAM_A[10]<=1'b1; //All banks to be precharged
			{SDRAM_RASn,SDRAM_CASn,SDRAM_WEn}<=req_PRECHARGE;
			
			
			if(counter<3)
			begin
				counter<=counter+1;
				stateAfterWait<=writingSingleACTIVE;
				timeToWait<=16'd15;  //2 cycles should in theory be enough
				state<=waiter;
			end
			else
			begin
				stateAfterWait<=writingDispose;
				timeToWait<=16'd15;  //2 cycles should in theory be enough
				state<=waiter;
			end
			
			
		end
		
		
		
		
		
		
		
		
		
		
		
		
		
		writingDispose:
		begin
			writeInProgress<=1'b0;
			state<=idle;
		end
		
		STUCK:
		begin
			state<=STUCK;
		end
	
	endcase
end


		
		

endmodule