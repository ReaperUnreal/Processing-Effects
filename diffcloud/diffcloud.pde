PImage img;
float[] cloud;
float[] p1;
float[] p2;
float[] d;

int show = 2;

float t = 0;
float dt = 0.02f;

float thresh = 0.2f;
boolean enableThresholding = false;

void keyPressed() {
  if(keyCode == UP)
    show++;
  if(keyCode == DOWN)
    show--;
  show = constrain(show, 0, 2);
  
  if(key == 't')
    enableThresholding = !enableThresholding;
  
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
  p1 = new float[width * height];
  p2 = new float[width * height];
  d = new float[width * height];
  
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
} 

void drawcloud(float[] pix) {
  img.loadPixels();
  
  int len = img.pixels.length;
  if(enableThresholding) {
    for(int i = 0; i < len; i++) {
      //makes most sense to put the threshold step here
      if(pix[i] < thresh)
        img.pixels[i] = color(0);
      else
        img.pixels[i] = color(255);
    }
  }
  else {
    for(int i = 0; i < len; i++) {
      //copy as grayscale
      img.pixels[i] = color(pix[i] * 255);
    }
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
    
    t += dt;
}
