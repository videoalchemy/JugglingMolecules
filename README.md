###OmiCron-SpiroLight
- an interactive video installation designed for The Rhythm Society's EarthTones Retreat 2013.09.22
- the interface is a combination of gesture controls from dancers and knob turning from participants.  The podium sized OmiCron Interface will sit somewhere on the edge of the dance floor enticing users with its large knobs and glowing buttons.  Omicrons controls are mapped to the parameters of a spirograph-like pattern projected on a rear projection screen.  Dancers control the location of the pattern by way of the closest point in a 3D point cloud (ie the pattern will follow their hand if their hand contains the point closest to the Kinect sensor.  Dancers can also interact with a particle system whose behavior is controlled by a depth informed flow field.  Dancer's distance and velocity determine the behavior of the particles.

###Requirements:
- [OmiCron The Interface](http://www.flickr.com/photos/jaycody9/sets/72157632699562712/)
- Kinect Depth Sensor
- Processing 2.0.3
- SimpleOpenNI 1.96

###Interactions:**
0. Dancer with OmiCron Controller
1. Dancer with SpiroLight
2. Dancer with Particles
3. Particles with SpiroLight
	- Autonomous Vehicles AVOID OR PURSUE SpiroLight (Omicron Control)
	- When emerging from and avoiding spiroLight, particles steer toward Dancer
	- When emerging from and avoiding dancer, particles steer toward Spirolight.  When within range of outter most arm, particles accelerate like additive flashes of light and disappear inside spirolight.  Born again from Dancer's movement (optical flow)
4. OmiCron with SpiroLight
5. OmiCron with Particles


###Next Steps:
- [] Setup OmiCron:
	- [] Run Calibration with Processing.  Systems Check
	- [] Tighten Bolts
	- [] Study RotaDeva code for how inputs were passed around.
	- [] Write the code that treats OmiCron as if it were a variety of forces.  
	- ```omiCron.KnobLeftRed(); // returns a PVector reading for Magnitude, direction, velocity, etc```
	- ```omiCron.lookup(KnobFoo); // returns an array of PVectors?????```
	- [] study the code and see how Owen did it.
	- [] then save this as it's own Tool for use anytime.
	- [] make a version for SpiroLight
- [] rewrite the centerPiece_SpiroLight to include OmiCron
	- [] scale model using foam core or construction paper??
	- [] get all the inputs with stationary SpiroLight first Tiers 1-3

###OmiCron: Map Controls to SpiroLight:**
- [] Button shuffles ratios for specified tier
	- where on the circle is arm connected? (make that a perlin noise function where button down progresses through perlin noise for all variables.
- [] First tier Red knobs control overall size of spiroLight, mass, and steering ability toward target.  Mass gets bigger, slower it moves, the larger the circle, the larger the entire spiroLight  (as opposed to following closest point, which changes the size of spiroLight because of perspective being further away, but does not change the mass or the periods)
- [] Knobs control Magnitude of all the vectors, while buttons control location within each variables range
- [] Snap Button = Reverse Emitter Location from Tier 3 to Dancer.
	- when Emitter Origin is in SpiroLight, particles flock to Dancer
	- Particles follow path along edges up dancer and out of spirolight
- [] Tier 1 = Red, Tier 2 = Green, Tier 3 = Blue
- [] Each of the 3 omiCron buttons will change ratios (angular velocities, magnitude) for that color
	- eg Green Line From Tier 1 to Tier 2, and Green Line from Tier 2 to Tier 3 are:  
		- 1:1 in length, 1:1 in angular velocity, and are IN PHASE 
		- 1:2 in length, 1:-2 in angular velocity, and are out of phase by 90degrees
		- 1:sqrt2 in length, 1:1.618 in angular velocity, and are out of phase by 180
- [] Knobs: Red(Left and Right) Green(L,R), Blue(L,R) control the rotational velocity and distance to next teir.
- [] Ohmite Knob controls the parameters of the flow field (somehow) and/or z-axis rotation
- [] Add remainder of tier 2 and 3
- **OmiCron Structure:**
	- [] Add extra lights to the bottom of OmiCron (since the device WILL be in an open field)
		- [] use a second Arduino??  Yes.
	- [] Add Handles
	- [] Bring extra batteries
	- [] bring usb mouse and keyboard just in case
	- [] bring Blue Tooth


###SpiroLight:
- **SpiroLight Forces:**
	- AstralLines (rotating arms):
		- arm length mapped to Velocity's Magnitude such that arms stretch when accelerating and shrink when decelerating (or vice versa).
		- Perlin Noise the mapping of acceleration to arm length such that perlin noise wanders along a continuum of MaxSpeed = MaxLength AND MaxSpeed = Min Length 
		- Arm Rotation to Perlin Noise
		- Add the SCALE function to simulate 3D
		- Arm pivot point on circle wanders
	- Tier 1 Location Vectors have 4 control modes: (4 types of Forces that act upon primary location vector)
		1. TEST MODE:  Follow Mouse (ie sub(location, mouse))
		2. DANCER MODE:  
			- Follow/ PursueClosest Point in Point Cloud (controlled by dancer)
			- Evade closest point Dancer
		3. NULL USER MODE:  Perlin Noise (which can be used to inform all the arms and rotations)
		4. OMICRON ONLY MODE: (or FP-13 Mode) or Touch OSC:  No Kinect Attached, no dancer.  Forces mapped to RedKnob Left and Right for (x,y)
	- **SpiroLight with FlowField.**  
		- Instead of constant angular velocity, SpiroLight joints can respond to the Flow Field with their own steering force.  The joints are vehicles that check in a ask, 'does the flow field bellow have information for me?  If not, then keep steady pace, otherwise, use flow field as desired velocity'.  Everytime spirolight sweeps over the dancer, the movements will adjust.  Or the colors will change to show the outline of the body.  If assign color variation to optical flow and sillouette, then the resulting blendMode(ADD) would be sufficient to change all the underlying pixels, effectively showing the dancers body.
	- **Specific Arms Always remain in contact with the DANCER and EDGE DETECT PATH FOLLOW.**  
		- **arrives and path follows along the edge of dancer's body with one of it's arms (or 2)!!**  The SpiroLight follows the dancer and when it arrives, it's arms lock on to the edges and path follow.  Could cover and encircle the dancer like an octopus.  OR it grows NEW arms that remain in constant contact with user as the rest of the SpiroLight floats around.  Instead of harmonic monition, the arm follows the outline of the user.  see PATHFOLLOWING using the DOT PRODUCT
		- Some parts of the SpiroLight seek the dancer and some parts evade the dancer, so the thing is constantly investigating AND keeping it's distance.  If the Tier 1 Location Vector brings spiro closer to dancer, then arms that are repelled with flock together and move away while arms that are attracted will get closer.
			- AND the closer the arm, the greater the connetion, the brighter.
			- Whichever arm is path following along body will have perlin noise generated organic branching.
		- AND Particle System coming from dancer ALWAYS remains in contact with spiroLight
		- where spiroLight is attracted to some point in the flow field that also guides the particles coming from Dancer
	- **Dancer's Movement Also Affects Size and Brightness of SpiroLight**
		- Use the Frame Differencing already used to inform the particle system
		- The same threshold velocity which triggers particles also brightens and expands the SpiroLight

- **SpiroLight Parameters and Controls:**
	- Inner sphere of 3D Hypotrochoid:
		- diameter -> User-N's distance from Kinect 
		- velocity -> informed by velocity, location, and gravitational pull (determined by mass (from diameter) of User-N's center of gravity
			- use Center of Gravity velocity to inform direction and speed of ball rolling inside of sphere of a 3D Hypotrochoid
		- location of traced point in center sphere:
			- informed by Omicron controls OR
			- set center of gravity to be an xyz point inside a ball.
		- color and weight of traced point -> Omicron

	- Outer Sphere of 3D Hypotrochoid:
		- diameter -> distance between User-N's center of gravity and body part furthest away from User-N's center of gravity
		- location -> follows User-N

	- Parameter Options: 
		- map the traced point to the corner of an Emblem (Snaps image) such that each of 3 users control one corner of an image with their individually controlled  nested sphere. 
		- Make each User's center of gravity a single cusp in an n-cusp hypocycloid.
			- http://demonstrations.wolfram.com/EpicycloidsFromAnEnvelopeOfLines/
		- Spirolight parameters effected by the presence of other Spirolights; creates interweaving patterns.  
		- line thickness controlled by Kinect depth info
		- Traced line is occluded when it passes behind the User!!! user appears to be inside the Spirolight. 
		- If user occludes the animation based on depth, then the outline created by User's body may br enough to depict the human form in negative space. Thus, no need for extra pixels. 
		- Each User gets their own Spirolight (up to 3)
		- Create a 3-cusp epicycloid that remains 3-cusp while the distance between the cusps change (i.e., each cusp is the center of a moving body).  What other variables would have to change?

- **Spirograph Definitions:**
	- **Hypocycloids:**
		- http://mathworld.wolfram.com/Hypocycloid.html
		- Coin inside a ring; tracing a point on circumference of coin
		- An n-cusped hypocycloid has radiusA / radiusB = n.
			- Thus, a 5 pointed star has is a hypocycloid whose ring's radius is 5x the radius of the coin inside.
	- **Hypotrochoids:**
		- http://mathworld.wolfram.com/Hypotrochoid.html
		- Coin inside a ring; tracing a point either inside or outside the perimeter of the coin
	- **Epicycloids:**
		- http://mathworld.wolfram.com/Epicycloid.html
		- Coin outside a ring; tracing a point on circumference of coin
	- **Epitrochoids:**
		- http://mathworld.wolfram.com/Epitrochoid.html
		- Coin outside of ring; tracing a point either inside or outside the perimeter of coin


###Kinect + Dancer:
- **Optical Flow with change in depth, not just change in frame!!!  Frame differencing in the z-axis!!**  
	- Frame AND GreyScale Differencing for Depth Changes that are not along the x,y, but are instead, back and forth from the sensor.
- We may keep the 2D world by pulling the 3D info from Kinect but projeting into 2D world.  Z-axis can convert to size instead of distance. 
- [] Make closest point in point cloud the desired target such that: 

```steering force = desired velocity - current velocity```

- [] Create an array of PImages, each containing the previous frame to create a 5 sec sample of dancer + depth.  then rotate along the z-axis (see La Danse Kinect on vimeo).
- [] How will CenterPiece-SpiroLight interact with the dancer's body?
	- blendMode(ADD)
- [] RealTime 3D Optical Flow on a point cloud (color = point velocity; or color denotes movement direction and alpha denotes point velocity)
- [] particles flock to silioutette when standing still
- [] particles flock / swarm together toward movement
- [] If movement, generate particle whose color equals the color of reference image and whose velocity is informed by the flow field.
- [] dancer is mask for reference image
- [] flow field points to spirolight, unless located on dancer within min-max range
- [] if dancer in field, then vector mag is depth and direction points to the edge.  once at the edge, particle moves toward spirolight according to background flow field
- [] flow field vectors increase in magnitude as they approach spirolight such that particles accelerate toward the light
- [] particle steering force and maxspeed change relative to their proximity to spirolight
- [] Create a Vector Field as function of depth
- [] Build Library for Depth related Forces
- [] upload diagrams
- [] PNGs with Alpha Layer for particles AND for ellipses of spiroLight.
- **Kinect Ideas**
	- [] Kinect:  Users Center of Mass linked to spiroCenter Location
	- [] Kinect: User's horizontal distance informs the spiroCenter's gravitational constant

###Code:
- Use createGraphics() to return a PGraphics object.  Unlike the main drawing surface, this surface retains transparency!  That means SpiroLight can fade without fading the particle system

- **ToDo(Owen):**
	- [] Particle System!  particle.lookup(PVector particleLocation); // will return a PVector force derived from the Flow Field state at that particle's location.  USE THE FORCE to inform acceleration to inform velocity to inform location.  



- **ToDo(Installation):**

###Code Snippets:

```spiroLight.applyForce(force);
``` 

- // with zero net force, object remains still or at constant velocity.  spiroLight object receives the force and hands it to the object's method applyForce(PVector force) where the force gets accumulated by acceleration with acceleration.add(force) (such that force informs acceleration, acceleration informs velocity, velocity informs location)

- accumulate the net force (but only for any specific frame).  Update should end with acc.mag(0); to clear the forces that the acceleration vector has accumulated.

```
void applyForce (PVector force) {
	PVector newForceBasedOnObjectMass = PVector.div(force, mass); 
				// b/c more force required to move larger mass.
	acceleration.add(force);
}
void update() {
velocity.add(acceleration);
location.add(velocity);
}
```

- A simpler For-Loop Syntax for an Array:
``` for (SpiroLight spiro : Spiros){}  // for every SpiroLight spiro in the array Spiros```

- Force = Mass X Acceleration
- Acceleration = Force/Mass

- What is the NORMAL force?  Always = 1 (in our processing world)

- Friction Algorithm (what is mag and direction of friction (always against the direction of velocity)):  Friction Force = -1 X (unit direction velocity vector) X the NORMAL force X the coefficient of friction

```
PVector friction = velocity.get();  // get a copy of velocity vector
friction.normalize();  // normalize the copied velocity vector to get its direction
friction.mult(-1);   // now take the direction and put it in the opposite direction (because friction acts AGAINST the direction of velocity)
float coefficientOfFriction = .001;  // set the strength of the friction
friction.mult(coefficientOfFriction)  // the direction of friction and multiply by the magnitude set by the kind of substance causing the friction (the Coefficient of Friction)
```

- **Polar to Cartesian Cordinates**
	- SOHCAHTOA
	- y = radius * sin(theta)
	- x = radius * cos(theta)

- The following statement will create a user defined function that will create Spirograph patterns:

```
spirograph = function (v_R, v_r, v_p, v_nRotations, s_color)
{
    t = vectorin(0, 0.05, 2 * pi * v_nRotations);:
    x = (v_R + v_r) * cos(t) + v_p * cos((v_R + v_r) * t / v_r);:
    y = (v_R + v_r)* sin(t) + v_p * sin((v_R + v_r) * t / v_r);:
    plot(x, y, s_color):
}
```
	- To see this function in action, execute the following statement:

>```spirograph(53, -29, 40, 30, gray)```



###Diagrams:


###Examples:
- [Spirograph Web App worth checking out](http://www.benjoffe.com/code/toys/spirograph)
- [Epicycles On Epicycles, Cable Knots on Cable Knots | vimeo](https://vimeo.com/7757058)
- [The 3D Spirograph Project | vimeo](https://vimeo.com/2228788)
	- The visual math of epicycloids. Nested rotational orbits produce emergent spiral designs in 3D.
- [Vectors: Acceleration Towards the Mouse (Nature of Code) - Shiffman](https://vimeo.com/59028636)
- [If Spirographs were 3D](http://matheminutes.blogspot.com/2012/01/if-spirograph-were-3d.html)
- [Spirographs and the 3rd Dimensions | 3D printing](http://maxwelldemon.com/2010/01/14/spirographs-and-the-third-dimension/)
- [Spirograph | Web App](http://wordsmith.org/~anu/java/spirograph.html#display)
- [Spirograph in Code | OpenProcessing website](http://www.openprocessing.org/browse/?viewBy=tags&tag=spirograph)
- [Spirographs Explained | Sam Brenner from ITP](http://samjbrenner.com/notes/processing-spirograph/)
- [Simple Spirograph | Web App from Aquilax's Dev Blog](http://dev.horemag.net/2008/03/03/spirograph-with-processing/)
- [Mathiversity | Spirograph Web App](http://mathiversity.com/Spirograph)
- [Spirograph Web App](http://www.eddaardvark.co.uk/nc/sprog/index.html#x)


###Future:
- [] toxilib
- [Flow no.1 The Kinect Projector Dance](http://princemio.net/portfolio/flow-1-kinect-projector-dance/)
	- Software Used for the project:
		- ofxOpenNI – created by gameoverhack – openNi wrapper to read captrued data from the kinect camera in realtime.
		- ofxCV – created by Kyle McDonald – fast openCV wrapper.
		- ofxFluidSolver – created by Memo Atken. After Years, it is still one of my favourite calculation models to illustrate continous flow of a dancer and graphics.
		- ofxUI – created by rezaali – having worked a lot in processing, i completly fell in love with this GUI library as it speeds up my tweaking processes. Its easy to use and fast to bind to variables.