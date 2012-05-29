PImage img;
float[] p1;
color[] palette;

boolean enableThresholding = false;

float t = 0;
float dt = 0.02f;
 
void clearImage(PImage img) {
  img.loadPixels();
  for(int i = 0; i < img.pixels.length; i++) {
    img.pixels[i] = color(255, 255, 255); // white
  }
  img.updatePixels();
}

void initcolor() {
  for(int i = 0; i < 256; i++) {
    float r = 0.0f, g = 0.0f, b = 0.0f;
    float h = ((float)i * 360.0f) / 255.0f;
    float hdash = h / 60.0f;
    float x = 1.0f - abs((hdash % 2.0f) - 1.0f);
    
    if(enableThresholding) {
      if(hdash < 0.5f) {
        r = 1.0f;
        g = 1.0f;
        b = 1.0f;
      }
    }
    else {
      if(hdash < 1.0f) {
        r = 1.0f;
        g = x;
      }
      else if(hdash < 2.0f) {
        r = x;
        g = 1.0f;
      }
      else if(hdash < 3.0f) {
        g = 1.0f;
        b = x;
      }
      else if(hdash < 4.0f) {
        g = x;
        b = 1.0f;
      }
      else if(hdash < 5.0f) {
        b = 1.0f;
        r = x;
      }
      else if(hdash < 6.0f) {
        b = x;
        r = 1.0f;
      }
    }
    
    palette[i] = color(r * 255.0f, g * 255.0f, b * 255.0f);
  }
}

void initplasma() {
  int i = 0;
  noiseSeed(1234);
  noiseDetail(3);
  for(int y = 0; y < height; y++) {
    for(int x = 0; x < width; x++, i++) {
      //perlin noise for p1
      p1[i] = (sin(cos(noise((float)x / 40.0f, (float)y / 40.0f, t) * PI) * PI) + 1.0f) * 0.5f;
    }
  }
}

void keyPressed() {
  if(key == 't') {
    enableThresholding = !enableThresholding;
    initcolor();
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
  palette = new color[256];
  
  initcolor();
} 

void drawplasma(float[] pix) {
  img.loadPixels();
  
  int len = img.pixels.length;
  for(int i = 0; i < len; i++) {
    //plasma palette
    float val = (sin(pix[i] * TWO_PI) + 1) * 0.5f;
    img.pixels[i] = palette[floor(val * 255)];
  }
  
  //copy image to screen
  img.updatePixels();
  image(img, 0, 0);
}

void draw() {
  //background(0);
  initplasma();
  drawplasma(p1);
    
  t += dt;
}
