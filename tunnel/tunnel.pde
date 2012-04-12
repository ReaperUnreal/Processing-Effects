PImage img;
float[] tunnel;
float[] tunnelv;

float t = 0;
float dt = 0.04;

int theight;
int twidth;
 
void clearImage(PImage img) {
  img.loadPixels();
  for(int i = 0; i < img.pixels.length; i++) {
    img.pixels[i] = color(255, 255, 255); // white
  }
  img.updatePixels();
}

void inittunnel() {
  tunnel = new float[twidth * theight];
  tunnelv = new float[twidth * theight];
  int i = 0;
  for(int y = 0; y < theight; y++) {
    float dy = float(2 * y - theight) / float(theight);
    for(int x = 0; x < twidth; x++, i++) {
      float dx = float(2 * x - twidth) / float(twidth);
      float s = 1.0 / sqrt(dx * dx + dy * dy);
      tunnel[i] = s;
      
      float v = (atan2(dy, dx) / TWO_PI) + 0.5;
      tunnelv[i] = constrain(v, 0, 1);
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
    theight = height * 2;
    twidth = width * 2;
    img = createImage(twidth, theight, RGB);
    clearImage(img);
    
    inittunnel();
} 

void drawtunnel() {
  img.loadPixels();
  
  int len = img.pixels.length;
  for(int i = 0; i < len; i++) {
    //mad hax: can precompute the entire tunnel and fake moving by just adding t to the values that come out
    float u = tunnel[i] + t;
    float v = tunnelv[i] + (0.1 * t);
    
    //make a checkerboard pattern
    boolean white = false;
    
    if(int(u * 2) % 2 == 0) {
      white = !white;
    }
    
    if(int(v * 10) % 2 == 0) {
      white = !white;
    }
    
    if(white) {
      img.pixels[i] = color(255);
    }
    else {
      img.pixels[i] = color(0);
    }
  }
  
  img.updatePixels();
  
  int cx = twidth / 2;
  int cy = theight / 2;
  
  //move the middle
  //mad hax part 2: by precomputing a larger area and changing the center, it looks like the camera is panning around
  float mx = sin(cos(t * 0.5) * TWO_PI);
  float my = sin(sin(t * 0.5) * TWO_PI);
  cx += int(50 * mx);
  cy += int(50 * my);
  
  int sx = (width / 2) - cx;
  int sy = (height / 2) - cy;
  
  image(img, sx, sy);
}

void draw() {
    background(0);
    
    drawtunnel();
    t += dt;
}
