/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2014 Jason Stephens, Owen Williams & VideoAlchemy Collective
 *
 *	See `credits.txt` for base work and shouts out.
 *	Published under CC Attrbution-ShareAlike 3.0 (CC BY-SA 3.0)
 *		            http://creativecommons.org/licenses/by-sa/3.0/
 *******************************************************************/

////////////////////////////////////////////////////////////
//  TouchOsc controller for JugglingMolecules sketch
////////////////////////////////////////////////////////////

class MolecularController extends OscController {

//	OscMultiToggleControl Loader;
//	OscMultiToggleControl Saver;

	public MolecularController() {
		super();

		// create special controls as necessary, everything else will just get a normal Control

		new OscXYControl(this, "particleGenerate", "particleGenerateSpread", "particleGenerateRate");
		new OscXYControl(this, "noise", "noiseStrength", "noiseScale");

		new OscChoiceControl(this, "particleColorScheme", 4);
		new OscChoiceControl(this, "depthImageBlendMode", new int[] {0,1,2,4,8,16,32,64,128,256});

		new OscButton(this, "sync");
		new OscButton(this, "snapshot");

		new OscGridControl(this, "particleImage", 4, 3);
		new OscGridControl(this, "setupWindowSize", 3, 2);

//		new OscGridControl(this, "windowSize", 3, 2);

//		Loader = new OscGridControl(this, "Loader", 10, 10, true);
//		Saver  = new OscMultiGridControl(this, "Saver", 10, 10, false);
	}

	void handleSpecialAction(OscControl control, String fieldName, float controllerValue, OscMessage message) {
		if (fieldName.equals("sync"))						gConfig.syncControllers();
//		else if (fieldName.equals("snapshot"))				snapshot();		// NOTE: calling a global method, breaks encapsulation
//		else if	(fieldName.equals("Loader")) 				this.loadConfig(control, message);
//		else if	(fieldName.equals("Saver")) 				this.saveConfig(control, message);
//		else if (fieldName.equals("Savelock"))				this.updateSaverFileGrid();
		else if (fieldName.equals("setupWindowSize"))  		this.onWindowSizeChanged();
		else if (fieldName.equals("kinectAngle"))			this.onKinectAngleChanged();
	}


	// When window size is changed from the controller, notify them they'll have to restart.
	void onWindowSizeChanged() {
		// notify about new size on restart
		int wdSize	 = gConfig.setupWindowSize;
		int wdWidth  = gConfig.windowWidths[wdSize];
		int wdHeight = gConfig.windowHeights[wdSize];
		this.say("Restart for "+wdWidth+"x"+wdHeight);
	}

	void onKinectAngleChanged() {
		try {
			int newAngle = gConfig.kinectAngle;
//println("changed kinect angle to "+newAngle);
			gKinecter.kinect.tilt(newAngle);
		} catch (Exception e){
			println("Exception updating kinect angle: "+e);
		}
	}

/*

	void loadConfig(OscControl control, OscMessage message) {
		int index = control.index(message);
		try {
			gConfig.load(index);
			this.say("Loaded slot "+index);
		} catch (Exception e) {
			this.say(" Slot "+index+" is empty!");
		}
	}


	void saveConfig(OscMessage message) {
		if (!this.flagIsSet("Savelock")) {
			println("!!!! YOU MUST PRESS SAVE BUTTON TO SAVE, F0O0O0O0O0O0L!!!!");
			this.say("!!Press SAVE to save!!");
			return;
		}
		try {
			int index = control.index(message);
			this.say("Saving to slot "+index);
			gConfig.save(index);
			this.say("Saved to slot "+index);
		} catch (Exception e) {
			this.say("Problem saving to slot "+index);
		}
	}



	// Update the "Saver" grid with the set of configs which already exist.
	void updateSaverFileGrid() {
		Saver.updateStates(gConfig.configExistsMap);
	}


// TODO: breaks encapsulation, the config should handle this!
	void updateKinectAngle(OscMessage message) {
		try {
			int angle = gConfig.getInt("kinectAngle");
			gKinecter.kinect.tilt(angle);

			// remember angle on restart
			gConfig.saveSetup();
		} catch (Exception e){
			println("Exception updating kinect angle: "+e);
		};
	}

	// Update the config with messages from OSC.
	// Special stuff to update the config w/weird controls, etc.
	void parseMessage(String fieldName, OscMessage message) {
		float value = message.get(0).floatValue();

		// Window background hue/greyscale toggle.
		if (fieldName.startsWith("windowBg")) {
			float _hue;
			if (fieldName.equals("windowBgGreyscale")) {
				gConfig.setFromController(fieldName, value, this.minValue, this.maxValue);
				_hue = gConfig.hueFromColor(gConfig.windowBgColor);
			} else {
				_hue = value;
			}

			if (gConfig.windowBgGreyscale) {
				int _grey = (int)map(_hue, 0, 1, 0, 255);
				gConfig.windowBgColor = color(_grey);
			} else {
				gConfig.windowBgColor = colorFromHue(_hue);
			}
			return;
		}


		// hue controls.  Note that the config currently expects "Color" to be setting hue value.
		if (fieldName.endsWith("Hue")) {
			fieldName = fieldName.replace("Hue", "") + "Color";
		}
	}


	// Special case for fields with special needs.
	void onConfigFieldChanged(String fieldName, float controllerValue, String typeName, String valueLabel) {
		this.sendLabel(fieldName, valueLabel);

		// map "Color" to "Hue"
		if (fieldName.endsWith("Color")) fieldName = fieldName.replace("Color", "Hue");

		// always send the raw value
		this.sendFloat(fieldName, controllerValue);

		// window bg
		else if (fieldName.startsWith("windowBg")) {
			this.sendBoolean("windowBgGreyscale", gConfig.windowBgGreyscale);
			float hueValue;
			try {
				if (gConfig.windowBgGreyscale) {
					println("GREYSCALE");
// TODO...
					hueValue = this.getFieldValue("windowBgColor");
				} else{
					println("COLOR");
					hueValue = this.getFieldValue("windowBgColor");
				}
				this.sendFloat("windowBgHue", hueValue);
			} catch (Exception e) {
				println("Exception setting windowBgHue: "+e);
			}
		}

	}
*/
}