class FlowField {
// class to output the force vector at a given position
// in the perlin noise flow field
// input: x,y,t co-ords
// output: force PVector
 
  float scaleFactor;
  PVector field;
 
  FlowField(float s) {
    // variable to determine scaling factor of perlin noise field in x and y
    scaleFactor = s;
  }
   
  PVector getForce(float x, float y, float t) {
    PVector field = new PVector(0.0,0.0);
    field.x = noise(scaleFactor*x,scaleFactor*y,t) -0.5;
    field.y = noise(scaleFactor*x,scaleFactor*y,t+1000) -0.5;
    return field;
  }
}

