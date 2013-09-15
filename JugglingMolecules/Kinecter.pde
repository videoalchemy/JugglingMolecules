/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2013 Jason Stephens & VideoAlchemy Collective
 *
 *	See `credits.txt` for base work and shouts out.
 *	Published under CC Attrbution-ShareAlike 3.0 (CC BY-SA 3.0)
 *		            http://creativecommons.org/licenses/by-sa/3.0/
 *******************************************************************/

import org.openkinect.*;
import org.openkinect.processing.*;


class Kinecter {

  Kinect kinect;
  int gKinectWidth  = 640;
  int gKinectHeight = 480;
  int kAngle  =  15;
  boolean isKinected = false;
  int[] rawDepth;
  int minDepth = 100;//655;//740;
  int maxDepth = 950;//995;//982;//818;//860;
  int thresholdRange = 2047;

  PImage depthImg;

  public Kinecter(PApplet parent) {
    try {
      kinect = new Kinect(parent);
      kinect.start();
      kinect.enableDepth(true);
      kinect.tilt(kAngle);

      kinect.processDepthImage(false);

      isKinected = true;
      println("KINECT IS INITIALISED");
    }
    catch (Throwable t) {
      isKinected = false;
      println("KINECT NOT INITIALISED");
    }

    depthImg = new PImage(gKinectWidth, gKinectHeight);
    rawDepth = new int[gKinectWidth*gKinectHeight];
  }

  public void updateKinectDepth(boolean updateDepthPixels) {
    if (!isKinected) return;

    // checks raw depth of kinect: if within certain depth range - color everything white, else black
    rawDepth = kinect.getRawDepth();
    for (int i=0; i < gKinectWidth*gKinectHeight; i++) {
      if (rawDepth[i] >= minDepth && rawDepth[i] <= maxDepth) {
        int greyScale = (int)map((float)rawDepth[i], minDepth, maxDepth, 255, 0);
        depthImg.pixels[i] = color(0, greyScale, greyScale, 0);
        rawDepth[i] = 255;
      }
      else {
        depthImg.pixels[i] = 0;  // transparent black
        rawDepth[i] = 0;
      }
    }

    // update the thresholded image
    if (updateDepthPixels) depthImg.updatePixels();
//    image(depthImg, 0, 0, width, height);
  }


  public void quit() {
    if (isKinected) kinect.quit();
  }
}
