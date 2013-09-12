float a = radians(58);
float k = sin(PI-3*a)/sin(a);
 
void setup(){
  size(1024,768);
  background(255);
  smooth();
  strokeWeight(2);
}
 
void draw(){
  background(0);
  translate(width/2-mouseX,-130);
  for (float l=600; l>2; l = l/(k+0.95)){
    if (l==600){
      noStroke();
    }else{stroke(255);strokeWeight(l/100);}
    a=radians(120*mouseX/width);
    line(0,0,0,l);
    translate(0,l);
    rotate(-PI+a);
  }
  if (mousePressed == true){saveFrame("spirals.jpg");}
}

