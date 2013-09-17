/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2013 Jason Stephens & VideoAlchemy Collective
 *
 *	See `credits.txt` for base work and shouts out.
 *	Published under CC Attrbution-ShareAlike 3.0 (CC BY-SA 3.0)
 *		            http://creativecommons.org/licenses/by-sa/3.0/
 *******************************************************************/

////////////////////////////////////////////////////////////
//  Configuration class for project.
//
//  We can load and save these to disk
//  to restore "interesting" states to play with.
////////////////////////////////////////////////////////////


// Depth image blend mode constants.
	int DEPTH_IMAGE_BLEND_MODE_0 = LIGHTEST;				// default stamp
	int DEPTH_IMAGE_BLEND_MODE_1 = DARKEST;
	int DEPTH_IMAGE_BLEND_MODE_2 = DIFFERENCE;
	int DEPTH_IMAGE_BLEND_MODE_3 = EXCLUSION;			// tracks black to body


class MolecularConfig {

////////////////////////////////////////////////////////////
//  Global config.  Note that we cannot override these at runtime.
////////////////////////////////////////////////////////////

	// Desired frame rate
	// NOTE: requires restart to change.
	int setupFPS = 30;

	// Random noise seed.
	// NOTE: requires restart to change.
	// Trent Brooks sez:  "finding the right noise seed makes a difference!"
// TODO: way to vary this ???
	int setupNoiseSeed = 26103;


////////////////////////////////////////////////////////////
//	Master controls for what we're showing on the screen
//	Note: they currently show in this order.
////////////////////////////////////////////////////////////

	// Show particles.
	boolean showParticles = true;

	// Show force lines.
	boolean showFlowLines = false;

	// Show the depth image.
	boolean showDepthImage = false;

	// Show depth pixels
	boolean showDepthPixels = false;

	// Show setup screen OVER the rest of the screen.
	boolean showSettings = false;


////////////////////////////////////////////////////////////
//	OpticalFlow field parameters
////////////////////////////////////////////////////////////

	// background color (black)
	color windowBgColor = color(0,139,213,50);	// color
	color windowBgColorFromUnit(float value){return value == 0 ? color(0) : color(255);};

	// Amount to "dim" the background each round by applying partially opaque background
	// Higher number means less of each screen sticks around on subsequent draw cycles.
	int windowOverlayAlpha = 20;	//	0-255
	int MIN_windowOverlayAlpha = 0;
	int MAX_windowOverlayAlpha = 255;
	int windowOverlayAlphaFromUnit(float value){return (int) map(value, 0, 1, MIN_windowOverlayAlpha, MAX_windowOverlayAlpha);}
	float windowOverlayAlphaToUnit(){return map((float) windowOverlayAlpha, MIN_windowOverlayAlpha, MAX_windowOverlayAlpha, 0, 1);}



////////////////////////////////////////////////////////////
//	OpticalFlow field parameters
////////////////////////////////////////////////////////////

	// Resolution of the flow field.
	// Smaller means more coarse flowfield = faster but less precise
	// Larger means finer flowfield = slower but better tracking of edges
	// NOTE: requires restart to change this.
	int flowfieldResolution = 15;	// 1..50 ?
	int MIN_flowfieldResolution = 1;
	int MAX_flowfieldResolution = 50;
// TODO: make sure this doesn't change dynamically...
	int flowfieldResolutionFromUnit(float value) {return flowfieldResolution;}//(int) map(value, 0, 1, MIN_flowfieldResolution, MAX_flowfieldResolution);}
	float flowfieldResolutionToUnit(){return map((float) flowfieldResolution, MIN_flowfieldResolution, MAX_flowfieldResolution, 0, 1);}

	// Amount of time (in seconds) between "averages" to compute the flow.
	float flowfieldPredictionTime = 0.5;
	float MIN_flowfieldPredictionTime = .1;
	float MAX_flowfieldPredictionTime = 2;
	float flowfieldPredictionTimeFromUnit(float value){return map(value, 0, 1, MIN_flowfieldPredictionTime, MAX_flowfieldPredictionTime);}
	float flowfieldPredictionTimeToUnit(){return map(flowfieldPredictionTime, MIN_flowfieldPredictionTime, MAX_flowfieldPredictionTime, 0, 1);}

	// Velocity must exceed this to add/draw particles in the flow field.
	int flowfieldMinVelocity = 20;
	int MIN_flowfieldMinVelocity = 1;
	int MAX_flowfieldMinVelocity = 50;
	int flowfieldMinVelocityFromUnit(float value){return (int) map(value, 0, 1, MIN_flowfieldMinVelocity, MAX_flowfieldMinVelocity);}
	float flowfieldMinVelocityToUnit(){return map((float) flowfieldMinVelocity, MIN_flowfieldMinVelocity, MAX_flowfieldMinVelocity, 0, 1);}

	// Regularization term for regression.
	// Larger values for noisy video (?).
	float flowfieldRegularization = pow(10,8);
	float MIN_flowfieldRegularization = 0;
	float MAX_flowfieldRegularization = pow(10,10);
	float flowfieldRegularizationFromUnit(float value) {return map(value, 0, 1, MIN_flowfieldRegularization, MAX_flowfieldRegularization);}
	float flowfieldRegularizationToUnit(){return map(flowfieldRegularization, MIN_flowfieldRegularization, MAX_flowfieldRegularization, 0, 1);}

	// Smoothing of flow field.
	// Smaller value for longer smoothing.
	float flowfieldSmoothing = 0.05;
	float MIN_flowfieldSmoothing = 0;
	float MAX_flowfieldSmoothing = 1;		// ????
	float flowfieldSmoothingFromUnit(float value) {return map(value, 0, 1, MIN_flowfieldSmoothing, MAX_flowfieldSmoothing);}
	float flowfieldSmoothingToUnit(){return map(flowfieldSmoothing, MIN_flowfieldSmoothing, MAX_flowfieldSmoothing, 0, 1);}

////////////////////////////////////////////////////////////
//	Perlin noise generation.
////////////////////////////////////////////////////////////

	// Cloud variation.
	// Low values have long stretching clouds that move long distances.
	// High values have detailed clouds that don't move outside smaller radius.
//TODO: convert to int?
	int noiseStrength = 100; //1-300;
	int MIN_noiseStrength = 1;
	int MAX_noiseStrength = 300;
	int noiseStrengthFromUnit(float value){return (int)map(value, 0, 1, MIN_noiseStrength, MAX_noiseStrength);}
	float noiseStrengthToUnit(){return map((float) noiseStrength, MIN_noiseStrength, MAX_noiseStrength, 0, 1);}

	// Cloud strength multiplier.
	// Low strength values makes clouds more detailed but move the same long distances. ???
//TODO: convert to int?
	int noiseScale = 100; //1-400
	int MIN_noiseScale = 1;
	int MAX_noiseScale = 400;
	int noiseScaleFromUnit(float value){return (int)map(value, 0, 1, MIN_noiseScale, MAX_noiseScale);}
	float noiseScaleToUnit(){return map((float)noiseScale, MIN_noiseScale, MAX_noiseScale, 0, 1);};

////////////////////////////////////////////////////////////
//	Interaction between particles and flow field.
////////////////////////////////////////////////////////////

	// How much particle slows down in fluid environment.
	float particleViscocity = .995;	//0-1	???
	float MIN_particleViscocity = 0;
	float MAX_particleViscocity = 1;
	float particleViscocityFromUnit(float value){return map(value, 0, 1, MIN_particleViscocity, MAX_particleViscocity);}
	float particleViscocityToUnit(){return map(particleViscocity, MIN_particleViscocity, MAX_particleViscocity, 0, 1);}

	// Force to apply to input - mouse, touch etc.
	float particleForceMultiplier = 50;	 //1-300
	float MIN_particleForceMultiplier = 1;
	float MAX_particleForceMultiplier = 300;
	float particleForceMultiplierFromUnit(float value){return map(value, 0, 1, MIN_particleForceMultiplier, MAX_particleForceMultiplier);}
	float particleForceMultiplierToUnit(){return map(particleForceMultiplier, MIN_particleForceMultiplier, MAX_particleForceMultiplier, 0, 1);}

	// How fast to return to the noise after force velocities.
	float particleAccelerationFriction = .7511973;	//.001-.999	// WAS: .075
	float MIN_particleAccelerationFriction = .001;
	float MAX_particleAccelerationFriction = .999;
	float particleAccelerationFrictionFromUnit(float value){return map(value, 0, 1, MIN_particleAccelerationFriction, MAX_particleAccelerationFriction);}
	float particleAccelerationFrictionToUnit(){return map(particleAccelerationFriction, MIN_particleAccelerationFriction, MAX_particleAccelerationFriction, 0, 1);}

	// How fast to return to the noise after force velocities.
	float particleAccelerationLimiter = .35;	// - .999
	float MIN_particleAccelerationLimiter = .001;
	float MAX_particleAccelerationLimiter = .999;
	float particleAccelerationLimiterFromUnit(float value){return map(value, 0, 1, MIN_particleAccelerationLimiter, MAX_particleAccelerationLimiter);}
	float particleAccelerationLimiterToUnit(){return map(particleAccelerationLimiter, MIN_particleAccelerationLimiter, MAX_particleAccelerationLimiter, 0, 1);}

	// Turbulance, or how often to change the 'clouds' - third parameter of perlin noise: time.
	float particleNoiseVelocity = .008; // .005 - .3
	float MIN_particleNoiseVelocity = .005;
	float MAX_particleNoiseVelocity = .3;
	float particleNoiseVelocityFromUnit(float value){return map(value, 0, 1, MIN_particleNoiseVelocity, MAX_particleNoiseVelocity);}
	float particleNoiseVelocityToUnit(){return map(particleNoiseVelocity, MIN_particleNoiseVelocity, MAX_particleNoiseVelocity, 0, 1);}



////////////////////////////////////////////////////////////
//	Particle drawing
////////////////////////////////////////////////////////////

	// Scheme for how we name particles.
	// 	- 0 = all particles same color, coming from `particle[Red|Green|Blue]` below
	// 	- 1 = particle color set from origin
	int PARTICLE_COLOR_SCHEME_SAME_COLOR 	= 0;
	int PARTICLE_COLOR_SCHEME_XY 			= 1;
	int PARTICLE_COLOR_SCHEME_YX			= 2;
	int PARTICLE_COLOR_SCHEME_XYX			= 3;
	int particleColorScheme = PARTICLE_COLOR_SCHEME_XY;
	int particleColorSchemeFromUnit(float value) {return (int) value;}
	float particleColorSchemeToUnit(){return (float) particleColorScheme;}

	// Color for particles iff `PARTICLE_COLOR_SCHEME_SAME_COLOR` color scheme in use.
	color particleColor		= color(255);
	color particleColorFromUnit(float value) {return colorFromHue(value);}
	float particleColorToUnit(){return hueFromColor(particleColor);}

	// Opacity for all particle lines, used for all color schemes.
	int particleAlpha		= 50;	//0-255
	int MIN_particleAlpha 	= 0;
	int MAX_particleAlpha 	= 255;
	int particleAlphaFromUnit(float value) {return (int) map(value, 0, 1, 0, 255);}
	float particleAlphaToUnit(){return map((float) particleAlpha, 0, 255, 0, 1);}


	// Maximum number of particles that can be active at once.
	// More particles = more detail because less "recycling"
	// Fewer particles = faster.
// TODO: must restart to change this
	int particleMaxCount = 30000;
	int MIN_particleMaxCount = 1000;
	int MAX_particleMaxCount = 30000;
	int particleMaxCountFromUnit(float value) {return (int) map(value, 0, 1, MIN_particleMaxCount, MAX_particleMaxCount);}
	float particleMaxCountToUnit(){return map((float) particleMaxCount, MIN_particleMaxCount, MAX_particleMaxCount, 0, 1);}

	// how many particles to emit when mouse/tuio blob move
	int particleGenerateRate = 10; //2-200
	int MIN_particleGenerateRate = 1;
	int MAX_particleGenerateRate = 200;
	int particleGenerateRateFromUnit(float value) {return (int) map(value, 0, 1, MIN_particleGenerateRate, MAX_particleGenerateRate);}
	float particleGenerateRateToUnit() {return map((float)particleGenerateRate, MIN_particleGenerateRate, MAX_particleGenerateRate, 0, 1);}

	// random offset for particles emitted, so they don't all appear in the same place
	int particleGenerateSpread = 20; //1-50
	int MIN_particleGenerateSpread = 1;
	int MAX_particleGenerateSpread = 50;
	int particleGenerateSpreadFromUnit(float value) {return (int) map(value, 0, 1, MIN_particleGenerateSpread, MAX_particleGenerateSpread);}
	int particleGenerateSpreadToUnit() {return (int)map(particleGenerateSpread, MIN_particleGenerateSpread, MAX_particleGenerateSpread, 0, 1);}

	// Upper and lower bound of particle movement each frame.
	int particleMinStepSize = 4;
	int particleMaxStepSize = 8;
	int MIN_particleStepSize = 2;
	int MAX_particleStepSize = 20;
	int particleStepSizeFromUnit(float value){return (int) map(value, 0, 1, MIN_particleStepSize, MAX_particleStepSize);}
	float particleStepSizeToUnit(int stepSize){return map((float) stepSize, MIN_particleStepSize, MAX_particleStepSize, 0, 1);}

	// Particle lifetime.
	int particleLifetime = 400;
	int MIN_particleLifetime = 50;
	int MAX_particleLifetime = 1000;
	int particleLifetimeFromUnit(float value){return (int) map(value, 0, 1, MIN_particleLifetime, MAX_particleLifetime);}
	float particleLifetimeToUnit(){return map((float) particleLifetime, MIN_particleLifetime, MAX_particleLifetime, 0, 1);}


////////////////////////////////////////////////////////////
//	Drawing flow field lines
////////////////////////////////////////////////////////////

	// color for optical flow lines
	color flowLineColor = color(255, 0, 0, 30);
	color flowLineColorFromUnit(float value) {return colorFromHue(value);}
	float flowLineColorToUnit() {return hueFromColor(flowLineColor);}

//TODO: apply alpha separately from hue
	int flowLineAlpha = 30;
	int MIN_flowLineAlpha 	= 0;
	int MAX_flowLineAlpha 	= 255;
	int flowLineAlphaFromUnit(float value){return (int) map(value, 0, 1, MIN_flowLineAlpha, MAX_flowLineAlpha);}
	float flowLineAlphaToUnit(){return map((float) flowLineAlpha, 0, 255, 0, 1);}


////////////////////////////////////////////////////////////
//	Depth image drawing
////////////////////////////////////////////////////////////

	// `tint` color for the depth image.
	// NOTE: NOT CURRENTLY USED.  see
	color depthImageColor = color(255,0,0,255);
	color depthImageColorFromUnit(float value) {return colorFromHue(value);}
	float depthImageColorToUnit() {return hueFromColor(depthImageColor);}

	int depthImageAlpha = 30;
	int MIN_depthImageAlpha 	= 0;
	int MAX_depthImageAlpha 	= 255;
	int depthImageAlphaFromUnit(float value){return (int) map(value, 0, 1, MIN_depthImageAlpha, MAX_depthImageAlpha);}
	float depthImageAlphaToUnit(){return map((float) depthImageAlpha, 0, 255, 0, 1);}

	// blend mode for the depth image
	int depthImageBlendMode = DEPTH_IMAGE_BLEND_MODE_1;
	int depthImageBlendModeFromUnit(float value){
		if (value == 1.0f) return DEPTH_IMAGE_BLEND_MODE_1;
		if (value == 2.0f) return DEPTH_IMAGE_BLEND_MODE_2;
		if (value == 3.0f) return DEPTH_IMAGE_BLEND_MODE_3;
		return DEPTH_IMAGE_BLEND_MODE_0;
	}
	float depthImageBlendModeToUnit(){
		if 		(depthImageBlendMode == DEPTH_IMAGE_BLEND_MODE_1) return 1.0f;
		else if (depthImageBlendMode == DEPTH_IMAGE_BLEND_MODE_2) return 2.0f;
		else if (depthImageBlendMode == DEPTH_IMAGE_BLEND_MODE_3) return 3.0f;
		return 0.0f;
	}





////////////////////////////////////////////////////////////
//	Config manipulation
////////////////////////////////////////////////////////////

	// Print the current config to the console.
	void echo() {
		println("---------------------------------------------------------");
		println("-------      C U R R E N T     C O N F I G        -------");
		println("---------------------------------------------------------");
		println("showParticles	" + echoBoolean(showParticles));
		println("showFlowLines	" + echoBoolean(showFlowLines));
		println("showDepthImage	" + echoBoolean(showDepthImage));
		println("showDepthPixels	" + echoBoolean(showDepthPixels));
		println("showSettings	" + echoBoolean(showSettings));
		println("windowBgColor	" + echoColor(windowBgColor));
		println("windowOverlayAlpha	" + windowOverlayAlpha);
		println("flowfieldResolution	" + flowfieldResolution);
		println("flowfieldPredictionTime	" + flowfieldPredictionTime);
		println("flowfieldMinVelocity	" + flowfieldMinVelocity);
		println("flowfieldRegularization	" + flowfieldRegularization);
		println("flowfieldSmoothing	" + flowfieldSmoothing);
		println("noiseStrength	" + noiseStrength);
		println("noiseScale	" + noiseScale);
		println("particleViscocity	" + particleViscocity);
		println("particleForceMultiplier	" + particleForceMultiplier);
		println("particleAccelerationFriction	" + particleAccelerationFriction);
		println("particleAccelerationLimiter	" + particleAccelerationLimiter);
		println("particleNoiseVelocity	" + particleNoiseVelocity);
		println("particleColorScheme	" + particleColorScheme);
		println("particleColor	" + echoColor(particleColor));
		println("particleAlpha	" + particleAlpha);
		println("particleMaxCount	" + particleMaxCount);
		println("particleGenerateRate	" + particleGenerateRate);
		println("particleGenerateSpread	" + particleGenerateSpread);
		println("particleMinStepSize	" + particleMinStepSize);
		println("particleMaxStepSize	" + particleMaxStepSize);
		println("particleLifetime	" + particleLifetime);
		println("flowLineColor	" + echoColor(flowLineColor));
		println("flowLineAlpha	" + flowLineAlpha);
		println("depthImageColor	" + echoColor(depthImageColor));
		println("depthImageAlpha	" + depthImageAlpha);
		println("---------------------------------------------------------");
	}

	// Load configuration from json data stored in a config file.
	// `configFileName` is, e.g., `PS01`.
	void loadFromConfigFile(String configFileName) {
		String filePath = "config/"+configFileName+".json";
		println("Loading MolecularConfiguration from "+filePath);

		JSONArray json = loadJSONArray(filePath);
		int i = 0, last = json.size();
		while (i < last) {
			String keyName = json.getString(i++);
			float value    = json.getFloat(i++);

			println("   Setting "+keyName+" to (float) value "+value);
			this.applyConfigValue(keyName, value);
		}

		// remember that we have loaded this file
		gConfigFileName = configFileName;

		// print out the config
		this.echo();
	}

	// Update the current config file with the new settings.
	void updateCurrentConfigFile() {
		if (gConfigFileName == null) {
			println("updateCurrentConfigFile(): we've never loaded a config!");
		} else {
			saveToConfigFile(gConfigFileName);
		}
	}

	// Save our current configuration to a JSON file.
	// `configFileName` is, e.g., `PS01`.
	void saveToConfigFile(String configFileName) {
		String filePath = "config/"+configFileName+".json";
		println("Saving MolecularConfiguration to "+filePath);

		JSONArray json = this.toJSON(true);
		saveJSONArray(json, filePath);
	}


	// Apply a single named configuration value to our current configuration.
	void applyConfigValue(String keyName, float value) {

	/////////////////
	//	Display of different layers
	/////////////////
		if 		(keyName.equals("showParticles"))			showParticles  = (value != 0);
		else if (keyName.equals("showFlowLines")) 			showFlowLines  = (value != 0);
		else if (keyName.equals("showDepthImage")) 			showDepthImage = (value != 0);
		else if (keyName.equals("showDepthPixels")) 		showDepthPixels = (value != 0);
		else if (keyName.equals("showSettings")) 			showSettings   = (value != 0);


	/////////////////
	//	Background/overlay
	/////////////////
		// window background color, 0 == black, 1 == white
		else if (keyName.equals("windowBgColor"))			 	windowBgColor = windowBgColorFromUnit(value);

		// background overlay opacity
		else if (keyName.equals("windowOverlayAlpha"))			windowOverlayAlpha = windowOverlayAlphaFromUnit(value);
		else if (keyName.equals("MIN_windowOverlayAlpha"))	MIN_windowOverlayAlpha = (int) value;
		else if (keyName.equals("MAX_windowOverlayAlpha"))	MAX_windowOverlayAlpha = (int) value;


	/////////////////
	//	Optical Flow
	/////////////////
		// flowfield resolution
		else if (keyName.equals("flowfieldResolution"))				flowfieldResolution = flowfieldResolutionFromUnit(value);
		else if (keyName.equals("MIN_flowfieldResolution"))		MIN_flowfieldResolution = (int) value;
		else if (keyName.equals("MAX_flowfieldResolution"))		MAX_flowfieldResolution = (int) value;

		// flowfield prediction time (seconds)
		else if (keyName.equals("flowfieldPredictionTime"))			flowfieldPredictionTime = flowfieldPredictionTimeFromUnit(value);
		else if (keyName.equals("MIN_flowfieldPredictionTime"))	MIN_flowfieldPredictionTime = value;
		else if (keyName.equals("MAX_flowfieldPredictionTime"))	MAX_flowfieldPredictionTime = value;

		// flowfield min velocity
		else if (keyName.equals("flowfieldMinVelocity"))			flowfieldMinVelocity = flowfieldMinVelocityFromUnit(value);
		else if (keyName.equals("MIN_flowfieldMinVelocity"))		MIN_flowfieldMinVelocity = (int) value;
		else if (keyName.equals("MAX_flowfieldMinVelocity"))		MAX_flowfieldMinVelocity = (int) value;

		// flowfield regularization term
		else if (keyName.equals("flowfieldRegularization"))			flowfieldRegularization = flowfieldRegularizationFromUnit(value);
		else if (keyName.equals("MIN_flowfieldRegularization"))	MIN_flowfieldRegularization = value;
		else if (keyName.equals("MAX_flowfieldRegularization"))	MAX_flowfieldRegularization = value;

		// flowfield smoothing term
		else if (keyName.equals("flowfieldSmoothing"))				flowfieldSmoothing = flowfieldSmoothingFromUnit(value);
		else if (keyName.equals("MIN_flowfieldSmoothing"))			MIN_flowfieldSmoothing = value;
		else if (keyName.equals("MAX_flowfieldSmoothing"))			MAX_flowfieldSmoothing = value;


	/////////////////
	//	Noise generation
	/////////////////
		// noise strength
		else if (keyName.equals("noiseStrength"))				noiseStrength = noiseStrengthFromUnit(value);
		else if (keyName.equals("MIN_noiseStrength"))			MIN_noiseStrength = (int) value;
		else if (keyName.equals("MAX_noiseStrength"))			MAX_noiseStrength = (int) value;

		// noise strength
		else if (keyName.equals("noiseScale"))					noiseScale = noiseScaleFromUnit(value);
		else if (keyName.equals("MIN_noiseScale"))				MIN_noiseScale = (int) value;
		else if (keyName.equals("MAX_noiseScale"))				MAX_noiseScale = (int) value;


	/////////////////
	// 	Particle interaction with flow field
	/////////////////
		// particle viscocity
		else if (keyName.equals("particleViscocity"))					particleViscocity = particleViscocityFromUnit(value);
		else if (keyName.equals("MIN_particleViscocity"))				MIN_particleViscocity = value;
		else if (keyName.equals("MAX_particleViscocity"))				MAX_particleViscocity = value;

		// particle force multiplier
		else if (keyName.equals("particleForceMultiplier"))				particleForceMultiplier = particleForceMultiplierFromUnit(value);
		else if (keyName.equals("MIN_particleForceMultiplier"))		MIN_particleForceMultiplier = value;
		else if (keyName.equals("MAX_particleForceMultiplier"))		MAX_particleForceMultiplier = value;

		// particle acceleration friction
		else if (keyName.equals("particleAccelerationFriction"))		particleAccelerationFriction = particleAccelerationFrictionFromUnit(value);
		else if (keyName.equals("MIN_particleAccelerationFriction"))	MIN_particleAccelerationFriction = value;
		else if (keyName.equals("MAX_particleAccelerationFriction"))	MAX_particleAccelerationFriction = value;

		// particle acceleration limiter
		else if (keyName.equals("particleAccelerationLimiter"))			particleAccelerationLimiter = particleAccelerationLimiterFromUnit(value);
		else if (keyName.equals("MIN_particleAccelerationLimiter"))	MIN_particleAccelerationLimiter = value;
		else if (keyName.equals("MAX_particleAccelerationLimiter"))	MAX_particleAccelerationLimiter = value;

		// particle noise velocity
		else if (keyName.equals("particleNoiseVelocity"))				particleNoiseVelocity = particleNoiseVelocityFromUnit(value);
		else if (keyName.equals("MIN_particleNoiseVelocity"))			MIN_particleNoiseVelocity = value;
		else if (keyName.equals("MAX_particleNoiseVelocity"))			MAX_particleNoiseVelocity = value;


	/////////////////
	// 	Particle drawing
	/////////////////
		// particle color scheme
		else if (keyName.equals("particleColorScheme")) 			particleColorScheme = particleColorSchemeFromUnit(value);

		// particle color as Hue + Opacity
		else if (keyName.equals("particleHue"))						particleColor = particleColorFromUnit(value);
		else if (keyName.equals("particleAlpha"))					particleAlpha = particleAlphaFromUnit(value);
		else if (keyName.equals("MIN_particleAlpha"))				MIN_particleAlpha = (int) value;
		else if (keyName.equals("MAX_particleAlpha"))				MAX_particleAlpha = (int) value;

		// particle max count
		else if (keyName.equals("particleMaxCount"))				particleMaxCount = particleMaxCountFromUnit(value);
		else if (keyName.equals("MIN_particleMaxCount"))			MIN_particleMaxCount = (int) value;
		else if (keyName.equals("MAX_particleMaxCount"))			MAX_particleMaxCount = (int) value;

		// particle generate rate
		else if (keyName.equals("particleGenerateRate"))			particleGenerateRate = particleGenerateRateFromUnit(value);
		else if (keyName.equals("MIN_particleGenerateRate"))		MIN_particleGenerateRate = (int) value;
		else if (keyName.equals("MAX_particleGenerateRate"))		MAX_particleGenerateRate = (int) value;

		// particle generate spread
		else if (keyName.equals("particleGenerateSpread"))			particleGenerateSpread = particleGenerateSpreadFromUnit(value);
		else if (keyName.equals("MIN_particleGenerateSpread"))	MIN_particleGenerateSpread = (int) value;
		else if (keyName.equals("MAX_particleGenerateSpread"))	MAX_particleGenerateSpread = (int) value;

		// particle min/max step size
		else if (keyName.equals("particleMinStepSize"))				particleMinStepSize = particleStepSizeFromUnit(value);
		else if (keyName.equals("particleMaxStepSize"))				particleMaxStepSize = particleStepSizeFromUnit(value);
		else if (keyName.equals("MIN_particleStepSize"))			MIN_particleStepSize = (int) value;
		else if (keyName.equals("MAX_particleStepSize"))			MAX_particleStepSize = (int) value;

		// particle lifetime
		else if (keyName.equals("particleLifetime"))				particleLifetime = particleLifetimeFromUnit(value);
		else if (keyName.equals("MIN_particleLifetime"))			MIN_particleLifetime = (int) value;
		else if (keyName.equals("MAX_particleLifetime"))			MAX_particleLifetime = (int) value;


	/////////////////
	// 	Particle drawing
	/////////////////
		// flow field line color as Hue + Opacity
		else if (keyName.equals("flowLineHue"))						flowLineColor = flowLineColorFromUnit(value);
		else if (keyName.equals("flowLineAlpha"))					flowLineAlpha = flowLineAlphaFromUnit(value);
		else if (keyName.equals("MIN_flowLineAlpha"))				MIN_flowLineAlpha = (int) value;
		else if (keyName.equals("MAX_flowLineAlpha"))				MAX_flowLineAlpha = (int) value;


	/////////////////
	// 	Depth image drawing
	/////////////////
		// depth image color as Hue (no opacity)
		else if (keyName.equals("depthImageHue"))					depthImageColor = depthImageColorFromUnit(value);
		else if (keyName.equals("depthImageAlpha"))					depthImageAlpha = depthImageAlphaFromUnit(value);
		else if (keyName.equals("MIN_depthImageAlpha"))			MIN_depthImageAlpha = (int) value;
		else if (keyName.equals("MAX_depthImageAlpha"))			MAX_depthImageAlpha = (int) value;
		else if (keyName.equals("depthImageBlendMode")) 			depthImageBlendMode = depthImageBlendModeFromUnit(value);

		// error case for debugging
		else {
			println("MolecularConfig.applyConfigValue('"+keyName+"'): key not understood");
		}
	}

	// Return the current configuration as a JSON array of `[ key, value, key, value, ...]` .
	// If `saveMinMax` is true, we'll output the _MIN and _MAX values.
	//		You'll want to set this to `true` for writing to a file,
	//		and `false` for outputting to TouchOSC.
//TODO:
	// If `deltasOnly` is true (default), we'll only save the differences between
	//		this config and a fresh, unmodified MolecularConfig,
	//		which will result in a smaller file.
	JSONArray toJSON(boolean saveMinMax/*, boolean deltasOnly*/) {
		JSONArray array = new JSONArray();

		this.addToUnitArray(array, "showParticles", showParticles ? 1 : 0);
		this.addToUnitArray(array, "showFlowLines", showFlowLines ? 1 : 0);
		this.addToUnitArray(array, "showDepthImage", showDepthImage ? 1 : 0);
		this.addToUnitArray(array, "showDepthPixels", showDepthPixels ? 1 : 0);
		this.addToUnitArray(array, "showSettings", showSettings ? 1 : 0);

	/////////////////
	//	Background/overlay
	/////////////////
		// window background color, 0 == black, 1 == white
		this.addToUnitArray(array, "windowBgColor", (red(windowBgColor) == 0 ? 0 : 1));
		if (saveMinMax) this.addToUnitArray(array, "MIN_windowOverlayAlpha", (float) MIN_windowOverlayAlpha);
		if (saveMinMax) this.addToUnitArray(array, "MAX_windowOverlayAlpha", (float) MAX_windowOverlayAlpha);
		this.addToUnitArray(array, "windowOverlayAlpha", windowOverlayAlphaToUnit());

	/////////////////
	//	Optical Flow
	/////////////////
		// flowfield resolution
		if (saveMinMax) this.addToUnitArray(array, "MIN_flowfieldResolution", (float) MIN_flowfieldResolution);
		if (saveMinMax) this.addToUnitArray(array, "MAX_flowfieldResolution", (float) MAX_flowfieldResolution);
		this.addToUnitArray(array, "flowfieldResolution", flowfieldResolutionToUnit());

		// flowfield prediction time (seconds)
		if (saveMinMax) this.addToUnitArray(array, "MIN_flowfieldPredictionTime", MIN_flowfieldPredictionTime);
		if (saveMinMax) this.addToUnitArray(array, "MAX_flowfieldPredictionTime", MAX_flowfieldPredictionTime);
		this.addToUnitArray(array, "flowfieldPredictionTime", flowfieldPredictionTimeToUnit());

		// flowfield min velocity
		if (saveMinMax) this.addToUnitArray(array, "MIN_flowfieldMinVelocity", (float) MIN_flowfieldMinVelocity);
		if (saveMinMax) this.addToUnitArray(array, "MAX_flowfieldMinVelocity", (float) MAX_flowfieldMinVelocity);
		this.addToUnitArray(array, "flowfieldMinVelocity", flowfieldMinVelocityToUnit());

		// flowfield regularization term
		if (saveMinMax) this.addToUnitArray(array, "MIN_flowfieldRegularization", MIN_flowfieldRegularization);
		if (saveMinMax) this.addToUnitArray(array, "MAX_flowfieldRegularization", MAX_flowfieldRegularization);
		this.addToUnitArray(array, "flowfieldRegularization", flowfieldRegularizationToUnit());

		// flowfield smoothing term
		if (saveMinMax) this.addToUnitArray(array, "MIN_flowfieldSmoothing", MIN_flowfieldSmoothing);
		if (saveMinMax) this.addToUnitArray(array, "MAX_flowfieldSmoothing", MAX_flowfieldSmoothing);
		this.addToUnitArray(array, "flowfieldSmoothing", flowfieldSmoothingToUnit());

	/////////////////
	//	Noise generation
	/////////////////
		// noise strength
		if (saveMinMax) this.addToUnitArray(array, "MIN_noiseStrength", MIN_noiseStrength);
		if (saveMinMax) this.addToUnitArray(array, "MAX_noiseStrength", MAX_noiseStrength);
		this.addToUnitArray(array, "noiseStrength", this.noiseStrengthToUnit());

		// noise strength
		if (saveMinMax) this.addToUnitArray(array, "MIN_noiseScale", MIN_noiseScale);
		if (saveMinMax) this.addToUnitArray(array, "MAX_noiseScale", MAX_noiseScale);
		this.addToUnitArray(array, "noiseScale", this.noiseScaleToUnit());

	/////////////////
	// 	Particle interaction with flow field
	/////////////////
		// particle viscocity
		if (saveMinMax) this.addToUnitArray(array, "MIN_particleViscocity", MIN_particleViscocity);
		if (saveMinMax) this.addToUnitArray(array, "MAX_particleViscocity", MAX_particleViscocity);
		this.addToUnitArray(array, "particleViscocity", particleViscocityToUnit());

		// particle force multiplier
		if (saveMinMax) this.addToUnitArray(array, "MIN_particleForceMultiplier", MIN_particleForceMultiplier);
		if (saveMinMax) this.addToUnitArray(array, "MAX_particleForceMultiplier", MAX_particleForceMultiplier);
		this.addToUnitArray(array, "particleForceMultiplier", particleForceMultiplierToUnit());

		// particle acceleration friction
		if (saveMinMax) this.addToUnitArray(array, "MIN_particleAccelerationFriction", MIN_particleAccelerationFriction);
		if (saveMinMax) this.addToUnitArray(array, "MAX_particleAccelerationFriction", MAX_particleAccelerationFriction);
		this.addToUnitArray(array, "particleAccelerationFriction", particleAccelerationFrictionToUnit());

		// particle acceleration limiter
		if (saveMinMax) this.addToUnitArray(array, "MIN_particleAccelerationLimiter", MIN_particleAccelerationLimiter);
		if (saveMinMax) this.addToUnitArray(array, "MAX_particleAccelerationLimiter", MAX_particleAccelerationLimiter);
		this.addToUnitArray(array, "particleAccelerationLimiter", particleAccelerationLimiterToUnit());

		// particle noise velocity
		if (saveMinMax) this.addToUnitArray(array, "MIN_particleNoiseVelocity", MIN_particleNoiseVelocity);
		if (saveMinMax) this.addToUnitArray(array, "MAX_particleNoiseVelocity", MAX_particleNoiseVelocity);
		this.addToUnitArray(array, "particleNoiseVelocity", particleNoiseVelocityToUnit());

	/////////////////
	// 	Particle drawing
	/////////////////
		// particle color scheme
		this.addToUnitArray(array, "particleColorScheme", particleColorSchemeToUnit());

		// particle color as Hue + Opacity
		this.addToUnitArray(array, "particleHue", particleColorToUnit());
		if (saveMinMax) this.addToUnitArray(array, "MIN_particleAlpha", (float) MIN_particleAlpha);
		if (saveMinMax) this.addToUnitArray(array, "MAX_particleAlpha", (float) MAX_particleAlpha);
		this.addToUnitArray(array, "particleAlpha", particleAlphaToUnit());

		// particle max count
		if (saveMinMax) this.addToUnitArray(array, "MIN_particleMaxCount", (float) MIN_particleMaxCount);
		if (saveMinMax) this.addToUnitArray(array, "MAX_particleMaxCount", (float) MAX_particleMaxCount);
		this.addToUnitArray(array, "particleMaxCount", particleMaxCountToUnit());

		// particle generate rate
		if (saveMinMax) this.addToUnitArray(array, "MIN_particleGenerateRate", (float) MIN_particleGenerateRate);
		if (saveMinMax) this.addToUnitArray(array, "MAX_particleGenerateRate", (float) MAX_particleGenerateRate);
		this.addToUnitArray(array, "particleGenerateRate", this.particleGenerateRateToUnit());

		// particle generate spread
		if (saveMinMax) this.addToUnitArray(array, "MIN_particleGenerateSpread", MIN_particleGenerateSpread);
		if (saveMinMax) this.addToUnitArray(array, "MAX_particleGenerateSpread", MAX_particleGenerateSpread);
		this.addToUnitArray(array, "particleGenerateSpread", this.particleGenerateSpreadToUnit());

		// particle min/max step size
		if (saveMinMax) this.addToUnitArray(array, "MIN_particleStepSize", (float) MIN_particleStepSize);
		if (saveMinMax) this.addToUnitArray(array, "MAX_particleStepSize", (float) MAX_particleStepSize);
		this.addToUnitArray(array, "particleMinStepSize", particleStepSizeToUnit(particleMinStepSize));
		this.addToUnitArray(array, "particleMaxStepSize", particleStepSizeToUnit(particleMaxStepSize));

		// particle lifetime
		if (saveMinMax) this.addToUnitArray(array, "MIN_particleLifetime", (float) MIN_particleLifetime);
		if (saveMinMax) this.addToUnitArray(array, "MAX_particleLifetime", (float) MAX_particleLifetime);
		this.addToUnitArray(array, "particleLifetime", particleLifetimeToUnit());


	/////////////////
	// 	Particle drawing
	/////////////////
		// flow field line color as Hue + Opacity
		this.addToUnitArray(array, "flowLineHue", flowLineColorToUnit());
		if (saveMinMax) this.addToUnitArray(array, "MIN_flowLineAlpha", (float) MIN_flowLineAlpha);
		if (saveMinMax) this.addToUnitArray(array, "MAX_flowLineAlpha", (float) MAX_flowLineAlpha);
		this.addToUnitArray(array, "flowLineAlpha", flowLineAlphaToUnit());

	/////////////////
	// 	Depth image drawing
	/////////////////
		// depth image color as Hue + Opacity
		this.addToUnitArray(array, "depthImageHue", depthImageColorToUnit());
		if (saveMinMax) this.addToUnitArray(array, "MIN_depthImageAlpha", (float) MIN_depthImageAlpha);
		if (saveMinMax) this.addToUnitArray(array, "MAX_depthImageAlpha", (float) MAX_depthImageAlpha);
		this.addToUnitArray(array, "depthImageAlpha", depthImageAlphaToUnit());
		// depth image blend mode
		this.addToUnitArray(array, "depthImageBlendMode", depthImageBlendModeToUnit());

		return array;
	}

	// Add a string+float to a JSON array.
	void addToUnitArray(JSONArray array, String keyName, float value) {
		array.setString(array.size(), keyName);
		array.setFloat(array.size(), value);
	}


















	// Print the current config to the console.
	String[] getOutput() {
		String[] output = new String[100];
		output.append("---------------------------------------------------------");
		output.append("-------      C U R R E N T     C O N F I G        -------");
		output.append("---------------------------------------------------------");
		output.append("-  showParticles                : " + echoBoolean(showParticles));
		output.append("-  showFlowLines                : " + echoBoolean(showFlowLines));
		output.append("-  showDepthImage               : " + echoBoolean(showDepthImage));
		output.append("-  showDepthPixels              : " + echoBoolean(showDepthPixels));
		output.append("-  showSettings                 : " + echoBoolean(showSettings));
		output.append("-  windowBgColor                : " + echoColor(windowBgColor));
		output.append("-  windowOverlayAlpha           : " + windowOverlayAlpha);
		output.append("-  flowfieldResolution          : " + flowfieldResolution);
		output.append("-  flowfieldPredictionTime      : " + flowfieldPredictionTime);
		output.append("-  flowfieldMinVelocity         : " + flowfieldMinVelocity);
		output.append("-  flowfieldRegularization      : " + flowfieldRegularization);
		output.append("-  flowfieldSmoothing           : " + flowfieldSmoothing);
		output.append("-  noiseStrength                : " + noiseStrength);
		output.append("-  noiseScale                   : " + noiseScale);
		output.append("-  particleViscocity            : " + particleViscocity);
		output.append("-  particleForceMultiplier      : " + particleForceMultiplier);
		output.append("-  particleAccelerationFriction : " + particleAccelerationFriction);
		output.append("-  particleAccelerationLimiter  : " + particleAccelerationLimiter);
		output.append("-  particleNoiseVelocity        : " + particleNoiseVelocity);
		output.append("-  particleColorScheme          : " + particleColorScheme);
		output.append("-  particleColor                : " + echoColor(particleColor));
		output.append("-  particleAlpha                : " + particleAlpha);
		output.append("-  particleMaxCount             : " + particleMaxCount);
		output.append("-  particleGenerateRate         : " + particleGenerateRate);
		output.append("-  particleGenerateSpread       : " + particleGenerateSpread);
		output.append("-  particleMinStepSize          : " + particleMinStepSize);
		output.append("-  particleMaxStepSize          : " + particleMaxStepSize);
		output.append("-  particleLifetime             : " + particleLifetime);
		output.append("-  flowLineColor                : " + echoColor(flowLineColor));
		output.append("-  flowLineAlpha                : " + flowLineAlpha);
		output.append("-  depthImageColor              : " + echoColor(depthImageColor));
		output.append("-  depthImageAlpha              : " + depthImageAlpha);
		output.append("---------------------------------------------------------");
		return output.join("\n");
	}

