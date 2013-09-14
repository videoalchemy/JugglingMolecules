// Object borrowed from 'Forces - Nature of code'
// by Daniel Shiffman <http://www.shiffman.net>
 
class Thing {
  PVector loc;
  PVector vel;
  PVector acc;
  float mass;
  float max_vel;
  color c;
     
  Thing(PVector a, PVector v, PVector l, float m_, int option) {
    acc = a.get();
    vel = v.get();
    loc = l.get();
    mass = m_;
    max_vel = 20.0;
    // set the colour to one of three options, with a little randomness
    switch(option) {
      case 1:
        c = color(random(0,5),1,3);
        break;
      case 2:
        c = color(1,random(1,5),3);
        break;
      case 3:
        c = color(6,random(0,2),1);
        break;
    }
  }
   
  PVector getLoc() {
    return loc;
  }
 
  PVector getVel() {
    return vel;
  }
  float getMass() {
    return mass;
  }
 
  void applyForce(PVector force) {
    force.div(mass);
    acc.add(force);
  }
 
  // Main method to operate object
  void go() {
    update();
    render();
  }
   
  // Method to update location
  void update() {
    vel.add(acc);
    vel.limit(max_vel);
    loc.add(vel);
    acc.mult(0);
  }
   
  // Method to display
  void render() {
    // additive blending, could be written faster, but it's ok
    color c0 = buff.get(int(loc.x),int(loc.y));
    float c0r = red(c0);
    float c0g = green(c0);
    float c0b = blue(c0);
    float cr = red(c);
    float cg = green(c);
    float cb = blue(c);
    c0 = color(min(c0r+cr,255),min(c0g+cg,255),min(c0b+cb,255));
    buff.set(int(loc.x),int(loc.y),c0); 
  }
}

