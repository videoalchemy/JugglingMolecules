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
	int DEPTH_IMAGE_BLEND_MODE_0 = BLEND;				// default stamp
	int DEPTH_IMAGE_BLEND_MODE_1 = SUBTRACT;
	int DEPTH_IMAGE_BLEND_MODE_2 = DARKEST;
	int DEPTH_IMAGE_BLEND_MODE_3 = DIFFERENCE;			// tracks black to body


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
	boolean showDepthImage = true;

	// Show setup screen OVER the rest of the screen.
	boolean showSettings = false;


////////////////////////////////////////////////////////////
//	OpticalFlow field parameters
////////////////////////////////////////////////////////////

	// background color (black)
	color windowBgColor = color(0);	// color
	color windowBgColorFromJSON(float value){return value == 0 ? color(0) : color(255);};

	// Amount to "dim" the background each round by applying partially opaque background
	// Higher number means less of each screen sticks around on subsequent draw cycles.
	int windowOverlayAlpha = 20;	//	0-255
	int WINDOW_OVERLAY_ALPHA_MIN = 0;
	int WINDOW_OVERLAY_ALPHA_MAX = 255;
	int windowOverlayAlphaFromJSON(float value){return (int) map(value, 0, 1, WINDOW_OVERLAY_ALPHA_MIN, WINDOW_OVERLAY_ALPHA_MAX);}
	float windowOverlayAlphaToJSON(){return map((float) windowOverlayAlpha, WINDOW_OVERLAY_ALPHA_MIN, WINDOW_OVERLAY_ALPHA_MAX, 0, 1);}



////////////////////////////////////////////////////////////
//	OpticalFlow field parameters
////////////////////////////////////////////////////////////

	// Resolution of the flow field.
	// Smaller means more coarse flowfield = faster but less precise
	// Larger means finer flowfield = slower but better tracking of edges
	// NOTE: requires restart to change this.
	int flowfieldResolution = 15;	// 1..50 ?
	int FLOWFIELD_RESOLUTION_MIN = 1;
	int FLOWFIELD_RESOLUTION_MAX = 50;
	int flowfieldResolutionFromJSON(float value) {return (int) map(value, 0, 1, FLOWFIELD_RESOLUTION_MIN, FLOWFIELD_RESOLUTION_MAX);}
	float flowfieldResolutionToJSON(){return map((float) flowfieldResolution, FLOWFIELD_RESOLUTION_MIN, FLOWFIELD_RESOLUTION_MAX, 0, 1);}

	// Amount of time (in seconds) between "averages" to compute the flow.
	float flowfieldPredictionTime = 0.5;
	float FLOWFIELD_PREDICTION_TIME_MIN = .1;
	float FLOWFIELD_PREDICTION_TIME_MAX = 2;
	float flowfieldPredictionTimeFromJSON(float value){return map(value, 0, 1, FLOWFIELD_PREDICTION_TIME_MIN, FLOWFIELD_PREDICTION_TIME_MAX);}
	float flowfieldPredictionTimeToJSON(){return map(flowfieldPredictionTime, FLOWFIELD_PREDICTION_TIME_MIN, FLOWFIELD_PREDICTION_TIME_MAX, 0, 1);}

	// Velocity must exceed this to add/draw particles in the flow field.
	int flowfieldMinVelocity = 20;
	int FLOWFIELD_MIN_VELOCITY_MIN = 1;
	int FLOWFIELD_MIN_VELOCITY_MAX = 50;
	int flowfieldMinVelocityFromJSON(float value){return (int) map(value, 0, 1, FLOWFIELD_MIN_VELOCITY_MIN, FLOWFIELD_MIN_VELOCITY_MAX);}
	float flowfieldMinVelocityToJSON(){return map((float) flowfieldMinVelocity, FLOWFIELD_MIN_VELOCITY_MIN, FLOWFIELD_MIN_VELOCITY_MAX, 0, 1);}

	// Regularization term for regression.
	// Larger values for noisy video (?).
	float flowfieldRegularization = pow(10,8);
	float FLOWFIELD_REGULARIZATION_MIN = 0;
	float FLOWFIELD_REGULARIZATION_MAX = pow(10,10);
	float flowfieldRegularizationFromJSON(float value) {return map(value, 0, 1, FLOWFIELD_REGULARIZATION_MIN, FLOWFIELD_REGULARIZATION_MAX);}
	float flowfieldRegularizationToJSON(){return map(flowfieldRegularization, FLOWFIELD_REGULARIZATION_MIN, FLOWFIELD_REGULARIZATION_MAX, 0, 1);}

	// Smoothing of flow field.
	// Smaller value for longer smoothing.
	float flowfieldSmoothing = 0.05;
	float FLOWFIELD_SMOOTHING_MIN = 0;
	float FLOWFIELD_SMOOTHING_MAX = 1;		// ????
	float flowfieldSmoothingFromJSON(float value) {return map(value, 0, 1, FLOWFIELD_SMOOTHING_MIN, FLOWFIELD_SMOOTHING_MAX);}
	float flowfieldSmoothingToJSON(){return map(flowfieldSmoothing, FLOWFIELD_SMOOTHING_MIN, FLOWFIELD_SMOOTHING_MAX, 0, 1);}

////////////////////////////////////////////////////////////
//	Perlin noise generation.
////////////////////////////////////////////////////////////

	// Cloud variation.
	// Low values have long stretching clouds that move long distances.
	// High values have detailed clouds that don't move outside smaller radius.
	float noiseStrength = 100; //1-300;
	float NOISE_STRENGTH_MIN = 1;
	float NOISE_STRENGTH_MAX = 300;
	float noiseStrengthFromJSON(float value){return map(value, 0, 1, NOISE_STRENGTH_MIN, NOISE_STRENGTH_MAX);}
	float noiseStrengthToJSON(){return map(noiseStrength, NOISE_STRENGTH_MIN, NOISE_STRENGTH_MAX, 0, 1);}

	// Cloud strength multiplier.
	// Low strength values makes clouds more detailed but move the same long distances. ???
	float noiseScale = 100; //1-400
	float NOISE_SCALE_MIN = 1;
	float NOISE_SCALE_MAX = 400;
	float noiseScaleFromJSON(float value){return map(value, 0, 1, NOISE_SCALE_MIN, NOISE_SCALE_MAX);}
	float noiseScaleToJSON(){return map(noiseScale, NOISE_SCALE_MIN, NOISE_SCALE_MAX, 0, 1);};

////////////////////////////////////////////////////////////
//	Interaction between particles and flow field.
////////////////////////////////////////////////////////////

	// How much particle slows down in fluid environment.
	float particleViscocity = .995;	//0-1	???
	float PARTICLE_VISCOSITY_MIN = 0;
	float PARTICLE_VISCOSITY_MAX = 1;
	float particleViscocityFromJSON(float value){return map(value, 0, 1, PARTICLE_VISCOSITY_MIN, PARTICLE_VISCOSITY_MAX);}
	float particleViscocityToJSON(){return map(particleViscocity, PARTICLE_VISCOSITY_MIN, PARTICLE_VISCOSITY_MAX, 0, 1);}

	// Force to apply to input - mouse, touch etc.
	float particleForceMultiplier = 50;	 //1-300
	float PARTICLE_FORCE_MULTIPLIER_MIN = 1;
	float PARTICLE_FORCE_MULTIPLIER_MAX = 300;
	float particleForceMultiplierFromJSON(float value){return map(value, 0, 1, PARTICLE_FORCE_MULTIPLIER_MIN, PARTICLE_FORCE_MULTIPLIER_MAX);}
	float particleForceMultiplierToJSON(){return map(particleForceMultiplier, PARTICLE_FORCE_MULTIPLIER_MIN, PARTICLE_FORCE_MULTIPLIER_MAX, 0, 1);}

	// How fast to return to the noise after force velocities.
	float particleAccelerationFriction = .075;	//.001-.999
	float PARTICLE_ACCELERATION_FRICTION_MIN = .001;
	float PARTICLE_ACCELERATION_FRICTION_MAX = .999;
	float particleAccelerationFrictionFromJSON(float value){return map(value, 0, 1, PARTICLE_ACCELERATION_FRICTION_MIN, PARTICLE_ACCELERATION_FRICTION_MAX);}
	float particleAccelerationFrictionToJSON(){return map(particleAccelerationFriction, PARTICLE_ACCELERATION_FRICTION_MIN, PARTICLE_ACCELERATION_FRICTION_MAX, 0, 1);}

	// How fast to return to the noise after force velocities.
	float particleAccelerationLimiter = .35;	// - .999
	float PARTICLE_ACCELERATION_LIMITER_MIN = .001;
	float PARTICLE_ACCELERATION_LIMITER_MAX = .999;
	float particleAccelerationLimiterFromJSON(float value){return map(value, 0, 1, PARTICLE_ACCELERATION_LIMITER_MIN, PARTICLE_ACCELERATION_LIMITER_MAX);}
	float particleAccelerationLimiterToJSON(){return map(particleAccelerationLimiter, PARTICLE_ACCELERATION_LIMITER_MIN, PARTICLE_ACCELERATION_LIMITER_MAX, 0, 1);}

	// Turbulance, or how often to change the 'clouds' - third parameter of perlin noise: time.
	float particleNoiseVelocity = .008; // .005 - .3
	float PARTICLE_NOISE_VELOCITY_MIN = .005;
	float PARTICLE_NOISE_VELOCITY_MAX = .3;
	float particleNoiseVelocityFromJSON(float value){return map(value, 0, 1, PARTICLE_NOISE_VELOCITY_MIN, PARTICLE_NOISE_VELOCITY_MAX);}
	float particleNoiseVelocityToJSON(){return map(particleNoiseVelocity, PARTICLE_NOISE_VELOCITY_MIN, PARTICLE_NOISE_VELOCITY_MAX, 0, 1);}



////////////////////////////////////////////////////////////
//	Particle drawing
////////////////////////////////////////////////////////////

	// Scheme for how we name particles.
	// 	- 0 = all particles same color, coming from `particle[Red|Green|Blue]` below
	// 	- 1 = particle color set from origin
	int PARTICLE_COLOR_SCHEME_SAME_COLOR 	= 0;
	int PARTICLE_COLOR_SCHEME_XY 			= 1;
	int PARTICLE_COLOR_SCHEME_UNKNOWN_1		= 2;
	int PARTICLE_COLOR_SCHEME_UNKNOWN_2		= 3;
	int particleColorScheme = PARTICLE_COLOR_SCHEME_XY;
	int particleColorSchemeFromJSON(float value) {return (int) value;}
	float particleColorSchemeToJSON(){return (float) particleColorScheme;}

	// Color for particles iff `PARTICLE_COLOR_SCHEME_SAME_COLOR` color scheme in use.
	color particleColor		= color(255);
	color particleColorFromJSON(float value) {return colorFromHue(value);}
	float particleColorToJSON(){return hueFromColor(particleColor);}

	// Opacity for all particle lines, used for all color schemes.
	int particleAlpha		= 50;	//0-255
	int PARTICLE_ALPHA_MIN 	= 0;
	int PARTICLE_ALPHA_MAX 	= 255;
	int particleAlphaFromJSON(float value) {return (int) map(value, 0, 1, 0, 255);}
	float particleAlphaToJSON(){return map((float) particleAlpha, 0, 255, 0, 1);}


	// Maximum number of particles that can be active at once.
	// More particles = more detail because less "recycling"
	// Fewer particles = faster.
// TODO: must restart to change this
	int particleMaxCount = 30000;
	int PARTICLE_MAX_COUNT_MIN = 1000;
	int PARTICLE_MAX_COUNT_MAX = 30000;
	int particleMaxCountFromJSON(float value) {return (int) map(value, 0, 1, PARTICLE_MAX_COUNT_MIN, PARTICLE_MAX_COUNT_MAX);}
	float particleMaxCountToJSON(){return map((float) particleMaxCount, PARTICLE_MAX_COUNT_MIN, PARTICLE_MAX_COUNT_MAX, 0, 1);}

	// how many particles to emit when mouse/tuio blob move
	int particleGenerateRate = 10; //2-200
	int PARTICLE_GENERATE_RATE_MIN = 1;
	int PARTICLE_GENERATE_RATE_MAX = 200;
	int particleGenerateRateFromJSON(float value) {return (int) map(value, 0, 1, PARTICLE_GENERATE_RATE_MIN, PARTICLE_GENERATE_RATE_MAX);}
	float particleGenerateRateToJSON() {return map((float)particleGenerateRate, PARTICLE_GENERATE_RATE_MIN, PARTICLE_GENERATE_RATE_MAX, 0, 1);}

	// random offset for particles emitted, so they don't all appear in the same place
	float particleGenerateSpread = 20; //1-50
	float PARTICLE_GENERATE_SPREAD_MIN = 1;
	float PARTICLE_GENERATE_SPREAD_MAX = 50;
	float particleGenerateSpreadFromJSON(float value) {return map(value, 0, 1, PARTICLE_GENERATE_SPREAD_MIN, PARTICLE_GENERATE_SPREAD_MAX);}
	float particleGenerateSpreadToJSON() {return map((float)particleGenerateSpread, PARTICLE_GENERATE_SPREAD_MIN, PARTICLE_GENERATE_SPREAD_MAX, 0, 1);}

	// Upper and lower bound of particle movement each frame.
	int particleMinStepSize = 4;
	int particleMaxStepSize = 8;
	int PARTICLE_STEP_SIZE_MIN = 2;
	int PARTICLE_STEP_SIZE_MAX = 20;
	int particleStepSizeFromJSON(float value){return (int) map(value, 0, 1, PARTICLE_STEP_SIZE_MIN, PARTICLE_STEP_SIZE_MAX);}
	float particleStepSizeToJSON(int stepSize){return map((float) stepSize, PARTICLE_STEP_SIZE_MIN, PARTICLE_STEP_SIZE_MAX, 0, 1);}

	// Particle lifetime.
	int particleLifetime = 400;
	int PARTICLE_LIFETIME_MIN = 50;
	int PARTICLE_LIFETIME_MAX = 1000;
	int particleLifetimeFromJSON(float value){return (int) map(value, 0, 1, PARTICLE_LIFETIME_MIN, PARTICLE_LIFETIME_MAX);}
	float particleLifetimeToJSON(){return map((float) particleLifetime, PARTICLE_LIFETIME_MIN, PARTICLE_LIFETIME_MAX, 0, 1);}


////////////////////////////////////////////////////////////
//	Drawing flow field lines
////////////////////////////////////////////////////////////

	// color for optical flow lines
	color flowLineColor = color(255, 0, 0);
	color flowLineColorFromJSON(float value) {return colorFromHue(value);}
	float flowLineColorToJSON() {return hueFromColor(flowLineColor);}

//TODO: apply alpha separately from hue
	int flowLineAlpha = 30;
	int FLOW_LINE_ALPHA_MIN 	= 0;
	int FLOW_LINE_ALPHA_MAX 	= 255;
	int flowLineAlphaFromJSON(float value){return (int) map(value, 0, 1, FLOW_LINE_ALPHA_MIN, FLOW_LINE_ALPHA_MAX);}
	float flowLineAlphaToJSON(){return map((float) flowLineAlpha, 0, 255, 0, 1);}


////////////////////////////////////////////////////////////
//	Depth image drawing
////////////////////////////////////////////////////////////

	// `tint` color for the depth image.
	// NOTE: NOT CURRENTLY USED.  see
	color depthImageColor = color(128, 12);
	color depthImageColorFromJSON(float value) {return colorFromHue(value);}
	float depthImageColorToJSON() {return hueFromColor(depthImageColor);}

	// blend mode for the depth image
	int depthImageBlendMode = DEPTH_IMAGE_BLEND_MODE_3;
	int depthImageBlendModeFromJSON(float value){
		if (value == 1) depthImageBlendMode = DEPTH_IMAGE_BLEND_MODE_1;
		if (value == 2) depthImageBlendMode = DEPTH_IMAGE_BLEND_MODE_2;
		if (value == 3) depthImageBlendMode = DEPTH_IMAGE_BLEND_MODE_3;
		return DEPTH_IMAGE_BLEND_MODE_0;
	}
	float depthImageBlendModeToJSON(){
		if 		(depthImageBlendMode == DEPTH_IMAGE_BLEND_MODE_1) return 1;
		else if (depthImageBlendMode == DEPTH_IMAGE_BLEND_MODE_2) return 2;
		else if (depthImageBlendMode == DEPTH_IMAGE_BLEND_MODE_3) return 3;
		return 0;
	}





////////////////////////////////////////////////////////////
//	Config manipulation
////////////////////////////////////////////////////////////

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
		else if (keyName.equals("showSettings")) 			showSettings   = (value != 0);


	/////////////////
	//	Background/overlay
	/////////////////
		// window background color, 0 == black, 1 == white
		else if (keyName.equals("windowBgColor"))			 	windowBgColor = windowBgColorFromJSON(value);

		// background overlay opacity
		else if (keyName.equals("windowOverlayAlpha"))			windowOverlayAlpha = windowOverlayAlphaFromJSON(value);
		else if (keyName.equals("WINDOW_OVERLAY_ALPHA_MIN"))	WINDOW_OVERLAY_ALPHA_MIN = (int) value;
		else if (keyName.equals("WINDOW_OVERLAY_ALPHA_MAX"))	WINDOW_OVERLAY_ALPHA_MAX = (int) value;


	/////////////////
	//	Optical Flow
	/////////////////
		// flowfield resolution
		else if (keyName.equals("flowfieldResolution"))				flowfieldResolution = flowfieldResolutionFromJSON(value);
		else if (keyName.equals("FLOWFIELD_RESOLUTION_MIN"))		FLOWFIELD_RESOLUTION_MIN = (int) value;
		else if (keyName.equals("FLOWFIELD_RESOLUTION_MAX"))		FLOWFIELD_RESOLUTION_MAX = (int) value;

		// flowfield prediction time (seconds)
		else if (keyName.equals("flowfieldPredictionTime"))			flowfieldPredictionTime = flowfieldPredictionTimeFromJSON(value);
		else if (keyName.equals("FLOWFIELD_PREDICTION_TIME_MIN"))	FLOWFIELD_PREDICTION_TIME_MIN = value;
		else if (keyName.equals("FLOWFIELD_PREDICTION_TIME_MAX"))	FLOWFIELD_PREDICTION_TIME_MAX = value;

		// flowfield min velocity
		else if (keyName.equals("flowfieldMinVelocity"))			flowfieldMinVelocity = flowfieldMinVelocityFromJSON(value);
		else if (keyName.equals("FLOWFIELD_MIN_VELOCITY_MIN"))		FLOWFIELD_MIN_VELOCITY_MIN = (int) value;
		else if (keyName.equals("FLOWFIELD_MIN_VELOCITY_MAX"))		FLOWFIELD_MIN_VELOCITY_MAX = (int) value;

		// flowfield regularization term
		else if (keyName.equals("flowfieldRegularization"))			flowfieldRegularization = flowfieldRegularizationFromJSON(value);
		else if (keyName.equals("FLOWFIELD_REGULARIZATION_MIN"))	FLOWFIELD_REGULARIZATION_MIN = value;
		else if (keyName.equals("FLOWFIELD_REGULARIZATION_MAX"))	FLOWFIELD_REGULARIZATION_MAX = value;

		// flowfield smoothing term
		else if (keyName.equals("flowfieldSmoothing"))				flowfieldSmoothing = flowfieldSmoothingFromJSON(value);
		else if (keyName.equals("FLOWFIELD_SMOOTHING_MIN"))			FLOWFIELD_SMOOTHING_MIN = value;
		else if (keyName.equals("FLOWFIELD_SMOOTHING_MAX"))			FLOWFIELD_SMOOTHING_MAX = value;


	/////////////////
	//	Noise generation
	/////////////////
		// noise strength
		else if (keyName.equals("noiseStrength"))				noiseStrength = noiseStrengthFromJSON(value);
		else if (keyName.equals("NOISE_STRENGTH_MIN"))			NOISE_STRENGTH_MIN = value;
		else if (keyName.equals("NOISE_STRENGTH_MAX"))			NOISE_STRENGTH_MAX = value;

		// noise strength
		else if (keyName.equals("noiseScale"))					noiseScale = noiseScaleFromJSON(value);
		else if (keyName.equals("NOISE_SCALE_MIN"))				NOISE_SCALE_MIN = value;
		else if (keyName.equals("NOISE_SCALE_MAX"))				NOISE_SCALE_MAX = value;


	/////////////////
	// 	Particle interaction with flow field
	/////////////////
		// particle viscocity
		else if (keyName.equals("particleViscocity"))					particleViscocity = particleViscocityFromJSON(value);
		else if (keyName.equals("PARTICLE_VISCOSITY_MIN"))				PARTICLE_VISCOSITY_MIN = value;
		else if (keyName.equals("PARTICLE_VISCOSITY_MAX"))				PARTICLE_VISCOSITY_MAX = value;

		// particle force multiplier
		else if (keyName.equals("particleForceMultiplier"))				particleForceMultiplier = particleForceMultiplierFromJSON(value);
		else if (keyName.equals("PARTICLE_FORCE_MULTIPLIER_MIN"))		PARTICLE_FORCE_MULTIPLIER_MIN = value;
		else if (keyName.equals("PARTICLE_FORCE_MULTIPLIER_MAX"))		PARTICLE_FORCE_MULTIPLIER_MAX = value;

		// particle acceleration friction
		else if (keyName.equals("particleAccelerationFriction"))		particleAccelerationFriction = particleAccelerationFrictionFromJSON(value);
		else if (keyName.equals("PARTICLE_ACCELERATION_FRICTION_MIN"))	PARTICLE_ACCELERATION_FRICTION_MIN = value;
		else if (keyName.equals("PARTICLE_ACCELERATION_FRICTION_MAX"))	PARTICLE_ACCELERATION_FRICTION_MAX = value;

		// particle acceleration limiter
		else if (keyName.equals("particleAccelerationLimiter"))			particleAccelerationLimiter = particleAccelerationLimiterFromJSON(value);
		else if (keyName.equals("PARTICLE_ACCELERATION_LIMITER_MIN"))	PARTICLE_ACCELERATION_LIMITER_MIN = value;
		else if (keyName.equals("PARTICLE_ACCELERATION_LIMITER_MAX"))	PARTICLE_ACCELERATION_LIMITER_MAX = value;

		// particle noise velocity
		else if (keyName.equals("particleNoiseVelocity"))				particleNoiseVelocity = particleNoiseVelocityFromJSON(value);
		else if (keyName.equals("PARTICLE_NOISE_VELOCITY_MIN"))			PARTICLE_NOISE_VELOCITY_MIN = value;
		else if (keyName.equals("PARTICLE_NOISE_VELOCITY_MAX"))			PARTICLE_NOISE_VELOCITY_MAX = value;


	/////////////////
	// 	Particle drawing
	/////////////////
		// particle color scheme
		else if (keyName.equals("particleColorScheme")) 			particleColorScheme = particleColorSchemeFromJSON(value);

		// particle color as Hue + Opacity
		else if (keyName.equals("particleHue"))						particleColor = particleColorFromJSON(value);
		else if (keyName.equals("particleAlpha"))					particleAlpha = particleAlphaFromJSON(value);
		else if (keyName.equals("PARTICLE_ALPHA_MIN"))				PARTICLE_ALPHA_MIN = (int) value;
		else if (keyName.equals("PARTICLE_ALPHA_MAX"))				PARTICLE_ALPHA_MAX = (int) value;

		// particle max count
		else if (keyName.equals("particleMaxCount"))				particleMaxCount = particleMaxCountFromJSON(value);
		else if (keyName.equals("PARTICLE_MAX_COUNT_MIN"))			PARTICLE_MAX_COUNT_MIN = (int) value;
		else if (keyName.equals("PARTICLE_MAX_COUNT_MAX"))			PARTICLE_MAX_COUNT_MAX = (int) value;

		// particle generate rate
		else if (keyName.equals("particleGenerateRate"))			particleGenerateRate = particleGenerateRateFromJSON(value);
		else if (keyName.equals("PARTICLE_GENERATE_RATE_MIN"))		PARTICLE_GENERATE_RATE_MIN = (int) value;
		else if (keyName.equals("PARTICLE_GENERATE_RATE_MAX"))		PARTICLE_GENERATE_RATE_MAX = (int) value;

		// particle generate spread
		else if (keyName.equals("particleGenerateSpread"))			particleGenerateSpread = particleGenerateSpreadFromJSON(value);
		else if (keyName.equals("PARTICLE_GENERATE_SPREAD_MIN"))	PARTICLE_GENERATE_SPREAD_MIN = value;
		else if (keyName.equals("PARTICLE_GENERATE_SPREAD_MAX"))	PARTICLE_GENERATE_SPREAD_MAX = value;

		// particle min/max step size
		else if (keyName.equals("particleMinStepSize"))				particleMinStepSize = particleStepSizeFromJSON(value);
		else if (keyName.equals("particleMaxStepSize"))				particleMaxStepSize = particleStepSizeFromJSON(value);
		else if (keyName.equals("PARTICLE_STEP_SIZE_MIN"))			PARTICLE_STEP_SIZE_MIN = (int) value;
		else if (keyName.equals("PARTICLE_STEP_SIZE_MAX"))			PARTICLE_STEP_SIZE_MAX = (int) value;

		// particle lifetime
		else if (keyName.equals("particleLifetime"))				particleLifetime = particleLifetimeFromJSON(value);
		else if (keyName.equals("PARTICLE_LIFETIME_MIN"))			PARTICLE_LIFETIME_MIN = (int) value;
		else if (keyName.equals("PARTICLE_LIFETIME_MAX"))			PARTICLE_LIFETIME_MAX = (int) value;


	/////////////////
	// 	Particle drawing
	/////////////////
		// flow field line color as Hue + Opacity
		else if (keyName.equals("flowLineHue"))						flowLineColor = flowLineColorFromJSON(value);
		else if (keyName.equals("flowLineAlpha"))					flowLineAlpha = flowLineAlphaFromJSON(value);
		else if (keyName.equals("FLOW_LINE_ALPHA_MIN"))				FLOW_LINE_ALPHA_MIN = (int) value;
		else if (keyName.equals("FLOW_LINE_ALPHA_MAX"))				FLOW_LINE_ALPHA_MAX = (int) value;


	/////////////////
	// 	Depth image drawing
	/////////////////
		// depth image color as Hue (no opacity)
		else if (keyName.equals("depthImageHue"))					depthImageColor = depthImageColorFromJSON(value);
		else if (keyName.equals("depthImageBlendMode")) 			depthImageBlendMode = depthImageBlendModeFromJSON(value);

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

		this.addToJSONArray(array, "showParticles", showParticles ? 1 : 0);
		this.addToJSONArray(array, "showFlowLines", showFlowLines ? 1 : 0);
		this.addToJSONArray(array, "showDepthImage", showDepthImage ? 1 : 0);
		this.addToJSONArray(array, "showSettings", showSettings ? 1 : 0);

	/////////////////
	//	Background/overlay
	/////////////////
		// window background color, 0 == black, 1 == white
		this.addToJSONArray(array, "windowBgColor", (red(windowBgColor) == 0 ? 0 : 1));
		if (saveMinMax) this.addToJSONArray(array, "WINDOW_OVERLAY_ALPHA_MIN", (float) WINDOW_OVERLAY_ALPHA_MIN);
		if (saveMinMax) this.addToJSONArray(array, "WINDOW_OVERLAY_ALPHA_MAX", (float) WINDOW_OVERLAY_ALPHA_MAX);
		this.addToJSONArray(array, "windowOverlayAlpha", windowOverlayAlphaToJSON());

	/////////////////
	//	Optical Flow
	/////////////////
		// flowfield resolution
		if (saveMinMax) this.addToJSONArray(array, "FLOWFIELD_RESOLUTION_MIN", (float) FLOWFIELD_RESOLUTION_MIN);
		if (saveMinMax) this.addToJSONArray(array, "FLOWFIELD_RESOLUTION_MAX", (float) FLOWFIELD_RESOLUTION_MAX);
		this.addToJSONArray(array, "flowfieldResolution", flowfieldResolutionToJSON());

		// flowfield prediction time (seconds)
		if (saveMinMax) this.addToJSONArray(array, "FLOWFIELD_PREDICTION_TIME_MIN", FLOWFIELD_PREDICTION_TIME_MIN);
		if (saveMinMax) this.addToJSONArray(array, "FLOWFIELD_PREDICTION_TIME_MAX", FLOWFIELD_PREDICTION_TIME_MAX);
		this.addToJSONArray(array, "flowfieldPredictionTime", flowfieldPredictionTimeToJSON());

		// flowfield min velocity
		if (saveMinMax) this.addToJSONArray(array, "FLOWFIELD_MIN_VELOCITY_MIN", (float) FLOWFIELD_MIN_VELOCITY_MIN);
		if (saveMinMax) this.addToJSONArray(array, "FLOWFIELD_MIN_VELOCITY_MAX", (float) FLOWFIELD_MIN_VELOCITY_MAX);
		this.addToJSONArray(array, "flowfieldMinVelocity", flowfieldMinVelocityToJSON());

		// flowfield regularization term
		if (saveMinMax) this.addToJSONArray(array, "FLOWFIELD_REGULARIZATION_MIN", FLOWFIELD_REGULARIZATION_MIN);
		if (saveMinMax) this.addToJSONArray(array, "FLOWFIELD_REGULARIZATION_MAX", FLOWFIELD_REGULARIZATION_MAX);
		this.addToJSONArray(array, "flowfieldRegularization", flowfieldRegularizationToJSON());

		// flowfield smoothing term
		if (saveMinMax) this.addToJSONArray(array, "FLOWFIELD_SMOOTHING_MIN", FLOWFIELD_SMOOTHING_MIN);
		if (saveMinMax) this.addToJSONArray(array, "FLOWFIELD_SMOOTHING_MAX", FLOWFIELD_SMOOTHING_MAX);
		this.addToJSONArray(array, "flowfieldSmoothing", flowfieldSmoothingToJSON());

	/////////////////
	//	Noise generation
	/////////////////
		// noise strength
		if (saveMinMax) this.addToJSONArray(array, "NOISE_STRENGTH_MIN", NOISE_STRENGTH_MIN);
		if (saveMinMax) this.addToJSONArray(array, "NOISE_STRENGTH_MAX", NOISE_STRENGTH_MAX);
		this.addToJSONArray(array, "noiseStrength", this.noiseStrengthToJSON());

		// noise strength
		if (saveMinMax) this.addToJSONArray(array, "NOISE_SCALE_MIN", NOISE_SCALE_MIN);
		if (saveMinMax) this.addToJSONArray(array, "NOISE_SCALE_MAX", NOISE_SCALE_MAX);
		this.addToJSONArray(array, "noiseScale", this.noiseScaleToJSON());

	/////////////////
	// 	Particle interaction with flow field
	/////////////////
		// particle viscocity
		if (saveMinMax) this.addToJSONArray(array, "PARTICLE_VISCOSITY_MIN", PARTICLE_VISCOSITY_MIN);
		if (saveMinMax) this.addToJSONArray(array, "PARTICLE_VISCOSITY_MAX", PARTICLE_VISCOSITY_MAX);
		this.addToJSONArray(array, "particleViscocity", particleViscocityToJSON());

		// particle force multiplier
		if (saveMinMax) this.addToJSONArray(array, "PARTICLE_FORCE_MULTIPLIER_MIN", PARTICLE_FORCE_MULTIPLIER_MIN);
		if (saveMinMax) this.addToJSONArray(array, "PARTICLE_FORCE_MULTIPLIER_MAX", PARTICLE_FORCE_MULTIPLIER_MAX);
		this.addToJSONArray(array, "particleForceMultiplier", particleForceMultiplierToJSON());

		// particle acceleration friction
		if (saveMinMax) this.addToJSONArray(array, "PARTICLE_ACCELERATION_FRICTION_MIN", PARTICLE_ACCELERATION_FRICTION_MIN);
		if (saveMinMax) this.addToJSONArray(array, "PARTICLE_ACCELERATION_FRICTION_MAX", PARTICLE_ACCELERATION_FRICTION_MAX);
		this.addToJSONArray(array, "particleAccelerationFriction", particleAccelerationFrictionToJSON());

		// particle acceleration limiter
		if (saveMinMax) this.addToJSONArray(array, "PARTICLE_ACCELERATION_LIMITER_MIN", PARTICLE_ACCELERATION_LIMITER_MIN);
		if (saveMinMax) this.addToJSONArray(array, "PARTICLE_ACCELERATION_LIMITER_MAX", PARTICLE_ACCELERATION_LIMITER_MAX);
		this.addToJSONArray(array, "particleAccelerationLimiter", particleAccelerationLimiterToJSON());

		// particle noise velocity
		if (saveMinMax) this.addToJSONArray(array, "PARTICLE_NOISE_VELOCITY_MIN", PARTICLE_NOISE_VELOCITY_MIN);
		if (saveMinMax) this.addToJSONArray(array, "PARTICLE_NOISE_VELOCITY_MAX", PARTICLE_NOISE_VELOCITY_MAX);
		this.addToJSONArray(array, "particleNoiseVelocity", particleNoiseVelocityToJSON());

	/////////////////
	// 	Particle drawing
	/////////////////
		// particle color scheme
		this.addToJSONArray(array, "particleColorScheme", particleColorSchemeToJSON());

		// particle color as Hue + Opacity
		this.addToJSONArray(array, "particleHue", particleColorToJSON());
		if (saveMinMax) this.addToJSONArray(array, "PARTICLE_ALPHA_MIN", (float) FLOW_LINE_ALPHA_MIN);
		if (saveMinMax) this.addToJSONArray(array, "PARTICLE_ALPHA_MAX", (float) PARTICLE_ALPHA_MAX);
		this.addToJSONArray(array, "particleAlpha", particleAlphaToJSON());

		// particle max count
		if (saveMinMax) this.addToJSONArray(array, "PARTICLE_MAX_COUNT_MIN", (float) PARTICLE_MAX_COUNT_MIN);
		if (saveMinMax) this.addToJSONArray(array, "PARTICLE_MAX_COUNT_MAX", (float) PARTICLE_MAX_COUNT_MAX);
		this.addToJSONArray(array, "particleMaxCount", particleMaxCountToJSON());

		// particle generate rate
		if (saveMinMax) this.addToJSONArray(array, "PARTICLE_GENERATE_RATE_MIN", (float) PARTICLE_GENERATE_RATE_MIN);
		if (saveMinMax) this.addToJSONArray(array, "PARTICLE_GENERATE_RATE_MAX", (float) PARTICLE_GENERATE_RATE_MAX);
		this.addToJSONArray(array, "particleGenerateRate", this.particleGenerateRateToJSON());

		// particle generate spread
		if (saveMinMax) this.addToJSONArray(array, "PARTICLE_GENERATE_SPREAD_MIN", PARTICLE_GENERATE_SPREAD_MIN);
		if (saveMinMax) this.addToJSONArray(array, "PARTICLE_GENERATE_SPREAD_MAX", PARTICLE_GENERATE_SPREAD_MAX);
		this.addToJSONArray(array, "particleGenerateSpread", this.particleGenerateSpreadToJSON());

		// particle min/max step size
		if (saveMinMax) this.addToJSONArray(array, "PARTICLE_STEP_SIZE_MIN", (float) PARTICLE_STEP_SIZE_MIN);
		if (saveMinMax) this.addToJSONArray(array, "PARTICLE_STEP_SIZE_MAX", (float) PARTICLE_STEP_SIZE_MAX);
		this.addToJSONArray(array, "particleMinStepSize", particleStepSizeToJSON(particleMinStepSize));
		this.addToJSONArray(array, "particleMaxStepSize", particleStepSizeToJSON(particleMaxStepSize));

		// particle lifetime
		if (saveMinMax) this.addToJSONArray(array, "PARTICLE_LIFETIME_MIN", (float) PARTICLE_LIFETIME_MIN);
		if (saveMinMax) this.addToJSONArray(array, "PARTICLE_LIFETIME_MAX", (float) PARTICLE_LIFETIME_MAX);
		this.addToJSONArray(array, "particleLifetime", particleLifetimeToJSON());


	/////////////////
	// 	Particle drawing
	/////////////////
		// flow field line color as Hue + Opacity
		this.addToJSONArray(array, "flowLineHue", flowLineColorToJSON());
		if (saveMinMax) this.addToJSONArray(array, "FLOW_LINE_ALPHA_MIN", (float) FLOW_LINE_ALPHA_MIN);
		if (saveMinMax) this.addToJSONArray(array, "FLOW_LINE_ALPHA_MAX", (float) FLOW_LINE_ALPHA_MAX);
		this.addToJSONArray(array, "flowLineAlpha", flowLineAlphaToJSON());

	/////////////////
	// 	Depth image drawing
	/////////////////
		// depth image color as Hue (no opacity)
		this.addToJSONArray(array, "depthImageHue", depthImageColorToJSON());
		// depth image blend mode
		this.addToJSONArray(array, "depthImageBlendMode", depthImageBlendModeToJSON());

		return array;
	}

	// Add a string+float to a JSON array.
	void addToJSONArray(JSONArray array, String keyName, float value) {
		array.setString(array.size(), keyName);
		array.setFloat(array.size(), value);
	}






















}
