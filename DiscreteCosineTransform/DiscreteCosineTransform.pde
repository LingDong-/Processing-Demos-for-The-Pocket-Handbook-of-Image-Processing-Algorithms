//|  ===============  |
//|  |     THE     |  |
//|  POCKET HANDBOOK  |
//|OF IMAGE PROCESSING|
//|  ALGORITHMS IN C  |
//|  |             |  |

// Discrete Cosine Transform
// Page 68

// Notes:
// - Faster implementations seem to exist

class Image {//Square, Float Image
  int Rows;//
  int Cols;//==Rows
  float[] Data;
  Image(int w, int h){
    Data = new float[w*h];
    Rows = h;
    Cols = w;
  }
  Image(PImage img){
    this(img.width,img.height);
    img.loadPixels();
    for (int i = 0; i < img.pixels.length; i++){
      Data[i] = 0.21 * (float)(img.pixels[i] >> 16 & 0xFF) + 0.72 * (float)(img.pixels[i] >> 8 & 0xFF) + 0.07 * (float)(img.pixels[i] & 0xFF);
      Data[i]/=255;
    }
  }
  float sigmoid(float x, float a){
    return (x<=0.5)?((pow(2.0*x, 1.0/(1-a)))/2.0):(1.0 - (pow(2.0*(1.0-x), 1.0/(1-a)))/2.0);
  }

  PImage toPImage(int normalizeMode){
    PImage img = createImage(Cols,Rows,ARGB);
    img.loadPixels();
    float m = Float.POSITIVE_INFINITY;
    float M = Float.NEGATIVE_INFINITY;
    for (int i = 0; i < Data.length; i++){
      M = max(Data[i],M);
      m = min(Data[i],m);
    }
    float MMm = max(abs(M),abs(m));
    for (int i = 0; i < img.pixels.length; i++){
      if (normalizeMode == 0){
        img.pixels[i] = color(Data[i]*255);
      }else{
        img.pixels[i] = color(sigmoid((Data[i]+MMm)/(MMm*2),0.95)*255);
      }
    }
    img.updatePixels();
    return img;
  }
};

void DiscreteCosine(Image IMAGE, Image IMAGE1, int dir){
  int X, Y, n, m, num;
  float sum, pi, k0, k1, ktx, kty, A;
  pi = 3.141592654;
  num = IMAGE.Rows;
  k0 = sqrt(1.0/(float)num);
  k1 = sqrt(2.0/(float)num);
  for (m = 0; m < num; m++){
    for (n = 0; n < num; n++){
      sum = 0.0;
      for (Y = 0; Y < num; Y++){
        if (dir == 1){
          A = cos((float)((2.0*(float)Y+1)*m*pi/2.0/num));
        }else{
          A = cos((float)((2.0*(float)m+1)*Y*pi/2.0/num));
        }
        for (X = 0; X < num; X++){
          if (dir == -1){
            if (X == 0) ktx = k0; else ktx = k1;
            if (Y == 0) kty = k0; else kty = k1;
            sum = sum + IMAGE.Data[X+Y*IMAGE.Rows]*cos((float)((2.0*(float)n+1)*X*pi/2.0/(float)num))*A*ktx*kty;
          }else{
            ktx = 1;
            kty = 1;
            sum = sum + IMAGE.Data[X+Y*IMAGE.Rows]*cos((float)((2.0*(float)X+1)*n*pi/2.0/(float)num))*A*ktx*kty;
            
          }
        }
      }
      if (dir == 1){
        if (n == 0) sum *= k0; else sum *= k1;
        if (m == 0) sum *= k0; else sum *= k1;
      }
      IMAGE1.Data[n+m*IMAGE.Rows]=sum;
    }
  }
}


void setup(){
  size(768,268);
  PImage img,img1;

  Image IMAGE, IMAGE1;
  noSmooth();
  textSize(12);
  noStroke();
  fill(0);
  
  img = loadImage(sketchPath("../images/cameraman.png"));
  img.resize(64,64);

  IMAGE = new Image(img);
  IMAGE1 = new Image(img.width,img.height);
  
  println("generating DCT...");
  DiscreteCosine(IMAGE,IMAGE1,1);
  img1 = IMAGE1.toPImage(1);
    
  image(img,0,0,256,256);
  image(img1,256,0,256,256);

  println("reconstructing...");
  DiscreteCosine(IMAGE1,IMAGE,-1);
  PImage img2 = IMAGE.toPImage(0);
  image(img2,512,0,256,256);
  
  text("Original",0,266);
  text("DCT",256,266);
  text("Reconstructed",512,266);
  
  save("preview.png");
}
