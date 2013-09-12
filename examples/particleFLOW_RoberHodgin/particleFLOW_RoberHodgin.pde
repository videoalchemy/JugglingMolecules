import processing.opengl.*;
import java.util.*;
int N = 200;
float repulsion = 0.1;        // how much the particles repel each other
float contraction = 0.0005;   // how much they are pulled towards the center
float mainHue = random(360);  
float damping = 0.9;          // how much drag is applied to the particles

// allows for fast adding and deleting of the particles
LinkedList<Particle> parts = new LinkedList<Particle>();

void setup() {
  size(1024,768, OPENGL);
  background(0);
  smooth();
  colorMode(HSB, 360, 1, 1);
}

void draw() {
  if (mousePressed && mouseButton == LEFT){
    
    // create some new particles, adding the mouse velocity
    for (int i = 0; i < 5; i++) {
      parts.add(new Particle(mouseX+random(-0.7,0.7), mouseY+random(-0.7,0.7),
      (mouseX-pmouseX)*0.3, (mouseY-pmouseY)*0.3));
    }
  } else if (mousePressed && mouseButton == RIGHT) {
    
    //pick a new hue
    mainHue = random(360);
  }
  if (frameCount % 2 == 0){
      noStroke();
      fill(0,15);
      rect(0,0,width,height);
  }

  ListIterator<Particle> it = parts.listIterator();
  while(it.hasNext()){
    Particle p = it.next();
    if (!p.alive) {
      it.remove();
      continue;
    }
    p.vx += (width/2-p.x)*contraction;
    p.vy += (height/2-p.y)*contraction;
    
    // iterate over the particles which the current particle has not interacted with yet
    ListIterator<Particle> forward = parts.listIterator(it.nextIndex());
    while(forward.hasNext()){
      Particle np = forward.next();
      float p2npx = np.x-p.x;
      float p2npy = np.y-p.y;
      float sqdist = p2npx*p2npx + p2npy*p2npy;
      
      //apply repulsive forces
      p.vx -= p2npx/sqdist * repulsion/p.s;
      np.vx+= p2npx/sqdist * repulsion/np.s;
      p.vy -= p2npy/sqdist * repulsion/p.s;
      np.vy+= p2npy/sqdist * repulsion/np.s;
    }
    
    // apply a random force
    float nscale = 0.01;
    float offset = 500;
    p.vx += (noise(p.x*nscale, p.y*nscale,frameCount*nscale) - 0.5) / p.s;
    p.vy += (noise(p.x*nscale+offset, p.y*nscale+offset,frameCount*nscale*0.2) - 0.5) / p.s;
    p.update();
  }
  
  for (Particle p : parts){
    noStroke();    
    p.draw();
  }
}
