//|  ===============  |
//|  |     THE     |  |
//|  POCKET HANDBOOK  |
//|OF IMAGE PROCESSING|
//|  ALGORITHMS IN C  |
//|  |             |  |

// Maximum Axis
// Page 145 (Moments on page 157)

// Notes:
// - The quadratic root formula used in the 
//   book is incorrectly written as -b*sqrt(b^2+4ac)/2,
//   where * should be +/-
// - After correcting the formula, the two roots
//   alternate between being minimum and maximum axes.
//   This seems to be fixed by casing on the sign of
//   cm11.
// - In the central moment code in the book, 
//   i-yb should be j-yb in the second to last nested for loop.
//   All the loops are re-nested in a cache friendly
//   manner in this port.

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
      //Data[i]/=255; 
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


float cmoment(int p, int q, Image In, int x1, int y1, int x2, int y2){
  int i,j,xb,yb;
  float m00=0.0,m10=0.0,m01=0.0,upq=0.0;
  
  if ((p==1 && q==0) || (p==0 && q==1))
    return upq;
    
  for (i = y1; i < y2; ++i)
    for (j = x1; j < x2; ++j)
      m00 += In.Data[i*In.Cols+j];
      
  if (p == 0 && q == 0) return m00;
  
  for (i = y1; i < y2; ++i)
    for (j = x1; j < x2; ++j)
      m10 += j * In.Data[i*In.Cols+j];
      
  if (p==1 && q==0) return m10;
      
  for (i = y1; i < y2; ++i)
    for (j = y1; j < y2; ++j)
      m01 += i * In.Data[i*In.Cols+j];
      
  if (p==0 && q==1) return m01;
  
  xb = (int)floor(0.5+m10/m00);
  yb = (int)floor(0.5+m01/m00);
  
  if (p == 0){
    for (i=y1; i<y2; ++i)
      for (j=x1; j<x2; ++j)
        upq += pow(i-yb,q)*In.Data[i*In.Cols+j];
    return upq;
  }
  if (q == 0){
    for (i=y1; i<y2; ++i)
      for (j=x1; j<x2; ++j)
        upq += pow(j-xb,p)*In.Data[i*In.Cols+j];
    return upq;
  }
  for (i=y1; i<y2; ++i)
    for (j=x1; j<x2; ++j)
      upq += pow(j-xb,p) * pow(i-yb,q) * In.Data[i*In.Cols+j];
   return upq;
}

float max_axis_slope(Image In, int x1, int y1, int x2, int y2){
  float cm20, cm02, cm11, b;

  cm20 = cmoment(2,0,In,x1,y1,x2,y2);
  cm02 = cmoment(0,2,In,x1,y1,x2,y2);
  cm11 = cmoment(1,1,In,x1,y1,x2,y2);
  
  b = (cm20-cm02)/cm11;
  
  if (cm11 > 0){
    return atan(((-b)+sqrt(b*b+4.0))/2.0);
  }else{
    return atan(((-b)-sqrt(b*b+4.0))/2.0);
  }
  

}



void setup(){
  size(256,256);
  
}
void draw(){
  
  PGraphics img = createGraphics(256,256);
  img.beginDraw();
  
  img.background(0);
  img.translate(128,128);
  img.rotate(0.01*frameCount);
  img.noStroke();
  img.ellipse(0,0,200,40);
  
  img.rect(-30,0,60,60);
  
  img.endDraw();
  
  image(img,0,0);
  
  Image In = new Image(img);
  
  float a = max_axis_slope(In,0,0,img.width,img.height);

  strokeWeight(2);

  pushMatrix();
  translate(128,128);
  rotate(a);
  stroke(255,0,0);
  line(-150,0,150,0);
  popMatrix();
  

  save("preview.png");
}
