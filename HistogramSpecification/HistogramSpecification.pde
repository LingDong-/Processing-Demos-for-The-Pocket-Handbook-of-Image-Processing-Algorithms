//|  ===============  |
//|  |     THE     |  |
//|  POCKET HANDBOOK  |
//|OF IMAGE PROCESSING|
//|  ALGORITHMS IN C  |
//|  |             |  |

// Histogram Specification
// Page 112 (Histogram Equalization on page 110)

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
      IHIST[J]++;
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

void HistogramSpecify(Image IMAGE, Image IMAGE1, float[] SPEC){
  int X,Y,I,minval,minj,J;
  int[] HISTSPEC = new int[256];
  int[] InvHist = new int[256];
  float SUM;
  Histogram_Equalization(IMAGE,IMAGE1);

  for (I=0; I<=255; I++){
    SUM=0.0;
    for (J=0; J<=I; J++){
      SUM += SPEC[J];
    }
    HISTSPEC[I] = (int)(255*SUM+0.5);
  }
  for (I=0; I<=255; I++){
    minval = abs(I-HISTSPEC[0]);
    minj=0;
    for (J=0; J<=255; J++){
      if (abs(I-HISTSPEC[J])<minval){
        minval=abs(I-HISTSPEC[J]);
        minj=J;
      }
      InvHist[I]=minj;
    }
  }

  for (Y=0; Y<IMAGE.Rows; Y++){
    for (X=0; X<IMAGE.Cols; X++){
      IMAGE1.Data[X+Y*IMAGE.Cols] = (char)InvHist[IMAGE1.Data[X+Y*IMAGE.Cols]];
    }
  }
}

interface Func{
  public float call(float x);
}

void testHistogram(Image IMAGE, Func func){
  Image IMAGE1 = new Image(IMAGE.Cols,IMAGE.Rows);
  PImage img1;
  float[] hist = new float[256];
  
  float[] spec = new float[256];
  float sum = 0;
  for (int i = 0; i < spec.length; i++){
    float y = func.call((float)i/(float)spec.length);
    spec[i] = y;
    sum += y;
  }
  for (int i = 0; i < spec.length; i++){
    spec[i]/=sum;
  }
  HistogramSpecify(IMAGE,IMAGE1,spec);
  img1 = IMAGE1.toPImage();
  image(img1,0,0);
 
  Histogram(IMAGE1,hist);
  noStroke();
  fill(255);
  float m = 0;
  for (int i = 0; i < hist.length; i++){
    m = max(hist[i],m);
  }
  for (int i = 0; i < hist.length; i++){
    rect(i,356-hist[i]/m*100,1,hist[i]/m*100);
  }
  fill(255,0,0);
  for (int i = 0; i < spec.length; i++){
    rect(i-1,356-spec[i]/m*100-2,2,2);
  }
}

void setup(){
  size(1024,712);
  background(0);
  fill(255);
  noStroke();
  
  PImage img;
  
  img = loadImage(sketchPath("../images/boat.png"));
  img.resize(256,256);
  Image IMAGE = new Image(img);

  
  img = IMAGE.toPImage();
  image(img,0,0);

  float[] hist = new float[256];
  Histogram(IMAGE,hist);
  for (int i = 0; i < hist.length; i++){
    rect(i,356-hist[i]*2000,1,hist[i]*2000);
  }
    
  translate(256,0);
  testHistogram(IMAGE,new Func(){
    public float call(float x){
      return 1;
    }
  });
  
  translate(256,0);
  testHistogram(IMAGE,new Func(){
    public float call(float x){
      return x < 0.5 ? x : (1-x);
    }
  });
  
  translate(256,0);
  testHistogram(IMAGE,new Func(){
    public float call(float x){
      return x < 0.5 ? (0.5-x) : (x-0.5);
    }
  });
  
  translate(-512,356);
  testHistogram(IMAGE,new Func(){
    public float call(float x){
      return max(0,x-0.5);
    }
  });

  
  translate(256,0);
  testHistogram(IMAGE,new Func(){
    public float call(float x){
      return (int)(x*256) % 80 == 40 ? 1 : 0;
    }
  });
  
  translate(256,0);
  testHistogram(IMAGE,new Func(){
    public float call(float x){
      return (0.4 < x && x < 0.6) ? 1 : 0.05;
    }
  });
  
  save("preview.png");

}
