// MatrixFunctions.h

#ifndef _MATRIXFUNCTIONS_h
#define _MATRIXFUNCTIONS_h

#if defined(ARDUINO) && ARDUINO >= 100
	#include "arduino.h"
#else
	#include "WProgram.h"
#endif


#endif


void sendMatrixRow(byte row, byte r, byte g, byte b);

void sendMatrixPixel(byte row, short column, byte r, byte g, byte b);

void fillWithColor(byte r, byte g, byte b);

void changeBrightness(byte level);

void sendMediaRequest(short mediaID, short x, byte y);