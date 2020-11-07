using A2C_Serial;
using LED_MATRIX_PC.A2CFunctions;
using Microsoft.VisualBasic;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.IO.Ports;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using AlecamarLIB;
using Newtonsoft.Json;

namespace LED_MATRIX_PC
{
    public partial class PictureForm : Form
    {
        Bitmap originalBitmap;
        MyPicture picture;

        Random random = new Random();

        MediaContentData contentData = new MediaContentData();

        public List<int> rowsChanged = new List<int>(); //Rows that have been updated and need to be sent to the FLASH


  
        public PictureForm()
        {
            InitializeComponent();
        }

        private void Label1_Click(object sender, EventArgs e)
        {

        }

        private void Button1_Click(object sender, EventArgs e)
        {
            if(openFileDialog1.ShowDialog()==DialogResult.OK)
            {
                originalBitmap = new Bitmap(openFileDialog1.FileName);
                picture = new MyPicture(originalBitmap);
                picture.setNewColorDepth((int)numericUpDown1.Value);
                pictureBox1.Image = picture.ToBitmap();
            }
        }

        private void NumericUpDown1_ValueChanged(object sender, EventArgs e)
        {
            picture.setNewColorDepth((int)numericUpDown1.Value);
            pictureBox1.Image = picture.ToBitmap();
            MatrixFunctions.sendWholePictureRowByRow(MainForm.serial,picture);
        }



     

        private void Button5_Click(object sender, EventArgs e)
        {
            MatrixFunctions.sendWholePictureRowByRow(MainForm.serial,picture);
        }

        private void PictureForm_Load(object sender, EventArgs e)
        {
            if (File.Exists(Environment.CurrentDirectory + "\\MediaContents\\media.txt"))
            {
                using(StreamReader reader=new StreamReader(Environment.CurrentDirectory + "\\MediaContents\\media.txt"))
                {
                    contentData = JsonConvert.DeserializeObject<MediaContentData>(reader.ReadToEnd());
                }
                foreach(MediaContentMedia media in contentData.mediaContent)
                {
                    addNewMedia(media);
                }
            }
        }

        private void Button4_Click(object sender, EventArgs e) //Add media
        {
            if(openFileDialog2.ShowDialog()==DialogResult.OK)
            {
                FileInfo fileInfo = new FileInfo(openFileDialog2.FileName);
                if (File.Exists(Environment.CurrentDirectory + "\\MediaContents\\Media\\" + fileInfo.Name))
                {
                    Interaction.MsgBox("This file name already exists!");
                    return;
                }

                if (fileInfo.Extension ==".jpg"||fileInfo.Extension==".png")
                {
                    MediaContentMedia media = new MediaContentMedia();
                    media.name = fileInfo.Name;
                    media.type = MediaType.Picture;
                    File.Copy(fileInfo.FullName, getMediaDirectory() + fileInfo.Name);
                    contentData.mediaContent.Add(media);
                    addNewMedia(media);
                }else if(fileInfo.Extension=="mpeg")
                {
                    MediaContentMedia media = new MediaContentMedia();
                    media.name = fileInfo.Name;
                    media.type = MediaType.Video;
                    addNewMedia(media);
                }
                using (StreamWriter writer = new StreamWriter(Environment.CurrentDirectory + "\\MediaContents\\media.txt"))
                {
                    writer.Write(JsonConvert.SerializeObject(contentData));
                }
            }
        }

        private void addNewMedia(MediaContentMedia media)
        {
            if(media.type==MediaType.Picture)
            {
                Bitmap thumbnail = new Bitmap(getMediaDirectory() + media.name);
                ListViewItem item = new ListViewItem();
                item.SubItems.Add(media.name);
                item.SubItems.Add(media.type.ToString());
                media.width = thumbnail.Width;
                media.height = thumbnail.Height;
                media.sizeBytes = (long)Math.Ceiling((media.width * media.height*3) / 2.0);
                item.SubItems.Add(media.sizeBytes.ToShortByteString());            
                item.SubItems.Add(media.width + " x " + media.height);
                media.numberFrames = 1;
             
                item.SubItems.Add(media.numberFrames.ToString());
                imageList1.Images.RemoveByKey(media.name);
                imageList1.Images.Add(media.name,thumbnail);
                item.ImageKey = media.name;                
                listView1.Items.Add(item);
                thumbnail.Dispose();
                showUsedSpaceStats();
            }
            else if(media.type==MediaType.Video)
            {

            }
        }

        public static string getMediaDirectory()
        {
            return Environment.CurrentDirectory + "\\MediaContents\\Media\\";
        }

        private void ButtonRemoveMedia_Click(object sender, EventArgs e)
        {
            if(listView1.SelectedIndices.Count>0)
            {
                MediaContentMedia media = getMediaByFileName(listView1.SelectedItems[0].SubItems[1].Text);
                File.Delete(getMediaDirectory() + media.name);
                for(int i=0;i<contentData.mediaContent.Count;i++)
                {
                    if(contentData.mediaContent[i].name==media.name)
                    {
                        contentData.mediaContent.RemoveAt(i);
                        break;
                    }
                }
                listView1.Items.RemoveAt(listView1.SelectedIndices[0]);
            }
        }

        public MediaContentMedia getMediaByFileName(string fileName)
        {
            return contentData.mediaContent.Where(p => p.name == fileName).First();
        }

        void reacalculateRowPositions()
        {
            int currentRow = -1;
            for(int i=0;i<contentData.mediaContent.Count;i++)
            {
                currentRow++;
                contentData.mediaContent[i].startingRow = currentRow;
                long theoricalSize = contentData.mediaContent[i].sizeBytes;
                int currentLineCount = 0;
                while(theoricalSize>0)
                {
                    currentLineCount++;
                    theoricalSize--;
                    if(currentLineCount>1998) //Gone over a line
                    {
                        currentRow++;
                        currentLineCount = 0;
                    }
                }
                contentData.mediaContent[i].endingRow = currentRow;
            }
        }

        void showUsedSpaceStats()
        {
            var totalB = contentData.mediaContent.Sum(p => p.sizeBytes);
            var totalRows= contentData.mediaContent.Sum(p => Math.Ceiling(p.sizeBytes/1998.0));
            labelSpaceUsed.Text = totalB.ToShortByteString();
            labelRowsUsed.Text = Math.Round((totalRows / 65536.0) * 100, 2) + "% rows used";
        }

        private void ButtonResendHeaders_Click(object sender, EventArgs e)
        {
            reacalculateRowPositions();
            MatrixFunctions.sendFlashHeaders(MainForm.serial,contentData);
        }

        private void ButtonResendAll_Click(object sender, EventArgs e)
        {
            buttonResendHeaders.PerformClick();
            foreach(var media in contentData.mediaContent)
            {
                MatrixFunctions.sendMediaData(MainForm.serial, media);
            }
        }

        private void ButtonDisplayMedia_Click(object sender, EventArgs e)
        {
            MatrixFunctions.sendMediaDisplayRequest(MainForm.serial,(short)numericUpDownMediaToShow.Value, (short)numericUpDownMediaX.Value, (byte)numericUpDownMediaY.Value);
        }
    }
}
