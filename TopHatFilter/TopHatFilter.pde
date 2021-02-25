//|  ===============  |
//|  |     THE     |  |
//|  POCKET HANDBOOK  |
//|OF IMAGE PROCESSING|
//|  ALGORITHMS IN C  |
//|  |             |  |

// Top Hat
// Page 242


int N = 5;

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


void ErosionGray(Image IMAGE, int[][] MASK, Image FILTER){
  int[][] a = new int[N][N];
  int X, Y, I, J, smin;
  for (Y=N/2; Y<IMAGE.Rows-N/2; Y++){
    for (X=N/2; X<IMAGE.Cols-N/2; X++){
      smin = 255;
      for (J=-N/2; J<=N/2; J++){
        for (I=-N/2; I<=N/2; I++){
          a[I+N/2][J+N/2]=(IMAGE.Data[X+I+(Y+J)*IMAGE.Cols]-MASK[I+N/2][J+N/2]);
        }
      }
      for (J=-N/2; J<=N/2; J++){
        for (I=-N/2; I<=N/2; I++){
          if (a[I+N/2][J+N/2]<smin){
            smin = a[I+N/2][J+N/2];
          }
        }
      }
      if (smin<0) smin = 0;
      FILTER.Data[X+Y*IMAGE.Cols]=(char)smin;
    }
  }
}

void DilationGray(Image IMAGE, int[][] MASK, Image FILTER){
  int[][] a = new int[N][N];
  int X, Y, I, J, smax;
  for (Y=N/2; Y<IMAGE.Rows-N/2; Y++){
    for (X=N/2; X<IMAGE.Cols-N/2; X++){
      smax = 0;
      for (J=-N/2; J<=N/2; J++){
        for (I=-N/2; I<=N/2; I++){
          a[I+N/2][J+N/2]=(IMAGE.Data[X+I+(Y+J)*IMAGE.Cols]-MASK[I+N/2][J+N/2]);
        }
      }
      for (J=-N/2; J<=N/2; J++){
        for (I=-N/2; I<=N/2; I++){
          if (a[I+N/2][J+N/2]>smax){
            smax = a[I+N/2][J+N/2];
          }
        }
      }
      if (smax>255) smax = 255;
      FILTER.Data[X+Y*IMAGE.Cols]=(char)smax;
    }
  }
}

void OpenGray(Image IMAGE, int[][] MASK, Image FILTER){
  int X, Y;
  ErosionGray(IMAGE, MASK, FILTER);
  for (Y=0; Y<IMAGE.Rows; Y++){
    for (X=0; X<IMAGE.Cols; X++){
      IMAGE.Data[X+Y*IMAGE.Cols] = FILTER.Data[X+Y*IMAGE.Cols];
    }
  }
  DilationGray(IMAGE,MASK,FILTER);
}


void TopHat(Image IMAGE, int[][] MASK, Image FILTER){
  int X, Y, B;
  Image TEMP = new Image(IMAGE.Cols,IMAGE.Rows);
  for (Y=0;Y<IMAGE.Rows;Y++){
    for (X=0;X<IMAGE.Cols;X++){
      TEMP.Data[X+Y*IMAGE.Cols]=IMAGE.Data[X+Y*IMAGE.Cols];
    }
  }
  OpenGray(IMAGE,MASK,FILTER);
  for (Y=0; Y<IMAGE.Rows; Y++){
    for (X=0; X<IMAGE.Cols; X++){
      B = TEMP.Data[X+Y*IMAGE.Cols]-FILTER.Data[X+Y*IMAGE.Cols];
      if (B<0) B = 0;
      FILTER.Data[X+Y*IMAGE.Cols]=(char)B;
    }
  }
}

void setup(){
  size(1024,512);
  PImage img = loadImage("../images/boat.png");
  Image IMAGE = new Image(img);
  PImage img0 = IMAGE.toPImage();
  Image FILTER = new Image(img.width,img.height);
  int[][] MASK = {{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}};
  //int[][] MASK = {{-10,-10,10,-10,-10},{-10,10,10,10,-10},{10,10,10,10,10},{-10,10,10,10,-10},{-10,-10,10,-10,-10}};
  TopHat(IMAGE,MASK,FILTER);
  
  //// use sqrt scale to brighten tophat visualization
  //float m = 0;
  //for (int i = 0; i < FILTER.Data.length; i++) m = max(FILTER.Data[i],m);
  //for (int i = 0; i < FILTER.Data.length; i++) FILTER.Data[i] = (char)(sqrt((float)FILTER.Data[i]/m)*255);
  
  PImage img1 = FILTER.toPImage();
  image(img0,0,0);
  image(img1,512,0);
  
  save("preview.png");
  
}
