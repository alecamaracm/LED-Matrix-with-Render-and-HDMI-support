// 
// 
// 

#include "IOFunctions.h"
#include "PIN_DEFINITIONS.h"

void myShiftOut(uint8_t dataPin, uint8_t clockPin, uint8_t val) {
	for (uint8_t i = 0; i < 8; i++) {
		digitalWrite(dataPin, !!(val & (1 << i)));
		for (int i = 0; i < 9; i++) { __asm__ __volatile__("nop;nop;nop;nop;nop;"); }
		digitalWrite(clockPin, HIGH);
		for (int i = 0; i < 9; i++) { __asm__ __volatile__("nop;nop;nop;nop;nop;"); }
		digitalWrite(clockPin, LOW);
	}
}

void myShiftOutSlow(uint8_t dataPin, uint8_t clockPin, uint8_t val) {
	for (uint8_t i = 0; i < 8; i++) {
		digitalWrite(dataPin, !!(val & (1 << i)));

		digitalWrite(clockPin, HIGH);
		delay(1);
		
		digitalWrite(clockPin, LOW);
		delay(1);
	}
}

void setUpIO()
{
	pinMode(A2C_DT, OUTPUT);
	pinMode(A2C_CK, OUTPUT);
	digitalWrite(A2C_DT, LOW);
	digitalWrite(A2C_CK, LOW);

	setFlashPinsForSingle();

	pinMode(FLASH_CS, OUTPUT);
	digitalWrite(FLASH_CS, HIGH);

	pinMode(FLASH_CTRL, OUTPUT);
	digitalWrite(FLASH_CTRL, LOW);
}

void setFlashPinsForSingle() //Sets the I/O for single wire operations
{
	pinMode(FLASH_HOLD, OUTPUT);
	digitalWrite(FLASH_HOLD, HIGH);

	pinMode(FLASH_SCK, OUTPUT);

	pinMode(FLASH_SI, OUTPUT);

	pinMode(FLASH_SO, INPUT);

	pinMode(FLASH_WP, OUTPUT);
	digitalWrite(FLASH_WP, HIGH);

}

void setFlashPinsMultiRead() //Sets the I/O for multi read operations
{
	pinMode(FLASH_HOLD, INPUT);
	pinMode(FLASH_SI, INPUT);
	pinMode(FLASH_SO, INPUT);
	pinMode(FLASH_WP, INPUT);
}

void setFlashPinsMultiWrite() //Sets the I/O for multi read operations
{
	pinMode(FLASH_HOLD, OUTPUT);
	pinMode(FLASH_SI, OUTPUT);
	pinMode(FLASH_SO, OUTPUT);
	pinMode(FLASH_WP, OUTPUT);
}


