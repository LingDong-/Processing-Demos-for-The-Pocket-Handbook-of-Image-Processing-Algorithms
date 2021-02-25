//|  ===============  |
//|  |     THE     |  |
//|  POCKET HANDBOOK  |
//|OF IMAGE PROCESSING|
//|  ALGORITHMS IN C  |
//|  |             |  |

// Gaussian Noise
// Page 86

// Notes:
// - Seems to be a constant-time approximation
//   using cosine to model the Gaussian function.

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

void Gaussian(Image IMAGE, float VAR, float MEAN){
  int X, Y;
  float NOISE, theta;
  for (Y = 0; Y<IMAGE.Rows; Y++){
    for (X = 0; X<IMAGE.Cols; X++){
      NOISE = sqrt(-2*VAR*log(1.0-random(32767)/32767.1));
      theta = random(32767)*1.9175345E-4 - 3.14159265;
      NOISE = NOISE * cos(theta);
      NOISE = NOISE + MEAN;
      if (NOISE > 255) NOISE = 255;
      if (NOISE < 0) NOISE = 0;
      IMAGE.Data[X+Y*IMAGE.Cols]= (char)(NOISE+0.5);
    }
  }
}

void setup(){
  size(513,256);
  
  Image IMAGE = new Image(256,256);
  float stdev = 16;
  
  Gaussian(IMAGE,stdev*stdev,128);
  
  PImage img0 = IMAGE.toPImage();
  
  image(img0,0,0);
  text("Pocket Handbook Gaussian()",0,10);
  
  // Compare with Processing randomGaussian():
  // (which seems to be an alias of Java Random.nextGaussian())
  
  PImage img1 = new PImage(256,256);
  img1.loadPixels();
  for (int i = 0; i < img1.pixels.length; i++){
    img1.pixels[i] = color(randomGaussian()*stdev+128);
  }
  img1.updatePixels();
  image(img1,257,0);
  text("Processing randomGaussian()",257,10);
  
  save("preview.png");
}
