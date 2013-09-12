
import processing.opengl.*;
import processing.video.*;

Capture cam;


float frameSize=10;
PImage img;
PImage patternLang;
PImage tex;

void setup() {
  noCursor();

  size(800, 800, P3D);
  
//get list of available cameras
 String[] devices = Capture.list();
  println(devices);

  // If no device is specified, will just use the default.
  cam = new Capture(this, 320, 240);


  
  
  img = loadImage("8Fold.png"); //start with an initial image
  patternLang = loadImage ("01.png");
  stroke(255);
}

void draw() {
  strokeWeight(frameSize);
  background(0);



  translate(width / 2, height / 2);

  // use 2 full rotations in both directions with 2*PI
  rotateY(map(mouseX, 0, width, -2*PI, 2*PI));
  rotateX(map(mouseY, 0, width, -2*PI, 2*PI));

  //________________call camera
  //commented this out to prevent flicker
  // if (cam.available() == true) {
  //    cam.read();
  //    image(cam, -50, -50);
  //  }
  cam.read();
  image(cam, -50, -50, 200, 200);

  //begin mesh shape and place the grabbed texture from get()
  beginShape();
  texture(img);
  vertex(-200, -200, 0, 0, 0);
  vertex(200, -200, 0, 400, 0);
  vertex(200, 200, 0, 400, 400);
  vertex(-200, 200, 0, 0, 400);
  endShape(CLOSE);

  //place a png from previous generative art piece
  image(patternLang, -200, -200, 200, 200);

  // acquire pixels within these dimensions and store in PImage varible 'img'
  img=get(200, 200, 400, 400);
}

void keyPressed() {
  if (keyCode == 38) { //arrow up
    frameSize++;
  }
  else if (keyCode==40) { //arrow down
    frameSize--;
  }
}

