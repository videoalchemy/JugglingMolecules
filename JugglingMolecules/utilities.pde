/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2013 Jason Stephens & VideoAlchemy Collective
 *
 *	See `credits.txt` for base work and shouts out.
 *	Published under CC Attrbution-ShareAlike 3.0 (CC BY-SA 3.0)
 *		            http://creativecommons.org/licenses/by-sa/3.0/
 *******************************************************************/

////////////////////////////////////////////////////////////
//	Depth image manipulation
////////////////////////////////////////////////////////////

	// Draw the depth image to the screen according to our global config.
	void drawDepthImage() {
		pushStyle();
		pushMatrix();
//TODO...
//		tint(depthImageColor);
//		tint(256,128);
		scale(-1,1);	// reverse image to mirrored direction
		blendMode(gConfig.depthImageBlendMode);
		image(gKinecter.depthImg, 0, 0, -width, height);
		blendMode(BLEND);	// NOTE: things don't look good if you don't restore this!
		popMatrix();
		popStyle();
	}


////////////////////////////////////////////////////////////
//	Drawing utilities.
////////////////////////////////////////////////////////////

	// Partially fade the screen by drawing a translucent black rectangle over everything.
	void fadeScreen(color bgColor, int opacity) {
		pushStyle();
		noStroke();
		fill(bgColor, opacity);
		rect(0, 0, width, height);
		popStyle();
	}

	// Show the instruction screen as an overlay.
	void drawInstructionScreen() {
	  pushStyle();
	  // instructions under depth image in gray box
	  fill(50);
	  int top = height-85;
	  rect(0, top, 640, 85);
	  fill(255);
	  text("Press keys 'a' and 'z' to adjust minimum depth: " + gKinecter.minDepth, 5, top+15);
	  text("Press keys 's' and 'x' to adjust maximum depth: " + gKinecter.maxDepth, 5, top+30);

	  text("> Adjust depths until you get a white silhouette of your whole body with everything else black.", 5, top+55);
	  text("PRESS SPACE TO CONTINUE", 5, top+75);
	  popStyle();
	}




////////////////////////////////////////////////////////////
//	Generic math-ey utilities.
////////////////////////////////////////////////////////////
	// Return a perline noise vector field, size of `rows` x `columns`.
	PVector[][] makePerlinNoiseField(int rows, int cols) {
	  //noiseSeed((int)random(10000));  // TODO???
	  PVector[][] field = new PVector[cols][rows];
	  float xOffset = 0;
	  for (int col = 0; col < cols; col++) {
		float yOffset = 0;
		for (int row = 0; row < rows; row++) {
		  // Use perlin noise to get an angle between 0 and 2 PI
		  float theta = map(noise(xOffset,yOffset),0,1,0,TWO_PI);
		  // Polar to cartesian coordinate transformation to get x and y components of the vector
		  field[col][row] = new PVector(cos(theta),sin(theta));
		  yOffset += 0.1;
		}
		xOffset += 0.1;
	  }
	  return field;
	}
