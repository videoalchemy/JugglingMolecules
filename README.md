###OmiCron-SpiroLight
- an interactive video installation designed for The Rhythm Society's EarthTones Retreat 2013.09.22
- the interface is a combination of gesture controls from dancers and knob turning from participants.  The podium sized OmiCron Interface will sit somewhere on the edge of the dance floor enticing users with its large knobs and glowing buttons.  Omicrons controls are mapped to the parameters of a spirograph-like pattern projected on a rear projection screen.  Dancers control the location of the pattern by way of the closest point in a 3D point cloud (ie the pattern will follow their hand if their hand contains the point closest to the Kinect sensor.  Dancers can also interact with a particle system whose behavior is controlled by a depth informed flow field.  Dancer's distance and velocity determine the behavior of the particles.

###Requirements:
- [OmiCron The Interface](http://www.flickr.com/photos/jaycody9/sets/72157632699562712/)
- Kinect Depth Sensor
- Processing 2.0.3
- SimpleOpenNI 1.96

###ToDo:
- **ToDo(Jason):**
	- [] Start by rebuilding CenterPiece-SpiroLight (with OmiCron controls and stationary centerpiece.)
	- [] Map OmiCron Controls to the 3 tiered CenterPiece-SpiroLight
		- [] Tier 1 = Red, Tier 2 = Green, Tier 3 = Blue
		- [] Each of the 3 omiCron buttons will change ratios (angular velocities, magnitude) for that color
			- eg Green Line From Tier 1 to Tier 2, and Green Line from Tier 2 to Tier 3 are:  
				- 1:1 in length, 1:1 in angular velocity, and are IN PHASE 
				- 1:2 in length, 1:-2 in angular velocity, and are out of phase by 90degrees
				- 1:sqrt2 in length, 1:1.618 in angular velocity, and are out of phase by 180
		- [] Knobs: Red(Left and Right) Green(L,R), Blue(L,R) control the rotational velocity and distance to next teir.
		- [] Ohmite Knob controls the parameters of the flow field (somehow) and/or z-axis rotation
	- [] Add remainder of tier 2 and 3
	- [] Make closest point in point cloud the desired target such that: 
	
	```steering force = desired velocity - current velocity```

	- [] Create an array of PImages, each containing the previous frame to create a 5 sec sample of dancer + depth.  then rotate along the z-axis (see La Danse Kinect on vimeo).
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


- **ToDo(Owen):**
	- [] Particle System!  particle.lookup(PVector particleLocation); // will return a PVector force derived from the Flow Field state at that particle's location.  USE THE FORCE to inform acceleration to inform velocity to inform location.   


- **ToDo(Installation):**


- **Finished:**
	
###Ideas:
- [] Kinect:  Users Center of Mass linked to spiroCenter Location
- [] Kinect: User's horizontal distance informs the spiroCenter's gravitational constant
- [] Create a 3-cusp epicycloid that remains 3-cusp while the distance between the cusps change (i.e., each cusp is the center of a moving body).  What other variables would have to change?

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


###Spirograph Definitions:
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


###Spirograph Parameters and Controls:
- ###Inner sphere of 3D Hypotrochoid:
	- diameter -> User-N's distance from Kinect 
	- velocity -> informed by velocity, location, and gravitational pull (determined by mass (from diameter) of User-N's center of gravity
		- use Center of Gravity velocity to inform direction and speed of ball rolling inside of sphere of a 3D Hypotrochoid
	- location of traced point in center sphere:
		- informed by Omicron controls OR
		- set center of gravity to be an xyz point inside a ball.
	- color and weight of traced point -> Omicron

- ###Outer Sphere of 3D Hypotrochoid:
	- diameter -> distance between User-N's center of gravity and body part furthest away from User-N's center of gravity
	- location -> follows User-N

- ###Parameter Options: 
	- map the traced point to the corner of an Emblem (Snaps image) such that each of 3 users control one corner of an image with their individually controlled  nested sphere. 
	- Make each User's center of gravity a single cusp in an n-cusp hypocycloid.
		- http://demonstrations.wolfram.com/EpicycloidsFromAnEnvelopeOfLines/
	- Spirolight parameters effected by the presence of other Spirolights; creates interweaving patterns.  
	- line thickness controlled by Kinect depth info
	- Traced line is occluded when it passes behind the User!!! user appears to be inside the Spirolight. 
	- If user occludes the animation based on depth, then the outline created by User's body may br enough to depict the human form in negative space. Thus, no need for extra pixels. 
	- Each User gets their own Spirolight (up to 3)


###Diagrams:


###Examples:
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
- [Flow no.1 The Kinect Projector Dance](http://princemio.net/portfolio/flow-1-kinect-projector-dance/)
	- Software Used for the project:
		- ofxOpenNI – created by gameoverhack – openNi wrapper to read captrued data from the kinect camera in realtime.
		- ofxCV – created by Kyle McDonald – fast openCV wrapper.
		- ofxFluidSolver – created by Memo Atken. After Years, it is still one of my favourite calculation models to illustrate continous flow of a dancer and graphics.
		- ofxUI – created by rezaali – having worked a lot in processing, i completly fell in love with this GUI library as it speeds up my tweaking processes. Its easy to use and fast to bind to variables.