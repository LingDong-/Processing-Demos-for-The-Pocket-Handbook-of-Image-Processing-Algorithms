//|  ===============  |
//|  |     THE     |  |
//|  POCKET HANDBOOK  |
//|OF IMAGE PROCESSING|
//|  ALGORITHMS IN C  |
//|  |             |  |

// Histogram Equalization
// Page 110 (Graylevel Histogram on page 96)

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

void Histogram(Image IMAGE, float[] HIST){
  int X, Y, I, J;
  int[] IHIST = new int[256];
  int SUM;
  for (I=0;I<=255;I++)IHIST[I]=0;
  SUM=0;
  for (Y=0;Y<IMAGE.Rows;Y++){
    for (X=0;X<IMAGE.Cols;X++){
      J=IMAGE.Data[X+Y*IMAGE.Cols];
      IHIST[J]=IHIST[J]+1;
      SUM++;
    }
  }
  for (I=0;I<255;I++){
    HIST[I]=(float)IHIST[I]/(float)SUM;
  }
}

void Histogram_Equalization(Image IMAGE, Image IMAGE1){
  int X,Y,I,J;
  int[] HISTEQ = new int[256];
  float[] HIST = new float[256];
  float SUM;
  Histogram(IMAGE,HIST);
  for (I=0; I<=255; I++){
    SUM=0.0;
    for(J=0;J<=I;J++) SUM+=HIST[J];
    HISTEQ[I]=(int)(255*SUM+0.5);
  }
  for (Y=0; Y<IMAGE.Rows; Y++){
    for (X=0; X<IMAGE.Cols; X++){
      IMAGE1.Data[X+Y*IMAGE.Cols] = (char)HISTEQ[(int)IMAGE.Data[X+Y*IMAGE.Cols]];
    }
  }
}

void setup(){
  size(1024,612);
  background(0);
  PImage img, img1;
  
  img = loadImage(sketchPath("../images/boat.png"));
  Image IMAGE = new Image(img);
  
  //delibrately make the image "dull"
  for (int i = 0; i < IMAGE.Data.length; i++){
    IMAGE.Data[i] = (char)(((float)IMAGE.Data[i]-128)*0.5+128);
  }
  
  Image IMAGE1 = new Image(img.width,img.height);
  Histogram_Equalization(IMAGE,IMAGE1);
  
  img = IMAGE.toPImage();
  img1 = IMAGE1.toPImage();
  
  image(img,0,0);
  image(img1,512,0);
  
  fill(255);
  noStroke();
  
  float[] hist = new float[256];
  Histogram(IMAGE,hist);
  for (int i = 0; i < hist.length; i++){
    rect(i*2,height-hist[i]*2000,1,hist[i]*2000);
  }
  Histogram(IMAGE1,hist);
  for (int i = 0; i < hist.length; i++){
    rect(512+i*2,height-hist[i]*2000,1,hist[i]*2000);
  }
  
  save("preview.png");
}
