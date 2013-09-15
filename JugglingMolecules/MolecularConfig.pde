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

	// Amount to "dim" the background each round by applying partially opaque background
	// Higher number means less of each screen sticks around on subsequent draw cycles.
	int windowOverlayAlpha = 20;	//	0-255
	int WINDOW_OVERLAY_ALPHA_MIN = 0;
	int WINDOW_OVERLAY_ALPHA_MAX = 255;




////////////////////////////////////////////////////////////
//	OpticalFlow field parameters
////////////////////////////////////////////////////////////

	// Resolution of the flow field.
	// Smaller means more coarse flowfield = faster but less precise
	// Larger means finer flowfield = slower but better tracking of edges
	// NOTE: requires restart to change this.
	int flowfieldResolution = 15;	// 1..50 ?
	int FLOWFIELD_RESOLUTION_MIN = 1;
	int FLOWFIELD_RESOLUTION_MAX = 50;	// ???

	// Amount of time (in seconds) between "averages" to compute the flow.
	float flowfieldPredictionTime = 0.5;
	float FLOWFIELD_PREDICTION_TIME_MIN = .1;
	float FLOWFIELD_PREDICTION_TIME_MAX = 2;

	// Velocity must exceed this to add/draw particles in the flow field.
	int flowfieldMinVelocity = 20;
	int FLOWFIELD_MIN_VELOCITY_MIN = 1;
	int FLOWFIELD_MIN_VELOCITY_MAX = 50;

	// Regularization term for regression.
	// Larger values for noisy video (?).
	float flowfieldRegularization = pow(10,8);
	float FLOWFIELD_REGULARIZATION_MIN = 0;
	float FLOWFIELD_REGULARIZATION_MAX = pow(10,10);

	// Smoothing of flow field.
	// Smaller value for longer smoothing.
	float flowfieldSmoothing = 0.05;
	float FLOWFIELD_SMOOTHING_MIN = 0;
	float FLOWFIELD_SMOOTHING_MAX = 1;		// ????


////////////////////////////////////////////////////////////
//	Perlin noise generation.
////////////////////////////////////////////////////////////

	// Cloud variation.
	// Low values have long stretching clouds that move long distances.
	// High values have detailed clouds that don't move outside smaller radius.
	float noiseStrength = 100; //1-300;
	float NOISE_STRENGTH_MIN = 1;
	float NOISE_STRENGTH_MAX = 300;

	// Cloud strength multiplier.
	// Low strength values makes clouds more detailed but move the same long distances. ???
	float noiseScale = 100; //1-400
	float NOISE_SCALE_MIN = 1;
	float NOISE_SCALE_MAX = 400;


////////////////////////////////////////////////////////////
//	Interaction between particles and flow field.
////////////////////////////////////////////////////////////

	// How much particle slows down in fluid environment.
	float particleViscocity = .995;	//0-1	???
	float PARTICLE_VISCOSITY_MIN = 0;
	float PARTICLE_VISCOSITY_MAX = 1;

	// Force to apply to input - mouse, touch etc.
	float particleForceMultiplier = 50;	 //1-300
	float PARTICLE_FORCE_MULTIPLIER_MIN = 1;
	float PARTICLE_FORCE_MULTIPLIER_MAX = 300;

	// How fast to return to the noise after force velocities.
	float particleAccelerationFriction = .075;	//.001-.999
	float PARTICLE_ACCELERATION_FRICTION_MIN = .001;
	float PARTICLE_ACCELERATION_FRICTION_MAX = .999;

	// How fast to return to the noise after force velocities.
	float particleAccelerationLimiter = .35;	// - .999
	float PARTICLE_ACCELERATION_LIMITER_MIN = .001;
	float PARTICLE_ACCELERATION_LIMITER_MAX = .999;

	// Turbulance, or how often to change the 'clouds' - third parameter of perlin noise: time.
	float particleNoiseVelocity = .008; // .005 - .3
	float PARTICLE_NOISE_VELOCITY_MIN = .005;
	float PARTICLE_NOISE_VELOCITY_MAX = .3;




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

	// Color for particles iff `PARTICLE_COLOR_SCHEME_SAME_COLOR` color scheme in use.
	color particleColor		= color(255);

	// Opacity for all particle lines, used for all color schemes.
	int particleAlpha		= 50;	//0-255
	int PARTICLE_ALPHA_MIN 	= 0;
	int PARTICLE_ALPHA_MAX 	= 255;


	// Maximum number of particles that can be active at once.
	// More particles = more detail because less "recycling"
	// Fewer particles = faster.
// TODO: must restart to change this
	int particleMaxCount = 30000;
	int PARTICLE_MAX_COUNT_MIN = 1000;
	int PARTICLE_MAX_COUNT_MAX = 30000;

	// how many particles to emit when mouse/tuio blob move
	int particleGenerateRate = 10; //2-200
	int PARTICLE_GENERATE_RATE_MIN = 1;
	int PARTICLE_GENERATE_RATE_MAX = 200;

	// random offset for particles emitted, so they don't all appear in the same place
	float particleGenerateSpread = 20; //1-50
	float PARTICLE_GENERATE_SPREAD_MIN = 1;
	float PARTICLE_GENERATE_SPREAD_MAX = 50;

	// Upper and lower bound of particle movement each frame.
	int particleMinStepSize = 4;
	int particleMaxStepSize = 8;
	int PARTICLE_STEP_SIZE_MIN = 2;
	int PARTICLE_STEP_SIZE_MAX = 20;

	// Particle lifetime.
	int particleLifetime = 400;
	int PARTICLE_LIFETIME_MIN = 50;
	int PARTICLE_LIFETIME_MAX = 1000;


////////////////////////////////////////////////////////////
//	Drawing flow field lines
////////////////////////////////////////////////////////////

	// color for optical flow lines
	color flowLineColor = color(255, 0, 0);
//TODO: apply alpha separately from hue
	int   flowLineAlpha = 30;
	int FLOW_LINE_ALPHA_MIN 	= 0;
	int FLOW_LINE_ALPHA_MAX 	= 255;



////////////////////////////////////////////////////////////
//	Depth image drawing
////////////////////////////////////////////////////////////

	// `tint` color for the depth image.
	// NOTE: NOT CURRENTLY USED.  see
	color depthImageColor = color(128, 12);

	// blend mode for the depth image
	int depthImageBlendMode = DEPTH_IMAGE_BLEND_MODE_3;





////////////////////////////////////////////////////////////
//	Config manipulation
////////////////////////////////////////////////////////////

	// Load configuration from json data stored in a config file.
	// `configFileName` is, e.g., `PS01`.
	void loadFromConfigFile(String configFileName) {
		String filePath = "config/"+configFileName+".json";
		println("Loading MolecularConfiguration from "+filePath);

		JSONObject json = loadJSONObject(filePath);
		Iterator keyIterator = json.keyIterator();
		while (keyIterator.hasNext()) {
			String keyName 	= (String)keyIterator.next();
			float  value 	= json.getFloat(keyName);

			println("   Setting "+keyName+" to (float) value "+json.getFloat(keyName));
			this.applyConfigValue(keyName, value);
		}
	}

	// Save our current configuration to a JSON file.
	// `configFileName` is, e.g., `PS01`.
	void saveToConfigFile(String configFileName) {
		String filePath = "config/"+configFileName+".json";
		println("Saving MolecularConfiguration to "+filePath);

		JSONObject json = this.toJSON(true);
		saveJSONObject(json, filePath);
	}


	// Apply a single named configuration value to our current configuration.
	void applyConfigValue(String configName, float value) {

	/////////////////
	//	Display of different layers
	/////////////////
		if 		(configName == "showParticles")		showParticles  = (value != 0);
		else if (configName == "showFlowLines") 	showFlowLines  = (value != 0);
		else if (configName == "showDepthImage") 	showDepthImage = (value != 0);
		else if (configName == "showSettings") 		showSettings   = (value != 0);


	/////////////////
	//	Background/overlay
	/////////////////
		// window background color, 0 == black, 1 == white
		else if (configName == "windowBgColor")			 		windowBgColor = (value == 0 ? color(0) : color(1));

		// background overlay opacity
		else if (configName == "windowOverlayAlpha")			windowOverlayAlpha = (int) map(value, 0, 1, WINDOW_OVERLAY_ALPHA_MIN, WINDOW_OVERLAY_ALPHA_MAX);
		else if (configName == "WINDOW_OVERLAY_ALPHA_MIN")		WINDOW_OVERLAY_ALPHA_MIN = (int) map(value, 0, 1, 0, 255);
		else if (configName == "WINDOW_OVERLAY_ALPHA_MAX")		WINDOW_OVERLAY_ALPHA_MAX = (int) map(value, 0, 1, 0, 255);


	/////////////////
	//	Optical Flow
	/////////////////
		// flowfield resolution
		else if (configName == "flowfieldResolution")			flowfieldResolution = (int) map(value, 0, 1, FLOWFIELD_RESOLUTION_MIN, FLOWFIELD_RESOLUTION_MAX);
		else if (configName == "FLOWFIELD_RESOLUTION_MIN")		FLOWFIELD_RESOLUTION_MIN = (int) map(value, 0, 1, 1, 50);
		else if (configName == "FLOWFIELD_RESOLUTION_MAX")		FLOWFIELD_RESOLUTION_MAX = (int) map(value, 0, 1, 1, 50);

		// flowfield prediction time (seconds)
		else if (configName == "flowfieldPredictionTime")		flowfieldPredictionTime = map(value, 0, 1, FLOWFIELD_PREDICTION_TIME_MIN, FLOWFIELD_PREDICTION_TIME_MAX);
		else if (configName == "FLOWFIELD_PREDICTION_TIME_MIN")	FLOWFIELD_PREDICTION_TIME_MIN = map(value, 0, 1, .1, 2);
		else if (configName == "FLOWFIELD_PREDICTION_TIME_MAX")	FLOWFIELD_PREDICTION_TIME_MAX = map(value, 0, 1, .1, 2);

		// flowfield min velocity
		else if (configName == "flowfieldMinVelocity")			flowfieldMinVelocity = (int) map(value, 0, 1, FLOWFIELD_MIN_VELOCITY_MIN, FLOWFIELD_MIN_VELOCITY_MAX);
		else if (configName == "FLOWFIELD_MIN_VELOCITY_MIN")	FLOWFIELD_MIN_VELOCITY_MIN = (int) map(value, 0, 1, 1, 50);
		else if (configName == "FLOWFIELD_MIN_VELOCITY_MAX")	FLOWFIELD_MIN_VELOCITY_MAX = (int) map(value, 0, 1, 1, 50);

		// flowfield regularization term
		else if (configName == "flowfieldRegularization")		flowfieldRegularization = map(value, 0, 1, FLOWFIELD_REGULARIZATION_MIN, FLOWFIELD_REGULARIZATION_MAX);
		else if (configName == "FLOWFIELD_REGULARIZATION_MIN")	FLOWFIELD_REGULARIZATION_MIN = map(value, 0, 1, 0, pow(10,10));
		else if (configName == "FLOWFIELD_REGULARIZATION_MAX")	FLOWFIELD_REGULARIZATION_MAX = map(value, 0, 1, 0, pow(10,10));

		// flowfield smoothing term
		else if (configName == "flowfieldSmoothing")			flowfieldSmoothing = map(value, 0, 1, FLOWFIELD_SMOOTHING_MIN, FLOWFIELD_SMOOTHING_MAX);
		else if (configName == "FLOWFIELD_SMOOTHING_MIN")		FLOWFIELD_SMOOTHING_MIN = map(value, 0, 1, 0, 1);
		else if (configName == "FLOWFIELD_SMOOTHING_MAX")		FLOWFIELD_SMOOTHING_MAX = map(value, 0, 1, 0, 1);


	/////////////////
	//	Noise generation
	/////////////////
		// noise strength
		else if (configName == "noiseStrength")					noiseStrength = map(value, 0, 1, NOISE_STRENGTH_MIN, NOISE_STRENGTH_MAX);
		else if (configName == "NOISE_STRENGTH_MIN")			NOISE_STRENGTH_MIN = map(value, 0, 1, 1, 300);
		else if (configName == "NOISE_STRENGTH_MAX")			NOISE_STRENGTH_MAX = map(value, 0, 1, 1, 300);

		// noise strength
		else if (configName == "noiseScale")					noiseScale = map(value, 0, 1, NOISE_SCALE_MIN, NOISE_SCALE_MAX);
		else if (configName == "NOISE_SCALE_MIN")				NOISE_SCALE_MIN = map(value, 0, 1, 1, 400);
		else if (configName == "NOISE_SCALE_MAX")				NOISE_SCALE_MAX = map(value, 0, 1, 1, 400);


	/////////////////
	// 	Particle interaction with flow field
	/////////////////
		// particle viscocity
		else if (configName == "particleViscocity")				particleViscocity = map(value, 0, 1, PARTICLE_VISCOSITY_MIN, PARTICLE_VISCOSITY_MAX);
		else if (configName == "PARTICLE_VISCOSITY_MIN")		PARTICLE_VISCOSITY_MIN = map(value, 0, 1, 0, 1);
		else if (configName == "PARTICLE_VISCOSITY_MAX")		PARTICLE_VISCOSITY_MAX = map(value, 0, 1, 0, 1);

		// particle force multiplier
		else if (configName == "particleForceMultiplier")		particleForceMultiplier = map(value, 0, 1, PARTICLE_FORCE_MULTIPLIER_MIN, PARTICLE_FORCE_MULTIPLIER_MAX);
		else if (configName == "PARTICLE_FORCE_MULTIPLIER_MIN")	PARTICLE_FORCE_MULTIPLIER_MIN = map(value, 0, 1, 1, 300);
		else if (configName == "PARTICLE_FORCE_MULTIPLIER_MAX")	PARTICLE_FORCE_MULTIPLIER_MAX = map(value, 0, 1, 1, 300);

		// particle acceleration friction
		else if (configName == "particleAccelerationFriction")		particleAccelerationFriction = map(value, 0, 1, PARTICLE_ACCELERATION_FRICTION_MIN, PARTICLE_ACCELERATION_FRICTION_MAX);
		else if (configName == "PARTICLE_ACCELERATION_FRICTION_MIN")PARTICLE_ACCELERATION_FRICTION_MIN = map(value, 0, 1, .001, .999);
		else if (configName == "PARTICLE_ACCELERATION_FRICTION_MAX")PARTICLE_ACCELERATION_FRICTION_MAX = map(value, 0, 1, .001, .999);

		// particle acceleration limiter
		else if (configName == "particleAccelerationLimiter")		particleAccelerationLimiter = map(value, 0, 1, PARTICLE_ACCELERATION_LIMITER_MIN, PARTICLE_ACCELERATION_LIMITER_MAX);
		else if (configName == "PARTICLE_ACCELERATION_LIMITER_MIN")	PARTICLE_ACCELERATION_LIMITER_MIN = map(value, 0, 1, .001, .999);
		else if (configName == "PARTICLE_ACCELERATION_LIMITER_MAX")	PARTICLE_ACCELERATION_LIMITER_MAX = map(value, 0, 1, .001, .999);

		// particle noise velocity
		else if (configName == "particleNoiseVelocity")			particleNoiseVelocity = map(value, 0, 1, PARTICLE_NOISE_VELOCITY_MIN, PARTICLE_NOISE_VELOCITY_MAX);
		else if (configName == "PARTICLE_NOISE_VELOCITY_MIN")	PARTICLE_NOISE_VELOCITY_MIN = map(value, 0, 1, .005, .3);
		else if (configName == "PARTICLE_NOISE_VELOCITY_MAX")	PARTICLE_NOISE_VELOCITY_MAX = map(value, 0, 1, .005, .3);


	/////////////////
	// 	Particle drawing
	/////////////////
		// particle color scheme
		else if (configName == "particleColorScheme") 			particleColorScheme = (int) value;

		// particle color as Hue + Opacity
		else if (configName == "particleHue")					particleColor = colorFromHue(value);
		else if (configName == "particleAlpha")					particleAlpha = (int) map(value, 0, 1, 0, 255);
		else if (configName == "PARTICLE_ALPHA_MIN")			PARTICLE_ALPHA_MIN = (int) map(value, 0, 1, 0, 255);
		else if (configName == "PARTICLE_ALPHA_MAX")			PARTICLE_ALPHA_MAX = (int) map(value, 0, 1, 0, 255);

		// particle max count
		else if (configName == "particleMaxCount")				particleMaxCount = (int) map(value, 0, 1, PARTICLE_MAX_COUNT_MIN, PARTICLE_MAX_COUNT_MAX);
		else if (configName == "PARTICLE_MAX_COUNT_MIN")		PARTICLE_MAX_COUNT_MIN = (int) map(value, 0, 1, 1000, 30000);
		else if (configName == "PARTICLE_MAX_COUNT_MAX")		PARTICLE_MAX_COUNT_MAX = (int) map(value, 0, 1, 1000, 30000);

		// particle generate rate
		else if (configName == "particleGenerateRate")			particleGenerateRate = (int) map(value, 0, 1, PARTICLE_GENERATE_RATE_MIN, PARTICLE_GENERATE_RATE_MAX);
		else if (configName == "PARTICLE_GENERATE_RATE_MIN")	PARTICLE_GENERATE_RATE_MIN = (int) map(value, 0, 1, 1, 200);
		else if (configName == "PARTICLE_GENERATE_RATE_MAX")	PARTICLE_GENERATE_RATE_MAX = (int) map(value, 0, 1, 1, 200);

		// particle generate spread
		else if (configName == "particleGenerateSpread")		particleGenerateSpread = map(value, 0, 1, PARTICLE_GENERATE_SPREAD_MIN, PARTICLE_GENERATE_SPREAD_MAX);
		else if (configName == "PARTICLE_GENERATE_SPREAD_MIN")	PARTICLE_GENERATE_SPREAD_MIN = map(value, 0, 1, 1, 50);
		else if (configName == "PARTICLE_GENERATE_SPREAD_MAX")	PARTICLE_GENERATE_SPREAD_MAX = map(value, 0, 1, 1, 50);

		// particle min/max step size
		else if (configName == "particleMinStepSize")			particleMinStepSize = (int) map(value, 0, 1, PARTICLE_STEP_SIZE_MIN, PARTICLE_STEP_SIZE_MAX);
		else if (configName == "particleMaxStepSize")			particleMaxStepSize = (int) map(value, 0, 1, PARTICLE_STEP_SIZE_MIN, PARTICLE_STEP_SIZE_MAX);
		else if (configName == "PARTICLE_STEP_SIZE_MIN")		PARTICLE_STEP_SIZE_MIN = (int) map(value, 0, 1, 2, 20);
		else if (configName == "PARTICLE_STEP_SIZE_MAX")		PARTICLE_STEP_SIZE_MAX = (int) map(value, 0, 1, 2, 20);

		// particle lifetime
		else if (configName == "particleLifetime")				particleLifetime = (int) map(value, 0, 1, PARTICLE_LIFETIME_MIN, PARTICLE_LIFETIME_MAX);
		else if (configName == "PARTICLE_LIFETIME_MIN")			PARTICLE_LIFETIME_MIN = (int) map(value, 0, 1, 5, 1000);
		else if (configName == "PARTICLE_LIFETIME_MAX")			PARTICLE_LIFETIME_MAX = (int) map(value, 0, 1, 5, 1000);


	/////////////////
	// 	Particle drawing
	/////////////////
		// flow field line color as Hue + Opacity
		else if (configName == "flowLineHue")					flowLineColor = colorFromHue(value);
		else if (configName == "flowLineAlpha")					flowLineAlpha = (int) map(value, 0, 1, 0, 255);
		else if (configName == "FLOW_LINE_ALPHA_MIN")			FLOW_LINE_ALPHA_MIN = (int) map(value, 0, 1, 0, 255);
		else if (configName == "FLOW_LINE_ALPHA_MAX")			FLOW_LINE_ALPHA_MAX = (int) map(value, 0, 1, 0, 255);


	/////////////////
	// 	Depth image drawing
	/////////////////
		// depth image color as Hue (no opacity)
		else if (configName == "depthImageHue")					depthImageColor = colorFromHue(value);
		// depth image blend mode
		else if (configName == "depthImageBlendMode") {
			if (value == 0) depthImageBlendMode = DEPTH_IMAGE_BLEND_MODE_0;
			if (value == 1) depthImageBlendMode = DEPTH_IMAGE_BLEND_MODE_1;
			if (value == 2) depthImageBlendMode = DEPTH_IMAGE_BLEND_MODE_2;
			if (value == 3) depthImageBlendMode = DEPTH_IMAGE_BLEND_MODE_3;
		}

		// error case for debugging
		else {
			println("MolecularConfig.applyConfigValue('"+configName+"'): key not understood");
		}
	}


	// Return the current configuration as a JSON blob.
	// If `saveMinMax` is true, we'll output the _MIN and _MAX values.
	//		You'll want to set this to `true` for writing to a file,
	//		and `false` for outputting to TouchOSC.
//TODO:
	// If `deltasOnly` is true (default), we'll only save the differences between
	//		this config and a fresh, unmodified MolecularConfig,
	//		which will result in a smaller file.
	JSONObject toJSON(boolean saveMinMax/*, boolean deltasOnly*/) {
		JSONObject json = new JSONObject();

		json.setFloat("showParticles",  (showParticles ? 1 : 0));
		json.setFloat("showFlowLines",  (showFlowLines ? 1 : 0));
		json.setFloat("showDepthImage", (showDepthImage ? 1 : 0));
		json.setFloat("showSettings",   (showSettings ? 1 : 0));

	/////////////////
	//	Background/overlay
	/////////////////
		// window background color, 0 == black, 1 == white
		json.setFloat("windowBgColor",  (red(windowBgColor) == 0 ? 0 : 1));
		if (saveMinMax) json.setFloat("WINDOW_OVERLAY_ALPHA_MIN", map((float)WINDOW_OVERLAY_ALPHA_MIN, 0, 255, 0, 1));
		if (saveMinMax) json.setFloat("WINDOW_OVERLAY_ALPHA_MAX", map((float)WINDOW_OVERLAY_ALPHA_MAX, 0, 255, 0, 1));
		json.setFloat("windowOverlayAlpha", map((float) windowOverlayAlpha, WINDOW_OVERLAY_ALPHA_MIN, WINDOW_OVERLAY_ALPHA_MAX, 0, 1));

	/////////////////
	//	Optical Flow
	/////////////////
		// flowfield resolution
		if (saveMinMax) json.setFloat("FLOWFIELD_RESOLUTION_MIN", map((float)FLOWFIELD_RESOLUTION_MIN, 1, 50, 0, 1));
		if (saveMinMax) json.setFloat("FLOWFIELD_RESOLUTION_MAX", map((float)FLOWFIELD_RESOLUTION_MAX, 1, 50, 0, 1));
		json.setFloat("flowfieldResolution", map((float)flowfieldResolution, FLOWFIELD_RESOLUTION_MIN, FLOWFIELD_RESOLUTION_MAX, 0, 1));

		// flowfield prediction time (seconds)
		if (saveMinMax) json.setFloat("FLOWFIELD_PREDICTION_TIME_MIN", map(FLOWFIELD_PREDICTION_TIME_MIN, .1, 2, 0, 1));
		if (saveMinMax) json.setFloat("FLOWFIELD_PREDICTION_TIME_MAX", map(FLOWFIELD_PREDICTION_TIME_MAX, .1, 2, 0, 1));
		json.setFloat("flowfieldPredictionTime", map(flowfieldPredictionTime, FLOWFIELD_PREDICTION_TIME_MIN, FLOWFIELD_PREDICTION_TIME_MAX, 0, 1));

		// flowfield min velocity
		if (saveMinMax) json.setFloat("FLOWFIELD_MIN_VELOCITY_MIN", map((float)FLOWFIELD_MIN_VELOCITY_MIN, 1, 50, 0, 1));
		if (saveMinMax) json.setFloat("FLOWFIELD_MIN_VELOCITY_MAX", map((float)FLOWFIELD_MIN_VELOCITY_MAX, 1, 50, 0, 1));
		json.setFloat("flowfieldMinVelocity", map((float)flowfieldMinVelocity, FLOWFIELD_MIN_VELOCITY_MIN, FLOWFIELD_MIN_VELOCITY_MAX, 0, 1));

		// flowfield regularization term
		if (saveMinMax) json.setFloat("FLOWFIELD_REGULARIZATION_MIN", map(FLOWFIELD_REGULARIZATION_MIN, 0, pow(10,10), 0, 1));
		if (saveMinMax) json.setFloat("FLOWFIELD_REGULARIZATION_MAX", map(FLOWFIELD_REGULARIZATION_MAX, 0, pow(10,10), 0, 1));
		json.setFloat("flowfieldRegularization", map(flowfieldRegularization, FLOWFIELD_REGULARIZATION_MIN, FLOWFIELD_REGULARIZATION_MAX, 0, 1));

		// flowfield smoothing term
		if (saveMinMax) json.setFloat("FLOWFIELD_SMOOTHING_MIN", map(FLOWFIELD_SMOOTHING_MIN, 0, 1, 0, 1));
		if (saveMinMax) json.setFloat("FLOWFIELD_SMOOTHING_MAX", map(FLOWFIELD_SMOOTHING_MAX, 0, 1, 0, 1));
		json.setFloat("flowfieldSmoothing", map(flowfieldSmoothing, FLOWFIELD_SMOOTHING_MIN, FLOWFIELD_SMOOTHING_MAX, 0, 1));

	/////////////////
	//	Noise generation
	/////////////////
		// noise strength
		if (saveMinMax) json.setFloat("NOISE_STRENGTH_MIN", map(NOISE_STRENGTH_MIN, 1, 300, 0, 1));
		if (saveMinMax) json.setFloat("NOISE_STRENGTH_MAX", map(NOISE_STRENGTH_MAX, 1, 300, 0, 1));
		json.setFloat("noiseStrength", map(noiseStrength, NOISE_STRENGTH_MIN, NOISE_STRENGTH_MAX, 0, 1));

		// noise strength
		if (saveMinMax) json.setFloat("NOISE_SCALE_MIN", map(NOISE_SCALE_MIN, 1, 400, 0, 1));
		if (saveMinMax) json.setFloat("NOISE_SCALE_MAX", map(NOISE_SCALE_MAX, 1, 400, 0, 1));
		json.setFloat("noiseScale", map(noiseScale, NOISE_SCALE_MIN, NOISE_SCALE_MAX, 0, 1));

	/////////////////
	// 	Particle interaction with flow field
	/////////////////
		// particle viscocity
		if (saveMinMax) json.setFloat("PARTICLE_VISCOSITY_MIN", map(PARTICLE_VISCOSITY_MIN, 0, 1, 0, 1));
		if (saveMinMax) json.setFloat("PARTICLE_VISCOSITY_MAX", map(PARTICLE_VISCOSITY_MAX, 0, 1, 0, 1));
		json.setFloat("particleViscocity", map(particleViscocity, PARTICLE_VISCOSITY_MIN, PARTICLE_VISCOSITY_MAX, 0, 1));

		// particle force multiplier
		if (saveMinMax) json.setFloat("PARTICLE_FORCE_MULTIPLIER_MIN", map(PARTICLE_FORCE_MULTIPLIER_MIN, 1, 300, 0, 1));
		if (saveMinMax) json.setFloat("PARTICLE_FORCE_MULTIPLIER_MAX", map(PARTICLE_FORCE_MULTIPLIER_MAX, 1, 300, 0, 1));
		json.setFloat("particleForceMultiplier", map(particleForceMultiplier, PARTICLE_FORCE_MULTIPLIER_MIN, PARTICLE_FORCE_MULTIPLIER_MAX, 0, 1));

		// particle acceleration friction
		if (saveMinMax) json.setFloat("PARTICLE_ACCELERATION_FRICTION_MIN", map(PARTICLE_ACCELERATION_FRICTION_MIN, .001, .999, 0, 1));
		if (saveMinMax) json.setFloat("PARTICLE_ACCELERATION_FRICTION_MAX", map(PARTICLE_ACCELERATION_FRICTION_MAX, .001, .999, 0, 1));
		json.setFloat("particleAccelerationFriction", map(particleAccelerationFriction, PARTICLE_ACCELERATION_FRICTION_MIN, PARTICLE_ACCELERATION_FRICTION_MAX, 0, 1));

		// particle acceleration limiter
		if (saveMinMax) json.setFloat("PARTICLE_ACCELERATION_LIMITER_MIN", map(PARTICLE_ACCELERATION_LIMITER_MIN, .001, .999, 0, 1));
		if (saveMinMax) json.setFloat("PARTICLE_ACCELERATION_LIMITER_MAX", map(PARTICLE_ACCELERATION_LIMITER_MAX, .001, .999, 0, 1));
		json.setFloat("particleAccelerationLimiter", map(particleAccelerationLimiter, PARTICLE_ACCELERATION_LIMITER_MIN, PARTICLE_ACCELERATION_LIMITER_MAX, 0, 1));

		// particle noise velocity
		if (saveMinMax) json.setFloat("PARTICLE_NOISE_VELOCITY_MIN", map(PARTICLE_NOISE_VELOCITY_MIN, .005, .3, 0, 1));
		if (saveMinMax) json.setFloat("PARTICLE_NOISE_VELOCITY_MAX", map(PARTICLE_NOISE_VELOCITY_MAX, .005, .3, 0, 1));
		json.setFloat("particleNoiseVelocity", map(particleNoiseVelocity, PARTICLE_NOISE_VELOCITY_MIN, PARTICLE_NOISE_VELOCITY_MAX, 0, 1));

	/////////////////
	// 	Particle drawing
	/////////////////
		// particle color scheme
		json.setFloat("particleColorScheme", (float)particleColorScheme);

		// particle color as Hue + Opacity
		json.setFloat("particleColor",  hueFromColor(particleColor));
		if (saveMinMax) json.setFloat("PARTICLE_ALPHA_MIN", map((float)PARTICLE_ALPHA_MIN, 0, 255, 0, 1));
		if (saveMinMax) json.setFloat("PARTICLE_ALPHA_MAX", map((float)PARTICLE_ALPHA_MAX, 0, 255, 0, 1));
		json.setFloat("particleAlpha", map((float) particleAlpha, 0, 255, 0, 1));

		// particle max count
		if (saveMinMax) json.setFloat("PARTICLE_MAX_COUNT_MIN", map((float)PARTICLE_MAX_COUNT_MIN, 1000, 30000, 0, 1));
		if (saveMinMax) json.setFloat("PARTICLE_MAX_COUNT_MAX", map((float)PARTICLE_MAX_COUNT_MAX, 1000, 30000, 0, 1));
		json.setFloat("particleMaxCount", map((float)particleMaxCount, PARTICLE_MAX_COUNT_MIN, PARTICLE_MAX_COUNT_MAX, 0, 1));

		// particle generate rate
		if (saveMinMax) json.setFloat("PARTICLE_GENERATE_RATE_MIN", map((float)PARTICLE_GENERATE_RATE_MIN, 1, 200, 0, 1));
		if (saveMinMax) json.setFloat("PARTICLE_GENERATE_RATE_MAX", map((float)PARTICLE_GENERATE_RATE_MAX, 1, 200, 0, 1));
		json.setFloat("particleGenerateRate", map((float)particleGenerateRate, PARTICLE_GENERATE_RATE_MIN, PARTICLE_GENERATE_RATE_MAX, 0, 1));

		// particle generate spread
		if (saveMinMax) json.setFloat("PARTICLE_GENERATE_SPREAD_MIN", map(PARTICLE_GENERATE_SPREAD_MIN, 1, 50, 0, 1));
		if (saveMinMax) json.setFloat("PARTICLE_GENERATE_SPREAD_MAX", map(PARTICLE_GENERATE_SPREAD_MAX, 1, 50, 0, 1));
		json.setFloat("particleGenerateSpread", map(particleGenerateSpread, PARTICLE_GENERATE_SPREAD_MIN, PARTICLE_GENERATE_SPREAD_MAX, 0, 1));

		// particle min/max step size
		if (saveMinMax) json.setFloat("PARTICLE_STEP_SIZE_MIN", map((float)PARTICLE_STEP_SIZE_MIN, 2, 20, 0, 1));
		if (saveMinMax) json.setFloat("PARTICLE_STEP_SIZE_MAX", map((float)PARTICLE_STEP_SIZE_MAX, 2, 20, 0, 1));
		json.setFloat("particleMinStepSize", map((float)particleMinStepSize, PARTICLE_STEP_SIZE_MIN, PARTICLE_STEP_SIZE_MAX, 0, 1));
		json.setFloat("particleMaxStepSize", map((float)particleMaxStepSize, PARTICLE_STEP_SIZE_MIN, PARTICLE_STEP_SIZE_MAX, 0, 1));

		// particle lifetime
		if (saveMinMax) json.setFloat("PARTICLE_LIFETIME_MIN", map((float)PARTICLE_LIFETIME_MIN, 5, 1000, 0, 1));
		if (saveMinMax) json.setFloat("PARTICLE_LIFETIME_MAX", map((float)PARTICLE_LIFETIME_MAX, 5, 1000, 0, 1));
		json.setFloat("particleLifetime", map((float)particleLifetime, PARTICLE_LIFETIME_MIN, PARTICLE_LIFETIME_MAX, 0, 1));


	/////////////////
	// 	Particle drawing
	/////////////////
		// flow field line color as Hue + Opacity
		json.setFloat("flowLineColor",  hueFromColor(flowLineColor));
		if (saveMinMax) json.setFloat("FLOW_LINE_ALPHA_MIN", map((float)FLOW_LINE_ALPHA_MIN, 0, 255, 0, 1));
		if (saveMinMax) json.setFloat("FLOW_LINE_ALPHA_MAX", map((float)FLOW_LINE_ALPHA_MAX, 0, 255, 0, 1));
		json.setFloat("flowLineAlpha", map((float) flowLineAlpha, 0, 255, 0, 1));

	/////////////////
	// 	Depth image drawing
	/////////////////
		// depth image color as Hue (no opacity)
		json.setFloat("depthImageColor",  hueFromColor(depthImageColor));
		// depth image blend mode
		if 		(depthImageBlendMode == DEPTH_IMAGE_BLEND_MODE_0) 	json.setFloat("depthImageBlendMode", 0);
		else if (depthImageBlendMode == DEPTH_IMAGE_BLEND_MODE_1) 	json.setFloat("depthImageBlendMode", 1);
		else if (depthImageBlendMode == DEPTH_IMAGE_BLEND_MODE_2) 	json.setFloat("depthImageBlendMode", 2);
		else if (depthImageBlendMode == DEPTH_IMAGE_BLEND_MODE_3) 	json.setFloat("depthImageBlendMode", 3);

		return json;
	}






















}
