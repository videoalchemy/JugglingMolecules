/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2014 Jason Stephens, Owen Williams & VideoAlchemy Collective
 *
 *	See `credits.txt` for base work and shouts out.
 *	Published under CC Attrbution-ShareAlike 3.0 (CC BY-SA 3.0)
 *								http://creativecommons.org/licenses/by-sa/3.0/
 *******************************************************************/

import org.openkinect.*;
import org.openkinect.processing.*;

////////////////////////////////////////////////////////////
//	Kinect setup (constant for all configs)
////////////////////////////////////////////////////////////
	// size of the kinect
	int	 gKinectWidth=640, gKinectHeight = 480;		 // use by optical flow and particles
	float gInvKWidth = 1.0f/(float)gKinectWidth;		 // inverse of screen dimensions
	float gInvKHeight = 1.0f/(float)gKinectHeight;	 	 // inverse of screen dimensions
	// set in constructor below
	float gKinectToWindowWidth	= 0;			 		// multiplier for kinect size to window size
	float gKinectToWindowHeight = 0;			 		// multiplier for kinect size to window size


class Kinecter {
	Kinect kinect;
	boolean isKinected = false;

	int kAngle	 = gConfig.kinectAngle;
	int thresholdRange = 2047;

	public Kinecter(PApplet parent) {
		// multiplier for kinect size to window size
		gKinectToWindowWidth  = ((float) width)	* gInvKWidth;
		gKinectToWindowHeight = ((float) height) * gInvKHeight;

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
	}

	int lowestMin = 2047;
	int highestMax = 0;
	public void updateKinectDepth() {
		if (!isKinected) return;

		// checks raw depth of kinect: if within certain depth range - color everything white, else black
		gRawDepth = kinect.getRawDepth();
		for (int i=0; i < gKinectWidth*gKinectHeight; i++) {
			int depth = gRawDepth[i];
			int greyScale = (int)map((float)depth, gConfig.kinectMinDepth, gConfig.kinectMaxDepth, 255, 0);

			if (depth < lowestMin) println("LOWEST: "+(lowestMin = depth)+"::"+greyScale);
			if (depth > highestMax) println("HIGHEST: "+(highestMax = depth)+"::"+greyScale);

			// if less than min, make it white
			if (depth <= gConfig.kinectMinDepth) {
				gDepthImg.pixels[i] = color(255);	// solid white
				gNormalizedDepth[i] = 255;

			} else if (depth >= gConfig.kinectMaxDepth) {
				gDepthImg.pixels[i] = 0;	// transparent black
				gNormalizedDepth[i] = 0;

			} else {
				gDepthImg.pixels[i] = color(greyScale);//color(greyScale, gConfig.depthImageAlpha);
				gNormalizedDepth[i] = 255;
			}
		}

		// update the thresholded image
		gDepthImg.updatePixels();
	}


	public void quit() {
		if (isKinected) kinect.quit();
	}
}
