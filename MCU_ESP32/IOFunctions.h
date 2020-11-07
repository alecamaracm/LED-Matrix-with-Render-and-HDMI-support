// IOFunctions.h

#ifndef _IOFUNCTIONS_h
#define _IOFUNCTIONS_h

#if defined(ARDUINO) && ARDUINO >= 100
	#include "arduino.h"
#else
	#include "WProgram.h"
#endif


#endif

void myShiftOut(uint8_t dataPin, uint8_t clockPin, uint8_t val);
void myShiftOutSlow(uint8_t dataPin, uint8_t clockPin, uint8_t val);

void setFlashPinsForSingle();
void setFlashPinsMultiRead();
void setFlashPinsMultiWrite();

void selectFlash(); //Gets access to flash I/O
void deselectFlash(); //Gives flash I/O to the FPGA

void setUpIO();

