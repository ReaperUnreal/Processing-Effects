float[] vertices = {-1, -1, -1, 1, //0
                    -1, -1, 1, 1, //1
                    1, -1, -1, 1, //2
                    1, -1, 1, 1, //3
                    -1, 1, -1, 1, //4
                    1, 1, -1, 1, //5 
                    -1, 1, 1, 1, //6
                    1, 1, 1, 1, //7
                    
                    -1, -1, -1, -1, //8
                    -1, -1, 1, -1, //9
                    1, -1, -1, -1, //10
                    1, -1, 1, -1, //11
                    -1, 1, -1, -1, //12
                    1, 1, -1, -1, //13
                    -1, 1, 1, -1, //14
                    1, 1, 1, -1}; //15
                    
int numVertices = 8 + 8;
                    
int[] edges = {0, 1, //cube 1
               0, 2,
               0, 4,
               1, 6,
               1, 3,
               2, 5,
               2, 3,
               3, 7,
               4, 6,
               4, 5,
               5, 7,
               6, 7,
               
               8, 9, //cube 2
               8, 10,
               8, 12,
               9, 14,
               9, 11,
               10, 13,
               10, 11,
               11, 15,
               12, 14,
               12, 13,
               13, 15,
               14, 15,
               
               0, 8, //hypercube
               1, 9,
               2, 10,
               3, 11,
               4, 12,
               5, 13,
               6, 14,
               7, 15};
               
int numEdges = 12 + 12 + 8;
                    
float alpha = 0.05;
float ca = cos(alpha);
float sa = sin(alpha);
float s2a, c2a, sca, c3a, sc2a, s2ca, s3ca, s3a;
float zdist = 7;
float xoff = 0;
float yoff = 0;
int centerx = (width / 2);
int centery = (height / 2);
float noiseScale = 30;
float omega = 0.05;
float cm = cos(omega);
float sm = sin(omega);
int detail = 2;
PImage img;
float b[];
 
void clearImage(PImage img) {
  img.loadPixels();
  for(int i = 0; i < img.pixels.length; i++) {
    img.pixels[i] = color(255, 255, 255, 0); // white
  }
  img.updatePixels();
}

void setupBrightnessArray() {
  b = new float[width * height];
}
 
void setup() {
    colorMode(RGB);
    background(0);
    smooth();
    fill(255);
    size(400, 400); 
    frameRate(30);
    img = createImage(400, 400, ARGB);
    clearImage(img);
                    
    ca = cos(alpha);
    sa = sin(alpha);
    s2a = sa * sa;
    c2a = ca * ca;
    sca = sa * ca;
    c3a = c2a * ca;
    sc2a = sa * c2a;
    s2ca = s2a * ca;
    s3ca = s2ca * sa;
    s3a = s2a * sa;
    
    cm = cos(omega);
    sm = sin(omega);
    
    setupBrightnessArray();
} 

void keyPressed() {
    if(keyCode == UP)
        detail++;
    if(keyCode == DOWN)
        detail--;
    constrain(detail, 2, 10);
}
 
void rotate() {
    //xw yw zw
    //c -s2 -s2c -sc2
    //0 c -s2 -sc
    //0 0 c2 -sc
    //s sc sc2 c3
    
    //xw yw
    //c -s2 0 -sc
    //0 c 0 -s
    //0 0 c 0
    //s sc 0 c2
    
    //xz
    //c 0 -s 0
    //0 1 0 0
    //s 0 c 0
    //0 0 0 1
    
    for(int i = 0; i < numVertices * 4; i += 4) {
        float x = vertices[i];
        float y = vertices[i + 1];
        float z = vertices[i + 2];
        float w = vertices[i + 3];
        
        /*
        //xy zw
        vertices[i] = (ca * x) - (sa * y);
        vertices[i + 1] = (sa * x) + (ca * y);
        vertices[i + 2] = (ca * z) - (sa * w);
        vertices[i + 3] = (sa * z) + (ca * w);
        */
        
        vertices[i] = (ca * x) - (s2a * y) - (s2ca * z) - (sc2a * w);
        vertices[i + 1] = (ca * y) - (s2a * z) - (sca * w);
        vertices[i + 2] = (c2a * z) - (sca * w);
        vertices[i + 3] = (sa * x) + (sca * y) + (sc2a * z) + (c3a * w);
        
        /*
        vertices[i] = (ca * x) - (s2a * y) - (sca * w);
        vertices[i + 1] = (ca * y) - (sa * w);
        vertices[i + 2] = ca * z;
        vertices[i + 3] = (sa * x) + (sca * y) + (c2a * w);
        */
        x = vertices[i];
        z = vertices[i + 2];
        vertices[i] = (x * ca) - (z * sa);
        vertices[i + 2] = (x * sa) + (z * ca);
    }
}

void noiseline(float sx, float sy, float sz, float ex, float ey, float ez, int d) {
    if(d < 2) d = 2;
    if(d > 10) d = 10;
    
    float[] xs = new float[d];
    float[] ys = new float[d];
    float[] zs = new float[d];
    float n;
    xs[0] = sx;
    ys[0] = sy;
    zs[0] = sz;
    xs[d - 1] = ex;
    ys[d - 1] = ey;
    zs[d - 1] = ez;
    
    float stepSize = 1.0 / (d - 1);
    float pos = stepSize;
    for(int i = 1; i < d - 1; i++, pos += stepSize) {
        xs[i] = lerp(xs[0], xs[d - 1], pos);
        ys[i] = lerp(ys[0], ys[d - 1], pos);
        zs[i] = lerp(zs[0], zs[d - 1], pos);
        n = (noise(zs[i]) - 0.5) * noiseScale;
        xs[i] += n;
        ys[i] += n;
    }
    
    noFill();
    beginShape();
    //repeat first and last to start at correct places
    curveVertex(xs[0], ys[0]);
    for(int i = 0; i < d; i++) {
        curveVertex(xs[i], ys[i]);
    }
    curveVertex(xs[d - 1], ys[d - 1]);
    endShape();
}

void whiteBlur(int blurSize) {
  //validate parms
  if(blurSize < 1) blurSize = 1;
  if(blurSize > 50) blurSize = 50;
  int blurOff = floor(blurSize / 2.0);
  //load our image so far
  loadPixels();
  
  //load our glow plane
  img.loadPixels();
  
  //create brightness array
  int len = pixels.length;
  for(int i = 0; i < len; i++) {
    b[i] = brightness(pixels[i]);
  }
  
  //alpha increments  
  int i = 0;
  for(int y = 0; y < height; y++) {
    int sy = max(0, y - blurOff - 1);
    int ey = min(height - 1, y + blurOff);
    
    for(int x = 0; x < width; x++, i++) {
      int sx = max(0, x - blurOff - 1);
      int ex = min(width - 1, x + blurOff);
      
      float sum = 0;
      int count = 0;
      int sample;
      for(int row = sy; row < ey; row++) {
        sample = row * width + sx;
        for(int col = sx; col < ex; col++, count++, sample++) {
          sum += b[sample];
        }
      }
      sum /= float(count);
      img.pixels[i] = color(int(sum));
    }
  }
  
  //done with the glow
  img.updatePixels();
  
  //draw the glow
  //image(img, 0, 0);
  
  //blend the glow
  blend(img, 0, 0, width, height, 0, 0, width, height, LIGHTEST);
}
 
void draw() {
    background(0);
    
    //perspective divide
    float[] screenVertices = new float[numVertices * 3];
    for(int i = 0; i < numVertices; i++) {
        float z = vertices[i * 4 + 2] + zdist;
        screenVertices[i * 3 + 2] = z;
        if(z > 0) {
            float invz = 1.0 / z;
            float scaler = invz * width;
            screenVertices[i * 3] = (vertices[i * 4] + xoff) * scaler + (width / 2);
            screenVertices[i * 3 + 1] = (vertices[i * 4 + 1] + yoff) * scaler + (height / 2);
        }
    }
    
    //draw edges
    stroke(255);
    strokeWeight(2);
    for(int i = 0; i < numEdges * 2; i += 2) {
        int sv = edges[i];
        int ev = edges[i + 1];
        noiseline(screenVertices[sv * 3], screenVertices[sv * 3 + 1], screenVertices[sv * 3 + 2],
                  screenVertices[ev * 3], screenVertices[ev * 3 + 1], screenVertices[ev * 3 + 2],
                  detail);
    }
    
    //blur white parts for fun
    whiteBlur(5);
    
    //draw vertices
    noStroke();
    colorMode(HSB, 256);
    for(int i = 0; i < numVertices * 3; i += 3) {
        float z = screenVertices[i + 2];
        if(z > 0) {
            float x = screenVertices[i];
            float y = screenVertices[i + 1];
            int h = int(50 * z) % 256;
            fill(h, 255, 255);
            ellipse(x, y, 10, 10);
        }
    }
    colorMode(RGB);
    
    //rotate hypercube
    rotate();
}
