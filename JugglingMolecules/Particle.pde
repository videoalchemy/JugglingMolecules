/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2013 Jason Stephens & VideoAlchemy Collective
 *
 *	See `credits.txt` for base work and shouts out.
 *	Published under CC Attrbution-ShareAlike 3.0 (CC BY-SA 3.0)
 *		            http://creativecommons.org/licenses/by-sa/3.0/
 *******************************************************************/

float gLastParticleHue = 0;

////////////////////////////////////////////////////////////
//	Particle class
////////////////////////////////////////////////////////////
class Particle {
	// ParticleManager we interact with, set in our constructor.
	ParticleManager manager;

	// Our configuration object, set in our constructor.
	MolecularConfig config;

	// set on `reset()`
	PVector location;
	PVector prevLocation;
	PVector acceleration;
	float zNoise;
	int life;					// lifetime of this particle
	color clr;

	// randomized on `reset()`
	float stepSize;

	// working calculations
	PVector velocity;
	float angle;


	// for flowfield
	PVector steer;
	PVector desired;
	PVector flowFieldLocation;


// J :: adding experimental variables
        int particleWidth;    // strokeWeight;
        
        PVector depthImageTheta; // to save the angle change vector:
        float theta;  // hold  the angle for use with depth Image
        int depthImageResolution; //  How large is each 'cell' of the depthImage
        int cols, rows; // columns and rows for the depthImage



	// Particle constructor.
	// NOTE: you can count on the particle being `reset()` before it will be drawn.
	public Particle(ParticleManager _manager, MolecularConfig _config) {
		// remember our configuration object & particle manager
		manager = _manager;
		config  = _config;

		// initialize data structures
		location 			= new PVector(0, 0);
		prevLocation 		= new PVector(0, 0);
		acceleration 		= new PVector(0, 0);
		velocity 			= new PVector(0, 0);
		flowFieldLocation 	= new PVector(0, 0);

// J :: experiments*************************
                particleWidth = 2;
                depthImageResolution = 25;
                //cols = 
                
//*****************************************
	}


	// resets particle with new origin and velocitys
	public void reset(float _x,float _y,float _zNoise, float _dx, float _dy) {
		location.x = prevLocation.x = _x;
		location.y = prevLocation.y = _y;
		zNoise = _zNoise;
		acceleration.x = _dx;
		acceleration.y = _dy;

		// reset lifetime
		life = config.particleLifetime;

		// randomize step size each time we're reset
		stepSize = random(config.particleMinStepSize, config.particleMaxStepSize);

// J ::  add REFERENCE IMAGE COLOR HERE -->>*******************************
		// set up now if we're basing particle color on its initial x/y coordinate
		if (config.particleColorScheme == PARTICLE_COLOR_SCHEME_XY) {
			int r = (int) map(_x, 0, width, 0, 255);
			int g = (int) map(_y, 0, width, 0, 255);	// NOTE: this is nice w/ Y plotted to width
			int b = (int) map(_x + _y, 0, width+height, 0, 255);
			clr = color(r, g, b, config.particleAlpha);
		} else if (config.particleColorScheme == PARTICLE_COLOR_SCHEME_YX) {
			int r = (int) map(_x + _y, 0, width+height, 0, 255);
			int g = (int) map(_x, 0, width, 0, 255);
			int b = (int) map(_y, 0, height, 0, 255);
			clr = color(r, g, b, config.particleAlpha);
		} else if (config.particleColorScheme == PARTICLE_COLOR_SCHEME_XYX) {
			if (++gLastParticleHue > 360) gLastParticleHue = 0;
			float nextHue = map(gLastParticleHue, 0, 360, 0, 1);
			clr = color(colorFromHue(nextHue), config.particleAlpha);
		} else {	//if (config.particleColorScheme == gConfig.PARTICLE_COLOR_SCHEME_SAME_COLOR) {
			clr = color(config.particleColor, config.particleAlpha);
		}
	}

	// Is this particle still alive?
	public boolean isAlive() {
		return (life > 0);
	}

// J :: add depthIMAGEFLOW code HERE (or at the Flow Field creation point??) ---->>*************** 

	// Update this particle's position.
	public void update() {
		prevLocation = location.get();
    /*          
		if (acceleration.mag() < config.particleAccelerationLimiter) {
			life--;

// J :: experiment with adding to user's depth info to the particles angle/////////////////
                        // look up the pixel info from the depth Image at pixel's location.  problem is that PImage gDepthImg is different size than particle screen
                        // may have to put dDepthImg pixels into different size
                        //color gDepthImgColor = gDepthImg.get(location.x, location.y); // get the pixel color at this locatoin
                        
                        // try extracting pixel info from the main draw screen
                       // color mainScreenPixel = get(int(location.x), int(location.y));
                     //   angle =  map(brightness(mainScreenPixel), 0, 255, 0, 10*TWO_PI);
                       
                       
                       
                        //original//////////////////////
                        //angle = noise(location.x / (float)config.noiseScale, location.y / (float)config.noiseScale, zNoise);
			//angle *= (float)config.noiseStrength;
                        //original//////////////////////
// J :: ///////////////////////////////////////////////////////////////////////////


//EXTRA CODE HERE

// J :: swap velocity's x and y experiment.  
                        velocity.x = cos(angle); // original = velocity.x
			velocity.y = sin(angle); // original = velocity.y
			velocity.mult(stepSize);


		}
		else {
*/

                        // this lookup code is now calculated everytime and is used for either the flowfield or for the depthImage
			// normalise an invert particle position for lookup in flowfield
			// flowFieldLocation.x = norm(width-location.x, 0, width);		// width-location.x flips the x-axis.
			// flowFieldLocation.x *= gKinectWidth; // - (test.x * wscreen);
			// flowFieldLocation.y = norm(location.y, 0, height);
			// flowFieldLocation.y *= gKinectHeight;

//create a new lookup using depthImage
                if (acceleration.mag() < config.particleAccelerationLimiter) {
                      life--;
                      
                      flowFieldLocation.x = norm(location.x, 0, gDepthImg.width);    // width-location.x flips the x-axis, which we don't want here
                      flowFieldLocation.x *= gKinectWidth; // - (test.x * wscreen);
                      flowFieldLocation.y = norm(location.y, 0, gDepthImg.height);
                      flowFieldLocation.y *= gKinectHeight;
                      
                      //  !!!!!!!!!!!!!!!!!!!!!!  THIS ISN"T FUCKING WORKING
                      // giving up
                      
                      
                      
                      //use pixel array to look up color at specific pixel instead of the slow get() to find pixel color
                      int gDepthImgIndex = int(flowFieldLocation.x + flowFieldLocation.y * gDepthImg.width);
                      int gDepthImgColor = gDepthImg.pixels[gDepthImgIndex-1];
                      
                      // dont use the folloing get method....too slow
                      //color gDepthImgColor = gDepthImg.get(location.x, location.y); // get the pixel color at this locatoin
                     
                     // now use the brightness from the pixel and map to theta
                      angle = map(brightness(gDepthImgColor), 0, 255, 0, TWO_PI);
                      angle += noise(location.x / (float)config.noiseScale, location.y / (float)config.noiseScale, zNoise);
                      angle *= (float)config.noiseStrength;
                      
                      velocity.x = cos(angle); // original = velocity.x
                      velocity.y = sin(angle); // original = velocity.y
                      velocity.mult(stepSize);
////////////////////////////////////////////////////////
                      
                }
                else {
                      flowFieldLocation.x = norm(width-location.x, 0, width);    // width-location.x flips the x-axis.
                      flowFieldLocation.x *= gKinectWidth; // - (test.x * wscreen);
                      flowFieldLocation.y = norm(location.y, 0, height);
                      flowFieldLocation.y *= gKinectHeight;
                  
			desired = manager.flowfield.lookup(flowFieldLocation);
			desired.x *= -1;	// TODO??? WHAT'S THIS?

			steer = PVector.sub(desired, velocity);
			steer.limit(stepSize);	// Limit to maximum steering force
			acceleration.add(steer);
		}

		acceleration.mult(config.particleAccelerationFriction);

// TODO:  HERE IS THE PLACE TO CHANGE ACCELERATION, BEFORE IT IS APPLIED.   ???

// J :: adding steering force of depthImageTheta

// END ACCELERATION

		velocity.add(acceleration);
		location.add(velocity);

		// apply exponential (*=) friction or normal (+=) ? zNoise *= 1.02;//.95;//+= zNoiseVelocity;
		zNoise += config.particleNoiseVelocity;

		// slow down the Z noise??? Dissipative Force, viscosity
		//Friction Force = -c * (velocity unit vector) //stepSize = constrain(stepSize - .05, 0,10);
		//Viscous Force = -c * (velocity vector)
		stepSize *= config.particleViscocity;
	}

	// 2-d render using processing OPENGL rendering context
	void render() {

// J :: experiments ***************
                strokeWeight(particleWidth);	
//*********************************  
        	stroke(clr);
		line(prevLocation.x, prevLocation.y, location.x, location.y);
	}
}
