//|  ===============  |
//|  |     THE     |  |
//|  POCKET HANDBOOK  |
//|OF IMAGE PROCESSING|
//|  ALGORITHMS IN C  |
//|  |             |  |

// Alpha-Trimmed Mean Filter
// Page 21

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

void AlphaMean(Image IMAGE, int P, Image IMAGE1){
  int X, Y, I, J, SUM, Z;
  int N, A;
  int[] AR = new int[121];
  N = 7;
  for (Y=N/2; Y<IMAGE.Rows-N/2; Y++){
    for (X=N/2; X<IMAGE.Cols-N/2; X++){
      Z = 0;
      for (J=-N/2; J<=N/2; J++){
        for (I=-N/2; I<=N/2; I++){
          AR[Z]=IMAGE.Data[X+I+(Y+J)*IMAGE.Cols];
          Z++;
        }
      }
      for (J=1; J<=N*N-1; J++){
        A = AR[J];
        I = J-1;
        while (I>=0 && AR[I] >A){
          AR[I+1]=AR[I];
          I--;
        }
        AR[I+1]=A;
      }
      SUM = 0; Z = 0;
      for (J=P; J<=N*N-1-P;J++){
        SUM = SUM + AR[J];
        Z++;
      }
      IMAGE1.Data[X+Y*IMAGE.Cols]=(char) ((float)SUM/(float)Z+0.5); 
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
  
  int P = 12;
  AlphaMean(IMAGE,P,IMAGE1);
  
  PImage img0 = IMAGE.toPImage();
  PImage img1 = IMAGE1.toPImage();
  
  image(img0,0,0);
  image(img1,512,0);
  
  save("preview.png");
}
