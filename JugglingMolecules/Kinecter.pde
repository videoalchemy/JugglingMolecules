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

	// size of the kinect, use by optical flow and particles
	int	gKinectWidth=640;
	int gKinectHeight = 480;


class Kinecter {
	Kinect kinect;
	boolean isKinected = false;

	int kAngle	 = gConfig.kinectAngle;
	int thresholdRange = 2047;

	public Kinecter(PApplet parent) {
		try {
			kinect = new Kinect(parent);
			kinect.start();
			kinect.enableDepth(true);
			kinect.tilt(kAngle);

			// the below makes getRawDepth() faster
			kinect.processDepthImage(false);

			isKinected = true;
			println("KINECT IS INITIALISED");
		}
		catch (Throwable t) {
			isKinected = false;
			println("KINECT NOT INITIALISED.  Exception: "+t);
		}
	}

	int lowestMin = 2047;
	int highestMax = 0;
	public void updateKinectDepth() {
		if (!isKinected) return;

		color white = color(255);
		color black = color(0, 0);
		int _min = gConfig.kinectMinDepth;
		int _max = gConfig.kinectMaxDepth;

		// checks raw depth of kinect: if within certain depth range - color everything white, else black
		gRawDepth = kinect.getRawDepth();
		int lastPixel = gRawDepth.length;
		for (int i=0; i < lastPixel; i++) {
			int depth = gRawDepth[i];

			// if less than min, make it white
			if (depth <= _min) {
				gDepthImg.pixels[i] = white;
				gNormalizedDepth[i] = 255;

			} else if (depth >= _max) {
				gDepthImg.pixels[i] = black;
				gNormalizedDepth[i] = 0;

			} else {
				int greyScale = (int)map((float)depth, _min, _max, 255, 0);

//				if (depth < lowestMin) println("LOWEST: "+(lowestMin = depth)+"::"+greyScale);
//				if (depth > highestMax) println("HIGHEST: "+(highestMax = depth)+"::"+greyScale);

				gDepthImg.pixels[i] = (gConfig.depthImageAsGreyscale ? color(greyScale) : white);
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
