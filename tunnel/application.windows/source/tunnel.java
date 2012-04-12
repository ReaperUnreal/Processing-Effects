import processing.core.*; 
import processing.xml.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class tunnel extends PApplet {

int detail = 2;
PImage img;
float[] tunnel;
float[] tunnelv;

float t = 0;
float dt = 0.04f;

int theight;
int twidth;
 
public void clearImage(PImage img) {
  img.loadPixels();
  for(int i = 0; i < img.pixels.length; i++) {
    img.pixels[i] = color(255, 255, 255); // white
  }
  img.updatePixels();
}

public void inittunnel() {
  tunnel = new float[twidth * theight];
  tunnelv = new float[twidth * theight];
  int i = 0;
  for(int y = 0; y < theight; y++) {
    float dy = PApplet.parseFloat(2 * y - theight) / PApplet.parseFloat(theight);
    for(int x = 0; x < twidth; x++, i++) {
      float dx = PApplet.parseFloat(2 * x - twidth) / PApplet.parseFloat(twidth);
      float s = 1.0f / sqrt(dx * dx + dy * dy);
      tunnel[i] = s;
      
      float v = (atan2(dy, dx) / TWO_PI) + 0.5f;
      tunnelv[i] = constrain(v, 0, 1);
    }
  }
}
 
public void setup() {
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

public void keyPressed() {
    if(keyCode == UP)
        detail++;
    if(keyCode == DOWN)
        detail--;
    constrain(detail, 2, 10);
}

public void drawtunnel() {
  img.loadPixels();
  
  int len = img.pixels.length;
  for(int i = 0; i < len; i++) {
    //mad hax: can precompute the entire tunnel and fake moving by just adding t to the values that come out
    float u = tunnel[i] + t;
    float v = tunnelv[i] + (0.1f * t);
    
    //make a checkerboard pattern
    boolean white = false;
    
    if(PApplet.parseInt(u * 2) % 2 == 0) {
      white = !white;
    }
    
    if(PApplet.parseInt(v * 10) % 2 == 0) {
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
  float mx = sin(cos(t * 0.5f) * TWO_PI);
  float my = sin(sin(t * 0.5f) * TWO_PI);
  cx += PApplet.parseInt(50 * mx);
  cy += PApplet.parseInt(50 * my);
  
  int sx = (width / 2) - cx;
  int sy = (height / 2) - cy;
  
  image(img, sx, sy);
}

public void draw() {
    background(0);
    
    drawtunnel();
    t += dt;
}
  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#F0F0F0", "tunnel" });
  }
}
