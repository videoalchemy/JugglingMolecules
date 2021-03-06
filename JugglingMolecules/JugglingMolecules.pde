/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2014 Jason Stephens, Owen Williams & VideoAlchemy Collective
 *
 *	See `credits.txt` for base work and shouts out.
 *	Published under CC Attribution-ShareAlike 3.0 (CC BY-SA 3.0)
 *		            http://creativecommons.org/licenses/by-sa/3.0/
 *******************************************************************/

import oscP5.*;	// TouchOSC
import netP5.*;
import processing.video.*;
import processing.opengl.*;
//import javax.media.opengl.*;
import java.util.Iterator;

////////////////////////////////////////////////////////////
//	Global objects
////////////////////////////////////////////////////////////
	// TouchOSC controller
	OscP5 gOscMaster;

	// Configuration object, manipulated by TouchOSC and OmiCron
	MolecularConfig gConfig;

	// TouchOsc controller for our app
	MolecularController gController;

	// Kinect helper
	Kinecter gKinecter;

	// OpticalFlow field which converts Kinect depth into a vector flow field
	OpticalFlow gFlowfield;

	// Particle manager which renders the flow field
	ParticleManager gParticleManager;

	// Raw depth info from the kinect.
	int[] gRawDepth;

	// Adjusted depth, thresholded by `updateKinectDepth()`.
	int[] gNormalizedDepth;

	// Depth image, thresholded by `updateKinectDepth()` and displayable.
	PImage gDepthImg;


// Start() is the very first thing that's run, then setup().
// Load our config object first thing!
void start() {
	// create the config object
	gConfig = new MolecularConfig();
	// Load setup, defaults and the last config automatically
	gConfig.loadAll();

}

// Initialize all of our global objects.
//
// NOTE: We want as much as possible to come from our gConfig object,
//		 which we can dynamically reload.  All config variables
//		 can be overridden except for the `setupXXX` items.
//
void setup() {
	// window size comes from config
	//size(gConfig.setupWindowWidth, gConfig.setupWindowHeight, OPENGL);
  size(1024, 768, OPENGL);

	// Initialize TouchOSC control bridge and start it listening on port 8000
	gOscMaster = new OscP5(this, 8000);

	// create and set up our controller
	gController = new MolecularController();
	gConfig.addController(gController);

	// set up display parametets
	background(gConfig.fadeColor);

	// set up noise seed
	noiseSeed(gConfig.setupNoiseSeed);
	frameRate(gConfig.setupFPS);

	// helper class for kinect
	gKinecter = new Kinecter(this);

	// initialize depth variables
    gRawDepth = new int[gKinectWidth*gKinectHeight];
	gNormalizedDepth = new int[gKinectWidth*gKinectHeight];
    gDepthImg = new PImage(gKinectWidth, gKinectHeight);

	// Create the particle manager.
	gParticleManager = new ParticleManager(gConfig);

	// Create the flowfield
	gFlowfield = new OpticalFlow(gConfig, gParticleManager);

	// Tell the particleManager about the flowfield
	gParticleManager.flowfield = gFlowfield;


	// print the configuration
	gConfig.echo();

	// save our startup state
	gConfig.saveSetup();
// MOW: NOTE - no need to save defaults, just pull them from the config variables directly
//	gConfig.saveDefaults();
//	gConfig.saveRestartState();


/*	print out the blendModes...

	println("	BLEND:       "+BLEND);
	println("	ADD:         "+ADD);
	println("	SUBTRACT:    "+SUBTRACT);
	println("	DARKEST:     "+DARKEST);
	println("	LIGHTEST:    "+LIGHTEST);
	println("	DIFFERENCE:  "+DIFFERENCE);
	println("	EXCLUSION:   "+EXCLUSION);
	println("	MULTIPLY:    "+MULTIPLY);
	println("	SCREEN:      "+SCREEN);
	println("	REPLACE:     "+ REPLACE);
*/
}


// Our draw loop.
void draw() {
	pushStyle();
	pushMatrix();

	// updates the kinect gRawDepth, gNormalizedDepth & gDepthImg variables
	gKinecter.updateKinectDepth();

	// draw the depth image underneath the particles
	if (gConfig.showDepthImage) drawDepthImage();

	// update the optical flow vectors from the gKinecter depth image
	// NOTE: also draws the force vectors if `showFlowLines` is true
	gFlowfield.update();

	// show the flowfield particles
	if (gConfig.showParticles) gParticleManager.updateAndRender();

	// apply a full-screen color overlay
	// NOTE: this is where the blend mode is applied!
	if (gConfig.showFade) fadeScreen(gConfig.fadeColor, gConfig.fadeAlpha);

	// display instructions for adjusting kinect depth image on top of everything else
	if (gConfig.showSettings) drawInstructionScreen();


	popStyle();
	popMatrix();
}


////////////////////////////////////////////////////////////
//	Receiving events from the device.
////////////////////////////////////////////////////////////

// create function to recv and parse oscP5 messages
void oscEvent(OscMessage message) {
	try {
		gController.oscEvent(message);
	} catch (Exception e) {
		println("ERROR processing oscEvent: "+e);
	}
}

// Take a picture, fool!
void snapshot() {
	println("TAKE A PICTURE, FOOL!!!!");
}


// That's all folks!
void stop() {
  gKinecter.quit();
  super.stop();
}