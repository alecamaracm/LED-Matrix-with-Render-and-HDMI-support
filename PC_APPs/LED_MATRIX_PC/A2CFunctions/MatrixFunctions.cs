using A2C_Serial;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace LED_MATRIX_PC.A2CFunctions
{
    class MatrixFunctions
    {        
        public static void changeSinglePixel(A2CSerial serial,byte row, int column, byte r, byte g, byte b)
        {
            byte[] data = new byte[6];
            data[0] = row;
            data[1] = (byte)(column >> 8);
            data[2] = (byte)((column << 24) >> 24);
            data[3] = r;
            data[4] = g;
            data[5] = b;
            serial.addMessage(0, data);
        }

        public static void changeWholeScreen(A2CSerial serial,byte r,byte g,byte b)
        {
            byte[] data = new byte[3];
            data[0] = r;
            data[1] = g;
            data[2] = b;
            serial.addMessage(1, data);
        }

        public static void sendWholePictureRowByRow(A2CSerial serial, MyPicture picture)
        {
            for (int y = 0; y < picture.height; y++)
            {
                byte[] data = new byte[(128 * 3 * 3) / 2 + 1];
                data[0] = (byte)y;
                for (int x = 0; x < picture.width; x += 2)
                {
                    byte[] color = picture.colors[y * picture.width + x];
                    byte[] color2 = picture.colors[y * picture.width + x + 1];
                    data[1 + 3 * (x / 2)] = (byte)((color[0] >> 4) + color[1]);
                    data[2 + 3 * (x / 2)] = (byte)((color[2] >> 4) + color2[0]);
                    data[3 + 3 * (x / 2)] = (byte)((color2[1] >> 4) + color2[2]);
                }
                serial.addMessage(2, data);
                Thread.Sleep(30);
            }
        }

        public static void sendBrightness(A2CSerial serial,byte level)
        {
            byte[] data = new byte[1];
            data[0] = level;
            serial.addMessage(3, data);
        }

        public static void sendFlashRow(A2CSerial serial,short row,byte[] data)
        {
            byte[] newData=new byte[data.Length+2];
            newData[0] = (byte)(row>>8);
            newData[1] = (byte)row;
            for (int i=0;i<data.Length;i++)
            {
                newData[i + 2] = data[i];
            }
            serial.addMessage(4,newData);
        }

        //249 media per row (10 rows reserved for this)
        //TTTTRRRR RRRRRRRR WWWWWWWW WWWWHHHH HHHHHHHH FFFFFFFF FFFFFFFF SSSSSSSS
        //T==> Type of media, R==> Starting row W/H==> Width and height, F==>Number of frames, S==>Delay between frames (In 10s of ms)
        public static void sendFlashHeaders(A2CSerial serial,MediaContentData data)
        {
            byte[][] dataToSend = new byte[10][];
            for (int i = 0; i < dataToSend.Length; i++) dataToSend[i] = new byte[1998];
            byte[] currentBuffer = new byte[8];
            for(int i=0;i<data.mediaContent.Count;i++)
            {
                MediaContentMedia media = data.mediaContent[i];
                currentBuffer[0] = (byte)(((byte)media.type) << 4);
                currentBuffer[0] += (byte)(media.startingRow >> 8);
                currentBuffer[1] = (byte)media.startingRow;
                currentBuffer[2] = (byte)((media.width) >> 4);
                currentBuffer[3] = (byte)((byte)(media.width) & 0b11110000);
                currentBuffer[3] += (byte)(media.height >>8);
                currentBuffer[4] = (byte)media.height;
                currentBuffer[5] = (byte)(media.numberFrames>>8);
                currentBuffer[6] = (byte)media.numberFrames;
                currentBuffer[7] = (byte)media.frameDelay;

                

                Array.Copy(currentBuffer, 0, dataToSend[i / 249], (i % 249)*8, 8);
            }
            for (int ia = 0; ia < 1998; ia++)
            {
                dataToSend[0][ia] = 255;
            }

            for (short i=0;i<10;i++)
            {
                sendFlashRow(serial, i, dataToSend[i]);
                Thread.Sleep(35);
            }           
        }

        public static void sendMediaData(A2CSerial serial,MediaContentMedia media)
        {
            byte[][] dataToSend = new byte[(media.endingRow-media.startingRow)+1][];
            for (int i = 0; i < dataToSend.Length; i++) dataToSend[i] = new byte[1998];
            if(media.type==MediaType.Picture)
            {
                using(Bitmap bitmap=new Bitmap(PictureForm.getMediaDirectory()+media.name))
                {
                    MyPicture picture = new MyPicture(bitmap);
                    picture.setNewColorDepth(4);
                    int currentCount = 0;
                    for(int i=0;i<picture.colors.Count;i+=2)
                    {
                        byte[] color1 = picture.colors[i];
                        byte[] color2 = picture.colors[i + 1];
                        dataToSend[i / 1332][currentCount] =(byte)(color1[0] + (color1[1] >> 4));
                        dataToSend[i / 1332][currentCount+1] = (byte)(color1[2] + (color2[0] >> 4));
                        dataToSend[i / 1332][currentCount+2] = (byte)(color2[0] + (color2[0] >> 4));

                        currentCount +=3;

                        if (i % 1332 == 1330) currentCount = 0;
                    }                    
                }
      
            }else if(media.type==MediaType.Video)
            {

            }
            for (int i = media.startingRow; i <= media.endingRow; i++)
            {
                sendFlashRow(serial, (short)i, dataToSend[i-media.startingRow]);
                Thread.Sleep(35);
            }
        }

        
        public static void sendMediaDisplayRequest(A2CSerial serial,short mediaID,short x,byte y)
        {
            byte[] dataToSend = new byte[5];
            dataToSend[0] = (byte)(mediaID>>8);
            dataToSend[1] = (byte)mediaID;
            dataToSend[2]= (byte)(x >> 8);
            dataToSend[3] = (byte)x;
            dataToSend[4] = (byte)y;
            serial.addMessage(5, dataToSend);
        }
    }
}
