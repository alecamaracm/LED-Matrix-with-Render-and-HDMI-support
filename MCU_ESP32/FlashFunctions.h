
#ifndef _FLASHFUNCTIONS_h
#define _FLASHFUNCTIONS_h

#if defined(ARDUINO) && ARDUINO >= 100
	#include "arduino.h"
#else
	#include "WProgram.h"
#endif


#endif



bool testFlash(); //Tests is the FLASH chip is working properly
void selectFlash(); //Gets access to flash I/O
void deselectFlash(); //Gives flash I/O to the FPGA
void writeByteToFlash(uint8_t val); //Writes a single byte to the FLASH;

uint8_t readByteFromFlash(); //Reads a single byte from the FLASH chip
void writeByteToFlash(uint8_t val);   //Writes a single byte from the FLASH chip

void readBufferFromPage(short row, byte* buffer, int max = 2112);
byte readByteFromFlashMulti();

void writeBufferToPage(short row,byte * buffer, int max = 2112);
void writeByteToFlashMulti(byte byte);

byte getStatusRegister();


void resetFlash();

void unlockCells();
void lockCells();