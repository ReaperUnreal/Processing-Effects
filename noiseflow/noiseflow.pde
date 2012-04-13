float[] density;
float[] xgradient;
float[] ygradient;
float[] xcurl;
float[] ycurl;
int cellsize = 1;
int numxcells;
int numycells;
int numcells;

boolean modulate = true;
boolean buoyancy = true;
float floatval = 0.01;

int display = 0;

float minxgrad, minygrad, maxxgrad, maxygrad;
float minxcurl, minycurl, maxxcurl, maxycurl;

void keyPressed()
{
  if(keyCode == UP) display++;
  if(keyCode == DOWN) display--;
  display = constrain(display, 0, 2);
  
  if(keyCode == LEFT)
  {
    floatval -= 0.1;
    noiseinit();
  }
  if(keyCode == RIGHT)
  {
    floatval += 0.1;
    noiseinit();
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
      if(buoyancy)
      {
        ygradient[i] += floatval;
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
  }
}

void initcells()
{
  //sininit();
  noiseinit();
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
  
  initcells();
}

void draw()
{
  float xgradrange = maxxgrad - minxgrad;
  float ygradrange = maxygrad - minygrad;
  float xcurlrange = maxxcurl - minxcurl;
  float ycurlrange = maxycurl - minycurl;
  
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
      rect(cellsize * x, cellsize * y, cellsize, cellsize);
    }
  }
}
