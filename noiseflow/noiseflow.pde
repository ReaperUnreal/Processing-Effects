float[] density;
int cellsize = 10;
int numxcells;
int numycells;
int numcells;

void initcells()
{
  for(int y = 0; y < numycells; y++)
  {
    for(int x = 0; x < numxcells; x++)
    {
      int i = y * numxcells + x;
      density[i] = (1 + sin(x + y)) / 2;
    }
  }
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
  
  initcells();
}

void draw()
{
  for(int y = 0; y < numycells; y++)
  {
    for(int x = 0; x < numxcells; x++)
    {
      int i = y * numxcells + x;
      fill(constrain(density[i] * 255, 0, 255));
      rect(cellsize * x, cellsize * y, cellsize, cellsize);
    }
  }
}
