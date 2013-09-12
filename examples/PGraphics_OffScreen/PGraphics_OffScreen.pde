/**
 * Create Graphics. 
 * 
 * The createGraphics() function creates an object from the PGraphics class 
 * (PGraphics is the main graphics and rendering context for Processing). 
 * The beginDraw() method is necessary to prepare for drawing and endDraw() is
 * necessary to finish. Use this class if you need to draw into an off-screen 
 * graphics buffer or to maintain two contexts with different properties.
 */
import processing.opengl.*;
PGraphics pgBuffer;
PImage img;
PGraphics feedbackLoop;
PImage PImageLoop;

//global color chager
float changingColor;


void setup() {
  size(500, 500, OPENGL);
  pgBuffer = createGraphics(80, 80, OPENGL);
   feedbackLoop = createGraphics(width, height, OPENGL);
  //Img = pgBuffer.get(0,0,pgBuffer.width, pgBuffer.height);
}

void draw() {

  //import part here with updating pixels in the PImage with pixels from PGraphics
  //although get() doesn't seem to be the way to do it....
  //how did if work with the feedback application

  fill(0, 12);
  rect(0, 0, pgBuffer.width, pgBuffer.height);
  fill(255);
  noStroke();
  ellipse(mouseX, mouseY, 60, 60);




  pgBuffer.beginDraw();
  // pg.resize(120,120);
  pgBuffer.background(200, 90, 0);  // if zero background, then transparent?
  pgBuffer.noFill();
  pgBuffer.stroke(255, 0, 255);
  //PGraphic has it's own coordinate system.  mouseX for one screen may not be the same for another.
  pgBuffer.ellipse(mouseX, mouseY, 60, 60);
  pgBuffer.stroke(0, 255, 0);
  pgBuffer.ellipse(60, 60, 60, 60);

//pgBuffer.loadPixels();
//for (int i = 0;i <pgBuffer.pixels.length; i++) {
//  pgBuffer.pixels[i] = color (205  ,340,17 * (i+1)/pgBuffer.pixels.length);
//  }
//pgBuffer.updatePixels();
 pgBuffer.endDraw();
 

  image(pgBuffer, 60, 60); 
  image(pgBuffer, width- mouseX, height- mouseY);

  //img = pgBuffer;



 //image(img, width/2+(mouseX-width/2), height/2+ (mouseY-width/2),80, 90);
//
 //img.loadPixels();
// for (int i=0; i< img.pixels.length; i++) {
//    img.pixels[i] = color(255, 90, 102 * (i/img.pixels.length));//, 255* (i/img.pixels.length));
//  }
//  img.updatePixels();

//  image(img, mouseY, mouseX, 80, 80);

feedbackLoop.beginDraw();
PImageLoop=get(0,0,width,height);
feedbackLoop.endDraw();
image(PImageLoop, mouseX, mouseY, 0, 90);
}

