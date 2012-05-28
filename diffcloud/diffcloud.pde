PImage img;
float[] cloud;
float[] p1;
float[] p2;
float[] d;
float[] e;
float[] gx;
float[] gy;
float[] bl;

int show = 2;

float t = 0;
float dt = 0.02f;

float thresh = 0.2f;
boolean enableThresholding = false;
boolean enableEdges = false;

void keyPressed() {
  if(keyCode == UP)
    show++;
  if(keyCode == DOWN)
    show--;
  show = constrain(show, 0, 3);
  
  if(key == 't')
    enableThresholding = !enableThresholding;
    
  if(key == 'e')
    enableEdges = !enableEdges;
  
  if(keyCode == RIGHT)
    thresh += 0.1f;
  if(keyCode == LEFT)
    thresh -= 0.1f;
  thresh = constrain(thresh, 0.0f, 1.0f);
}
 
void clearImage(PImage img) {
  img.loadPixels();
  for(int i = 0; i < img.pixels.length; i++) {
    img.pixels[i] = color(255, 255, 255); // white
  }
  img.updatePixels();
}

void initcloud() {
  int i = 0;
  noiseSeed(1234);
  noiseDetail(10);
  for(int y = 0; y < height; y++) {
    for(int x = 0; x < width; x++, i++) {
      //perlin noise for p1
      p1[i] = noise((float)x / 40.0f, (float)y / 40.0f, t);
    }
  }
  
  i = 0;
  noiseSeed(1337);
  for(int y = 0; y < height; y++) {
    for(int x = 0; x < width; x++, i++) {
      //different perlin noise for p2
      p2[i] = noise((float)x / 40.0f, (float)y / 40.0f, t + 0.1);
    }
  }
  
  //difference clouds time, it's magic, no it's just abs(p1 - p2)
  int len = width * height;
  for(i = 0; i < len; i++) {
    d[i] = abs(p1[i] - p2[i]);
  }
  
  //thresholding
  if(enableThresholding) {
    for(i = 0; i < len; i++) {
      if(d[i] < thresh)
        d[i] = 0.0f;
      else
        d[i] = 1.0f;
    }
  }
  
  //edge detection
  if(enableEdges) {
    /*
    // this edge filter SUCKS
    float[][] kernel = {{-1, -1, -1},
                        {-1,  9, -1},
                        {-1, -1, -1}};
                        
    for(int y = 1; y < height - 1; y++) {
      for(int x = 1; x < width - 1; x++) {
        float sum = 0.0f; // initial kernel value
        
        //now do the 3x3 kernel
        for(int ky = -1; ky <= 1; ky++) {
          for(int kx = -1; kx <= 1; kx++) {
            int pos = (y + ky) * width + (x + kx);
            sum += kernel[ky + 1][kx + 1] * d[pos];
          }
        }
        
        //reassign result of kernel
        e[y * width + x] = sum;
      }
    }
    */
    
    //canny is neat, just a pre-blurring filter really
    float[][] canny = {{2,  4,  5,  4, 2},
                       {4,  9, 12,  9, 4},
                       {5, 12, 15, 12, 5},
                       {4,  9, 12,  9, 4},
                       {2,  4,  5,  4, 2}};
    for(int y = 2; y < height - 2; y++) {
      for(int x = 2; x < width - 2; x++) {
        float sum = 0.0f;
        
        //apply the 5x5 kernel
        for(int ky = -2; ky <= 2; ky++) {
          for(int kx = -2; kx <= 2; kx++) {
            int pos = (y + ky) * width + (x + kx);
            sum += canny[ky + 2][kx + 2] * d[pos];
          }
        }
        
        //reassign
        bl[y * width + x] = sum / 159.0f;
      }
    }
    
    //then sobel it
    float[][] sobelX = {{-1, 0, 1},
                        {-2, 0, 2},
                        {-1, 0, 1}};
    float[][] sobelY = {{-1, -2, -1},
                        { 0,  0,  0},
                        { 1,  2,  1}};
                        
    //iterate
    for(int y = 1; y < height - 1; y++) {
      for(int x = 1; x < width - 1; x++) {
        float sumx = 0.0f;
        float sumy = 0.0f;
        
        //now apply the kernels
        for(int ky = -1; ky <= 1; ky++) {
          for(int kx = -1; kx <= 1; kx++) {
            int pos = (y + ky) * width + (x + kx);
            sumx += sobelX[ky + 1][kx + 1] * bl[pos];
            sumy += sobelY[ky + 1][kx + 1] * bl[pos];
          }
        }
        
        //reassign the results
        int pos = y * width + x;
        gx[pos] = sumx;
        gy[pos] = sumy;
        e[pos] = sqrt(sumx * sumx + sumy * sumy);
      }
    }
  }
}
 
void setup() {
  colorMode(RGB);
  background(0);
  smooth();
  fill(255);
  size(400, 400); 
  frameRate(30);
  img = createImage(width, height, RGB);
  clearImage(img);
    
  p1 = new float[width * height];
  p2 = new float[width * height];
  d = new float[width * height];
  e = new float[width * height];
  gx = new float[width * height];
  gy = new float[width * height];
  bl = new float[width * height];
} 

void drawcloud(float[] pix) {
  img.loadPixels();
  
  int len = img.pixels.length;
  for(int i = 0; i < len; i++) {
    //copy as grayscale
    img.pixels[i] = color(pix[i] * 255);
  }
  
  //copy image to screen
  img.updatePixels();
  image(img, 0, 0);
}

void draw() {
  //background(0);
  initcloud();
  
  if(show == 0)
    drawcloud(p1);
  else if(show == 1)
    drawcloud(p2);
  else if(show == 2)
    drawcloud(d);
  else if(show == 3)
    drawcloud(e);
    
    t += dt;
}
