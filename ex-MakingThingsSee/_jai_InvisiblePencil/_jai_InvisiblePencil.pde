/* jason stephens - Making Things See Examples
 4Jan2012
 Branch = InvisiblePencil
 
 TODO:
 _____stage this file by saving it, then commit it, then check the results
 _____write the initial code without looking ....
 _____implement the InvisibleScratchPicklePencil
 _____strategies for building up information about the depth information across multiple frames
 _____using global variables to save the closest point in a particular depth image so as to be available when processing depth image
 _____use older point to smoothout the movement of red circle at closest point by averaging the current closest with previous closest
 _____use current and previous closest point to draw a line.
 _____eliminate the large abrubt jumps by tightening down the focus of the tracking to a depth range 2-5ft
 _____eliminate the tiny jitters, smooth out the movement of the line by "interplating" between each previous point and each new point
 _____use interpolation
 _____mirror the screen so we're not backwards!  To convert the Kinect's image into a mirror image,  flip the order of the depth points on the x-axis
 _____what is Kid-nap-ed.  Well that's just like, uh, your opinion, man
 _____lerp()  Linear interpolation function?  calculates a number between two numbers at a specific increment
 _____Mirror image of the depth data.  1. create reversedX, then calculate using new pixel cordinates convert to 1D array location.
 
 
 
 Notes:
 ->Chapter 4: Working With Skeleton Data (p.200)
 
 ->Interpolation:  the process of filling in the missing space between two known points.  For this sketch, rather than jumping to the
 next point, we'll orient our line towards that next point but only take the first step in that direction.  If we do this for every new
 closest point, we'll always be following the user's input,but we'll do so along a much smoother path.
 
 MirroredScreen AND Mirrored ArrayList:  reverse X by moving in from the right side of the screen.  Do this by reversing it inside the for-loop.
 The for-loop counts up to 639 from 0.  next line inverses the increasing x count by adding another variable to hold the result of subtracting
 the increasing x value of the for-loop count from the total length of the screen.  int reverseX = screen.width - x -1 //where -1 makes sure
 the count stays within 0-639.
 */

import SimpleOpenNI.*;
SimpleOpenNI kinect;

int closestValue;
int closestX;
int closestY;

float lastX;
float lastY;


float lineSize;// for controlling stroke weight

void setup() {
  size (640, 480);

  //initialize the kinect instance of the object SimpleOpenNI
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  
  //start with a black background
  background(0);
}

void draw () {
  closestValue = 8000; //setting the parameters

  kinect.update();

  //create and populate the array of depthMap values
  int[]depthValues = kinect.depthMap();

  //go through each row all the way down, and in each row, go all the way to screen.width scanning each pixel
  for (int y= 0; y<480; y++) { 
    for (int x = 0; x<640; x++) {  //increases count from 0-639

      //convert each xy coordinate into an integer representng the xy's associative index #, then get depth value

      //reverse x by moving in from the right side of the image
      int reversedX = 640-x-1; // REVERSES THE FOR-LOOP countup to countdown from 639, 

      //use reveredX to calculate the array index for mirrired image
      int i = reversedX + y*640; //array index calculation from REVERSE SCREEN DIRECTION as if my hand is writing on paper
      //int i = x + (y*640); // array index calculation STANDARD SCREEN DIRECTION as if I'm seen by others, my left hand is on their right side, 

      int currentDepthValue = depthValues[i];

      // now look for values only within a certain range of depth.  create depth criteria
      // 610 millimeters (2 feet) is the min
      // 1525 milli (5feet) is max

      if (currentDepthValue > 610 && currentDepthValue < 1525 && currentDepthValue < closestValue) { //love the logical run on sentence
        closestValue = currentDepthValue;
        closestX = x;
        closestY = y;
      }
    }
  }
  
  //"linear interpolation," i.e. smooth transition between last point and new closest point
  float interpolatedX = lerp(lastX, closestX, 0.3f); //
  float interpolatedY = lerp (lastY, closestY, 0.3f); //

// create a strokeWeight that increases relative to rate of hand movement (and therefor increased distance between current and previous)
// get distance return from 2 points, then map to usable size, then use as a variable for strokeWeight
  lineSize = dist(lastX, lastY, closestX, closestY);
  lineSize = map(lineSize, 0, 640, 0, 9);
  
  
   stroke (255, 0, 0);
   strokeWeight(lineSize); //when using the strokeWeight relative to hand rate
   //strokeWeight(3); //cause it looks nice
   
  line (lastX, lastY, interpolatedX, interpolatedY);
  
  //then change the guard. our new "lastPoint" is the previous interpolated calculation.  lerp seems like a dynamic scalar based on relative values
  lastX= interpolatedX;
  lastY=interpolatedY;
}


void mousePressed () {
  //save the image to a file then clear screen
  int r = int (random (50000));
  save((r) +"drawing.png");
  background(0);
}


