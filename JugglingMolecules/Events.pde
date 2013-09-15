/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2013 Jason Stephens & VideoAlchemy Collective
 *
 *	See `credits.txt` for base work and shouts out.
 *	Published under CC Attrbution-ShareAlike 3.0 (CC BY-SA 3.0)
 *		            http://creativecommons.org/licenses/by-sa/3.0/
 *******************************************************************/

////////////////////////////////////////////////////////////
//	Handle keypress to adjust parameters
////////////////////////////////////////////////////////////
	void keyPressed() {
	  println("*** CURRENT FRAMERATE: " + frameRate);

	  // up arrow to move kinect down
	  if (keyCode == UP) {
		gKinecter.kAngle++;
		gKinecter.kAngle = constrain(gKinecter.kAngle, 0, 30);
		gKinecter.kinect.tilt(gKinecter.kAngle);
	  }
	  // down arrow to move kinect down
	  else if (keyCode == DOWN) {
		gKinecter.kAngle--;
		gKinecter.kAngle = constrain(gKinecter.kAngle, 0, 30);
		gKinecter.kinect.tilt(gKinecter.kAngle);
	  }
	  // space bar for settings to adjust kinect depth
	  else if (keyCode == 32) {
		gConfig.showSettings = !gConfig.showSettings;
	  }
	  // 'a' pressed add to minimum depth
	  else if (key == 'a') {
		gKinecter.minDepth = constrain(gKinecter.minDepth + 10, 0, gKinecter.thresholdRange);
		println("minimum depth: " + gKinecter.minDepth);
	  }
	  // z pressed subtract to minimum depth
	  else if (key == 'z') {
		gKinecter.minDepth = constrain(gKinecter.minDepth - 10, 0, gKinecter.thresholdRange);
		println("minimum depth: " + gKinecter.minDepth);
	  }
	  // s pressed add to maximum depth
	  else if (key == 's') {
		gKinecter.maxDepth = constrain(gKinecter.maxDepth + 10, 0, gKinecter.thresholdRange);
		println("maximum depth: " + gKinecter.maxDepth);
	  }
	  // x pressed subtract to maximum depth
	  else if (key == 'x') {
		gKinecter.maxDepth = constrain(gKinecter.maxDepth - 10, 0, gKinecter.thresholdRange);
		println("maximum depth: " + gKinecter.maxDepth);
	  }

	  // toggle showParticles on/off
	  else if (key == 'q') {
		gConfig.showParticles = !gConfig.showParticles;
		println("showing particles: " + gConfig.showParticles);
	  }
	  // toggle showFlowLines on/off
	  else if (key == 'w') {
		gConfig.showFlowLines = !gConfig.showFlowLines;
		println("showing optical flow: " + gConfig.showFlowLines);
	  }
	  // toggle showDepthImage on/off
	  else if (key == 'e') {
		gConfig.showDepthImage = !gConfig.showDepthImage;
		println("showing depth image: " + gConfig.showDepthImage);
	  }


	// different blend modes
	  else if (key == '1') {
		gConfig.depthImageBlendMode = BLEND;
		println("Blend mode: BLEND");
	  }
	  else if (key == '2') {
		gConfig.depthImageBlendMode = ADD;
		println("Blend mode: ADD");
	  }
	  else if (key == '3') {
		gConfig.depthImageBlendMode = SUBTRACT;
		println("Blend mode: SUBTRACT");
	  }
	  else if (key == '4') {
		gConfig.depthImageBlendMode = DARKEST;
		println("Blend mode: DARKEST");
	  }
	  else if (key == '5') {
		gConfig.depthImageBlendMode = LIGHTEST;
		println("Blend mode: LIGHTEST");
	  }
	  else if (key == '6') {
		gConfig.depthImageBlendMode = DIFFERENCE;
		println("Blend mode: DIFFERENCE");
	  }
	  else if (key == '7') {
		gConfig.depthImageBlendMode = EXCLUSION;
		println("Blend mode: EXCLUSION");
	  }
	  else if (key == '7') {
		gConfig.depthImageBlendMode = MULTIPLY;
		println("Blend mode: MULTIPLY");
	  }
	  else if (key == '8') {
		gConfig.depthImageBlendMode = SCREEN;
		println("Blend mode: SCREEN");
	  }
	}
