//|  ===============  |
//|  |     THE     |  |
//|  POCKET HANDBOOK  |
//|OF IMAGE PROCESSING|
//|  ALGORITHMS IN C  |
//|  |             |  |

// Circularly Symmetric Filter
// Page 37 (FFT on Page 70)

// Notes:
// - It appears that the indexing expressions on page 39 for
//   real and imaginary parts of each pixel are incorrect:
//   (i*N+m) needs to be multiplied by 2, as each pixel consists
//   of two floats.


class Image {//Square, Power of 2, Complex Image
  int Rows;//==2^n<=512
  int Cols;//==Rows
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
        img.pixels[i] = color(mag[i]);
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

void circ_filt(Image filt, float Do, int n){
  int i,j,l,m,N;
  float[] f;
  float Huv;
  f = filt.Data;
  N = filt.Rows;
  for (i = 0, l=N-1; i<N/2; ++i, --l){
    for (j = 0, m=N-1; j<N/2; ++j, --m){

      Huv = 1.0/(1.0+pow(sqrt(i*i+j*j)/Do,2*n));

      f[2*(i*N+j)] = f[2*(i*N+j)+1] = Huv;
      f[2*(l*N+m)] = f[2*(l*N+m)+1] = Huv;
      f[2*(i*N+m)] = f[2*(i*N+m)+1] = Huv;
      f[2*(l*N+j)] = f[2*(l*N+j)+1] = Huv;
    }
  }
}

void mult_filt(Image IMAGE, Image filt){
  for (int i = 0; i < IMAGE.Data.length; i+= 2){
    IMAGE.Data[i] = IMAGE.Data[i] * filt.Data[i]; 
    IMAGE.Data[i+1]= IMAGE.Data[i+1] * filt.Data[i+1];
  }
}



void setup(){
  size(768,548);
  background(255);
  noSmooth();
  noStroke();
  fill(0);
  textSize(12);
  PImage img;
  PImage img1;
  Image IMAGE;
  Image filt;
  noSmooth();
  
  
  img = loadImage(sketchPath("../images/cameraman.png"));
  img.resize(256,256);
  
  image(img,0,12);
  text("0. Original",2,10);

  IMAGE = new Image(img);
  DiscreteFourier(IMAGE,1.0);
  
  img1 = IMAGE.toPImage(2);
  image(img1,256,12);
  text("1. Fourier",256,10);
  
  filt = new Image(img.width,img.height);
  circ_filt(filt,32,1);
  
  img1 = filt.toPImage(2);
  
  image(img1,512,12);
  text("2. Lowpass Butterworth filter",512,10);
  
  mult_filt(IMAGE,filt);
  
  img1 = IMAGE.toPImage(2);
  image(img1,256,256+12*3);
  text("3. Filtered Fourier",256,256+10+12*2);
  
  //--------------------------------
  //transform back
  
  DiscreteFourier(IMAGE,-1.0);
  PImage img2 = IMAGE.toPImage(0);
  image(img2,0,256+12*3);
  text("4. Final (blurred) result",0,256+10+12*2);
  
  save("preview.png");
}
