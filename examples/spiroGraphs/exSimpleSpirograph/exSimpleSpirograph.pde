 
int R = 130;         //Outer radius
int r = 90;          //Iner radius
int O = 90;           //Offset
float swidth = 1.8;  // Stroke width
int iter = 500;      // Numer of iterations
 
float x;
float y;
float ox = 0;
float oy = 0;
int offx;
int offy;
int t = 0;
 
void setup(){
  size(400,400);
  offx = width/2;
  offy = height/2;
  colorMode(HSB, iter);
  strokeWeight(swidth);
  background(0);
  smooth();
}
 
void draw(){
  if (t <= iter){
    x = (R+r)*cos(t) - (r+O)*cos(((R+r)/r)*t)+offx;
    y = (R+r)*sin(t) - (r+O)*sin(((R+r)/r)*t)+offy;
    stroke(t, iter/1.5, iter);
    //point (x, y);  //<- points
    if (ox != 0 && oy != 0){
      line (ox, oy, x, y);  //<-lines
    }
    ox = x;
    oy = y;
    t++;
  }
}
 
