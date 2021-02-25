//|  ===============  |
//|  |     THE     |  |
//|  POCKET HANDBOOK  |
//|OF IMAGE PROCESSING|
//|  ALGORITHMS IN C  |
//|  |             |  |

// Harmonic Mean Filter
// Page 103

// Notes:
// - This filter produces terrible squarish artifacts,
//   especially near darker pixels. However, it appears
//   that these are to be expected of a harmonic mean
//   filter.

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

void HarmonicMean(Image IMAGE, Image IMAGE1){
  int X, Y, I;
  int J, Z;
  int N, A;
  int[] AR = new int[121];
  float SUM;
  N = 5;
  for (Y=N/2; Y<IMAGE.Rows-N/2; Y++){
    for (X=N/2; X<IMAGE.Cols-N/2; X++){
      Z = 0;
      for (J=-N/2; J<=N/2; J++){
        for (I=-N/2; I<=N/2; I++){
          AR[Z]=IMAGE.Data[X+I+(Y+J)*IMAGE.Cols];
          Z++;
        }
      }
      Z = 0;
      SUM = 0.0;
      for (J=0; J<=N*N-1; J++){
        if (AR[J]==0){
          Z=1; SUM = 0;
        }else{
          SUM += 1.0/(float)AR[J];
        }
      }
      if (Z==1){
        IMAGE1.Data[X+Y*IMAGE.Cols]=0;
      }else{
        A=(int)((float)(N*N)/SUM+0.5);
        if (A>255){
          A = 255;
        }
        IMAGE1.Data[X+Y*IMAGE.Cols]=(char)A;
        
      }
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

  HarmonicMean(IMAGE,IMAGE1);
  
  PImage img0 = IMAGE.toPImage();
  PImage img1 = IMAGE1.toPImage();
  
  image(img0,0,0);
  image(img1,512,0);
  
  save("preview.png");
  
}
