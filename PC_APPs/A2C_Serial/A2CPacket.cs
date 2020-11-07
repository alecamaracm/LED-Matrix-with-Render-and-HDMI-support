using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace A2C_Serial
{
    public class A2CPacket
    {
        public int toSendSize=-1;  //Number of times checksums must be sent
        public int realSize=-1;

        public int msgType; //Message type
        public int ID;

        public byte[] data;

        public void calculateSizesFromData(int packetRecognitionSize)  //Sized do NOT include header or beggining
        {
            realSize = data.Length;
            toSendSize = (byte)Math.Ceiling((float)data.Length / (packetRecognitionSize - 1));
                //data.Length + (int)Math.Ceiling((float)data.Length / packetRecognitionSize);
        }

        public byte[] toByteArray(int packetRecognitionSize)
        {
            if (toSendSize == -1 || realSize == -1) calculateSizesFromData(packetRecognitionSize);

            byte[] toReturn = new byte[packetRecognitionSize+5+toSendSize* (packetRecognitionSize)];

            //Each beginning byte is a number incresing from 69 and whose first bit is 0
            for (int i = 0; i < packetRecognitionSize; i++) toReturn[i] =(byte)((byte)(69 + i) & 0b01111111);
            toReturn[packetRecognitionSize] = (byte)(toSendSize);
            toReturn[packetRecognitionSize+1] = (byte)(ID>>16);
            toReturn[packetRecognitionSize+2] = (byte)(ID>>8);
            toReturn[packetRecognitionSize+3] = (byte)(ID);
            toReturn[packetRecognitionSize+4] = (byte)(msgType);

            int counter = 0;
            int writeCounter = packetRecognitionSize + 5;
            byte lastAddition = 0;

            int countToChecksum = 0;

            while(counter<data.Length)
            {
                if(countToChecksum<packetRecognitionSize-1)
                {
                    lastAddition += data[counter];
                    toReturn[writeCounter] = data[counter];
                    countToChecksum++;
                    writeCounter++;
                    counter++;
                }
                else
                {
                    toReturn[writeCounter] = (byte)((lastAddition & 0b10111111) | 0b10000000);
                    writeCounter++;
                    lastAddition = 0;
                    countToChecksum = 0;
                }
            }

            for(int i=0;i<toSendSize*(packetRecognitionSize-1)-data.Length;i++)
            {
                toReturn[writeCounter] = 0;
                lastAddition += 0;
                writeCounter++;
            }

            toReturn[writeCounter] = (byte)(lastAddition | 0b11000000);
            

            
            return toReturn;
        }
    }
}
