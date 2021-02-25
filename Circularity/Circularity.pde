//|  ===============  |
//|  |     THE     |  |
//|  POCKET HANDBOOK  |
//|OF IMAGE PROCESSING|
//|  ALGORITHMS IN C  |
//|  |             |  |

// Circularity
// Page 35 (Centroid on Page 31, Erosion on Page 76)

// Notes:
// - The circularity() function in this port
//   also computes the boundary pixels, while
//   the book seems to assume they're precomputed.
//   It is so modified because the centroid
//   needs to be computed on the "solid" image
//   while the circularity on the "hollow" outline
//   image. The authors of the book seem to be
//   oblivious of this issue (if I understood the
//   algorithm correctly that is).

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

int area(Image In, int x1, int y1, int x2, int y2, char ObjVal){
  int i, j;
  int area_value = 0;
  for (i = y1; i <= y2; ++i){
    for (j = x1; j <= x2; ++j){
      if (In.Data[j+i*In.Cols]==ObjVal) ++ area_value;
    }
  }
  return area_value;
}

class coord {
  float x,y;
};

void centroid(Image In, int x1, int y1, int x2, int y2, char ObjVal, coord coords){
  int i, j;
  int area_value, Xcent = 0, Ycent = 0;
  area_value = area(In, x1, y1, x2, y2, ObjVal);
  if (area_value == 0){
    coords.x = -1; coords.y = -1;
    return;
  }
  for (i = y1; i <= y2; ++i){
    for (j = x1; j <= x2; ++j){
      if (In.Data[i*In.Cols+j]==ObjVal){
        Xcent += j;
        Ycent += i;
      }
    }
  }
  coords.x = Xcent/area_value + 1;
  coords.y = Ycent/area_value + 1;
  return;
}


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


float circularity(Image In, Image Bd, int x1, int y1, int x2, int y2, char ObjVal, coord Ocenter){  
  int i,j,points=0;
  float mean=0.0,temp,stdev=0.0,variance;
  
  int[][] MASK = {{0,1,0},{1,1,1},{0,1,0}};
  Erosion(In,MASK,Bd);
  for (i = 0; i < Bd.Rows; ++i){
    for (j = 0; j < Bd.Cols; ++j){
      Bd.Data[i*Bd.Cols+j]=(char)(In.Data[i*In.Cols+j]-Bd.Data[i*Bd.Cols+j]);
    }
  }
  
  centroid(In,x1,y1,x2,y2,ObjVal,Ocenter);
  
  for (i = y1; i <= y2; ++i){
    for (j = x1; j <= x2; ++j){
      if (Bd.Data[j+i*In.Cols] == ObjVal){
        mean += sqrt(
          (j-Ocenter.x)*(j-Ocenter.x)+
          (i-Ocenter.y)*(i-Ocenter.y));
        ++points;
      }
    }
  }
  if (points==0) return -1;
  mean /= (float)points;
  
  for (i = x1; i <= x2; ++i){
    for (j = y1; j <= y2; ++j){
      if (Bd.Data[j+i*In.Cols]==ObjVal){
        temp=sqrt((i-Ocenter.x)*
                  (i-Ocenter.x)+
                  (j-Ocenter.y)*
                  (j-Ocenter.y))-mean;
        stdev += temp*temp;
      }
    }
  }
  stdev /= (float)points;
  variance = sqrt(stdev);
  return mean/variance;
}


void setup(){
  size(512,512);
  randomSeed(0x5EED);
  noSmooth();
  for (int i = 0; i < 16; i++){
    
    PGraphics img = createGraphics(128,128);
    img.beginDraw();
    img.fill(255);
    img.noStroke();
    img.background(0);
    img.translate(64,64);
    if (i < 4){
      img.rotate(PI/4);
      img.ellipse(0,0,50,50+i*20);
    }else if (i < 8){
      img.rotate(PI/4);
      img.rect(-20+(i-4)*5,-20-(i-4)*5,40-(i-4)*10,40+(i-4)*10);
    }else if (i < 12){
      img.rect(-20,-20-(i-8)*8,40,40+(i-8)*8);
      img.ellipse(0,0,50,50);
    }else{
      img.beginShape();
      for (int j = 0; j < 10; j++){
        float a = TAU*(float)j/10.0;
        float r = random(1)*50;
        img.vertex(cos(a)*r,sin(a)*r);
        
      }
      img.endShape(CLOSE);
    }
    img.endDraw();
    
    Image In = new Image(img);
    Image Bd = new Image(img.width,img.height);
    coord Ocenter = new coord();
    float c = circularity(In,Bd,0,0,127,127,(char)255,Ocenter);
    
    PImage BdImg = Bd.toPImage();
    
    pushMatrix();
    translate((i%4)*128,(i/4)*128);
    image(BdImg,0,0);
    noStroke();
    fill(255,0,0);
    circle(Ocenter.x,Ocenter.y,5);
    
    noStroke();
    textSize(12);
    text(c,0,12);
    popMatrix();
  }
  save("preview.png");
}
