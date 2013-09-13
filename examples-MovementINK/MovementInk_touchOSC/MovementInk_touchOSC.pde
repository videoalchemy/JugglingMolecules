/*jason stephens::ITP
Movement Ink::
2011April::Intelligent Healing Spaces::Moving Image Project Development
2012May::evTherapy::Thesis

 * CREDIT::
 *  NOISE INK::Created by Trent Brooks, http://www.trentbrooks.com
 * Special thanks to Daniel Shiffman for the openkinect libraries 
 * Generative Gestaltung (http://www.generative-gestaltung.de/) for 
 * perlin noise articles. Patricio Gonzalez Vivo ( http://www.patriciogonzalezvivo.com )
 * & Hidetoshi Shimodaira (shimo@is.titech.ac.jp) for Optical Flow example
 * (http://www.openprocessing.org/visuals/?visualID=10435). 
 * Memotv (http://www.memo.tv/msafluid_for_processing) for inspiration. 
 * Creative Commons Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)
 * http://creativecommons.org/licenses/by-sa/3.0/
 **/

/**
 * CONTROLS
 * space = toggle menu options for kinect
 * a,z = adjust minimum kinect depth
 * s,x = adjust maximum kinect depth
 * d,c = adjust minimum kinect depth (+/- 1);
 * f,v = adjust maximum kinect depth (+/- 1);
 **/
 /*::TODO::
 ____Adding the control P5 stuff
*/


import controlP5.*;
import oscP5.*;  // ipad action
import netP5.*;

OscP5 oscP5;

//------------------ControlP5
ControlP5 controlP5;
ControlWindow controlWindow;
public int MaxForce = 50;
public int MaxSpeed = 50;
public int SeekStrength = 50;
public int SeparationStrength = 50;
public int Allignment = 50;
public int Cohesion = 50;
public int Indirection = 0;

import processing.video.*;
import processing.opengl.*;
import javax.media.opengl.*;


ParticleManager particleManager;
Kinecter kinecter;
OpticalFlow flowfield;

color bgColor = color(0);
int overlayAlpha = 20; //original = 10 fades background colour, low numbers <10 aren't great for on screen because it leaves color residue (it's ok when projected though).

int sw = 1024, sh = 768;
float invWidth, invHeight;
int kWidth=640, kHeight = 480; // use by optical flow and particles
float invKWidth, invKHeight; // inverse of screen dimensions

boolean drawOpticalFlow=true; 
boolean showSettings=true; 

PFont myFont;

//--------------------------------------------iPhone_touchOSC recepticles
float faderRed = 255;
float faderGreen=255;
float faderBlue=255;
float faderAlpha=255;
//---------------------------------------------noise parameters
float noiseStrengthOSC= 3; //1-300;
float noiseScaleOSC = 5; //1-400
float zNoiseVelocityOSC = .10; // .005 - .3
//---------------------------------------------touchOSC, the other parameters
float viscosityOSC = .999;
float forceMultiOSC = 5; //1-300
float accFrictionOSC = .095;  //.001-.999
float accLimiterOSC = .005;  // - .999
//-------------------------------------------
int generateRateOSC = 10; //2-200
float  generateSpreadOSC= 25; //1-50
//------------------------------------------
int minimumDepthOSC = 100;
int maximumDepthOSC = 1000;  

void setup() {
  size(sw, sh, OPENGL );//OPENGL
  hint( ENABLE_OPENGL_4X_SMOOTH );
  
   //start oscP5 listening for incoming messages at port 8000
  oscP5 = new OscP5(this, 8000);

  background(bgColor);
  frameRate(30);

  // to avoid dividing by zero errors (thanks memo)
  invWidth = 1.0f/sw;
  invHeight = 1.0f/sh;  
  invKWidth = 1.0f/kWidth;
  invKHeight = 1.0f/kHeight;

  // set arial 11 as default font?
  myFont = createFont("Arial", 11);
  textFont(myFont);

  // finding the right noise seed makes a difference!
  noiseSeed(26103); 

  // create the particles: 20000-40000 runs smooth at 30fps on latest macbook pro. 
  // drop this amount if running slow. press any key to print fps.
  particleManager = new ParticleManager(30000);//original 30000

  // helper class for kinect
  kinecter = new Kinecter(this);

  // optical flow from kinect depth image. parameter indicates flowfield gridsize
  // smaller is more detailed but heavier on cpu
  flowfield = new OpticalFlow(10);//15=original
  
   //----------------------------------------------------------------- for Control P5
  controlP5 = new ControlP5(this);
  controlP5.setAutoDraw(false);
  controlWindow = controlP5.addControlWindow("controlP5window", 100, 100, 600, 300);
  controlWindow.hideCoordinates();
  controlWindow.setBackground(color(40));

  //--------------Sliders
  Controller mySlider = controlP5.addSlider("Min_Distance", 0, 8000, 40, 20, 100, 15);
  mySlider.setWindow(controlWindow);
  Controller mySlider1 = controlP5.addSlider("Max_Distance", 0, 8000, 40, 50, 100, 15);
  mySlider1.setWindow(controlWindow);
  Controller mySlider2 = controlP5.addSlider("SeekStrength", 0, 100, 40, 80, 100, 15);
  mySlider2.setWindow(controlWindow);
  Controller mySlider3 = controlP5.addSlider("SeparationStrength", 0, 100, 40, 110, 100, 15);
  mySlider3.setWindow(controlWindow);
  Controller mySlider4 = controlP5.addSlider("Allignment", 0, 100, 40, 140, 100, 15);
  mySlider4.setWindow(controlWindow);
  Controller mySlider5 = controlP5.addSlider("Cohesion", 0, 100, 40, 170, 100, 15);
  mySlider5.setWindow(controlWindow);
  Controller mySlider6 = controlP5.addSlider("Indirection", 0, 100, 40, 200, 100, 15);
  mySlider6.setWindow(controlWindow);




  //--------------Toggle
  Toggle myToggle1 = controlP5.addToggle("Float", false, 250, 20, 40, 40);
  myToggle1.setWindow(controlWindow);
  Toggle myToggle2 = controlP5.addToggle("Glide", false, 330, 20, 40, 40);
  myToggle2.setWindow(controlWindow);
  Toggle myToggle3 = controlP5.addToggle("Dab", false, 410, 20, 40, 40);
  myToggle3.setWindow(controlWindow);
  Toggle myToggle4 = controlP5.addToggle("Flick", false, 490, 20, 40, 40);
  myToggle4.setWindow(controlWindow);
  Toggle myToggle5 = controlP5.addToggle("Wring", false, 250, 150, 40, 40);
  myToggle5.setWindow(controlWindow);
  Toggle myToggle6 = controlP5.addToggle("Slash", false, 330, 150, 40, 40);
  myToggle6.setWindow(controlWindow);
  Toggle myToggle7 = controlP5.addToggle("Punch", false, 410, 150, 40, 40);
  myToggle7.setWindow(controlWindow);
  Toggle myToggle8 = controlP5.addToggle("Press", false, 490, 150, 40, 40);
  myToggle8.setWindow(controlWindow);


  //---------Window
  controlWindow.setTitle("Movement_Ink Controls");

}



void draw() {
  
  // fades black rectangle over the top
  easyFade();

  if (showSettings) 
  {    
    // updates the kinect raw depth + pixels
    kinecter.updateKinectDepth(true);

    // display instructions for adjusting kinect depth image
    instructionScreen();

    // want to see the optical flow after depth image drawn.
    flowfield.update();
  }
  else
  {
    // updates the kinect raw depth
    kinecter.updateKinectDepth(false);

    // updates the optical flow vectors from the kinecter depth image 
    // (want to update optical flow before particles)!!
    flowfield.update();
    particleManager.updateAndRenderGL();
  }
}



void easyFade()
{
  fill(bgColor, overlayAlpha);
  noStroke();
  rect(0, 0, width, height);//fade background
}


void instructionScreen()
{
  // show kinect depth image
  image(kinecter.depthImg, 0, 0); 

  // instructions under depth image in gray box
  fill(50);
  rect(0, 490, 640, 85);
  fill(255);
  text("Press keys 'a' and 'z' to adjust minimum depth: " + kinecter.minDepth, 5, 505);
  text("Press keys 's' and 'x' to adjust maximum depth: " + kinecter.maxDepth, 5, 520);

  text("> Adjust depths until you get a white silhouette of your whole body with everything else black.", 5, 550);
  text("PRESS SPACE TO CONTINUE", 5, 565);
}


void keyPressed() {
  println("*** FRAMERATE: " + frameRate);

  if (keyCode == UP) {
    kinecter.kAngle++;
    kinecter.kAngle = constrain(kinecter.kAngle, 0, 30);
    kinecter.kinect.tilt(kinecter.kAngle);
  } 
  else if (keyCode == DOWN) {
    kinecter.kAngle--;
    kinecter.kAngle = constrain(kinecter.kAngle, 0, 30);
    kinecter.kinect.tilt(kinecter.kAngle);
  }
  else if (keyCode == 32) 
  { 
    // space bar for settings to adjust kinect depth
    background(bgColor);
    if (!showSettings) 
    {
      //controlP5.show();
      showSettings = true;
      drawOpticalFlow = true;
    }
    else
    {
      //controlP5.hide();
      showSettings = false;
      drawOpticalFlow = false;
    }
  }
  else if (keyCode == 65)
  {
    // a pressed add to minimum depth
    kinecter.minDepth = constrain(kinecter.minDepth + 10, 0, kinecter.thresholdRange);
    println("minimum depth: " + kinecter.minDepth);
  }
  else if (keyCode == 90)
  {
    // z pressed subtract to minimum depth
    kinecter.minDepth = constrain(kinecter.minDepth - 10, 0, kinecter.thresholdRange);
    println("minimum depth: " + kinecter.minDepth);
  }
  else if (keyCode == 83)
  {
    // s pressed add to maximum depth
    kinecter.maxDepth = constrain(kinecter.maxDepth + 10, 0, kinecter.thresholdRange);
    println("maximum depth: " + kinecter.maxDepth);
  }
  else if (keyCode == 88)
  {
    // x pressed subtract to maximum depth
    kinecter.maxDepth = constrain(kinecter.maxDepth - 10, 0, kinecter.thresholdRange);
    println("maximum depth: " + kinecter.maxDepth);
  }
  else if (key == 'f')
  {
    // d pressed add to maximum depth
    kinecter.maxDepth = constrain(kinecter.maxDepth + 1, 0, kinecter.thresholdRange);
    println("maximum depth: " + kinecter.maxDepth);
  }
   else if (key == 'v')
  {
    // c pressed add to maximum depth
    kinecter.maxDepth = constrain(kinecter.maxDepth - 1, 0, kinecter.thresholdRange);
    println("maximum depth: " + kinecter.maxDepth);
  }
   else if (key == 'd')
  {
    // a pressed add to minimum depth
    kinecter.minDepth = constrain(kinecter.minDepth + 1, 0, kinecter.thresholdRange);
    println("minimum depth: " + kinecter.minDepth);
  }
  else if (key == 'c')
  {
    // z pressed subtract to minimum depth
    kinecter.minDepth = constrain(kinecter.minDepth - 1, 0, kinecter.thresholdRange);
    println("minimum depth: " + kinecter.minDepth);
  }
  
}

void stop() {
  kinecter.quit();
  super.stop();
}

