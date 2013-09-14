class FlowField2 {
// class to output the force vector at a given position
// in the perlin noise flow field
// input: x,y,t co-ords
// output: force PVector
 
  float scaleFactor;
  PVector field;
 
  FlowField2(float s) {
    // variable to determine scaling factor of perlin noise field in x and y
    scaleFactor = s;
  }
   
  PVector getForce(float x, float y, float t) {
    PVector field = new PVector(0.0,0.0);
    float theta =  map(noise(scaleFactor*x,scaleFactor*y,t),0,1,0,2*PI);
    field.x = 0.1*cos(theta);
    field.y = 0.1*sin(theta);
    return field;
  }
}

