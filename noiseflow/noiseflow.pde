float[] density;
float[] xgradient;
float[] ygradient;
float[] xcurl;
float[] ycurl;
float[] obstacle;
float[] xgo; //x gradient for obstacle
float[] ygo; //y gradient for obstacle
float[] mergex;
float[] mergey;
int cellsize = 10;
int numxcells;
int numycells;
int numcells;

boolean modulate = true;
boolean buoyancy = true;
float floatval = 0.01;
int display = 0;
float obstacleRadius = numxcells / 6.0;
float d0 = constrain(numxcells / 40.0, 4, 1000);
float alphaVal = 0.7;

float minxgrad, minygrad, maxxgrad, maxygrad;
float minxcurl, minycurl, maxxcurl, maxycurl;
float minxgo, minygo, maxxgo, maxygo;
float maxmergex, minmergex, maxmergey, minmergey;

void keyPressed()
{
  if(keyCode == UP) display++;
  if(keyCode == DOWN) display--;
  display = constrain(display, 0, 5);
  
  if(keyCode == LEFT)
  {
    floatval -= 0.1;
    initcells();
  }
  if(keyCode == RIGHT)
  {
    floatval += 0.1;
    initcells();
  }
  
  if(key == 'a' || key == 'A')
  {
    alphaVal += 0.1;
    alphaVal = constrain(alphaVal, 0, 1);
    initcells();
  }
  if(key == 'z' || key == 'Z')
  {
    alphaVal -= 0.1;
    alphaVal = constrain(alphaVal, 0, 1);
    initcells();
  }
}

void sininit()
{
  float mod = 1;
  float step = 1.0 / (float)numycells;
  for(int y = 0; y < numycells; y++)
  {
    mod -= step;
    for(int x = 0; x < numxcells; x++)
    {
      int i = y * numxcells + x;
      float xpos = (x * cellsize) / 10.0;
      float ypos = (y * cellsize) / 10.0;
      density[i] = (1 + sin(xpos + ypos)) / 2;
      xgradient[i] = (((1 + sin(xpos - 0.001 + ypos)) / 2) - ((1 + sin(xpos + 0.001 + ypos)))) / 0.002;
      ygradient[i] = xgradient[i];
      if(modulate)
      {
        density[i] *= mod;
        xgradient[i] *= mod;
        ygradient[i] *= mod;
      }
      if(buoyancy)
      {
        ygradient[i] += floatval;
      }
      xcurl[i] = ygradient[i];
      ycurl[i] = -xgradient[i];
    }
  }
}

void noiseinit()
{
  float mod = 1;
  float step = 1.0 / (float)numycells;
  for(int y = 0; y < numycells; y++)
  {
    mod -= step;
    for(int x = 0; x < numxcells; x++)
    {
      int i = y * numxcells + x;
      float xpos = (x * cellsize) / 20.0;
      float ypos = (y * cellsize) / 20.0;
      density[i] = noise(xpos, ypos);
      xgradient[i] = (noise(xpos - 0.01, ypos) - noise(xpos + 0.01, ypos)) / 0.02;
      ygradient[i] = (noise(xpos, ypos - 0.01) - noise(xpos, ypos + 0.01)) / 0.02;
      if(modulate)
      {
        density[i] *= mod;
        xgradient[i] *= mod;
        ygradient[i] *= mod;
      }
      xcurl[i] = ygradient[i];
      ycurl[i] = -xgradient[i];
    }
  }
}

void minmax()
{
  minxgrad = xgradient[0];
  maxxgrad = xgradient[0];
  minygrad = ygradient[0];
  maxygrad = ygradient[0];
  minxcurl = xcurl[0];
  maxxcurl = xcurl[0];
  minycurl = ycurl[0];
  maxycurl = ycurl[0];
  minxgo = xgo[0];
  maxxgo = xgo[0];
  minygo = ygo[0];
  maxygo = ygo[0];
  minmergex = mergex[0];
  maxmergex = mergex[0];
  minmergey = mergey[0];
  maxmergey = mergey[0];
  
  for(int i = 1; i < numcells; i++)
  {
    if(xgradient[i] < minxgrad) minxgrad = xgradient[i];
    if(xgradient[i] > maxxgrad) maxxgrad = xgradient[i];
    if(ygradient[i] < minygrad) minygrad = ygradient[i];
    if(ygradient[i] > maxygrad) maxygrad = ygradient[i];
    if(xcurl[i] < minxcurl) minxcurl = xcurl[i];
    if(xcurl[i] > maxxcurl) maxxcurl = xcurl[i];
    if(ycurl[i] < minycurl) minycurl = ycurl[i];
    if(ycurl[i] > maxycurl) maxycurl = ycurl[i];
    if(xgo[i] < minxgo) minxgo = xgo[i];
    if(xgo[i] > maxxgo) maxxgo = xgo[i];
    if(ygo[i] < minygo) minygo = ygo[i];
    if(ygo[i] > maxygo) maxygo = ygo[i];
    if(mergex[i] < minmergex) minmergex = mergex[i];
    if(mergex[i] > maxmergex) maxmergex = mergex[i];
    if(mergey[i] < minmergey) minmergey = mergey[i];
    if(mergey[i] > maxmergey) maxmergey = mergey[i];
  }
}

float ramp(float r)
{
  //from Curl-Noise for Procedural Flow by Robert Bridson
  if(r >= 1) return 1;
  if(r <= -1) return -1;
  float retval = 15 * r;
  retval += 10 * r * r * r;
  retval += 3 * r * r * r * r * r;
  retval /= 8.0;
  return retval;
}

float obstacleSample(float x, float y)
{
  float dx = (numxcells / 2) - x;
  float dy = (numycells / 2) - y;
  float d = sqrt(dx * dx + dy * dy);
  
  //solid circle
  /*
  if(d < obstacleRadius)
  {
    return -1;
  }
  else
  {
    return 1;
  }
  */
  
  //blurred edges as recommended by the original non-divergent noise paper
  return ramp((d - obstacleRadius) / d0);
}

void initobstacle()
{
  int i = 0;
  float e = 1;
  for(int y = 0; y < numycells; y++)
  {
    for(int x = 0; x < numxcells; x++, i++)
    {
      obstacle[i] = obstacleSample(x, y);
      xgo[i] = (obstacleSample(x - e, y) - obstacleSample(x + e, y)) / (2 * e);
      ygo[i] = (obstacleSample(x, y - e) - obstacleSample(x, y + e)) / (2 * e);
      if(buoyancy)
      {
        ygo[i] += floatval;
      }
    }
  }
}

void merge()
{
  for(int i = 0; i < numcells; i++)
  {
    mergex[i] = (alphaVal * xgo[i]) + ((1.0 - alphaVal) * xcurl[i]);
    mergey[i] = (alphaVal * ygo[i]) + ((1.0 - alphaVal) * ycurl[i]);
  }
}

void initcells()
{
  //sininit();
  noiseinit();
  initobstacle();
  merge();
  minmax();
}

void setup()
{
  size(400, 400);
  background(0);
  noStroke();
  
  numxcells = width / cellsize;
  numycells = height / cellsize;
  
  numcells = numxcells * numycells;
  
  density = new float[numcells];
  xgradient = new float[numcells];
  ygradient = new float[numcells];
  xcurl = new float[numcells];
  ycurl = new float[numcells];
  obstacle = new float[numcells];
  xgo = new float[numcells];
  ygo = new float[numcells];
  mergex = new float[numcells];
  mergey = new float[numcells];
  
  initcells();
}

void draw()
{
  float xgradrange = maxxgrad - minxgrad;
  float ygradrange = maxygrad - minygrad;
  float xcurlrange = maxxcurl - minxcurl;
  float ycurlrange = maxycurl - minycurl;
  float xgorange = maxxgo - minxgo;
  float ygorange = maxygo - minygo;
  float mergexrange = maxmergex - minmergex;
  float mergeyrange = maxmergey - minmergey;
  
  for(int y = 0; y < numycells; y++)
  {
    for(int x = 0; x < numxcells; x++)
    {
      int i = y * numxcells + x;
      if(display == 0)
      {
        fill(constrain(density[i] * 255, 0, 255));
      }
      else if(display == 1)
      {
        float cx = (xgradient[i] - minxgrad) / xgradrange;
        float cy = (ygradient[i] - minygrad) / ygradrange;
        fill(constrain(cx * 255, 0, 255), constrain(cy * 255, 0, 255), 0);
      }
      else if(display == 2)
      {
        float cx = (xcurl[i] - minxcurl) / xcurlrange;
        float cy = (ycurl[i] - minycurl) / ycurlrange;
        fill(constrain(cx * 255, 0, 255), constrain(cy * 255, 0, 255), 0);
      }
      else if(display == 3)
      {
        fill(constrain((obstacle[i] + 1) * 128, 0, 255));
      }
      else if(display == 4)
      {
        float cx = (xgo[i] - minxgo) / xgorange;
        float cy = (ygo[i] - minygo) / ygorange;
        fill(constrain(cx * 255, 0, 255), constrain(cy * 255, 0, 255), 0);
      }
      else if(display == 5)
      {
        float cx = (mergex[i] - minmergex) / mergexrange;
        float cy = (mergey[i] - minmergey) / mergeyrange;
        fill(constrain(cx * 255, 0, 255), constrain(cy * 255, 0, 255), 0);
      }
      rect(cellsize * x, cellsize * y, cellsize, cellsize);
    }
  }
}
