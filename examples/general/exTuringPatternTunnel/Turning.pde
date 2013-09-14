/////////////////////////////////////////////////
//                                             //
//    The Secret Life of Turing Patterns       //
//                                             //
/////////////////////////////////////////////////
 
// Inspired by the work of Jonathan McCabe
// (c) Martin Schneider 2010
 
// for original code of "Turning Patterns" see...
//   http://openprocessing.org/visuals/?visualID=17043
 
int scl = 4, dirs = 19, lim = 128;
int res = 5, patternId = 2, bluring = 0;
int dx, dy, w, h, imgSize;
float[] pat;
PImage img;
   
void keyPressed2()
{
  switch(key) {
    case 'b': bluring = (bluring + 1) % 2;  doTuring();  break;
    case 'p': patternId = (patternId + 1) % 3;  break;
    case 'r': res = 3;  resetTuring();  doTuring(); break;
    case '+': lim = min(lim+8, 255);  break;
    case '-': lim = max(lim-8, 0);  break;
    case CODED:
      switch(keyCode) {
        case LEFT:  scl = max(scl-1, 2); break;
        case RIGHT: scl = min(scl+1, 6); break;
        case UP:    res = max(res-1, 2); resetTuring(); doTuring(); break;
        case DOWN:  res = min(res+1, 4); resetTuring(); doTuring(); break;
      }
      break;
  }
}
  
// moving the canvas
void mouseDragged()
{
  if(mousePressed)
  {
    dy = mod(dx - mouseX + pmouseX, width);
    dx = mod(dy + mouseY - pmouseY, height);
  }
}
  
void resetTuring()
{
  colorMode(HSB);
  w = 512/res;
  h = 512/res;
  imgSize = w*h;
  img = createImage(w, h, RGB);
  pat = new float[imgSize];
  // random init
  for(int i=0; i<imgSize; i++)
    pat[i] = floor(random(256));
}
  
void doTuring()
{
  // calculate a single pattern step
  pattern();
    
  // draw chemicals to the canvas
  img.loadPixels();
  for(int y=0; y<h; y++)
    for(int x=0; x<w; x++)
    { int c = (x+dx/res)%w + ((y+dy/res)%h)*w;
      float val = pat[x+y*w];
      img.pixels[c] = color(val, 255-val, 100 + val / 2);
//      img.pixels[c] = color(255-val, 255-val, 100+val / 2);
    }
  img.updatePixels();
    
  if (bluring == 1) img.filter(BLUR);
}
  
// floor modulo
final int mod(int a, int n)
{
  return a>=0 ? a%n : (n-1)-(-a-1)%n;
}
 
 
//--------------------------------------------------------
// this is where the magic happens ...
  
void pattern()
{
  // random angular offset
  float R = random(TWO_PI);
  
  // copy chemicals
  float[] pnew = new float[imgSize];
  for(int i=0; i<imgSize; i++) pnew[i] = pat[i];
  
  // create matrices
  float[][] pmedian = new float[imgSize][scl];
  float[][] prange = new float[imgSize][scl];
  float[][] pvar = new float[imgSize][scl];
  
  // iterate over increasing distances
  for(int i=0; i<scl; i++)
  {
    float d = (2<<i) ;
      
    // update median matrix
    for(int j=0; j<dirs; j++)
    {
      float dir = j*TWO_PI/dirs + R;
      int dx = int (d * cos(dir));
      int dy = int (d * sin(dir));
      for(int l=0; l<imgSize; l++)
      {
        // coordinates of the connected cell
        int x1 = l%w + dx, y1 = l/w + dy;
        // skip if the cell is beyond the border or wrap around
        if(x1<0) x1 = w-1-(-x1-1)% w; else if(x1>=w) x1 = x1%w;
        if(y1<0) y1 = h-1-(-y1-1)% h; else if(y1>=h) y1 = y1%h;
        // update median
        pmedian[l][i] += pat[x1+y1*w] / dirs;
      }
    }
      
    // update range and variance matrix
    for(int j=0; j<dirs; j++)
    {
      float dir = j*TWO_PI/dirs + R;
      int dx = int (d * cos(dir));
      int dy = int (d * sin(dir));
      for(int l=0; l<imgSize; l++)
      {
        // coordinates of the connected cell
        int x1 = l%w + dx, y1 = l/w + dy;
        // skip if the cell is beyond the border or wrap around
        if(x1<0) x1 = w-1-(-x1-1)% w; else if(x1>=w) x1 = x1%w;
        if(y1<0) y1 = h-1-(-y1-1)% h; else if(y1>=h) y1 = y1%h;
        // update variance
        pvar[l][i] += abs( pat[x1+y1*w]  - pmedian[l][i] ) / dirs;
        // update range
        prange[l][i] += pat[x1+y1*w] > (lim + i*10) ? +1 : -1;  
      }
    }   
  }
  
  for(int l=0; l<imgSize; l++)
  {   
    // find min and max variation
    int imin=0, imax=scl;
    float vmin = MAX_FLOAT;
    float vmax = -MAX_FLOAT;
    for(int i=0; i<scl; i++)
    {
      if (pvar[l][i] <= vmin) { vmin = pvar[l][i]; imin = i; }
      if (pvar[l][i] >= vmax) { vmax = pvar[l][i]; imax = i; }
    }
      
    // turing pattern variants
    switch(patternId)
    { case 0: for(int i=0;    i<=imin; i++) pnew[l] += prange[l][i]; break;
      case 1: for(int i=imin; i<=imax; i++) pnew[l] += prange[l][i]; break;
      case 2: for(int i=imin; i<=imax; i++) pnew[l] += prange[l][i] + pvar[l][i]/2; break;
    }
  }
  
  // rescale values
  float vmin = MAX_FLOAT;
  float vmax = -MAX_FLOAT;
  for(int i=0; i<imgSize; i++) 
  {
    vmin = min(vmin, pnew[i]);
    vmax = max(vmax, pnew[i]);
  }     
  float dv = vmax - vmin;
  for(int i=0; i<imgSize; i++)
    pat[i] = (pnew[i] - vmin) * 255 / dv;
}

