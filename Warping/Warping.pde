//|  ===============  |
//|  |     THE     |  |
//|  POCKET HANDBOOK  |
//|OF IMAGE PROCESSING|
//|  ALGORITHMS IN C  |
//|  |             |  |

// Warping
// Page 252

// Notes:
// - The code listed in the book apparently only works
//   when sx=sy=0 (i.e. upper left corner is at the origin).
//   This is fixed by subtracting the offset from the paramters
//   passed to the formula, and adding it back when sampling.
// - The 4 corners in Wx and Wy should be provided in clockwise
//   order, like so:
//     0---1
//    /   /
//   3---2
// - The code in the book does "fake" interpolation, by simply
//   iterating the pixels from the input image at 0.5 steps.
//   If the scaling is > 2 anywhere, black holes start showing 
//   up.
//   Perhaps a better algorithm should iterate the pixels of 
//   the output image instead, and apply the inverse transform
//   to find the corresponding color in the original image.
// - Perhaps barycentric coordinates is one such alternative.

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

void warp(Image Img, Image Out, int sx, int sy, int ex, int ey, int[] Wx, int[] Wy){
  float a,b,c,d,e,f,i,j,x,y,destX,destY;

  // fix book bug
  float sx0 = sx;
  float sy0 = sy;
  ex = ex - sx;
  ey = ey - sy;
  sx = 0;
  sy = 0;
  // end fix
  

  a = (float)(-Wx[0]+Wx[1])/(ey-sy);
  b = (float)(-Wx[0]+Wx[3])/(ex-sx);
  c = (float)(Wx[0]-Wx[1]+Wx[2]-Wx[3])/((ey-sy)*(ex-sx));
  d = (float)Wx[0];
  
  e = (float)(-Wy[0]+Wy[1])/(ex-sx);
  f = (float)(-Wy[0]+Wy[3])/(ey-sy);
  i = (float)(Wy[0]-Wy[1]+Wy[2]-Wy[3])/((ey-sy)*(ex-sx));
  j = (float)Wy[0];
  
  
  for (y = sy; y < ey; y+=0.5){
    for (x = sx; x < ex; x+=0.5){
      destX = a*x + b*y + c*x*y + d;
      destY = e*x + f*y + i*x*y + j;

      //doesn't work:
      //Out.Data[(int)(destY)*Out.Cols+(int)destX] = Img.Data[(int)y*Img.Cols+(int)(x)];
      
      //does:
      Out.Data[(int)(destY)*Out.Cols+(int)destX] = Img.Data[(int)(y+sy0)*Img.Cols+(int)(x+sx0)];
    }
  }
  
}



void setup(){
  size(1024,512);
  PImage img = loadImage("../images/boat.png");
  Image Img = new Image(img);
  PImage img0 = Img.toPImage();
  
  Image Out = new Image(Img.Cols,Img.Rows);
  
  int sx = 50;
  int sy = 50;
  int ex = 300;
  int ey = 300;
  
  int x0 = 20;
  int y0 = 100;
  
  int x1 = 400;
  int y1 = 100;
  
  int x2 = 400;
  int y2 = 300;
  
  int x3 = 100;
  int y3 = 400;
  
  warp(Img,Out,sx,sy,ex,ey,
    new int[]{x0,x1,x2,x3}, 
    new int[]{y0,y1,y2,y3}
  );
  
  PImage img1 = Out.toPImage();
  image(img0,0,0);
  noFill();
  stroke(255,255,0);
  rect(sx,sy,ex-sx,ey-sy);
  
  translate(img0.width,0);
  image(img1,0,0);

  circle(x0,y0,6);
  circle(x1,y1,6);
  circle(x2,y2,6);
  circle(x3,y3,6);
  
  save("preview.png");
  
}
