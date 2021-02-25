//|  ===============  |
//|  |     THE     |  |
//|  POCKET HANDBOOK  |
//|OF IMAGE PROCESSING|
//|  ALGORITHMS IN C  |
//|  |             |  |

// Hadamard Transform
// Page 99

// Notes:
// - B=malloc(...) seems to be never freed
//   (not that it matters in this Java port)

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

void bitrep(char[] b, int q, int num){
  int x, i, bit;
  for (x = 0; x < num; x++){
    bit = 1;
    for (i = 0; i < q; i++){
      b[i+x*q] = (char)((x&bit)/bit);
      bit = bit << 1;
    }
  }
}

void Hadamard(Image IMAGE, Image IMAGE1, int dir){
  int X, Y, n, m, num, I, q;
  int sum1, temp;
  char[] B;
  float K0, sum;
  num = IMAGE.Rows;
  q = (int)(log((float)IMAGE.Rows) / log(2.0)+0.5);
  B = new char[num*q];
  bitrep(B,q,num);
  K0=num*num;
  for (m = 0; m < num; m++){
    for (n = 0; n < num; n++){
      sum = 0;
      for (Y = 0; Y < num; Y++){
        for (X = 0; X < num; X++){
          sum1 = 0;
          for (I = 0; I <= q-1; I++){
            sum1 += B[I+X*q]* B[I+n*q] + B[I+Y*q] * B[I+m*q];
          }
          if ((sum1/2)*2==sum1) temp = 1; else temp = -1;
          sum += IMAGE.Data[X+Y*IMAGE.Rows]*temp;
        }
      }
      IMAGE1.Data[n+m*IMAGE.Rows]=sum;
    }
  }
  if (dir == 1){
    for (Y=0; Y<num; Y++){
      for (X=0; X<num; X++){
        IMAGE1.Data[X+Y*IMAGE.Rows] /= K0;
      }
    }
  } 
}


void setup(){
  size(768,268);
  PImage img, img1;

  Image IMAGE, IMAGE1;
  noSmooth();
  textSize(12);
  noStroke();
  fill(0);
  
  img = loadImage(sketchPath("../images/cameraman.png"));
  img.resize(64,64);
  

  IMAGE = new Image(img);
  IMAGE1 = new Image(img.width,img.height);

  println("generating Hadamard transform...");
  Hadamard(IMAGE,IMAGE1,1);
  img1 = IMAGE1.toPImage(1);
    
  image(img,0,0,256,256);
  image(img1,256,0,256,256);

  println("reconstructing...");
  Hadamard(IMAGE1,IMAGE,0);
  PImage img2 = IMAGE.toPImage(0);
  image(img2,512,0,256,256);
  
  text("Original",0,266);
  text("Hadamard transform",256,266);
  text("Reconstructed",512,266);
  
  save("preview.png");
  
}
