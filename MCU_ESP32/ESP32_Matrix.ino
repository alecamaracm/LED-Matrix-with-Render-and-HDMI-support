
#include "SerialProtocol.h"
#include "PIN_DEFINITIONS.h"
#include "IOFunctions.h"
#include "MatrixFunctions.h"
#include "Arduino.h"
#include "FlashFunctions.h"

byte flashBuffer[2112];
byte flashBuffer2[2112];

void serialCallback(byte type, byte* data, int dataLength);

// the setup function runs once when you press reset or power the board
void setup() {
	setUpIO();
	Serial.begin(1000000);

	setFlashPinsForSingle();
	
	resetFlash();
	unlockCells();

	deselectFlash();

	

	setUpSerialProtocol(serialCallback);
	fillWithColor(0, 0, 0);
}





// the loop function runs over and over again until power down or reset
void loop() {

	//Serial.println("Looping!");

	doWork(100000);
	

	/*bool flashWorks = testFlash();
	if (flashWorks)
	{
		Serial.println("Flash works!");
	}
	else
	{
		Serial.println("Flash is not working!");
	}*/


	while (Serial.available() > 0) {
		Serial.read();
		
		
		resetFlash();
		unlockCells();
		selectFlash();

		for (int i = 0; i < 1998; i++)
		{
			flashBuffer[i] = (byte)i;
		}

		for (int i = 0; i < 1998; i++)
		{
			flashBuffer2[i] = 0;
		}

		writeBufferToPage(0, flashBuffer, 1998);
		readBufferFromPage(0, flashBuffer2, 1998);
		for (int i = 0; i < 1998; i++)
		{
			if (flashBuffer[i] != flashBuffer2[i])
			{
				Serial.print("Mismatch: ");
				Serial.print(i);
				Serial.print(" | ");
				Serial.print(flashBuffer[i]);
				Serial.print(" Vs ");
				Serial.println(flashBuffer2[i]);
			}			
		}




	//	deselectFlash();
	}; 
	


	

	//delay(1000);
	
}

void serialCallback(byte type,byte * data,int dataLength)
{
	switch (type)
	{
		case 0:  //Change single pixel
			Serial.println(data[0]);
			Serial.println((data[1] << 8) + data[2]);
			Serial.println(data[3]);
			Serial.println(data[4]);
			Serial.println(data[5]);
			sendMatrixPixel(data[0], (data[1]<<8)+data[2], data[3], data[4], data[5]);
		break;
		case 1: //Change the whole screen color
			Serial.println(data[0]);
			Serial.println(data[1]);
			Serial.println(data[2]);
			fillWithColor(data[1], data[1], data[2]);
			break;
		case 2: //Custom random data row
			for (int i = 0; i < 384; i+=2)
			{
				sendMatrixPixel(data[0], i, (data[1+3*(i/2)] & B00001111)<<4, (data[1 + 3 * (i / 2)] & B11110000), (data[2 + 3 * (i / 2)] & B00001111)<<4);
				sendMatrixPixel(data[0], i+1, (data[2 + 3 * (i / 2)] & B11110000), (data[3 + 3 * (i / 2)] & B00001111)<<4, (data[3 + 3 * (i / 2)] & B11110000));
			}
			break;
		case 3:  //Change brightness
			changeBrightness(data[0]);
			break;
		case 4: //Write row to flash
			selectFlash();
			delayMicroseconds(10);
			Serial.print("Writing to FLASH row: ");
			Serial.println((data[0] << 8) + data[1]);
			writeBufferToPage((data[0]<<8)+data[1], data + 2, 1998);  //Max length of the data in a row in 1998 bytes (Divisible by 3)
			delayMicroseconds(10);
			deselectFlash();
			break;
		case 5:
			//Media display request
			deselectFlash();
			Serial.println("Sending media display request...");
			sendMediaRequest((data[0]<<8)+data[1],(data[2]<<8)+data[3],data[4]);
	}	


}


