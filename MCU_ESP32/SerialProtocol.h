// SerialProtocol.h
#include "Arduino.h"


#ifndef _SERIALPROTOCOL_h
#define _SERIALPROTOCOL_h

#if defined(ARDUINO) && ARDUINO >= 100
	#include "arduino.h"
#else
	#include "WProgram.h"
#endif


#endif


void setUpSerialProtocol(void callback(byte, byte *, int));

void doWork(int timeoutUS);