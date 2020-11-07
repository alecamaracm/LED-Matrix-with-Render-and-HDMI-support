using A2C_Serial;
using LED_MATRIX_PC.A2CFunctions;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace LED_MATRIX_PC
{
    public partial class MainForm : Form
    {
        public static A2CSerial serial;
        public MainForm()
        {
            InitializeComponent();
        }

        private void Button1_Click(object sender, EventArgs e)
        {
            PictureForm form1 = new PictureForm();
            form1.ShowDialog();
        }

        private void MainForm_Load(object sender, EventArgs e)
        {
            serial = new A2CSerial();
            serial.Connect("COM5", 1000000);
        }

        private void TrackBar2_Scroll(object sender, EventArgs e)
        {
            MatrixFunctions.sendBrightness(MainForm.serial, (byte)trackBar2.Value);
        }

        private void Button4_Click(object sender, EventArgs e)
        {
            MatrixFunctions.changeWholeScreen(MainForm.serial, 0, 0, 0);
        }
    }
}
