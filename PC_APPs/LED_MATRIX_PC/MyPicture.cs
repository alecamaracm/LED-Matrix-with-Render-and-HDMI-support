using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LED_MATRIX_PC
{
    class MyPicture
    {
        public Bitmap originalBitmap;

        public int width;
        public int height;
        public List<byte[]> colors = new List<byte[]>();
        public int colorDepth;

        public MyPicture()
        {

        }

        public MyPicture(Bitmap originalBitmap)
        {
            this.originalBitmap = originalBitmap;
        }

        public void setNewColorDepth(int newColorDepth)
        {
            colorDepth = newColorDepth;
            int inverseDepth = 8 - colorDepth;
            width = originalBitmap.Width;
            height = originalBitmap.Height;
            colors = new List<byte[]>(originalBitmap.Width*originalBitmap.Height);

            for (int y = 0; y < originalBitmap.Height; y++)
            {
                for (int x = 0; x < originalBitmap.Width; x++)
                {
                    Color color = originalBitmap.GetPixel(x, y);
                    colors.Add(new byte[] { (byte)((color.R>> inverseDepth) << inverseDepth), (byte)((color.G >> inverseDepth) << inverseDepth), (byte)((color.B >> inverseDepth) << inverseDepth) });
                }
            }
        }

        public Bitmap ToBitmap()
        {
            Bitmap toReturn = new Bitmap(width, height);
            for (int y = 0; y < height; y++)
            {
                for (int x = 0; x < width; x++)
                {
                    byte[] color = colors[y*width+x];
                    toReturn.SetPixel(x, y, Color.FromArgb(color[0],color[1],color[2]));
                }
            }

            return toReturn;
        }
    }
}
