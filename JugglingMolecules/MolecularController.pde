/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2013 Jason Stephens & VideoAlchemy Collective
 *
 *	See `credits.txt` for base work and shouts out.
 *	Published under CC Attrbution-ShareAlike 3.0 (CC BY-SA 3.0)
 *		            http://creativecommons.org/licenses/by-sa/3.0/
 *******************************************************************/

////////////////////////////////////////////////////////////
//  TouchOsc controller for JugglingMolecules sketch
////////////////////////////////////////////////////////////

class MolecularController extends TouchOscController {

	boolean saveLock = false;

	public MolecularController() {
		super();
	}

	// Update the config with messages from OSC.
	// Special stuff to update the config w/weird controls, etc.
	void updateConfig(String fieldName, OscMessage message) {

		// If they're pressing the "Savelock" button, toggle the `saveLock` state.
		// We'll only save if `saveLock` is true.
		if (fieldName.equals("Savelock")) {
			float value = message.get(0).floatValue();
			this.saveLock = (value == 1);
println("--- saveLock:	" +  (this.saveLock ? "ON" : "OFF"));
			return;
		}

		// Load switcher control
		else if (fieldName.startsWith("Loader")) {
			println("Loader "+fieldName);
			int row = this.getZeroBasedRow(message, 10);		// TODO: get # rows from config
			int col = this.getZeroBasedColumn(message, 10);		// TODO: get # cols from config
			String fileName = "PS"+row+col;
			try {
				gConfig.load(fileName);
				this.say("Loaded "+fileName);
// This SHOULD work to tell the Saver which we just selected...
//				this.showMultiToggle("Saver", row, col, 10, 10);
			} catch (Exception e) {
				this.say(" Slot "+fileName+" is empty!");
			}
			return;
		}
		// Save switcher control.
		// Only works if `saveLock == true`.
		else if (fieldName.startsWith("Saver")) {
			if (!this.saveLock) {
				println("!!!! YOU MUST PRESS SAVE BUTTON TO SAVE, F0O0O0O0O0O0L!!!!");
				this.say("!!Press SAVE to save!!");
				return;
			}
			println("Saver "+fieldName);
			int row = this.getZeroBasedRow(message, 10);		// TODO: get # rows from config
			int col = this.getZeroBasedColumn(message, 10);		// TODO: get # cols from config
			String fileName = "PS"+row+col;						// TODO: get "PS" from config
			println("!!! SAVING to "+fileName);
			this.say("Saving "+fileName);
			gConfig.save(fileName);
			this.say("Saved "+fileName);
			return;
		}

		// Handle screen resolution toggles
// TODO: move into controller!!!!
		if (fieldName.startsWith("Screen")) {
			fieldName = fieldName.replace("Screen", "");
			String[] _split = split(fieldName, "x");
			int _width = int(_split[0]);
			int _height = int(_split[1]);
			gConfig.setupWindowWidth = _width;
			gConfig.setupWindowHeight = _height;
			println("Setting window size to "+_width+"x"+_height);
			gConfig.saveSetup();
			return;
		}

		float value = message.get(0).floatValue();

		// "particleGenerate" x/y pad
		if (fieldName.equals("particleGenerate")) {
			float otherValue = message.get(1).floatValue();
			gConfig.setFromController("particleGenerateRate", value, this.minValue, this.maxValue);
			gConfig.setFromController("particleGenerateSpread", otherValue, this.minValue, this.maxValue);
			return;
		}

		// "noise" x/y pad
		else if (fieldName.equals("noise")) {
			// x-y pad which returns 2 values
			float otherValue = message.get(1).floatValue();
			gConfig.setFromController("noiseStrength", value, this.minValue, this.maxValue);
			gConfig.setFromController("noiseScale", otherValue, this.minValue, this.maxValue);
			return;
		}

		// "particleColorScheme-0", "particleColorScheme-1", etc
		else if (fieldName.startsWith("particleColorScheme-")) {
			int mode = int(fieldName.replace("particleColorScheme-", ""));
			fieldName = "particleColorScheme";
			value = (float) mode;
		}

		// "depthImageBlendMode-0", "depthImageBlendMode-1", etc
		else if (fieldName.startsWith("depthImageBlendMode-")) {
			int mode = int(fieldName.replace("depthImageBlendMode-", ""));
			fieldName = "depthImageBlendMode";
			value = (float) mode;
		}

		// hue controls.  Note that the config currently expects "Color" to be setting hue value.
		else if (fieldName.contains("Hue")) {
			fieldName = fieldName.replace("Hue", "") + "Color";
		}

		gConfig.setFromController(fieldName, value, this.minValue, this.maxValue);


		if (fieldName.startsWith("kinect")) {
			gConfig.saveSetup();
			if (fieldName.equals("kinectAngle")) {
				try {
					int angle = gConfig.getInt("kinectAngle");
					gKinecter.kinect.tilt(angle);
				} catch (Exception e){};
			}
		}
	}


	// Special case for fields with special needs.
	void onFieldChanged(String fieldName, float controllerValue, String typeName, String valueLabel) {
		this.sendLabel(fieldName, valueLabel);

		// map "Color" to "Hue"
		if (fieldName.endsWith("Color")) fieldName = fieldName.replace("Color", "Hue");

		// always send the raw value
		this.sendFloat(fieldName, controllerValue);

		// do "specials"

		// "particleGenerate" x/y pad
		if (fieldName.equals("particleGenerateRate") || fieldName.equals("particleGenerateSpread")) {
			this.sendXY("particleGenerate", "particleGenerateRate", "particleGenerateSpread");
		}

		// "noise" x/y pad
		else if (fieldName.equals("noiseStrength") || fieldName.equals("noiseScale")) {
			this.sendXY("noise", "noiseStrength", "noiseScale");
		}

		// particleColorScheme toggles
		else if (fieldName.equals("particleColorScheme"))	{
			this.sendChoice("particleColorScheme", controllerValue, 3);
		}

		// depthImageBlendMode toggles
		else if (fieldName.equals("depthImageBlendMode")) {
			int[] choices = {0,1,2,4,8,16,32,64,128,256};
			this.sendChoice("depthImageBlendMode", controllerValue, choices);
		}

	}

}