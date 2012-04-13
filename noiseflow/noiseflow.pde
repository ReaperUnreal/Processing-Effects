float[] density;
float[] xgradient;
float[] ygradient;
int cellsize = 1;
int numxcells;
int numycells;
int numcells;

float minxgrad, minygrad, maxxgrad, maxygrad;

void sininit()
{
  for(int y = 0; y < numycells; y++)
  {
    for(int x = 0; x < numxcells; x++)
    {
      int i = y * numxcells + x;
      float xpos = (x * cellsize) / 10.0;
      float ypos = (y * cellsize) / 10.0;
      density[i] = (1 + sin(xpos + ypos)) / 2;
      xgradient[i] = (((1 + sin(xpos - 0.001 + ypos)) / 2) - ((1 + sin(xpos + 0.001 + ypos)))) / 0.002;
      ygradient[i] = xgradient[i];
    }
  }
}

void noiseinit()
{
  for(int y = 0; y < numycells; y++)
  {
    for(int x = 0; x < numxcells; x++)
    {
      int i = y * numxcells + x;
      float xpos = (x * cellsize) / 20.0;
      float ypos = (y * cellsize) / 20.0;
      density[i] = noise(xpos, ypos);
      xgradient[i] = (noise(xpos - 0.01, ypos) - noise(xpos + 0.01, ypos)) / 0.02;
      ygradient[i] = (noise(xpos, ypos - 0.01) - noise(xpos, ypos + 0.01)) / 0.02;
    }
  }
}

void minmax()
{
  minxgrad = xgradient[0];
  maxxgrad = xgradient[0];
  minygrad = ygradient[0];
  maxygrad = ygradient[0];
  
  for(int i = 1; i < numcells; i++)
  {
    if(xgradient[i] < minxgrad) minxgrad = xgradient[i];
    if(xgradient[i] > maxxgrad) maxxgrad = xgradient[i];
    if(ygradient[i] < minygrad) minygrad = ygradient[i];
    if(ygradient[i] > maxygrad) maxygrad = ygradient[i];
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
  
  initcells();
}

void draw()
{
  float xgradrange = maxxgrad - minxgrad;
  float ygradrange = maxygrad - minygrad;
  
  for(int y = 0; y < numycells; y++)
  {
    for(int x = 0; x < numxcells; x++)
    {
      int i = y * numxcells + x;
      //fill(constrain(density[i] * 255, 0, 255));
      float cx = (xgradient[i] - minxgrad) / xgradrange;
      float cy = (ygradient[i] - minygrad) / ygradrange;
      fill(constrain(cx * 255, 0, 255), constrain(cy * 255, 0, 255), 0);
      rect(cellsize * x, cellsize * y, cellsize, cellsize);
    }
  }
}
