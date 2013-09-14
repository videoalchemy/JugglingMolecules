

// Show the instruction screen
void drawInstructionScreen() {
  pushStyle();
  // instructions under depth image in gray box
  fill(50);
  int top = height-85;
  rect(0, top, 640, 85);
  fill(255);
  text("Press keys 'a' and 'z' to adjust minimum depth: " + kinecter.minDepth, 5, top+15);
  text("Press keys 's' and 'x' to adjust maximum depth: " + kinecter.maxDepth, 5, top+30);

  text("> Adjust depths until you get a white silhouette of your whole body with everything else black.", 5, top+55);
  text("PRESS SPACE TO CONTINUE", 5, top+75);
  popStyle();
}



// Handle keypress to adjust parameters
void keyPressed() {
  println("*** FRAMERATE: " + frameRate);

  // up arrow to move kinect down
  if (keyCode == UP) {
    kinecter.kAngle++;
    kinecter.kAngle = constrain(kinecter.kAngle, 0, 30);
    kinecter.kinect.tilt(kinecter.kAngle);
  } 
  // down arrow to move kinect down
  else if (keyCode == DOWN) {
    kinecter.kAngle--;
    kinecter.kAngle = constrain(kinecter.kAngle, 0, 30);
    kinecter.kinect.tilt(kinecter.kAngle);
  }
  // space bar for settings to adjust kinect depth
  else if (keyCode == 32) {
    showSettings = !showSettings; 
  }
  // 'a' pressed add to minimum depth
  else if (key == 'a') {
    kinecter.minDepth = constrain(kinecter.minDepth + 10, 0, kinecter.thresholdRange);
    println("minimum depth: " + kinecter.minDepth);
  }
  // z pressed subtract to minimum depth
  else if (key == 'z') {
    kinecter.minDepth = constrain(kinecter.minDepth - 10, 0, kinecter.thresholdRange);
    println("minimum depth: " + kinecter.minDepth);
  }
  // s pressed add to maximum depth
  else if (key == 's') {
    kinecter.maxDepth = constrain(kinecter.maxDepth + 10, 0, kinecter.thresholdRange);
    println("maximum depth: " + kinecter.maxDepth);
  }
  // x pressed subtract to maximum depth
  else if (key == 'x') {
    kinecter.maxDepth = constrain(kinecter.maxDepth - 10, 0, kinecter.thresholdRange);
    println("maximum depth: " + kinecter.maxDepth);
  }
  
  // toggle showParticles on/off
  else if (key == '1') {
    showParticles = !showParticles;
    println("showing particles? " + showParticles);
  }
  // toggle showOpticalFlow on/off
  else if (key == '2') {
    showOpticalFlow = !showOpticalFlow;
    println("showing optical flow? " + showOpticalFlow);
  }
  // toggle showDepthImage on/off
  else if (key == '3') {
    showDepthImage = !showDepthImage;
    println("showing depth image? " + showDepthImage);
  }
  // toggle showSettings on/off
  else if (key == '0') {
    showSettings = !showSettings;
    println("showing settings? " + showSettings);
  }
  
}

void stop() {
  kinecter.quit();
  super.stop();
}

