// Draw from the previous mouse location to the current
// mouse location to create a continuous line
void setup() {
  size(1024, 768);
}

void draw() {
  fill(0,5);
  rect(0,0,width,height);
  stroke(255);
  line(mouseX, mouseY, pmouseX, pmouseY);
  line(width-mouseX,height-mouseY,width-pmouseX,height-pmouseY);
  line(width-mouseX,mouseY,width-pmouseX,pmouseY);
   line(mouseX,height-mouseY,pmouseX,height-pmouseY);
   strokeWeight(abs(mouseX-pmouseX)*.5);
}
