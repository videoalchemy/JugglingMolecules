/*jasonStephens
thesis ITP spring 2012
evTherapy - create evProjectedObject

started with G.Bornestein's closest pixel example

HISTORY:
1. added mousePress function to get mouseCordinates for bounding box
dimensions needed around massage table.  current closest pixels are curtains

TODO:
____create a bounding box for depth measurements using thresholds

*/


import SimpleOpenNI.*;
SimpleOpenNI  kinect;

float brightestValue;
int brightestX;
int brightestY;

float sendClosestValue;

//bounding box threholds



void setup()
{
  size(640, 480);
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  PVector mouseLoc = new PVector(mouseX, mouseY, 0);
}

void draw()
{
  brightestValue = 0;
  kinect.update();

//  //setup bounding box threshold values here:
//  int[] depthValues = kinect.depthMap();
//  for (int x = 115; x < 560; x++) {
//    for (int y = 130; y < 340; y++) {
//      int i = x + y * 640;
//
//      int currentDepthValue = depthValues[i];
//
//      if (currentDepthValue > brightestValue) {
//        brightestValue = currentDepthValue;
//        brightestX = x;
//        brightestY = y;
//      }
//    }
//  }

 ////setup threshold values here:
 int[] depthValues = kinect.depthMap();
  for(int x = 0; x < 640; x++){
    for(int y = 0; y < 480; y++){
        int i = x + y * 640;
//  //      
       int currentDepthValue = depthValues[i];
//  //      
        if(currentDepthValue > brightestValue){
         brightestValue = currentDepthValue;
         brightestX = x;
         brightestY = y;
        }
      }
   }

  image(kinect.depthImage(), 0, 0);

  float closestValueInInches = brightestValue / 25.4;
  sendClosestValue = closestValueInInches;

  fill(255, 0, 0);
  ellipse(brightestX, brightestY, 25, 25);
}

void mousePressed() {
  color c = get(mouseX, mouseY);
  print("in: " + sendClosestValue);
  println("r: " + red(c) + " g: " + green(c) + " b: " + blue(c));
float xLoc = mouseX;
float yLoc = mouseY;

    println ("x = " + xLoc + "y = " + yLoc);
}

