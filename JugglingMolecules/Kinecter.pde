/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2013 Jason Stephens & VideoAlchemy Collective
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
	int kAngle	=	15;
	boolean isKinected = false;
	int minDepth = 100;//655;//740;
	int maxDepth = 950;//995;//982;//818;//860;
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

	public void updateKinectDepth() {
		if (!isKinected) return;

		// checks raw depth of kinect: if within certain depth range - color everything white, else black
		gRawDepth = kinect.getRawDepth();
		for (int i=0; i < gKinectWidth*gKinectHeight; i++) {
			if (gRawDepth[i] >= minDepth && gRawDepth[i] <= maxDepth) {
				int greyScale = (int)map((float)gRawDepth[i], minDepth, maxDepth, 255, 0);
//TODO: use depthImageColor
				gDepthImg.pixels[i] = color(gConfig.depthImageColor, gConfig.depthImageAlpha);//color(0, greyScale, greyScale, 0);
				gNormalizedDepth[i] = 255;
			}
			else {
				gDepthImg.pixels[i] = 0;	// transparent black
				gNormalizedDepth[i] = 0;
			}
		}

		// update the thresholded image
		gDepthImg.updatePixels();
	}


	public void quit() {
		if (isKinected) kinect.quit();
	}
}
