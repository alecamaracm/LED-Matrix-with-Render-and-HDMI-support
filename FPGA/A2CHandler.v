module A2CHandler(input clk50,
						input A2C_DT,
						input A2C_CK,
						output newDataReadyOUT,
						input DataWorkComplete,
						output reg [39:0]dataOut);

						
reg lastCKstate=1'b0;


reg [39:0]internalBuffer;
reg [39:0]internalBuffer2;

reg [6:0]counter=0;
reg newDataReady=1'b0;

wire fifo_full;
wire empty;
reg rdreq=1'b0;
reg wrreq=1'b0;
wire [39:0]fifo_out;
reg [39:0]fifoIN;

FIFO_A2C a2c_fifo(
	clk50,
	fifoIN,
	rdreq,
	wrreq,
	empty,
	fifo_full,
	fifo_out);




assign newDataReadyOUT=newDataReady;

reg flag=0;
reg lastFlag=0;

reg [31:0]ACKcount=0;




always @(posedge A2C_CK2)
begin
	if(counter>=39)
	begin
		internalBuffer[counter]<=A2C_DT;
		internalBuffer2<=internalBuffer;
		flag<=~flag;
		counter<=0;
	end
	else
	begin
		internalBuffer[counter]<=A2C_DT;
		counter<=counter+1;
	end	
end

wire A2C_CK2;


PushButton_Debouncer deb(clk50,A2C_CK,A2C_CK2);


reg lastCLK=0;
reg retry=0;


reg [3:0]state=idle;
reg [3:0]state2=idle;
localparam idle=4'd0,newData=4'd1,finishNewData=4'd2;

localparam get1=4'd1,get2=4'd2,get3=4'd3,get4=4'd4,get5=4'd5;

always @(posedge clk50)
begin

	case (state)
		idle:
		begin
			if(flag!=lastFlag)
			begin
				if(fifo_full==1'b0) //If there is enough space in the buffer
				begin			
					fifoIN<=internalBuffer2;
					wrreq<=1'b1;
					state<=newData;
				end		
				lastFlag<=flag;
			end
		end
		
		newData:
		begin
			wrreq<=1'b0;
			state<=idle;
		end	
	endcase
	
	
	case(state2)
		idle:
		begin
			if(empty==1'b0)
			begin
				rdreq<=1'b1;
				state2<=get1;
			end
		end
		
		get1:
		begin
			state2<=get2;
		end
		
		get2:
		begin
			rdreq<=1'b0;
			newDataReady<=1'b1;
			dataOut<=fifo_out;
			state2<=get3;
		end
		
		get3:
		begin			
			if(DataWorkComplete==1'b1)
			begin	
				newDataReady<=1'b0;
				state2<=idle;
			end
		end
		
	endcase
	

end








endmodule






module PushButton_Debouncer(
    input clk,
    input PB,  // "PB" is the glitchy, asynchronous to clk, active low push-button signal
    output reg PB_state  // 1 as long as the push-button is active (down)  
);

// First use two flip-flops to synchronize the PB signal the "clk" clock domain
reg PB_sync_0;  always @(posedge clk) PB_sync_0 <= PB;  // invert PB to make PB_sync_0 active high
reg PB_sync_1;  always @(posedge clk) PB_sync_1 <= PB_sync_0;

// Next declare a 16-bits counter
reg [1:0] PB_cnt;

// When the push-button is pushed or released, we increment the counter
// The counter has to be maxed out before we decide that the push-button state has changed

wire PB_idle = (PB_state==PB_sync_1);
wire PB_cnt_max = &PB_cnt;	// true when all bits of PB_cnt are 1's

always @(posedge clk)
if(PB_idle)
    PB_cnt <= 0;  // nothing's going on
else
begin
    PB_cnt <= PB_cnt + 1;  // something's going on, increment the counter
    if(PB_cnt_max) PB_state <= ~PB_state;  // if the counter is maxed out, PB changed!
end

endmodule