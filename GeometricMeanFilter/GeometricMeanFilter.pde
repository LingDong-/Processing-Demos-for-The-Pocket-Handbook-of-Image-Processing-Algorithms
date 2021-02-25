//|  ===============  |
//|  |     THE     |  |
//|  POCKET HANDBOOK  |
//|OF IMAGE PROCESSING|
//|  ALGORITHMS IN C  |
//|  |             |  |

// Geometric Mean Filter
// Page 88

// Notes:
// - Due to geometric mean, black pixels in 
//   the input image introduces black square 
//   artifacts. Here a max(1,gray) trick is 
//   added to ensure this does not happen.

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

void GeometricMean(Image IMAGE, Image IMAGE1){
  int X, Y, I, J, Z;
  int N;
  int[] AR = new int[121];
  float PRODUCT;
  float[] TAR = new float[121];
  N = 5;
  for (Y=N/2; Y<IMAGE.Rows-N/2; Y++){
    for (X=N/2; X<IMAGE.Cols-N/2; X++){
      Z = 0;
      for (J=-N/2; J<=N/2; J++){
        for (I=-N/2; I<=N/2; I++){
          AR[Z]=max(1,IMAGE.Data[X+I+(Y+J)*IMAGE.Cols]);
          Z++;
        }
      }
      for (J=0; J<=N*N-1; J++){
        TAR[J] = pow(AR[J],1.0/(float)(N*N));
      }
      PRODUCT = 1.0;
      for (J=0; J<=N*N-1; J++){
        PRODUCT *= TAR[J];
      }
      if (PRODUCT > 255){
        IMAGE1.Data[X+Y*IMAGE.Cols]=255;
      }else{
        IMAGE1.Data[X+Y*IMAGE.Cols]=(char)PRODUCT;
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

  GeometricMean(IMAGE,IMAGE1);
  
  PImage img0 = IMAGE.toPImage();
  PImage img1 = IMAGE1.toPImage();
  
  image(img0,0,0);
  image(img1,512,0);
  
  save("preview.png");
  
}
