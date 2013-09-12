/*
Particles additively blend to the current frame as they move around under the influence of a vector force field calculated using Perlin noise.
Click and drag the mouse to add new particles.

Controls:
r - reset
c - clear all particles
p - pause
f - toggle fade
t - toggle time evolution of flow field
a - toggle flow field arrows
Set colour with 1, 2, 3
Generate preset particle distribution with !,",£,$,%,^,&

With a class borrowed and adapted from Daniel Shiffman's wonderful Nature of Code tutorials.

*/
// noise field sketch
int w = 800;
int h = 500;
float time = 0;
ArrayList th;
FlowField wind;
int frame = 1;
int option = 1;
boolean run = true;
boolean flow_time = true;
boolean draw_time = false;
boolean arrow_time = false;
boolean fade = false;
Arrows show;
PGraphics buff;
 
void setup() {
 
  size(w,h,P3D);
   buff = createGraphics(w,h,P3D); 
  buff.colorMode(RGB, 100);
  frameRate(100);
  buff.noStroke();
  buff.noFill();
  buff.background(0);
  buff.smooth();
  noiseSeed(int(random(1,1000)));
  th = new ArrayList();
  // initialize with some random arrangement of particles,
  // several different presents, pick a random one each time.
  initialise(round(random(1,7)));
  wind = new FlowField(0.007);
  // new arrows object
  show = new Arrows(20);
}
 
void draw() {
  buff.beginDraw();
  // code for fading to black
  if (fade) {
    buff.fill(0,0.1);
    buff.rectMode(CORNER);
    buff.rect(0,0,width,height);
  }
  // update and render the particle system
  for(int k = th.size()-1; k>=0; k--) {
    Thing t = (Thing) th.get(k);
    PVector l = t.getLoc();
    // check for offscreen particles and remove
    if (l.x > width | l.y > height | l.x < 1 | l.y < 1) {
      th.remove(k);
    }
    // apply force to particles
    t.applyForce(wind.getForce(l.x,l.y,time));
    // need to change such that when paused particle positions added are visible
    if (run) {
      t.go();
    }
  }
  if (flow_time) {
      time +=0.001;
  }
  // for user directed addition of particles
  if (draw_time) {
    PVector a = new PVector(0,0);
    PVector v = new PVector(0,0);
    for (int i = 0; i < 100; i++) {
      // add smooth lines between previous and current mouse positions
      // add two random components, one along the length of the vector joining mouse
      // and pmouse, and the other orthogonal to this
      PVector r = new PVector(mouseX,mouseY);
      PVector p = new PVector(pmouseX,pmouseY);
      PVector l = PVector.sub(r,p);
      float l_length = l.mag();
      l.normalize();
      // to try and add some variation even if there is no mouse movement
      if(l_length == 0){
        l.add(new PVector(random(0,1),random(0,1)));
      }
      PVector l_norm = new PVector(l.y,-l.x);
      l_norm.mult(random(0,2));
      l.mult(random(-1,max(l_length,1)));
      PVector plot_loc = PVector.add(p,l);
      plot_loc.add(l_norm);
      th.add(new Thing(a,v,plot_loc,15,option));
    }
  }
  buff.endDraw();
  // place the buffer on the screen
  image(buff,0,0);
  if (arrow_time) {
    show.render();
  }
}
 
// KEYBOARD CONTROLS
void keyPressed() {
  switch(key) {
    case 'f': // fade the screen to black
      fade = !fade;
    case 's':
      String name = str(frame);
      save(name); // save on keypress s
      frame++;
      break;
    case 'r':
      setup(); // reset
      break;
    case 'c': // clear all particles
      for(int k = th.size()-1; k>=0; k--) {
        th.remove(k);
      }
      buff.background(0);
      break;
    // change colour of particles
    // 1 = purple, 2 = turqoise, 3 = red
    case '1':
      option = 1;
      break;
    case '2':
      option = 2;
      break;
    case '3':
      option = 3;
      break;
    case 'p': // pause
      run = !run;
      fade = false;
      flow_time = false;
      break;
    case 't': // evolve flow field over time
      flow_time = !flow_time;
      break;
    case 'a': // show flow field force vectors
      arrow_time = !arrow_time;
      break;
    // add one of the preset point distributions
    case '!':
      initialise(1);
      break;
    case '"':
      initialise(2);
      break;
    case '£':
      initialise(3);
      break;
    case '$':
      initialise(4);
      break;
    case '%':
      initialise(5);
      break;
    case '^':
      initialise(6);
      break;
    case '&':
      initialise(7);
      break;
  }
}
 
void mousePressed() {
  draw_time = true;
}
void mouseReleased() {
  draw_time = false;
}
 
// function to initialise flow field with some attractive
// present distribution of particles
void initialise(int in_option) {
  switch(in_option) {
    case 1:
    int n1 = 5000;
      for (int i = 1; i<n1; i++) {
        PVector a = new PVector(0.0,0.0);
        PVector v = new PVector(0.0,0.0);
        PVector l = new PVector(random(0,width),random(height/2 -1,height/2 +1));
        th.add(new Thing(a,v,l,15,option));
      }
    break;
    case 2:
    int n2 = 10000;
      for (int i = 1; i<n2; i++) {
        PVector a = new PVector(0.0,0.0);
        PVector v = new PVector(0.0,0.0);
        PVector l = new PVector(random(0,width),random(0,2));
        th.add(new Thing(a,v,l,15,option));
      }
    break;
    case 3:
    int n3 = 10000;
      for (int i = 1; i<n3; i++) {
        PVector a = new PVector(0.0,0.0);
        PVector v = new PVector(0.0,0.0);
        PVector l = new PVector(random(0,width),random(height-2,height));
        th.add(new Thing(a,v,l,15,option));
      }
    break;
    case 4:
    int n4 = 10000;
      for (int i = 1; i<n4; i++) {
        PVector a = new PVector(0.0,0.0);
        PVector v = new PVector(0.0,0.0);
        PVector l = new PVector(random(0,width),random(0,height));
        th.add(new Thing(a,v,l,15,option));
      }
    break;
    case 5:
    int n5 = 7500;
      for (int i = 1; i<n5; i++) {
        PVector a = new PVector(0.0,0.0);
        float theta = random(0,2*PI);
        PVector v = new PVector(1*sin(theta),-1*cos(theta));
        PVector l = new PVector(100*cos(theta) + width/2,100*sin(theta) +height/2);
        th.add(new Thing(a,v,l,15,option));
      }
      break;
    case 6:
    int n6 = 20000;
      for (int i = 1; i<n6; i++) {
        PVector a = new PVector(0.0,0.0);
        PVector v = new PVector(0.0,0.0);
        float theta = random(0,20*PI);
        PVector l = new PVector(10*theta*cos(theta) + width/2,10*theta*sin(theta) +height/2);
        th.add(new Thing(a,v,l,15,option));
      }
      break;
    case 7:
    int n7 = 5000;
    for (int j=1; j<4; j++) {
      option = j;
      for (int i = 1; i<n7; i++) {
        PVector a = new PVector(0.0,0.0);
        float theta = random(0,2*PI);
        PVector v = new PVector(1*sin(theta),-1*cos(theta));
        PVector l = new PVector(50*cos(theta) + width/2 -150*(j-2),50*sin(theta) +height/2);
        th.add(new Thing(a,v,l,15,option));
      }
    }
      break;
  }
}

