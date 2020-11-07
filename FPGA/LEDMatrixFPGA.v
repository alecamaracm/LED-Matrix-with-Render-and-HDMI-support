module LEDMatrixFPGA(
		output [7:0]LED,
		input [3:0]button,
		input clk50,
		output [2:0] matrixColor1,
		output [2:0] matrixColor2,
		output [4:0]matrixRow,
		output matrixClk,
		output matrixLatch,
		output matrixOE,
		output CEC,
		//SDRAM
		output [12:0] SDRAM_A,
		output [1:0] SDRAM_BA,
		inout [15:0] SDRAM_DQ,
		output SDRAM_CASn,
		output SDRAM_CKE,
		output SDRAM_CLK,
		output SDRAM_CSn,
		output SDRAM_DQMH,
		output SDRAM_DQML,
		output SDRAM_RASn,
		output SDRAM_WEn,
		//END OF SDRAM
		input A2C_DT,
		input A2C_CK,
		
		//FLASH
		output FLASH_CLK,		
		output FLASH_CS,
		inout FLASH_SO,
		inout FLASH_HOLD,
		inout FLASH_SI,
		inout FLASH_WP);
		
		
		//END OF FLASH);
		
		
wire clk1sec;
wire clk66;
wire clk133;
wire clk133_180;

Downclocker downclocker1sec(clk50,clk1sec,32'd5_000_000);

wire [4:0]stateOUT;
assign LED={1'b0,~matrixState,~writeInProgress,~requestInProgress};


//assign LED={4'b1111,~state};
//assign matrixColor1={button[0],button[0],button[0]};
//assign matrixColor1=0;

wire [4:0]currentMatrixRow; //Current row where the matrix is writing at
wire [1:0]currentMatrixPane;  //Current column where the matrix is writing at

/*wire [9215:0]matrixRowBuffer1;
assign matrixRowBuffer1={768{{4'b1111,4'b0000,4'b0000}}};*/

wire [15:0]matrixRowBuffer1;
wire [15:0]matrixRowBuffer2;


wire [4:0]matrixRow2;
//assign matrixRow=button[3:0];
//assign matrixRow={clk1sec,clk1sec,clk1sec,clk1sec,clk1sec};
wire matrixOE2;
//assign matrixOE=button[3];
//assign matrixRow=5'b00011;

reg [3:0]counter;

wire requestNewLine; //The matrix module can request a new line (The one which currentMatrixRow is outputing)
wire requestInProgress; //If SRAM interface is working on the request
reg [31:0]delayCounter=0;

//assign requestInProgress=~button[0];

reg [7:0]brightness=8'd19;

matrixPresenter matrixPresenter(clk133,matrixColor1,matrixColor2,matrixRow,matrixClk,matrixLatch,matrixOE,currentMatrixRow,currentMatrixPane, requestNewLine,requestInProgress, matrixRowBuffer1,matrixRowBuffer2,rowBuffAddrIN,CEC,button[3],stateOUT,brightness);

wire [7:0]rowBuffAddrIN;

wire CEC2;
//assign CEC=newDataReady;

Pll1 pll1(clk50,clk66 );
PLL_SRAM pllSDRAM(clk50,clk133,clk133_180);

reg requestNewWrite=0;
wire writeInProgress;
reg [39:0]writeData=32'b000_00101__00000000_0000_0001_0000_0001;

wire [4:0]matrixState;

frameBuffer frameBuffer(
		clk133,
		clk133_180,
		//SDRAM
		SDRAM_A,
		SDRAM_BA,
		SDRAM_DQ,
		SDRAM_CASn,
		SDRAM_CKE,
		SDRAM_CLK,
		SDRAM_CSn,
		SDRAM_DQMH,
		SDRAM_DQML,
		SDRAM_RASn,
		SDRAM_WEn,
		//END OF SDRAM
		
		//Output communication
		requestNewLine,
		requestInProgress,
		
		//Needed row and pane
		currentMatrixRow,
		currentMatrixPane,	
		rowBuffAddrIN,
		
		//Row output buffers
		matrixRowBuffer1,
		matrixRowBuffer2,
		
		//Writing
		requestNewWrite,
		writeInProgress,
		writeData,
		matrixState,
		
		//Media requests
		requestNewMedia,
		//FLASH PINS
		FLASH_CLK,		
		FLASH_CS,
		FLASH_SO,
		FLASH_HOLD,
		FLASH_SI,
		FLASH_WP);
		
reg up;


reg [3:0]state=4'd0;
localparam idle=4'd0,
				writeScreen1=4'd1,
				writeScreen2=4'd2,
				end1=4'd3,
				end2=4'd4,
				changeBrightness=4'd5,
				mediaRequest1=4'd6,
				mediaRequest2=5'd7,
				mediaRequest15=5'd8;

A2CHandler handler(clk133,A2C_DT,A2C_CK,newDataReady,DataWorkComplete,dataOut);
wire newDataReady;
reg DataWorkComplete;
wire [39:0]dataOut;

reg requestNewMedia;

//assign CEC=writeInProgress;

always @(posedge clk133)
begin
	case (state)
		idle:
		begin
			if(newDataReady==1'b1) 
			begin
				case (dataOut[39:36])
					4'b1001: state<=writeScreen1;				
					4'b1000: state<=changeBrightness;
					4'b1011: state<=mediaRequest1;
				default: state<=end1;
					
				endcase
			end			
		end
		
		writeScreen1:
		begin			
			writeData<=dataOut;		
			requestNewWrite<=1'b1;				
			if(writeInProgress==1'b1) state<=writeScreen2;	//Once the buffer has started saving the data, go to the next state
		end
		
		writeScreen2:
		begin
			requestNewWrite<=1'b0; //Remove the new   data flag
			if(writeInProgress==1'b0)	//Once the request has finished being written, send ACK	 	
			begin
				state<=end1;
			end
		end
		
		mediaRequest1:
		begin			
			writeData<=dataOut;		
			requestNewMedia<=1'b1;				
			state<=mediaRequest15;	//Once the buffer has started saving the data, go to the next state
		end
		
		mediaRequest15:
		begin							
			state<=mediaRequest2;	//Once the buffer has started saving the data, go to the next state
		end
		
		mediaRequest2:
		begin
			requestNewMedia<=1'b0; //Remove the new   data flag			
			state<=end1;		
		end
		
		changeBrightness:
		begin
			brightness=dataOut[7:0];
			state<=end1;
		end
		
		end1:
		begin
			DataWorkComplete<=1'b1;
			state<=end2;
		end
		
		end2:
		begin
			DataWorkComplete<=1'b0;
			state<=idle;			
		end		
	endcase
end

				
endmodule