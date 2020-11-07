using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LED_MATRIX_PC
{
    public class MediaContentData
    {
        public List<MediaContentMedia> mediaContent=new List<MediaContentMedia>();
    }

    public class MediaContentMedia
    {
        public string name;
        public MediaType type;

        public long sizeBytes;

        public int startingRow;  //Included
        public int endingRow; //Included
         
        public int width;
        public int height;

        public int numberFrames;
        public int frameDelay; //In 10s of ms

    }

    public enum MediaType
    {
        Picture,
        Video,
    }
}
