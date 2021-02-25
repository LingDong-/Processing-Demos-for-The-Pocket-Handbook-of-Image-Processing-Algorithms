//|  ===============  |
//|  |     THE     |  |
//|  POCKET HANDBOOK  |
//|OF IMAGE PROCESSING|
//|  ALGORITHMS IN C  |
//|  |             |  |

// Adaptive MMSE Filter
// Page 17

class Image {
  int Rows;
  int Cols;
  char[] Data;
  Image(int w, int h){
    Data = new char[w*h];
    Rows = h;
    Cols = w;
  }
  Image(PImage img){
    this(img.width,img.height);
    img.loadPixels();
    for (int i = 0; i < img.pixels.length; i++){
      Data[i] = (char)(0.21 * (float)(img.pixels[i] >> 16 & 0xFF) + 0.72 * (float)(img.pixels[i] >> 8 & 0xFF) + 0.07 * (float)(img.pixels[i] & 0xFF));
    }
  }
  PImage toPImage(){
    PImage img = createImage(Cols,Rows,ARGB);
    img.loadPixels();
    for (int i = 0; i < img.pixels.length; i++){
      img.pixels[i] = 0xFF000000 | (Data[i] << 16) |  (Data[i] << 8) | Data[i];
    }
    img.updatePixels();
    return img;
  }
};

void MMSE_filter(Image IMAGE, Image IMAGE1, float NVAR){
  int X, Y, x1, y1, N, g;
  int total, sum, sum1, R;
  float FSECOND, FVAR=0.0, FMEAN=0.0;
  R=IMAGE.Cols;
  N=5;
  for (Y=N/2;Y<IMAGE.Rows-N/2;Y++){
    for(X=N/2;X<IMAGE.Cols-N/2;X++){
      sum=0;
      sum1=0;
      total=0;
      for(y1=-N/2;y1<=N/2;y1++){
        for(x1=-N/2;x1<=N/2;x1++){
          sum+=IMAGE.Data[X+x1+(Y+y1)*R];
          sum1+=IMAGE.Data[X+x1+(Y+y1)*R]*IMAGE.Data[X+x1+(Y+y1)*R];
          total++;
        }
      }
      FSECOND=(float)sum1/(float)total;
      FMEAN = (float)sum/(float)total;
      FVAR=FSECOND - FMEAN*FMEAN;
    
      if (FVAR==0.0){
        g = (int)(FMEAN+0.5);
      }else{
        g = (int) ((1-NVAR/FVAR) * IMAGE.Data[X+Y*R] + NVAR/FVAR*FMEAN+0.5);
      }
      if (g > 255) g = 255;
      if (g < 0) g = 0;
      IMAGE1.Data[X+Y*R]=(char)g;
    }
  }
}

void setup(){
  size(1024,512);
  PImage img = loadImage(sketchPath("../images/peppers.png"));
  Image IMAGE = new Image(img);
  Image IMAGE1 = new Image(img.width,img.height);
  float NSTD = 20;
  for (int i = 0; i < IMAGE.Data.length; i++){
    IMAGE.Data[i] = (char)constrain(IMAGE.Data[i] + (randomGaussian() * NSTD),0,255);
  }
  
  MMSE_filter(IMAGE,IMAGE1,NSTD*NSTD);
  
  PImage img0 = IMAGE.toPImage();
  PImage img1 = IMAGE1.toPImage();
  
  image(img0,0,0);
  image(img1,512,0);
 
  save("preview.png");
}
