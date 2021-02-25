//|  ===============  |
//|  |     THE     |  |
//|  POCKET HANDBOOK  |
//|OF IMAGE PROCESSING|
//|  ALGORITHMS IN C  |
//|  |             |  |

// Adaptive DW-MTM Filter
// Page 13

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

void DDMTM_filter(Image IMAGE, Image IMAGE1, float NSTD, float K){
  int X, Y, x1, y1;
  int[] med = new int[9];
  int median;
  int gray, i, j, temp;
  int total, sum, R;
  R = IMAGE.Cols;
  for (Y = 2; Y < IMAGE.Rows-2; Y++){
    for (X = 2; X < IMAGE.Cols-2; X++){
      total = 0;
      for (y1 = -1; y1 <= 1; y1++){
        for (x1 = -1; x1 <= 1; x1++){
          med[total] = (int)IMAGE.Data[X+x1+(Y+y1)*R];
          total++;
        }
      }
      for (j = 1; j <= 8; j++){
        temp = med[j];
        i = j-1;
        while (i >= 0 && med[i] > temp){
          med[i+1] = med[i];
          i--;
        }
        med[i+1] = temp;
      }
      median=med[4];
      sum = 0; total = 0;
      for (y1 = -2; y1 <= 2; y1 ++){
        for (x1 = -2; x1 <= 2; x1 ++){
          gray = (int)IMAGE.Data[X+x1+(Y+y1)*R];
          if (gray>=(median-K*NSTD)){
            if (gray<=(median+K*NSTD)){
              sum+=gray;
              total++;
            }
          }
        }
      }
      IMAGE1.Data[X+Y*R] = (char)((float)sum/(float)total);
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
  float K = 2; // 1.5 - 2.5
  DDMTM_filter(IMAGE,IMAGE1,NSTD,K);
  
  PImage img0 = IMAGE.toPImage();
  PImage img1 = IMAGE1.toPImage();
  
  image(img0,0,0);
  image(img1,512,0);
  
  save("preview.png");
}
