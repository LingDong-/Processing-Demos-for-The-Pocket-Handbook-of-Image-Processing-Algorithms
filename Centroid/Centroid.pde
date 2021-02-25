//|  ===============  |
//|  |     THE     |  |
//|  POCKET HANDBOOK  |
//|OF IMAGE PROCESSING|
//|  ALGORITHMS IN C  |
//|  |             |  |

// Centroid
// Page 31 (Area on Page 23)

// Notes:
// - It appears that the authors of the book confused
//   the correspondance of i/j and x/y in 
//   the main loop of centroid() function. The error
//   has been corrected in this implementation,
//   and the loop is re-nested in a cache-friendly 
//   manner.


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

void setup(){
  size(512,512);
  PGraphics img = createGraphics(512,512);
  img.beginDraw();
  img.noStroke();
  img.background(0);
  img.ellipse(150,300,80,50);
  img.ellipse(170,260,60,130);
  img.rect(170,300,50,50);
  img.endDraw();
  
  Image In = new Image(img);
  coord coords = new coord();
  centroid(In,0,0,511,511,(char)255,coords);
  
  image(img,0,0);
  fill(255,0,0);
  noStroke();
  circle(coords.x,coords.y,10);
  
  save("preview.png");
}
