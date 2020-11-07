// 
// 
// 

#include "FlashFunctions.h"
#include "IOFunctions.h"
#include "PIN_DEFINITIONS.h"



bool testFlash()
{
	selectFlash();
	setFlashPinsForSingle();

	digitalWrite(FLASH_CS, LOW);

	writeByteToFlash(0x9F);
	writeByteToFlash(0x00);

	bool success=readByteFromFlash() == 0xC8 && readByteFromFlash() == 0x21;

	digitalWrite(FLASH_CS, HIGH);
	return success;
}




void writeBufferToPage(short row, byte* buffer,int max)
{
	digitalWrite(FLASH_CS, HIGH);
	digitalWrite(FLASH_SCK, LOW);
	setFlashPinsForSingle();
	
	//WRITE ENABLE
	digitalWrite(FLASH_CS, LOW);
	writeByteToFlash(0x06);  //Send OPCODE	
	digitalWrite(FLASH_CS, HIGH);
	//END OF WRITE ENABLE
	delayMicroseconds(1);

	//PROGRAM LOAD COMMAND I/Ox4
	digitalWrite(FLASH_CS, LOW);
	writeByteToFlash(0x32);  //Send OPCODE
	writeByteToFlash(0x00);  //Starting address (NC(4), addr[11:8]
	writeByteToFlash(0x00); //Starting address addr[7:0]

	setFlashPinsMultiWrite();
	for (int i = 0; i < 2112; i++)
	{
		//writeByteToFlashMulti(buffer[i]);
		writeByteToFlashMulti(255);
	}

	digitalWrite(FLASH_CS, HIGH);


	//END OF PROGRAM LOAD
	delay(1);

	setFlashPinsForSingle();

	Serial.print("Writing register1: ");
	Serial.println(getStatusRegister());
	


	//EXECUTE
	digitalWrite(FLASH_CS, LOW);
	writeByteToFlash(0x10);  //Send OPCODE	
	writeByteToFlash(0x00);  //Dummy byte
	writeByteToFlash(row >> 8);  //MSBs of the row
	writeByteToFlash((row << 8) >> 8);  //LSBs of the row
	digitalWrite(FLASH_CS, HIGH);



	//END OF EXECUTE
	delay(1);

	Serial.print("Writing register2: ");
	Serial.println(getStatusRegister());

	//Wait until the page is ready
	byte currentStatus;
	do
	{
		currentStatus = getStatusRegister();
		Serial.print("Writing register: ");
		Serial.println(currentStatus);
		delay(1);
	} while (currentStatus & B00000001 == 1); //The bit [0] of tghe status registers is the (operation in progress bit)

}

void readBufferFromPage(short row, byte* buffer, int max)
{
	setFlashPinsForSingle();

	//PAGE READ COMMAND
	digitalWrite(FLASH_CS, LOW);
	writeByteToFlash(0x13);  //Send OPCODE
	writeByteToFlash(0x00);  //Dummy byte
	writeByteToFlash(row >> 8);  //MSBs of the row
	writeByteToFlash((row << 8) >> 8);  //LSBs of the row
	digitalWrite(FLASH_CS, HIGH);
	//END OF PAGE READ
	
	//Wait until the page is ready
	byte currentStatus;
	do
	{
		currentStatus = getStatusRegister();
		Serial.print("Reading register: ");
		Serial.println(currentStatus);
		delay(1);
	} while (currentStatus& B00000001 == 1); //The bit [0] of tghe status registers is the (operation in progress bit)


	//READ the whole row, in I/Ox4
	digitalWrite(FLASH_CS, LOW);
	writeByteToFlash(0x6B);  //Send OPCODE
	writeByteToFlash(0x00);  //Starting address (NC(4), addr[11:8]
	writeByteToFlash(0x00); //Starting address addr[7:0]
	writeByteToFlash(0x00); //Dummy byte
	setFlashPinsMultiRead();
	int bufferCount = 0;
	for (int i = 0; i <max; i++)
	{
		buffer[bufferCount]=readByteFromFlashMulti();
		bufferCount++;
	}	
	digitalWrite(FLASH_CS, HIGH);
	//END OF WHOLE ROW READ

}





byte getStatusRegister()
{
	setFlashPinsForSingle();
	digitalWrite(FLASH_CS, LOW);
	writeByteToFlash(0x0F);  //Send OPCODE
	//writeByteToFlash(0xC0);  //Dummy byte
	writeByteToFlash(0xA0);  //Dummy byte
	byte toReturn = readByteFromFlash();
	digitalWrite(FLASH_CS, HIGH);
	return toReturn;
}

void unlockCells()
{
	setFlashPinsForSingle();
	digitalWrite(FLASH_CS, LOW);
	writeByteToFlash(0x1F);  //Send OPCODE
	writeByteToFlash(0xA0);  //Register address
	writeByteToFlash(0x00);  //New register data
	digitalWrite(FLASH_CS, HIGH);
}

void lockCells()
{
	setFlashPinsForSingle();
	digitalWrite(FLASH_CS, LOW);
	writeByteToFlash(0x1F);  //Send OPCODE
	writeByteToFlash(0xA0);  //Register address
	writeByteToFlash(0x56);  //New register data
	digitalWrite(FLASH_CS, HIGH);
}


void resetFlash()
{
	setFlashPinsForSingle();
	digitalWrite(FLASH_CS, LOW);
	writeByteToFlash(0xFF);  //Send OPCODE
	digitalWrite(FLASH_CS, HIGH);	
}



void selectFlash() //Gets access to flash I/O
{
	digitalWrite(FLASH_CTRL, LOW);
}
void deselectFlash() //Gives flash I/O to the FPGA
{
	digitalWrite(FLASH_CTRL, HIGH);
}


void writeByteToFlash(uint8_t val) {
	for (uint8_t i = 0; i < 8; i++) {
		digitalWrite(FLASH_SI, !!(val & (1 << (7 - i))));
		__asm__ __volatile__("nop;nop;nop;nop;nop;nop;nop;nop;nop;");
		digitalWrite(FLASH_SCK, HIGH);
		__asm__ __volatile__("nop;nop;nop;nop;nop;nop;nop;nop;nop;");
		digitalWrite(FLASH_SCK, LOW);
	}
}

uint8_t readByteFromFlash() {
	uint8_t value = 0;
	for (uint8_t i = 0; i < 8; ++i) {
		value |= digitalRead(FLASH_SO) << (7 - i);
		__asm__ __volatile__("nop;nop;nop;nop;nop;nop;nop;nop;nop;");
		digitalWrite(FLASH_SCK, HIGH);
		__asm__ __volatile__("nop;nop;nop;nop;nop;nop;nop;nop;nop;");
		digitalWrite(FLASH_SCK, LOW);
	}
	return value;
}

byte readByteFromFlashMulti()
{
	byte value = 0;

	value |= digitalRead(FLASH_HOLD) << 7;
	value |= digitalRead(FLASH_WP) << 6;
	value |= digitalRead(FLASH_SO) << 5;
	value |= digitalRead(FLASH_SI) << 4;
	digitalWrite(FLASH_SCK, HIGH);
	__asm__ __volatile__("nop;nop;nop;nop;nop;nop;nop;nop;nop;");
	digitalWrite(FLASH_SCK, LOW);
	__asm__ __volatile__("nop;nop;nop;nop;nop;nop;nop;nop;nop;");
	value |= digitalRead(FLASH_HOLD) << 3;
	value |= digitalRead(FLASH_WP) << 2;
	value |= digitalRead(FLASH_SO) << 1;
	value |= digitalRead(FLASH_SI) << 0;
	digitalWrite(FLASH_SCK, HIGH);
	__asm__ __volatile__("nop;nop;nop;nop;nop;nop;nop;nop;nop;");
	digitalWrite(FLASH_SCK, LOW);
	__asm__ __volatile__("nop;nop;nop;nop;nop;nop;nop;nop;nop;");
	return value;
}

void writeByteToFlashMulti(byte toWrite)
{
	digitalWrite(FLASH_HOLD, !!(toWrite & (1 << 7)));
	digitalWrite(FLASH_WP, !!(toWrite & (1 << 6)));
	digitalWrite(FLASH_SO, !!(toWrite & (1 << 5)));
	digitalWrite(FLASH_SI, !!(toWrite & (1 << 4)));

	digitalWrite(FLASH_SCK, HIGH);
	__asm__ __volatile__("nop;nop;nop;nop;nop;nop;nop;nop;nop;");
	digitalWrite(FLASH_SCK, LOW);
	__asm__ __volatile__("nop;nop;nop;nop;nop;nop;nop;nop;nop;");

	digitalWrite(FLASH_HOLD, !!(toWrite & (1 << 3)));
	digitalWrite(FLASH_WP, !!(toWrite & (1 << 2)));
	digitalWrite(FLASH_SO, !!(toWrite & (1 << 1)));
	digitalWrite(FLASH_SI, !!(toWrite & (1 << 0)));

	digitalWrite(FLASH_SCK, HIGH);
	__asm__ __volatile__("nop;nop;nop;nop;nop;nop;nop;nop;nop;");
	digitalWrite(FLASH_SCK, LOW);
	 __asm__ __volatile__("nop;nop;nop;nop;nop;nop;nop;nop;nop;"); 
}

