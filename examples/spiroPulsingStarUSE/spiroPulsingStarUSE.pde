//jason
//thesis
// add blending mode

/*felix faire
 http://www.openprocessing.org/sketch/58227
 */

import processing.opengl.*;
float rad = 0;
float rad2 = 0;
float theta = 0;
float speed = 0.02;
float maximum = 20;

void setup() {
  size(1024, 768, OPENGL);
  //background(0);
  //smooth();
  //frameRate(100);
}

void draw() {

  fill(0, 2);
  rect(0, 0, width, height);

  ellipseMode(CENTER);

  noStroke();
  fill(cos(theta)*255, cos(theta+(PI/3))*255, cos(theta+(2*PI/3))*255);
  ellipse(mouseX, mouseY, 300/(1+rad2), 300/(1+rad));

  pushMatrix();
  translate(mouseX, mouseY);
  rotate (.25*PI);//(6*PI*(mouseX/width));
  fill(sin(theta)*255, sin(theta+(PI/3))*255, sin(theta+(2*PI/3))*255);
  ellipse(0, 0, 300/(1+rad), 300/(1+rad2));
  popMatrix();
pushMatrix();
  translate(mouseX, mouseY);
  rotate (.25*PI);//(6*PI*(mouseX/width));
  fill(sin(theta+PI)*255, sin(theta+(PI/3))*255, sin(theta+(2*PI/3))*255);
  ellipse(0, 0, 300/(1+rad2), 300/(1+rad));
  popMatrix();
  theta = theta + speed;
  rad = maximum*sin(theta);
  rad2 = maximum*cos(theta);

  if (mousePressed == true) {
    // background(0);
  }
}

