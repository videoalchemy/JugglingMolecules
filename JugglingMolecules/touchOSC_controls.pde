/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2013 Jason Stephens & VideoAlchemy Collective
 *
 *	See `credits.txt` for base work and shouts out.
 *	Published under CC Attrbution-ShareAlike 3.0 (CC BY-SA 3.0)
 *		            http://creativecommons.org/licenses/by-sa/3.0/
 *******************************************************************/

////////////////////////////////////////////////////////////
//  TouchOSC mapping setup.
//
//	All values in TouchOSC controller map to floats 0..1
//	This is the same as our "JSON" output format, so we can use the config.toJSON()
//	 routines to feed back to the controller the current state of what's going on.
//
//	Currently this only supports listening to one controller, this will change.
//
////////////////////////////////////////////////////////////


// create function to recv and parse oscP5 messages
void oscEvent(OscMessage message) {
	// get the name of the control being affected, minus the initial slash
	String control = message.addrPattern().substring(1);
	// all controls return a float from 0..1, some return 2 floats (handled specially below)
	float value = message.get(0).floatValue();

	// if this is the first message we've received, gTouchControllerAddress will be empty.
	//	set it so we can communicate back with this device.
	if (gTouchControllerAddress == null) {
		NetAddress inboundAddress = message.netAddress();
		println("oscEvent(): First message received -- setting gTouchControllerAddress to "+inboundAddress.address() + ":" + gTouchControllerReceivingPort);
		gTouchControllerAddress = new NetAddress(inboundAddress.address(), gTouchControllerReceivingPort);
	}

	String debugMessage = "oscEvent(): " + control + " = " + value;

	// "particleGenerate" x/y pad
	if (control.equals("particleGenerate")) {
		// x-y pad which returns 2 values
		float otherValue = message.get(1).floatValue();
		debugMessage += ":"+otherValue;
		gConfig.applyConfigValue("particleGenerateRate", value);
		gConfig.applyConfigValue("particleGenerateSpread", otherValue);
	}
	// TODO: other x/y pad
	else if (control.equals("noise")) {
		// x-y pad which returns 2 values
		float otherValue = message.get(1).floatValue();
		debugMessage += ":"+otherValue;
		gConfig.applyConfigValue("noiseStrength", value);
		gConfig.applyConfigValue("noiseScale", otherValue);
	}

	// particleColorScheme toggles
	else if (control.equals("particleColorScheme-0"))	gConfig.applyConfigValue("particleColorScheme", 0);
	else if (control.equals("particleColorScheme-1"))	gConfig.applyConfigValue("particleColorScheme", 1);
	else if (control.equals("particleColorScheme-2"))	gConfig.applyConfigValue("particleColorScheme", 2);
	else if (control.equals("particleColorScheme-3"))	gConfig.applyConfigValue("particleColorScheme", 3);

	// depthImageBlendMode toggles
	else if (control.equals("depthImageBlendMode-0"))	gConfig.applyConfigValue("depthImageBlendMode", 0);
	else if (control.equals("depthImageBlendMode-1"))	gConfig.applyConfigValue("depthImageBlendMode", 1);
	else if (control.equals("depthImageBlendMode-2"))	gConfig.applyConfigValue("depthImageBlendMode", 2);
	else if (control.equals("depthImageBlendMode-3"))	gConfig.applyConfigValue("depthImageBlendMode", 3);

	// all other controls have a single value!
	else {
		gConfig.applyConfigValue(control, value);
	}

	println(debugMessage);

	// save the config back out to the controller
	this.outputStateToOSCController();
}


void outputStateToOSCController() {
	// get output states as a JSON blob, WITHOUT the _MIN and _MAX values
	JSONArray json = gConfig.toJSON(false);

	int i = 0, last = json.size();
	while (i < last) {
		String keyName = json.getString(i++);
		float value    = json.getFloat(i++);

		// "particleGenerate" x/y pad
		if 		(keyName.equals("particleGenerateRate")) sendFloatsToController("particleGenerate", gConfig.particleGenerateRateToJSON(), gConfig.particleGenerateSpreadToJSON());
		else if (keyName.equals("particleGenerateSpeed")) ;	// NOTE: sending value as part of "particleGenerate" message

		// "noise" x/y pad
		else if (keyName.equals("noiseStrength")) sendFloatsToController("noise", gConfig.noiseStrengthToJSON(), gConfig.noiseScaleToJSON());
		else if (keyName.equals("noiseScale")) ;	// NOTE: sending value as part of "noise" message

		// particleColorScheme toggles
		else if (keyName.equals("particleColorScheme"))	{
			sendIntToController("particleColorScheme-0", (value == 0 ? 1 : 0));
			sendIntToController("particleColorScheme-1", (value == 1 ? 1 : 0));
			sendIntToController("particleColorScheme-2", (value == 2 ? 1 : 0));
			sendIntToController("particleColorScheme-3", (value == 3 ? 1 : 0));
		}

		// depthImageBlendMode toggles
		else if (keyName.equals("depthImageBlendMode")) {
			sendIntToController("depthImageBlendMode-0", (value == 0 ? 1 : 0));
			sendIntToController("depthImageBlendMode-1", (value == 1 ? 1 : 0));
			sendIntToController("depthImageBlendMode-2", (value == 2 ? 1 : 0));
			sendIntToController("depthImageBlendMode-3", (value == 3 ? 1 : 0));
		}

		// all other controls go over as normal floats
		else {
			sendFloatToController(keyName, value);
		}
	}

	// output labels

	setControllerLabelValue("windowOverlayAlpha", 			""+gConfig.windowOverlayAlpha);

//	setControllerLabelValue("windowBgColor", 				""+gConfig.echoColor(windowBgColor));
	setControllerLabelValue("windowOverlayAlpha", 			""+gConfig.windowOverlayAlpha);
	setControllerLabelValue("flowfieldResolution", 			""+gConfig.flowfieldResolution);
	setControllerLabelValue("flowfieldPredictionTime", 		""+gConfig.flowfieldPredictionTime);
	setControllerLabelValue("flowfieldMinVelocity", 		""+gConfig.flowfieldMinVelocity);
	setControllerLabelValue("flowfieldRegularization", 		""+gConfig.flowfieldRegularization);
	setControllerLabelValue("flowfieldSmoothing", 			""+gConfig.flowfieldSmoothing);
	setControllerLabelValue("noiseStrength", 				""+gConfig.noiseStrength);
	setControllerLabelValue("noiseScale", 					""+gConfig.noiseScale);
	setControllerLabelValue("particleViscocity", 			""+gConfig.particleViscocity);
	setControllerLabelValue("particleForceMultiplier", 		""+gConfig.particleForceMultiplier);
	setControllerLabelValue("particleAccelerationFriction",	""+gConfig.particleAccelerationFriction);
	setControllerLabelValue("particleAccelerationLimiter",	""+gConfig.particleAccelerationLimiter);
	setControllerLabelValue("particleNoiseVelocity", 		""+gConfig.particleNoiseVelocity);
	setControllerLabelValue("particleColorScheme", 			""+gConfig.particleColorScheme);
//	setControllerLabelValue("particleColor", 				""+gConfig.echoColor(particleColor));
	setControllerLabelValue("particleAlpha", 				""+gConfig.particleAlpha);
	setControllerLabelValue("particleMaxCount", 			""+gConfig.particleMaxCount);
	setControllerLabelValue("particleGenerateRate", 		""+gConfig.particleGenerateRate);
	setControllerLabelValue("particleGenerateSpread", 		""+gConfig.particleGenerateSpread);
	setControllerLabelValue("particleMinStepSize", 			""+gConfig.particleMinStepSize);
	setControllerLabelValue("particleMaxStepSize", 			""+gConfig.particleMaxStepSize);
	setControllerLabelValue("particleLifetime", 			""+gConfig.particleLifetime);
//	setControllerLabelValue("flowLineColor", 				""+gConfig.echoColor(flowLineColor));
	setControllerLabelValue("flowLineAlpha", 				""+gConfig.flowLineAlpha);
//	setControllerLabelValue("depthImageColor", 				""+gConfig.echoColor(depthImageColor));
}

// Send a key:value pair to the controller with a single float value.
void sendFloatToController(String messageName, float value) {
	OscMessage message = new OscMessage("/"+messageName);
	message.add(value);
	println(">> sending /"+messageName+" "+value);
	sendMessageToController(message);
}

// Send a key:value pair to the controller with a single float value.
void sendIntToController(String messageName, int value) {
	OscMessage message = new OscMessage("/"+messageName);
	message.add(value);
	println(">> sending /"+messageName+" "+value);
	sendMessageToController(message);
}

// Send a key:value:value tuple to the controller with a TWO float values (eg: x/y pad).
void sendFloatsToController(String messageName, float x, float y) {
	OscMessage message = new OscMessage("/"+messageName);
	message.add(x);
	message.add(y);
	println(">> sending /"+messageName+" "+x+" "+y);
	sendMessageToController(message);
}

// Set a label on the controller with the name of label + the value;
void setControllerLabelValue(String labelName, String stringValue) {
	OscMessage message = new OscMessage("/"+labelName+"Label");
	message.add(labelName+"="+stringValue);
//	println(">> sending /"+labelName+" "+labelName+"="+stringValue);
	sendMessageToController(message);
}

// Send a prepared `message` to the OSCTouch controller.
// NOTE: if `gTouchControllerAddress` hasn't been set up, we'll show a warning and bail.
// TODO: support many controllers?
void sendMessageToController(OscMessage message) {
	if (gTouchControllerAddress == null) {
		println("osc.sendMessageToController("+message.addrPattern()+"): gTouchControllerAddress not set up!  Skipping message.");
	} else {
		gTouchController.send(message, gTouchControllerAddress);
	}
}