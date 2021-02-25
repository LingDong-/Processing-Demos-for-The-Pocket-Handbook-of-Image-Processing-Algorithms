//|  ===============  |
//|  |     THE     |  |
//|  POCKET HANDBOOK  |
//|OF IMAGE PROCESSING|
//|  ALGORITHMS IN C  |
//|  |             |  |

// Thickening
// Page 230

// Notes:
// - A seam tend to be produced when two thickened shapes
//   meet each other (unlike dilation in which the shapes
//   merge into one). The example image in the book does not
//   show any seam. However upon careful inspection of the
//   book's described algorithm, generation of seams seems 
//   to be an innevitable property.
//   Changing the second Erosion() call to Dilation() eliminates
//   the seams, but deviates from the book's definition of
//   Hit-Miss filter.
//   Due to lack of info about the algorithm on the Internet,
//   it is difficult to determine if seams are to be expected
//   of the thickening operator.

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

void Thickened(Image IMAGE, Image THICKEN, int MAXIT){
  int X, Y, I, J, Z;
  int[][][] M1 = new int[3][3][8];
  int[][] M4 = new int[3][3];
  int[][][] M2 = new int[3][3][8];
  int[][] M3 = new int[3][3];
  int stpflg = 0;
  int R;
  Image FILTER = new Image(IMAGE.Cols,IMAGE.Rows);
  Image IMAGEC = new Image(IMAGE.Cols,IMAGE.Rows);
  R = IMAGE.Cols;

  M1[0][1][0] = 1; M1[1][1][0] = 1; M1[2][1][0]=1;
  M1[0][2][0] = 1; M1[1][2][0] = 1; M1[2][2][0]=1;
  
  M1[0][0][1] = 1; M1[1][0][1] = 1; M1[2][0][1]=1;
  M1[0][1][1] = 1; M1[1][1][1] = 1; M1[2][1][1]=1;
  
  M1[0][0][2] = 1; M1[1][0][2] = 1; M1[0][1][2]=1;
  M1[1][1][2] = 1; M1[0][2][2] = 1; M1[1][2][2]=1;
  
  M1[1][0][3] = 1; M1[2][0][3] = 1; M1[1][1][3]=1;
  M1[2][1][3] = 1; M1[1][2][3] = 1; M1[2][2][3]=1;
  
  M1[0][0][4] = 1; M1[0][1][4] = 1; M1[1][1][4]=1;
  M1[0][2][4] = 1; M1[1][2][4] = 1; M1[2][2][4]=1;
  
  M1[0][0][5] = 1; M1[1][0][5] = 1; M1[2][0][5]=1;
  M1[0][1][5] = 1; M1[1][1][5] = 1; M1[0][2][5]=1;
  
  M1[0][0][6] = 1; M1[1][0][6] = 1; M1[2][0][6]=1;
  M1[1][1][6] = 1; M1[2][1][6] = 1; M1[2][2][6]=1;
  
  M1[2][0][7] = 1; M1[1][1][7] = 1; M1[2][1][7]=1;
  M1[0][2][7] = 1; M1[1][2][7] = 1; M1[2][2][7]=1;

  
  for (I = 0; I <= 2; I++){
    for (J = 0; J <= 2; J++){
      for (Z = 0; Z <= 7; Z++){
        M2[I][J][Z] = 1 - M1[I][J][Z];
      }
    }
  }
  while (stpflg<MAXIT){
    for (Z = 0; Z <= 7; Z++){
      for (J = 0; J <= 2; J++){
        for (I = 0; I <= 2; I++){
          M3[I][J] = M2[I][J][Z];
          M4[I][J] = M1[I][J][Z];
        }
      }
      for (Y = 0; Y<IMAGE.Rows; Y++){
        for (X = 0; X < IMAGE.Cols; X++){
          IMAGEC.Data[X+Y*IMAGE.Cols] = (char)(255 - IMAGE.Data[X+Y*IMAGE.Cols]);
        }
      }
      Erosion(IMAGE,M3,FILTER);
      Erosion(IMAGEC,M4,THICKEN); // change to Dilation() to match the example image in book
      
      for (Y=N/2; Y<IMAGE.Rows-N/2; Y++){
        for (X=N/2; X<IMAGE.Cols-N/2; X++){
          FILTER.Data[X+Y*IMAGE.Cols] = (char)(FILTER.Data[X+Y*IMAGE.Cols] & THICKEN.Data[X+Y*IMAGE.Cols]);
        }
      }
      
      
      for (Y=N/2; Y<IMAGE.Rows-N/2; Y++){
        for (X=N/2; X<IMAGE.Cols-N/2; X++){
          THICKEN.Data[X+Y*R] = (char)(IMAGE.Data[X+Y*R] | FILTER.Data[X+Y*R]);
          IMAGE.Data[X+Y*R] = THICKEN.Data[X+Y*R];
        }
      }
      stpflg ++;
    }
  }
}

void setup(){
  //size(240,394);
  //PImage img = loadImage("../images/horse.png");
  //Image IMAGE = new Image(img);
  //PImage img0 = IMAGE.toPImage();
  //Image THICKEN = new Image(img.width,img.height);

  //Thickened(IMAGE,THICKEN,200);
  //PImage img1 = THICKEN.toPImage();
  //image(img0,0,0);
  //image(img1,0,197);
  
  size(256,128);
  PGraphics img = createGraphics(128,128);
  img.beginDraw();
  img.background(0);
  img.noStroke();
  img.fill(255);
  img.rectMode(CENTER);
  img.rect(64,32,16,16);
  img.rect(64,64,16,16);
  img.rect(64,96,16,16);
  img.endDraw();
  
  Image IMAGE = new Image(img);
  PImage img0 = IMAGE.toPImage();
  Image THICKEN = new Image(img.width,img.height);

  Thickened(IMAGE,THICKEN,100);
  PImage img1 = THICKEN.toPImage();
  image(img0,0,0);
  image(img1,128,0);
  
  save("preview.png");
}
