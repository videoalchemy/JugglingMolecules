/**
 * CenterPiece_SpiroLight
 
 
 Acceleration with Vectors 
 * by Daniel Shiffman.  
 * 
 * Demonstration of the basics of motion with vector.
 * A "Mover" object stores location, velocity, and acceleration as vectors
 * The motion is controlled by affecting the acceleration (in this case towards the mouse)
 *
 * For more examples of simulating motion and physics with vectors, see 
 * Simulate/ForcesWithVectors, Simulate/GravitationalAttraction3D
 */

// A Mover object
Mover mover;
Mover mover1;


void setup() {
  size(displayWidth, displayHeight, P2D);
  background(0);
smooth();
  mover = new Mover(4, .3, .07, 0, 255, 255);  // top speed, accelerationScalar, rotationRate, point color
  mover1 = new Mover(5, .3, .04, 255, 0, 130);
}

void draw() {
  // background(0);
  // lights();
   
   blendMode(ADD);

  pushStyle();
  blendMode(BLEND);
  fill(0, 3);
  rect(0, 0, width, height);

  popStyle();
 
 
  pushStyle();
 blendMode(ADD);
  blendMode(REPLACE);
  // Update the location
// mover.update();
  mover1.update();


  // Display the Mover Without Background and only the points showing
  //mover.displayWithoutBackground(); 
  mover1.displayWithoutBackground(); 
  popStyle();
}

