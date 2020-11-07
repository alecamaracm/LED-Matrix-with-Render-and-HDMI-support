// 
// 
// 

#include "SerialProtocol.h"
#include "PIN_DEFINITIONS.h"

#define SERIAL_SPEED 1000000
#define MAX_BUFFER_SIZE (PACKET_RECONGINITION_SIZE-1)*256



enum status { WaitingForPacketStart, ReceivingHeader,ReiceivingData };
enum status currentStatus = WaitingForPacketStart;




//Start of a new packet
#define PACKET_RECONGINITION_SIZE 9 //Number of bytes that will make the start of a new packet recongizable x/(a+x+(x/a)) is the transmission efficiency

		//A beginning Packet is made of # number of bytes that are know (Consecutive, from 69 inc, and UP) and whose FIRST BIT IS ALWAYS 0 (Therefore, max 127). 
		//				This way, the extra packet sent between # data packets will ALWAYS start with a 1 and therefore, it will be impossible for any data packet to be recognized as a beginning packet.

byte currentPacketRecognitionPosition;

//End of start packet





//Current header
		//HEADER STRUCTURE
		//Byte 0 (FIRST)-->			[7:0]MSG_SIZE (In number of checksum msg)        
		//Byte 1 -->				[7:0]:MSG_ID 2 MSB
		//Byte 2 -->				[7:0]:MSG_ID 1
		//Byte 3 -->				[7:0]:MSG_ID 0 
		//Byte 4 (LAST TO SEND)-->	[7:0]:MSG_Type 0


byte headerBytesReceived = 0;
byte header[5];

byte msgSize;
int msgID;
byte msgType;

//End of current header




//Current data //Data currently incoming

int currentPacket = 0; //Data byte counter, includes the checksums
int currentIndex = 0; //Data byte counter, the current index int the array,withouth checksums
byte currentData[MAX_BUFFER_SIZE];
bool dataPacketFinished;  //Weather the packet has been fully received

//End of current data


char * packetExitReason; //Why or the result of the receiving
char packetResult[150]; //Final string to log

byte currentChecksumCount = 0;

bool checkPossiblePacketStart(byte lastByte);
void byteGathered(byte lastByte);
bool validateAndProcessHeader(byte lastByte);
bool receiveDataPacket(byte lastByte);

void (*callback)(byte,byte *,int);

void setUpSerialProtocol(void _callback(byte, byte *, int))
{
	callback = _callback;
	Serial2.begin(SERIAL_SPEED, SERIAL_8N1, SERIAL2_RX, SERIAL2_TX);
}

void doWork(int timeoutUS)
{
	int startTime = micros();
	while (Serial2.available() > 0 && micros()-startTime<timeoutUS) //Data still available and max time not exceeded
	{
	//	Serial.println("New byte detected!");
		byteGathered(Serial2.read());
	}

}

void byteGathered(byte lastByte)
{	
	if (checkPossiblePacketStart(lastByte)) //If true, new packet beggining has been detected
	{
		currentStatus = ReceivingHeader;
		//Serial.println("New packet start detected!");			
	}
	else
	{
		switch (currentStatus)
		{
		case ReceivingHeader:

			if (headerBytesReceived<6 && validateAndProcessHeader(lastByte))
			{ //Header seems fine, start receiving data

				if (headerBytesReceived >= 4) //Header transmission just finished
				{
					currentPacket = 0;
					currentChecksumCount = 0;
					currentIndex = 0;
					currentPacket = 0;
					currentStatus = ReiceivingData;
				//	Serial.println("Got header!");
				}
				else
				{
					headerBytesReceived++;
				}
			}
			else
			{ //Wrong header, wait for a new packet
				currentStatus = WaitingForPacketStart;
			}	

			break;
		case ReiceivingData:
			if (receiveDataPacket(lastByte)) //Data packet received successfully
			{
				if(dataPacketFinished)
				{
					//Serial.println("Packet received successfully!");
					sprintf(packetResult, "[%ld] [ID=%d, Type=%d, Size=%d] Success!", millis(), msgID, msgType, msgSize, packetExitReason);
					/*for (int i = 0; i < currentIndex; i++)
					{
						Serial.println(currentData[i]);
					}*/
					Serial.println(packetResult);
					callback(msgType,currentData,currentIndex);
					currentStatus = WaitingForPacketStart;
				}
			}
			else //Failed to receive the data packet
			{
				sprintf(packetResult, "[%ld] [ID=%d, Type=%d, Size=%d] Error: %s", millis(), msgID, msgType, msgSize, packetExitReason);
				Serial.println(packetResult);
				currentStatus = WaitingForPacketStart;
			}
			break;
		}
	
	}
	
}

bool checkPossiblePacketStart(byte lastByte)
{
	//A recognition byte always starts with a 0, and they increase by 1 each time
	if ((lastByte == (69 + currentPacketRecognitionPosition) & B01111111) && (lastByte & B10000000)==0) //The current byte is valid
	{		
		if (currentPacketRecognitionPosition == PACKET_RECONGINITION_SIZE - 1)
		{
			currentPacketRecognitionPosition = 0;
			headerBytesReceived = 0;
			currentPacket = 0;
			currentIndex = 0;
			dataPacketFinished = false;
			packetExitReason = "None";
			//Serial.println("valid1");
			return true;
		}
		else
		{
			//Serial.println("valid0");
			currentPacketRecognitionPosition++;
			return false;
		}
	}
	else //Invalid byte
	{	
		//Serial.println("invalid");
		currentPacketRecognitionPosition = 0;
		return false;
	}
}

bool receiveDataPacket(byte lastByte)
{
	if (currentIndex >= MAX_BUFFER_SIZE)   //Checking the current buffer index
	{
		packetExitReason="Exceded maximum PROTOCOL packet size!";
		return false;
	}

	if (currentPacket >= msgSize*(PACKET_RECONGINITION_SIZE))  //Checking the total packet count, including checksum
	{
		packetExitReason = "Exceded maximum PACKET DEFINED packet size!";
		return false;
	}

	

	if (currentPacket % PACKET_RECONGINITION_SIZE == (PACKET_RECONGINITION_SIZE-1)) //We are in a checksum packet
	{

		if (lastByte & B01000000) //Checking for the end of packet bit
		{
			if (msgSize * PACKET_RECONGINITION_SIZE != currentPacket + 1)
			{
				packetExitReason = "Final checksum arrived but length does not match the header one!";
				currentChecksumCount = 0;
				return false;
			}
			dataPacketFinished = true;
		}

		if (lastByte & B10000000==0) //Checking for the end of packet bit
		{
			packetExitReason = "First bit of a checksum packet was zero!";
			currentChecksumCount = 0;
			return false;			
		}

			   		
		byte remoteChecksum = lastByte & B00111111; //We only want the bits [5:0], the checksum

		if (remoteChecksum != (currentChecksumCount & B00111111))
		{ //Not equal, error out
			packetExitReason = "Checksum mismatch!";
		//	Serial.println(currentChecksumCount & B00111111);
		//	Serial.println(remoteChecksum);
			currentChecksumCount = 0;
			return false;
		}

		currentChecksumCount = 0;

	//	Serial.println("checksum packet");
	}
	else
	{
		currentChecksumCount += lastByte;
		currentData[currentIndex]=lastByte;
		currentIndex++;
	//	Serial.println(lastByte);
	}

	currentPacket++;
	return true;
}

bool validateAndProcessHeader(byte lastByte) //Header contents in header0 and header1
{
	header[headerBytesReceived] = lastByte;
	if (headerBytesReceived == 0) //First byte
	{
		msgSize = lastByte;
	}
	else if (headerBytesReceived == 3) //Last byte of the ID
	{
		msgID = header[1] << 16;
		msgID += header[2] << 8;
		msgID += header[3];
	}
	else if (headerBytesReceived == 4) //Last byte (type)
	{
		msgType = lastByte;
	}
	return true;
}