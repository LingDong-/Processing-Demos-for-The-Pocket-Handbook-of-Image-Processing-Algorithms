//|  ===============  |
//|  |     THE     |  |
//|  POCKET HANDBOOK  |
//|OF IMAGE PROCESSING|
//|  ALGORITHMS IN C  |
//|  |             |  |

// Discrete Fourier Transform
// Page 70

// Notes:
// - An additional fftshift() function is implemented
//   to center the FFT results, so the visualization look 
//   nice and familiar.

class Image {//Square, Complex Image
  int Rows;//<=512
  int Cols;//==Rows<=512
  float[] Data;
  Image(int w, int h){
    Data = new float[w*h*2];
    Rows = h;
    Cols = w;
  }
  Image(PImage img){
    this(img.width,img.height);
    img.loadPixels();
    for (int i = 0; i < img.pixels.length; i++){
      Data[i*2] = 0.21 * (float)(img.pixels[i] >> 16 & 0xFF) + 0.72 * (float)(img.pixels[i] >> 8 & 0xFF) + 0.07 * (float)(img.pixels[i] & 0xFF);
      Data[i*2]/=255;
    }
  }
  PImage toPImage(int normalizeMode){
    PImage img = createImage(Cols,Rows,ARGB);
    img.loadPixels();
    float[] mag = new float[img.pixels.length];
    float M = 0;
    float m = 0;
    for (int i = 0; i < mag.length; i++){
      mag[i] = sqrt(Data[i*2]*Data[i*2]+Data[i*2+1]*Data[i*2+1]);
      if (normalizeMode != 0){
        mag[i] = log(1+mag[i]);
      }
      M = max(mag[i],M);
      m += mag[i];
    }
    m/=mag.length;
    for (int i = 0; i < img.pixels.length; i++){
      if (normalizeMode == 0){
        img.pixels[i] = color(mag[i]*255);
      }else if (normalizeMode == 1){
        img.pixels[i] = color(mag[i]/M*255);
      }else{
        img.pixels[i] = color(mag[i]/m*32);
      }
    }
    img.updatePixels();
    return img;
  }
};

void DiscreteFourier(Image IMAGE, float dir){
  int X, Y, num;
  int R;
  float[] data = new float[1024];
  float scale;
  num = IMAGE.Rows;
  if (dir == 1.0){
    scale = num*num;
  }else{
    scale = 1.0;
  }
  if (dir==-1.0) fftshift(IMAGE);
   
  for (Y=0; Y<num; Y++){
    R = Y * IMAGE.Rows * 2;
    for (X=0; X<= 2*num-1; X++){
      data[X] = IMAGE.Data[X+R];
    }
    fft(data,num,dir);
    for (X=0; X<=2*num-1; X++){
      IMAGE.Data[X+R]=data[X];
    }
  }
  for (X=0; X<= 2*num-1; X+=2){
    for (Y=0; Y<num; Y++){
      R = Y*IMAGE.Rows*2;
      data[2*Y] = IMAGE.Data[X+R];
      data[2*Y+1] = IMAGE.Data[X+1+R];
    }
    fft(data, num, dir);
    for (Y=0; Y<num; Y++){
      R=Y*IMAGE.Rows*2;
      IMAGE.Data[X+R]=data[2*Y]/scale;
      IMAGE.Data[X+1+R]=data[2*Y+1]/scale;
    }
  }
  if (dir==1.0) fftshift(IMAGE);
}

void fft(float[] data, int num, float dir){
  int array_size, bits, ind, j, j1;
  int i, i1, u, step, inc;
  float[] sine = new float[513];
  float[] cose = new float[513];
  float wcos, wsin, tr, ti, temp;
  bits = (int)(log(num)/log(2)+0.5);
  for (i = 0; i < num+1; i++){
    sine[i]=dir*sin(3.141592654*i/num);
    cose[i]=cos(3.141592654*i/num);
  }
  array_size=num<<1;
  for (i = 0; i < num; i++){
    ind = 0;
    for (j = 0; j < bits; j++){
      u = 1<<j; ind = (ind << 1) + ((u&i)>>j);
    }
    ind = ind<<1; j = i << 1;
    if (j < ind){
      temp = data[j]; data[j] = data[ind];
      data[ind] = temp; temp = data[j+1];
      data[j+1] = data[ind+1];
      data[ind+1] = temp;
    }
  }
  for (inc=2;inc<array_size;inc=step){
    step = inc<<1;
    for (u = 0; u < inc; u+=2){
      ind = (u<<bits)/inc;
      wcos=cose[ind];wsin=sine[ind];
      for(i=u;i<array_size;i+=step){
        j = i+inc; j1=j+1; i1=i+1;
        tr=wcos*data[j] -wsin*data[j1];
        ti=wcos*data[j1]+wsin*data[j];
        data[j]=data[i]-tr;
        data[i]=data[i]+tr;
        data[j1]=data[i1]-ti;
        data[i1]=data[i1]+ti;
      }
    } 
  }
}

void fftshift(Image IMAGE){
  int hw = IMAGE.Cols/2;
  int hh = IMAGE.Rows/2;
  float temp;
  for (int i = 0; i < hh; ++i){
    for (int j = 0; j < IMAGE.Cols; ++j){
      int j1 = (j < hw) ? (j + hw) : (j - hw);
      int i1 = i+hh;

      temp = IMAGE.Data[(i*IMAGE.Cols+j)*2];
      IMAGE.Data[(i*IMAGE.Cols+j)*2]=IMAGE.Data[(i1*IMAGE.Cols+j1)*2];
      IMAGE.Data[(i1*IMAGE.Cols+j1)*2]=temp;
      
      temp = IMAGE.Data[(i*IMAGE.Cols+j)*2+1];
      IMAGE.Data[(i*IMAGE.Cols+j)*2+1]=IMAGE.Data[(i1*IMAGE.Cols+j1)*2+1];
      IMAGE.Data[(i1*IMAGE.Cols+j1)*2+1]=temp;
    }
  }
}

void setup(){
  size(1024,768);
  PGraphics img;
  PImage img1;
  Image IMAGE;
  noSmooth();
  
  //--------------------------------
  //test 1
  
  img = createGraphics(256,256);
  img.beginDraw();
  img.noStroke();
  img.background(0);
  img.circle(64,128,32);
  img.circle(192,128,32);
  img.endDraw();
  
  IMAGE = new Image(img);
  DiscreteFourier(IMAGE,1.0);
  img1 = IMAGE.toPImage(2);
  image(img,0,0);
  image(img1,256,0);
  
  
  //--------------------------------
  //test 2
  
  img.beginDraw();
  img.background(0);
  img.rect(128-16,128-16,32,32);
  img.endDraw();
  
  IMAGE = new Image(img);
  DiscreteFourier(IMAGE,1.0);
  img1 = IMAGE.toPImage(2);
  image(img,512,0);
  image(img1,768,0);
  
  //--------------------------------
  //test 3
  
  img = createGraphics(512,512);
  img.beginDraw();
  img.image(loadImage(sketchPath("../images/cameraman.png")),0,0);
  img.endDraw();
  IMAGE = new Image(img);
  DiscreteFourier(IMAGE,1.0);
  img1 = IMAGE.toPImage(2);
    
  image(img,0,256);
  image(img1,512,256);
  
  ////--------------------------------
  ////transform back
  
  //DiscreteFourier(IMAGE,-1.0);
  //PImage img2 = IMAGE.toPImage(0);
  //image(img2,0,256);
  
  save("preview.png");
  
}
