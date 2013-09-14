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
*/


import oscP5.*;  // TouchOSC
import netP5.*;

OscP5 oscP5;

import processing.video.*;
import processing.opengl.*;
import javax.media.opengl.*;


ParticleManager particleManager;
Kinecter kinecter;
OpticalFlow flowfield;


// background color (black)
color bgColor = color(0);

// Amount to "dim" the background each round by applying partially opaque background
// TODO: make touchOSC setting for this
int overlayAlpha = 20;  // original = 10 fades background colour, 
                        // low numbers <10 aren't great for on screen because 
                        // it leaves color residue (it's ok when projected though).

//////////////////////////////
///// Screen setup
//////////////////////////////

// projector size
int windowWidth = 1280;
int windowHeight = 800;

// rear screen projection?
boolean rearScreenProject = false;


//////////////////////////////
///// Configuration screen
//////////////////////////////
// set to true to show setup screen before flow (requires keyboard)
boolean showSettings=false;
// set to true to show red force lines during setup screen
boolean drawOpticalFlow=true;


//////////////////////////////
///// Kinect size
//////////////////////////////
// size of the kinect
int kWidth=640, kHeight = 480;     // use by optical flow and particles
float invKWidth = 1.0f/kWidth;     // inverse of screen dimensions
float invKHeight = 1.0f/kHeight;   // inverse of screen dimensions



//////////////////////////////
///// R,B,B,alpha for ALL particles, coming from TouchOSC
//////////////////////////////
float faderRed = 255;  //0-255
float faderGreen=255;  //0-255
float faderBlue=255;   //0-255
float faderAlpha=200;  //0-255

//////////////////////////////
///// Perlin noise generation, coming from TouchOSC
//////////////////////////////
// cloud variation, low values have long stretching clouds that move long distances,
//high values have detailed clouds that don't move outside smaller radius.
float noiseStrengthOSC= 3; //1-300;

// cloud strength multiplier,
//eg. multiplying low strength values makes clouds more detailed but move the same long distances.
float noiseScaleOSC = 5; //1-400

// turbulance, or how often to change the 'clouds' - third parameter of perlin noise: time. 
float zNoiseVelocityOSC = .10; // .005 - .3


//////////////////////////////
///// How much particles pay attention to the noise, coming from TouchOSC
//////////////////////////////
//how much particle slows down in fluid environment
float viscosityOSC = .999;  //0-1  ???

// force to apply to input - mouse, touch etc.
float forceMultiOSC = 5;   //1-300

// how fast to return to the noise after force velocities
float accFrictionOSC = .095;  //.001-.999

// how fast to return to the noise after force velocities
float accLimiterOSC = .005;  // - .999


//////////////////////////////
///// creating particles
//////////////////////////////

// Maximum number of particles that can be active at once.
// More particles = more detail because less "recycling"
// Fewer particles = faster.
int maxParticleCount = 20000;

// how many particles to emit when mouse/tuio blob move
int generateRateOSC = 2; //2-200

// random offset for particles emitted, so they don't all appear in the same place
float  generateSpreadOSC = 25; //1-50



//////////////////////////////
///// flowfield
//////////////////////////////

// resolution of the flow field.
// Smaller means more coarse flowfield = faster but less precise
// Larger means finer flowfield = slower but better tracking of edges
int flowfieldResolution = 30;  // 1..50 ?



void setup() {
  // set up with OPENGL rendering context == faster
  size(windowWidth, windowHeight, OPENGL);

  // finding the right noise seed makes a difference!
  noiseSeed(26103); 
  
  // TouchOSC control bridge
  //start oscP5 listening for incoming messages at port 8000
  oscP5 = new OscP5(this, 8000);

  background(bgColor);
  frameRate(60);

  particleManager = new ParticleManager(maxParticleCount);

  // helper class for kinect
  kinecter = new Kinecter(this);

  // create the flowfield
  flowfield = new OpticalFlow(flowfieldResolution);
}



void draw() {
  // partially fade the screen by drawing a semi-opaque rectangle over everything
  easyFade();

  if (showSettings) {    
    // updates the kinect raw depth + pixels
    kinecter.updateKinectDepth(true);

    // display instructions for adjusting kinect depth image
    instructionScreen();

    // want to see the optical flow after depth image drawn.
    flowfield.update();
  }
  
  // show the flowfield
  else {
    // updates the kinect raw depth
    kinecter.updateKinectDepth(false);

    // updates the optical flow vectors from the kinecter depth image 
    // (want to update optical flow before particles)!!
    flowfield.update();
    particleManager.updateAndRender();
  }
}


// Partially fade the screen by drawing a translucent black rectangle over everything.
void easyFade() {
  fill(bgColor, overlayAlpha);
  noStroke();
  rect(0, 0, width, height);//fade background
}



// Show the instruction screen
void instructionScreen() {
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



// Handle keypress to adjust parameters
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
  else if (keyCode == 32) { 
    // space bar for settings to adjust kinect depth
    background(bgColor);
    if (!showSettings) {
      //controlP5.show();
      showSettings = true;
      drawOpticalFlow = true;
    }
    else {
      //controlP5.hide();
      showSettings = false;
      drawOpticalFlow = false;
    }
  }
  else if (keyCode == 65) {
    // a pressed add to minimum depth
    kinecter.minDepth = constrain(kinecter.minDepth + 10, 0, kinecter.thresholdRange);
    println("minimum depth: " + kinecter.minDepth);
  }
  else if (keyCode == 90) {
    // z pressed subtract to minimum depth
    kinecter.minDepth = constrain(kinecter.minDepth - 10, 0, kinecter.thresholdRange);
    println("minimum depth: " + kinecter.minDepth);
  }
  else if (keyCode == 83) {
    // s pressed add to maximum depth
    kinecter.maxDepth = constrain(kinecter.maxDepth + 10, 0, kinecter.thresholdRange);
    println("maximum depth: " + kinecter.maxDepth);
  }
  else if (keyCode == 88) {
    // x pressed subtract to maximum depth
    kinecter.maxDepth = constrain(kinecter.maxDepth - 10, 0, kinecter.thresholdRange);
    println("maximum depth: " + kinecter.maxDepth);
  }
  else if (key == 'f') {
    // d pressed add to maximum depth
    kinecter.maxDepth = constrain(kinecter.maxDepth + 1, 0, kinecter.thresholdRange);
    println("maximum depth: " + kinecter.maxDepth);
  }
   else if (key == 'v') {
    // c pressed add to maximum depth
    kinecter.maxDepth = constrain(kinecter.maxDepth - 1, 0, kinecter.thresholdRange);
    println("maximum depth: " + kinecter.maxDepth);
  }
   else if (key == 'd') {
    // a pressed add to minimum depth
    kinecter.minDepth = constrain(kinecter.minDepth + 1, 0, kinecter.thresholdRange);
    println("minimum depth: " + kinecter.minDepth);
  }
  else if (key == 'c') {
    // z pressed subtract to minimum depth
    kinecter.minDepth = constrain(kinecter.minDepth - 1, 0, kinecter.thresholdRange);
    println("minimum depth: " + kinecter.minDepth);
  }
  
}

void stop() {
  kinecter.quit();
  super.stop();
}

