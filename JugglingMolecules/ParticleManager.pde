/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2014 Jason Stephens, Owen Williams & VideoAlchemy Collective
 *
 *	See `credits.txt` for base work and shouts out.
 *	Published under CC Attrbution-ShareAlike 3.0 (CC BY-SA 3.0)
 *		            http://creativecommons.org/licenses/by-sa/3.0/
 *******************************************************************/

class ParticleManager {
	// flowfield which influences our drawing.
	OpticalFlow flowfield;		// set AFTER init

	// Particles we manage.  Currently created DURING init.
	Particle particles[];

	// Index of next particle to revive when its time to "create" a new particle.
	int particleId = 0;


	public ParticleManager() {
		// pre-create all particles for efficiency when drawing.
		// NOTE: We pre-create the total maximum possible, even though we may be showing less right now.
		//		 This allows us to dynamically change the particleMaxCount range fully.
		int particleCount = gConfig.MAX_particleMaxCount;
		particles = new Particle[particleCount];
		for (int i=0; i < particleCount; i++) {
			// initialise maximum particles
			particles[i] = new Particle(this);
		}
	}

	public void updateAndRender() {
		// NOTE: doing pushStyle()/popStyle() on the outside of the loop makes this much much faster
		pushStyle();
		// loop through all particles
		int particleCount = gConfig.particleMaxCount;
		for (int i = 0; i < particleCount; i++) {
			Particle particle = particles[i];
			if (particle.isAlive()) {
				particle.update();
				particle.render();
			}
		}// end loop through all particles
		popStyle();
	}

	// Add a bunch of particles to represent a new vector in the flow field
	public void addParticlesForForce(float x, float y, float dx, float dy) {
		regenerateParticles(x * width, y * height, dx * gConfig.particleForceMultiplier, dy * gConfig.particleForceMultiplier);
	}

	// Update a set of particles based on a force vector.
	// NOTE: We re-use particles created at construction time.
	//		 `particleId` is a global index of the next particles to take over when it's time to "make" some new particles.
	// NOTE: With a small `gConfig.particleMaxCount`, we'll re-use particles before they've fully decayed.
	public void regenerateParticles(float startX, float startY, float forceX, float forceY) {
		for (int i = 0; i < gConfig.particleGenerateRate; i++) {
			float originX = startX + random(-gConfig.particleGenerateSpread, gConfig.particleGenerateSpread);
			float originY = startY + random(-gConfig.particleGenerateSpread, gConfig.particleGenerateSpread);
			float noiseZ = particleId/float(gConfig.particleMaxCount);

			particles[particleId].reset(originX, originY, noiseZ, forceX, forceY);

			// increment counter -- go back to 0 if we're past the end
			particleId++;
			if (particleId >= gConfig.particleMaxCount) particleId = 0;
		}
	}

}

