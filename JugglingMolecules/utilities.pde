/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2014 Jason Stephens, Owen Williams & VideoAlchemy Collective
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
		tint(gConfig.depthImageColor);
		scale(-1,1);	// reverse image to mirrored direction
		image(gDepthImg, 0, 0, -width, height);
		popMatrix();
		popStyle();
	}


////////////////////////////////////////////////////////////
//	Drawing utilities.
////////////////////////////////////////////////////////////

	// Partially fade the screen by drawing a translucent black rectangle over everything.
	// NOTE: this applies the current blendMode all over everything
	void fadeScreen() {
		pushStyle();
		blendMode(gConfig.blendMode);
		noStroke();
		fill(gConfig.fadeColor);
// println("blendMode: "+gConfig.blendMode+"  color:"+colorToString(gConfig.fadeColor));
		rect(0, 0, width, height);
		blendMode(BLEND);
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
	  text("Press keys 'a' and 'z' to adjust minimum depth: " + gConfig.kinectMinDepth, 5, top+15);
	  text("Press keys 's' and 'x' to adjust maximum depth: " + gConfig.kinectMaxDepth, 5, top+30);

	  text("> Adjust depths until you get a white silhouette of your whole body with everything else black.", 5, top+55);
	  text("PRESS SPACE TO CONTINUE", 5, top+75);
	  popStyle();
	}




////////////////////////////////////////////////////////////
//	Generic math-ey utilities.
////////////////////////////////////////////////////////////

	// Return a Perlin noise vector field, size of `rows` x `columns`.
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


////////////////////////////////////////////////////////////
//	Color stuff.
////////////////////////////////////////////////////////////

/*
		// switch to HSB color mode
		colorMode(HSB, 1.0);
		color clr = color(_hue, 1, 1, _alpha);
		// restore RGB color mode
		colorMode(RGB, 255);
		return clr;
*/

	// Initialize colors for all hues 0..359
	color[] HUE_COLORS;
	void initHueColors() {
		// switch to HSB color mode
		colorMode(HSB, 359, 1, 1, 1);

		HUE_COLORS = new color[360];
		for (int hueInt = 0; hueInt < 360; hueInt++) {
			HUE_COLORS[hueInt] = color(hueInt, 1, 1, 1);
		}

		// reset RGB color mode
		colorMode(RGB, 255);
//		for (int hueInt = 0; hueInt < 360; hueInt++) {
//			println(hueInt+ ":"+colorToString(HUE_COLORS[hueInt]));
//		}
	}

	// Return color for hue from 0..360
	color colorFromHue(int hueInt) {
		hueInt = constrain(hueInt, 0, 359);
		return HUE_COLORS[hueInt];
	}

	// Return color for hue from 0..1
	color colorFromHue(float hueFloat) {
		int hueInt = (int)map(hueFloat, 0, 1, 0, 359);
		return colorFromHue(hueInt);
	}


	// Given a color, return its hue as 0..1.
	// NOTE: assumes we're normally in RGB mode
	float hueFromColor(color clr) {
		// switch to HSB color mode
		colorMode(HSB, 1.0);
		float result = hue(clr);
		// restore RGB color mode
		colorMode(RGB, 255);
		return result;
	}


	color addAlphaToColor(color clr, int alfa) {
		return (clr & 0x00FFFFFF) + (alfa << 24);
	}




////////////////////////////////////////////////////////////
//	Given a native data type, return the equivalent String value.
//	Returns null on exception.
////////////////////////////////////////////////////////////

	// Return string value for integer.
	String intToString(int value) {
		return ""+value;
	}

	// Return string value for float field.
	String floatToString(float value) {
		return ""+value;
	}

	// Return string value for boolean value.
	String booleanToString(boolean value) {
		return (value ? "true" : "false");
	}

	// Return string value for color value.
	String colorToString(color value) {
		try {
			return "rgba("+(int)red(value)+","+(int)green(value)+","+(int)blue(value)+","+(int)alpha(value)+")";
		} catch (Exception e) {
			logWarning("ERROR in colorToString("+value+"): returning null", e);
			return null;
		}
	}

	// Return string value for string (base case).
	String stringToString(String string) {
		return string;
	}





////////////////////////////////////////////////////////////
//	Given a String representation of a native data type,
//		return the equivalent data type.
//	Returns throws on exception.
////////////////////////////////////////////////////////////

	int stringToInt(String stringValue) throws Exception {
		return int(stringValue);
	}

	float stringToFloat(String stringValue) throws Exception {
		return float(stringValue);
	}

	boolean stringToBoolean(String stringValue) throws Exception {
		return (stringValue.equals("true") ? true : false);
	}

	color stringToColor(String stringValue) throws Exception {
		String[] colorMatch = match(stringValue, "[color|rgba]\\((\\d+?)\\s*,\\s*(\\d+?)\\s*,\\s*(\\d+?)\\s*,\\s*(\\d+?)\\)");
		if (colorMatch == null) throw new Exception();	// TODO: more specific...
// TODO: variable # of arguments
// TODO: #FFCCAA
		int r = int(colorMatch[1]);
		int g = int(colorMatch[2]);
		int b = int(colorMatch[3]);
		int a = int(colorMatch[4]);
//		logDebug("parsed color color("+r+","+g+","+b+","+a+")");
		return color(r,g,b,a);
	}




////////////////////////////////////////////////////////////
//	Debugging and error handling.
////////////////////////////////////////////////////////////

	// Log a debug message -- something unexpected happened, but no biggie.
	void logDebug(String message) {
		if (gConfig.debugging) println(message);
	}


	// Log a warning message -- something unexpected happened, but it's not fatal.
	void logWarning(String message) {
		logWarning(message, null);
	}

	void logWarning(String message, Exception e) {
		if (!gConfig.debugging) return;
		println("--------------------------------------------------------------------------------------------");
		println("--  WARNING: " + message);
		if (e != null) println(e);
		println("--------------------------------------------------------------------------------------------");
	}

	// Log an error message -- something unexpected happened, and it's pretty bad.
	void logError(String message) {
		logError(message, null);
	}

	void logError(String message, Exception e) {
		if (!gConfig.debugging) return;
		println("--------------------------------------------------------------------------------------------");
		println("--  ERROR!!:   " + message);
		if (e != null) println(e);
		println("--------------------------------------------------------------------------------------------");
	}

