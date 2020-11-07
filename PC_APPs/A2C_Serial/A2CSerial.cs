using System;
using System.Collections.Generic;
using System.IO.Ports;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace A2C_Serial
{
    public class A2CSerial
    {
        SerialPort serialPort;

        Queue<A2CPacket> toSend = new Queue<A2CPacket>();

        public const int packetRecognitionSize= 9;

        public A2CSerial()
        {
            Thread sender=new Thread(sendingThread);
            sender.SetApartmentState(ApartmentState.STA);
            sender.IsBackground = true;
            sender.Start();
            Thread receiver = new Thread(receivingThread);
            receiver.SetApartmentState(ApartmentState.STA);
            receiver.IsBackground = true;
            receiver.Start();
        }

        public void Connect(string port,int baudRate)
        {
            serialPort = new SerialPort(port,baudRate);
            serialPort.Open();
        }

        public void Close()
        {
            serialPort.Close();         
        }

        void sendingThread()
        {
            while(true)
            {
                if(toSend.Count>0)
                {
                    sendMessage(toSend.Dequeue());
                }
                Thread.Sleep(1);
            }
        }

        private void sendMessage(A2CPacket A2CPacket)
        {
            byte[] toSend = A2CPacket.toByteArray(packetRecognitionSize);
            serialPort.Write(toSend, 0, toSend.Length);
        }

        void receivingThread()
        {
          
        }

        public void addMessage(byte type,byte[]data)
        {
            A2CPacket packet = new A2CPacket();
            packet.ID = 666;
            packet.msgType = type;
            packet.data = data;
            packet.calculateSizesFromData(packetRecognitionSize);
            toSend.Enqueue(packet);
        }
    }
}
