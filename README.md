###OmiCron-SpiroLight

###Requirements:
- [OmiCron The Interface](http://www.flickr.com/photos/jaycody9/sets/72157632699562712/)
- Kinect Depth Sensor

###ToDo:
- **ToDo(General):**
	
- **ToDo(Jason):**
	- [] Create a Vector Field as function of depth
	- [] Build Library for Depth related Forces
	- [] upload diagrams


- **ToDo(Owen):**
- **ToDo(Installation):**


- **Finished:**
	
###Ideas:
- [] Kinect:  Users Center of Mass linked to spiroCenter Location
- [] Kinect: User's horizontal distance informs the spiroCenter's gravitational constant
- [] Create a 3-cusp epicycloid that remains 3-cusp while the distance between the cusps change (i.e., each cusp is the center of a moving body).  What other variables would have to change?

###Code Snippets:
>```spiroLight.applyForce(force);``` 

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