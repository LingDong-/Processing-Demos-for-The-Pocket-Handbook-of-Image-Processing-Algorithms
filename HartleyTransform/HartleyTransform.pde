//|  ===============  |
//|  |     THE     |  |
//|  POCKET HANDBOOK  |
//|OF IMAGE PROCESSING|
//|  ALGORITHMS IN C  |
//|  |             |  |

// Hartley Transform
// Page 106

// Notes:
// - The code in the book seems to be a poor C translation
//   of the reference paper (Reeves)'s Pascal implementation.
//   There're many errors throughout (apparently the authors
//   didn't bother to actually run their code). Hopefully this port
//   manages to address all of them.
//
//   1 The handbook authors confused Pascal's "div" with "mod", hence
//     all of the % operators need to be changed back to /. Otherwise
//     the entirety of the function will be skipped.
// 
//   2 In the first "gpNum" for loop, "gpNum" should be incremented
//     instead of "i" (++i -> ++gpNum), otherwise it becomes an infinite
//     loop repeating the first iteration forever.
// 
//   3 Reeves describes a "bit reversal" algorithm, the effects of which 
//     seems to be acheived in a different way by the handbook authors. 
//     Unfortunately, the handbook version accesses out of bound indices
//     and crashes Java. Fortunately, after changing the line 
//     "n=length<<1" to "n=length", it starts to behave identically to the 
//     orignal bit reversal. Both methods are included in this port
//     for reference.
//
// - The algorithm is supposedly a 1D Hartley transform, but this demo
//   runs it on a flattened 2D image, for easier verification of correctness.
//   The resultant 2D pattern from the 1D pass nevertheless looks interesting.
//
// - TODO: figure out the 2D Harley transform

void hartley(float In[], int length, boolean dir){

  int stage, gpNum, gpIndex, gpSize, numGps, Nl2;
  int n,i,j,m;
  int bfNum, numBfs;
  int Ad0, Ad1, Ad2, Ad3, Ad4, CSAd;
  float[] C = new float[length];
  float[] S = new float[length];
  float rt1,rt2,rt3,rt4,tmp,theta,dTheta,pi;
  pi = PI;
  theta = 0;
  dTheta = 2 * pi / length;
  for (i = 0; i < length/4; ++i){
    C[i] = cos(theta);
    S[i] = sin(theta);
    theta += dTheta;
  }
  Nl2 = (int)(log(length)/log(2));
  n = length;
  j = 1;
  for (i=1; i<n; i++){
    if (j>i){
      tmp = In[j-1];
      In[j-1] = In[i-1];
      In[i-1] = tmp;
    }
    m = n>>1;
    while (m >= 2 && j > m){
      j -= m;
      m >>= 1;
    }
    j += m;
  }
  //alternatively:
  //BitRevRArr(In,Nl2,length);
  
  gpSize = 2;
  numGps = length / 4;

  for (gpNum = 0; gpNum < numGps - 1; ++gpNum){
    Ad1 = gpNum * 4;
    Ad2 = Ad1 + 1;
    Ad3 = Ad1 + gpSize;
    Ad4 = Ad2 + gpSize;
    rt1 = In[Ad1]+In[Ad2];
    rt2 = In[Ad1]-In[Ad2];
    rt3 = In[Ad3]+In[Ad4];
    rt4 = In[Ad3]-In[Ad4];
    In[Ad1]=rt1+rt3;
    In[Ad2]=rt2+rt4;
    In[Ad3]=rt1-rt3;
    In[Ad4]=rt2-rt4;
  }
  if (Nl2 > 2){
    gpSize = 4;
    numBfs = 2;
    numGps = numGps / 2;
    for (stage = 2; stage < Nl2; ++stage){
      for (gpNum = 0; gpNum < numGps; ++ gpNum){
        
        Ad0 = gpNum * gpSize * 2;
        Ad1 = Ad0;
        Ad2 = Ad1 + gpSize;
        Ad3 = Ad1 + gpSize / 2;
        Ad4 = Ad3 + gpSize;
        rt1 = In[Ad1];
        In[Ad1] = In[Ad1] + In[Ad2];
        In[Ad2] = rt1 - In[Ad2];
        rt1 = In[Ad3];
        In[Ad3] = In[Ad3] + In[Ad4];
        In[Ad4] = rt1 - In[Ad4];
        for (bfNum = 1; bfNum<numBfs; ++bfNum){
          Ad1 = bfNum + Ad0;
          Ad2 = Ad1 + gpSize;
          Ad3 = gpSize - bfNum + Ad0;
          Ad4 = Ad3 + gpSize;
          
          CSAd = bfNum * numGps;
          rt1 = In[Ad2] * C[CSAd] + In[Ad4] * S[CSAd];
          rt2 = In[Ad4] * C[CSAd] - In[Ad2] * S[CSAd];
          In[Ad2] = In[Ad1] - rt1;
          In[Ad1] = In[Ad1] + rt1;
          In[Ad4] = In[Ad3] + rt2;
          In[Ad3] = In[Ad3] - rt2;
        }
      }
      gpSize *= 2;
      numBfs *= 2;
      numGps /= 2; 
    }
  }
  if (!dir){
    for (i = 0; i < length; ++i){
      In[i] /= length;
    }
  }
}


// The bit reversal algorithm supposedly similar to the one used by
// Reeves's paper, found here: (in Pascal)
// https://imagej.nih.gov/nih-image/download/nih-image_spin-offs/Scion%20Image%201.59/Scion%20Image%201.59%20Source/fft.p
//
// It seems to behave identically to the Handbook author's algorithm,
// so the Handbook version is kept in the hartley() function above.
//
int BitRevX(int x, int bitlen){
  int i;
  int temp;
  temp = 0;
  for (i = 0; i <= bitlen; i++){
    if (((x>>i)&1) == 1){
      temp |= 1<<(bitlen-i-1);
    }
  }
  return temp & 0xFFFF;
}
void BitRevRArr(float[] x, int bitlen, int maxN){
  int i;
  float[] tempArr = new float[x.length];
  for (i = 0; i < maxN; i++){
    tempArr[i] = x[BitRevX(i,bitlen)];
  }
  System.arraycopy(tempArr,0,x,0,maxN);
}

void setup(){
  size(768,256);
  PImage img;

  float[] In;
  noSmooth();
  
  img = loadImage(sketchPath("../images/cameraman.png"));
  img.resize(256,256);
  
  image(img,0,0);

  img.loadPixels();
  In = new float[img.pixels.length];
  for (int i = 0; i < img.pixels.length; i++){
    In[i] =  0.21 * (float)(img.pixels[i] >> 16 & 0xFF) + 0.72 * (float)(img.pixels[i] >> 8 & 0xFF) + 0.07 * (float)(img.pixels[i] & 0xFF);
    In[i] /= 255;
  }
  
  hartley(In,In.length,true);
  
  for (int i = 0; i < img.pixels.length; i++){
    img.pixels[i] = color(128+In[i]*5);
  }
  img.updatePixels();
  
  image(img,256,0);

  img.loadPixels();

  hartley(In,In.length,false);
  for (int i = 0; i < img.pixels.length; i++){
    img.pixels[i] = color(In[i]*255);
  }
  img.updatePixels();
  
  image(img,512,0);
  
  save("preview.png");
  
}
