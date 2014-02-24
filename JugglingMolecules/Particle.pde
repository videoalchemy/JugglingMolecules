/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2014 Jason Stephens, Owen Williams & VideoAlchemy Collective
 *
 *	See `credits.txt` for base work and shouts out.
 *	Published under CC Attrbution-ShareAlike 3.0 (CC BY-SA 3.0)
 *		            http://creativecommons.org/licenses/by-sa/3.0/
 *******************************************************************/

int gLastParticleHue = 0;

////////////////////////////////////////////////////////////
//	Particle class
////////////////////////////////////////////////////////////
class Particle {
	// ParticleManager we interact with, set in our constructor.
	ParticleManager manager;

	// set on `reset()`
	PVector location;
	PVector prevLocation;
	PVector acceleration;
	float zNoise;
	int life;					// lifetime of this particle
	color pColor;

	// randomized on `reset()`
	float stepSize;

	// working calculations
	PVector velocity;
	float angle;


	// for flowfield
	PVector steer;
	PVector desired;
	PVector flowFieldLocation;



	// Particle constructor.
	// NOTE: you can count on the particle being `reset()` before it will be drawn.
	public Particle(ParticleManager _manager) {
		// remember our configuration object & particle manager
		manager = _manager;

		// initialize data structures
		location 			= new PVector(0, 0);
		prevLocation 		= new PVector(0, 0);
		acceleration 		= new PVector(0, 0);
		velocity 			= new PVector(0, 0);
		flowFieldLocation 	= new PVector(0, 0);
	}


	// resets particle with new origin and velocity
	public void reset(float _x,float _y,float _zNoise, float _dx, float _dy) {
		location.x = prevLocation.x = _x;
		location.y = prevLocation.y = _y;
		zNoise = _zNoise;
		acceleration.x = _dx;
		acceleration.y = _dy;

		// reset lifetime
		life = gConfig.particleLifetime;

		// randomize step size each time we're reset
		stepSize = random(gConfig.particleMinStepSize, gConfig.particleMaxStepSize);

		// get alpha from current color
		int _alpha = (int)alpha(gConfig.particleColor);

		// "spring" color scheme according to x/y coordinate
		if (gConfig.particleColorScheme == PARTICLE_COLOR_SCHEME_XY) {
			int r = (int) map(_x, 0, width, 0, 255);
			int g = (int) map(_y, 0, width, 0, 255);	// NOTE: this is nice w/ Y plotted to width
			int b = (int) map(_x + _y, 0, width+height, 0, 255);
			pColor = color(r, g, b, _alpha);
		}
		// rainbow color scheme
		else if (gConfig.particleColorScheme == PARTICLE_COLOR_SCHEME_RAINBOW) {
			if (++gLastParticleHue > 360) gLastParticleHue = 0;
			pColor = color(colorFromHue(gLastParticleHue), _alpha);
		}
		// derive color from image
		else if (gConfig.particleColorScheme == PARTICLE_COLOR_SCHEME_IMAGE) {
			pColor = getParticleImageColor(_x, _y);
		}
		// monochrome
		else {	//if (gConfig.particleColorScheme == gConfig.PARTICLE_COLOR_SCHEME_SAME_COLOR) {
			pColor = gConfig.particleColor;
		}
	}

	color getParticleImageColor(float _x, float _y) {
		PImage particleImage = gConfig.getParticleImage();
		// figure out index for this pixel
		int col = (int) map(constrain(_x, 0, width-1), 0, width, 0, particleImage.width);
		int row = (int) map(constrain(_y, 0, height-1), 0, height, 0, particleImage.height);
		int index = (row * particleImage.width) + col;
		// extract the color from the image, which is opaque
		color clr = particleImage.pixels[index];
		// add the current alpha
		return color(clr, (int)alpha(gConfig.particleColor));
	}

	// Is this particle still alive?
	public boolean isAlive() {
		return (life > 0);
	}

	// Update this particle's position.
	public void update() {
		prevLocation = location.get();

		if (acceleration.mag() < gConfig.particleAccelerationLimiter) {
			life--;
			angle = noise(location.x / (float)gConfig.noiseScale, location.y / (float)gConfig.noiseScale, zNoise);
			angle *= (float)gConfig.noiseStrength;

//EXTRA CODE HERE

			velocity.x = cos(angle);
			velocity.y = sin(angle);
			velocity.mult(stepSize);

		}
		else {
			// normalise an invert particle position for lookup in flowfield
			flowFieldLocation.x = norm(width-location.x, 0, width);		// width-location.x flips the x-axis.
			flowFieldLocation.x *= gKinectWidth; // - (test.x * wscreen);
			flowFieldLocation.y = norm(location.y, 0, height);
			flowFieldLocation.y *= gKinectHeight;

			desired = manager.flowfield.lookup(flowFieldLocation);
			desired.x *= -1;	// TODO??? WHAT'S THIS?

			steer = PVector.sub(desired, velocity);
			steer.limit(stepSize);	// Limit to maximum steering force
			acceleration.add(steer);
		}

		acceleration.mult(gConfig.particleAccelerationFriction);

// TODO:  HERE IS THE PLACE TO CHANGE ACCELERATION, BEFORE IT IS APPLIED.   ???


// END ACCELERATION

		velocity.add(acceleration);
		location.add(velocity);

		// apply exponential (*=) friction or normal (+=) ? zNoise *= 1.02;//.95;//+= zNoiseVelocity;
		zNoise += gConfig.particleNoiseVelocity;

		// slow down the Z noise??? Dissipative Force, viscosity
		//Friction Force = -c * (velocity unit vector) //stepSize = constrain(stepSize - .05, 0,10);
		//Viscous Force = -c * (velocity vector)
		stepSize *= gConfig.particleViscocity;
	}

	// 2-d render using processing OPENGL rendering context
	void render() {
		// apply image color at draw time?
		if (gConfig.particleColorScheme == PARTICLE_COLOR_SCHEME_IMAGE && gConfig.applyParticleImageColorAtDrawTime) {
			pColor = getParticleImageColor(location.x, location.y);
		}

//println(colorToString(pColor));
		stroke(pColor);
		line(prevLocation.x, prevLocation.y, location.x, location.y);
	}
}
