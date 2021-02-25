//|  ===============  |
//|  |     THE     |  |
//|  POCKET HANDBOOK  |
//|OF IMAGE PROCESSING|
//|  ALGORITHMS IN C  |
//|  |             |  |

// Skeleton
// Page 210

// Notes:
// - For a more sophisticated algorithm with "cleaner" results, 
//   see Zhang-Suen 1984 paper:
//   http://agcggs680.pbworks.com/f/Zhan-Suen_algorithm.pdf

int N = 3;

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
      Data[i] = (0.21 * (float)(img.pixels[i] >> 16 & 0xFF) + 0.72 * (float)(img.pixels[i] >> 8 & 0xFF) + 0.07 * (float)(img.pixels[i] & 0xFF)) > 127 ? (char)255 : (char)0;
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

void Erosion(Image IMAGE, int[][] MASK, Image FILTER){
  int X,Y,I,J,smin=255;
  int N=MASK.length;
  for (Y=N/2; Y<IMAGE.Rows-N/2; Y++){
    for (X=N/2; X<IMAGE.Cols-N/2; X++){
      smin=255;
      for (J=-N/2; J<=N/2; J++){
        for (I=-N/2; I<=N/2; I++){
          if (MASK[I+N/2][J+N/2]==1){
            if (IMAGE.Data[X+I+(Y+J)*IMAGE.Cols]<smin){
              smin = IMAGE.Data[X+I+(Y+J)*IMAGE.Cols];
            }
          }
        }
      }
      FILTER.Data[X+Y*IMAGE.Cols]=(char)smin;
    }
  }
}

void Dilation(Image IMAGE, int[][] MASK, Image FILTER){
  int X,Y,I,J,smax;
  int N=MASK.length;
  for (Y=N/2; Y<IMAGE.Rows-N/2; Y++){
    for (X=N/2; X<IMAGE.Cols-N/2; X++){
      smax=0;
      for (J=-N/2; J<=N/2; J++){
        for (I=-N/2; I<=N/2; I++){
          if (MASK[I+N/2][J+N/2]==1){
            if (IMAGE.Data[X+I+(Y+J)*IMAGE.Cols]>smax){
              smax = IMAGE.Data[X+I+(Y+J)*IMAGE.Cols];
            }
          }
        }
      }
      FILTER.Data[X+Y*IMAGE.Cols]=(char)smax;
    }
  }
}



void Skeleton_(Image IMAGE, int[][] MASK, Image SKELETON){
  int X, Y;
  int pixel;
  boolean pixel_on;
  Image FILTER, FILTER1;
  FILTER = new Image(IMAGE.Cols,IMAGE.Rows);
  FILTER1 = new Image(IMAGE.Cols,IMAGE.Rows);
  
  pixel_on = true;
  while (pixel_on){
    pixel_on = false;
    Erosion(IMAGE,MASK,FILTER);
    Dilation(FILTER,MASK,FILTER1);
    for (Y=N/2;Y<IMAGE.Rows-N/2;Y++){
      for (X=N/2; X<IMAGE.Cols-N/2;X++){
        pixel = IMAGE.Data[X+Y*IMAGE.Cols]-FILTER1.Data[X+Y*IMAGE.Cols];
        SKELETON.Data[X+Y*IMAGE.Cols] = (char)(SKELETON.Data[X+Y*IMAGE.Cols] | pixel);
        if (pixel == 255){
          pixel_on = true;
        }
        IMAGE.Data[X+Y*IMAGE.Cols]=FILTER.Data[X+Y*IMAGE.Cols];
      }
    }
  }
}

void setup(){
  size(240,394);
  PImage img = loadImage("../images/horse.png");
  Image IMAGE = new Image(img);
  PImage img0 = IMAGE.toPImage();
  Image SKELETON = new Image(img.width,img.height);
  int[][] MASK = {{0,1,0},{1,1,1},{0,1,0}};
  Skeleton_(IMAGE,MASK,SKELETON);
  PImage img1 = SKELETON.toPImage();
  image(img0,0,0);
  image(img1,0,197);
  
  save("preview.png");
  
}
