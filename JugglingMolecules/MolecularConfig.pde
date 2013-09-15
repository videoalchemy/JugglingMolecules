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

class MolecularConfig {

////////////////////////////////////////////////////////////
//  Global config.  Note that we cannot override these at runtime.
////////////////////////////////////////////////////////////
	// Desired frame rate
	// NOTE: requires restart to change.
	int setupFPS = 30;

	// Random noise seed.
	// TODO: requires restart to change ???
// TODO: way to vary this ???
	int setupNoiseSeed = 26103;


////////////////////////////////////////////////////////////
//	Master controls for what we're showing on the screen
//	Note: they currently show in this order.
////////////////////////////////////////////////////////////
	// set to true to show particles
	boolean showParticles=true;

	// set to true to show force lines
	boolean showFlowLines=false;

	// set to true to show the depth image
	boolean showDepthImage = true;

	// set to true to show setup screen OVER the rest of the screen
	boolean showSettings=false;


////////////////////////////////////////////////////////////
//	OpticalFlow field parameters
////////////////////////////////////////////////////////////
	// background color (black)
	color windowBgColor = color(0);

	// Amount to "dim" the background each round by applying partially opaque background
	// Higher number means less of each screen sticks around on subsequent draw cycles.
	int windowOverlayOpacity = 20;	//	0-255





////////////////////////////////////////////////////////////
//	OpticalFlow field parameters
////////////////////////////////////////////////////////////
	// resolution of the flow field.
	// Smaller means more coarse flowfield = faster but less precise
	// Larger means finer flowfield = slower but better tracking of edges
	// NOTE: requires restart to change this.
	int flowfieldResolution = 15;	// 1..50 ?

	// Amount of time in seconds between "averages" to compute the flow
	float flowfieldPredictionTime = 0.5;

	// velocity must exceed this to add/draw particles in the flow field
	float flowfieldMinVelocity = 20; //	2-10 ???

	// Regularization term for regression.
	// Larger values for noisy video (?).  Default pow(10,8)
	float flowfieldRegularization = pow(10,8);

	// Smoothing of flow field
	// smaller value for longer smoothing
	float flowfieldSmoothing = 0.05;


////////////////////////////////////////////////////////////
//	Perlin noise generation.
////////////////////////////////////////////////////////////
	// cloud variation, low values have long stretching clouds that move long distances,
	//high values have detailed clouds that don't move outside smaller radius.
	float noiseStrength = 100; //1-300;

	// cloud strength multiplier,
	//eg. multiplying low strength values makes clouds more detailed but move the same long distances.
	float noiseScale = 100; //1-400


////////////////////////////////////////////////////////////
//	Interaction between particles and flow field.
////////////////////////////////////////////////////////////
	//how much particle slows down in fluid environment
	float particleViscocity = .995;	//0-1	???

	// force to apply to input - mouse, touch etc.
	float particleForceMultiplier = 50;	 //1-300

	// how fast to return to the noise after force velocities
	float particleAccelerationFriction = .075;	//.001-.999

	// how fast to return to the noise after force velocities
	float particleAccelerationLimiter = .35;	// - .999

	// turbulance, or how often to change the 'clouds' - third parameter of perlin noise: time.
	float particleNoiseVelocity = .008; // .005 - .3




////////////////////////////////////////////////////////////
//	Particle drawing
////////////////////////////////////////////////////////////

	// Scheme for how we name particles.
	// 	- 0 = all particles same color, coming from `particle[Red|Green|Blue]` below
	// 	- 1 = particle color set from origin
	int PARTICLE_COLOR_SCHEME_SAME_COLOR 	= 0;
	int PARTICLE_COLOR_SCHEME_XY 			= 1;

	int particleColorScheme = PARTICLE_COLOR_SCHEME_XY;

	// Color for particles iff `PARTICLE_COLOR_SCHEME_SAME_COLOR` color scheme in use.
	float particleRed		= 255;	//0-255
	float particleGreen		= 255;	//0-255
	float particleBlue		= 255;	//0-255

	// Opacity for all particle lines, used for all color schemes.
	float particleAlpha		= 50;	//0-255


	// Maximum number of particles that can be active at once.
	// More particles = more detail because less "recycling"
	// Fewer particles = faster.
// TODO: must restart to change this
	int particleMaxCount = 30000;

	// how many particles to emit when mouse/tuio blob move
	int particleGenerateRate = 10; //2-200

	// random offset for particles emitted, so they don't all appear in the same place
	float particleGenerateSpread = 20; //1-50

	// Upper and lower bound of particle movement each frame.
	int particleMinStepSize = 4;
	int particleMaxStepSize = 8;

	// Particle lifetime.
	int particleLifetime = 400;


////////////////////////////////////////////////////////////
//	Drawing flow field lines
////////////////////////////////////////////////////////////

	// color for optical flow lines
	color flowLineColor = color(255, 0, 0, 30);



////////////////////////////////////////////////////////////
//	Depth image drawing
////////////////////////////////////////////////////////////
	// `tint` color for the depth image
	color depthImageColor = color(128, 12);			// NOT USED

	// blend mode for the depth image
	int depthImageBlendMode = DIFFERENCE;			// tracks black to body




}
