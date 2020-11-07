// 
// 
// 

#include "MatrixFunctions.h"
#include "IOFunctions.h"
#include "PIN_DEFINITIONS.h"

void sendMatrixRow(byte row, byte r, byte g, byte b)
{
	myShiftOut(A2C_DT, A2C_CK, ((g >> 4) << 4) + (b >> 4));  //G(4) B(4).    //7-0
	myShiftOut(A2C_DT, A2C_CK, r >> 4);  //NC(4)  R(4)    //15-8
	myShiftOut(A2C_DT, A2C_CK, B00000000); //NC(8)  //23-16
	myShiftOut(A2C_DT, A2C_CK, row);   //Row(8)   //31-24
	myShiftOut(A2C_DT, A2C_CK, B10011111);  //typeGeneral(4), typeWrite(4) //39-32
}

void sendMatrixPixel(byte row, short column, byte r, byte g, byte b)
{
	myShiftOut(A2C_DT, A2C_CK, ((g >> 4) << 4) + (b >> 4));  //G(4) B(4).
	myShiftOut(A2C_DT, A2C_CK, (byte)(((column & 1) << 7) + (r >> 4)));  //NC(4)  R(4)
	myShiftOut(A2C_DT, A2C_CK, (byte)(column >> 1)); //Column(8)
	myShiftOut(A2C_DT, A2C_CK, row);   //Row(8) 
	myShiftOut(A2C_DT, A2C_CK, B10011001);  //typeGeneral(4), typeWrite(4)
}

void changeBrightness(byte level)
{
	myShiftOut(A2C_DT, A2C_CK, level);  //Level(8).    //7-0
	myShiftOut(A2C_DT, A2C_CK, B00000000);  //NC(8)
	myShiftOut(A2C_DT, A2C_CK, B00000000); //NC(8) 
	myShiftOut(A2C_DT, A2C_CK, B00000000);   //NC(8) 
	myShiftOut(A2C_DT, A2C_CK, B10001111);  //typeGeneral(4), NC(4) //39-32
}


void sendMediaRequest(short mediaID, short x, byte y)
{
	myShiftOut(A2C_DT, A2C_CK, (((byte)x)<<7)+y);  //x[0] y[6:0]
	myShiftOut(A2C_DT, A2C_CK, (byte)(x>>1));  //x[8:1]
	myShiftOut(A2C_DT, A2C_CK, (byte)mediaID); //MediaID[7:0] 
	myShiftOut(A2C_DT, A2C_CK, (byte)(mediaID>>8));   //MediaID[15:8]
	myShiftOut(A2C_DT, A2C_CK, B10110000);  //typeGeneral(4), NC(4) //39-32
}

void fillWithColor(byte r, byte g, byte b)
{
	for (int i = 0; i < 128; i++)
	{
		sendMatrixRow(i, r, g, b);
	}
}