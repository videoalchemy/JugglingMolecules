/*keep track of the changes I made::

color changes happended in this function:	public void updateAndRenderGL() {

and here:
public void updateAndRenderGL() {

//----------------------------------------------------------------bring in the TOUCH OSC variables
		viscosity = particleViscocityOSC;


*/


// create function to recv and parse oscP5 messages
void oscEvent(OscMessage message) {
	// get the name of the control being affected, minus the initial slash
	String control = message.addrPattern().substring(1);
	// all controls return a float from 0..1, some return 2 floats (handled specially below)
	float value = message.get(0).floatValue();

	// if this is the first message we've received, gTouchControllerAddress will be empty.
	//	set it so we can communicate back with this device.
	if (gTouchControllerAddress == null) {
		println("oscEvent(): First message received -- setting gTouchControllerAddress to "+message.address() + ":" + message.port());
		gTouchControllerAddress = new NetAddress(message.address(), message.port());
	}

	String debugMessage = "oscEvent(): " + control + " = " + value;

	// "particleGenerate" x/y pad
	if (control == "particleGenerate") {
		// x-y pad which returns 2 values
		float otherValue = message.get(1).floatValue();
		debugMessage += ":"+otherValue;
		gConfig.applyConfigValue("particleGenerateRate", value);
		gConfig.applyConfigValue("particleGenerateSpread", otherValue);
	}
	// TODO: other x/y pad
	else if (control == "noise") {
		// x-y pad which returns 2 values
		float otherValue = message.get(1).floatValue();
		debugMessage += ":"+otherValue;
		gConfig.applyConfigValue("noiseStrength", value);
		gConfig.applyConfigValue("noiseScale", otherValue);
	}

	// particleColorScheme toggles
	else if (control == "particleColorScheme-0")	gConfig.applyConfigValue("particleColorScheme", 0);
	else if (control == "particleColorScheme-1")	gConfig.applyConfigValue("particleColorScheme", 1);
	else if (control == "particleColorScheme-2")	gConfig.applyConfigValue("particleColorScheme", 2);
	else if (control == "particleColorScheme-3")	gConfig.applyConfigValue("particleColorScheme", 3);

	// depthImageBlendMode toggles
	else if (control == "depthImageBlendMode-0")	gConfig.applyConfigValue("depthImageBlendMode", DEPTH_IMAGE_BLEND_MODE_0);
	else if (control == "depthImageBlendMode-1")	gConfig.applyConfigValue("depthImageBlendMode", DEPTH_IMAGE_BLEND_MODE_1);
	else if (control == "depthImageBlendMode-2")	gConfig.applyConfigValue("depthImageBlendMode", DEPTH_IMAGE_BLEND_MODE_2);
	else if (control == "depthImageBlendMode-3")	gConfig.applyConfigValue("depthImageBlendMode", DEPTH_IMAGE_BLEND_MODE_3);

	// all other controls have a single value!
	else {
		gConfig.applyConfigValue(control, value);
	}

	println(debugMessage);
}


void outputStateToOSCController() {
	// get output states as a JSON blob, WITHOUT the _MIN and _MAX values
	JSONObject json = gConfig.toJSON(false);

	// TODO: iterate over keys
	Iterator keyIterator = json.keyIterator();
	while (keyIterator.hasNext()) {
		String keyName 	= (String)keyIterator.next();
		float  value 	= json.getFloat(keyName);

		// "particleGenerate" x/y pad
		if 		(keyName == "particleGenerateRate") sendFloatsToController("particleGenerate", gConfig.particleGenerateRate, gConfig.particleGenerateSpread);
		else if (keyName == "particleGenerateSpeed") ;	// NOTE: sending value as "particleGenerate"

		// "noise" x/y pad
		else if (keyName == "noiseStrength") sendFloatsToController("noise", gConfig.noiseStrength, gConfig.noiseScale);
		else if (keyName == "noiseScale") ;	// NOTE: sending value as "noise"

		// particleColorScheme toggles
		else if (keyName == "particleColorScheme")	{
			sendFloatToController("particleColorScheme-0", (value == 0 ? 1 : 0));
			sendFloatToController("particleColorScheme-1", (value == 1 ? 1 : 0));
			sendFloatToController("particleColorScheme-2", (value == 2 ? 1 : 0));
			sendFloatToController("particleColorScheme-3", (value == 3 ? 1 : 0));
		}

		// depthImageBlendMode toggles
		else if (keyName == "depthImageBlendMode") {
			sendFloatToController("depthImageBlendMode-0", (value == DEPTH_IMAGE_BLEND_MODE_0 ? 1 : 0));
			sendFloatToController("depthImageBlendMode-1", (value == DEPTH_IMAGE_BLEND_MODE_1 ? 1 : 0));
			sendFloatToController("depthImageBlendMode-2", (value == DEPTH_IMAGE_BLEND_MODE_2 ? 1 : 0));
			sendFloatToController("depthImageBlendMode-3", (value == DEPTH_IMAGE_BLEND_MODE_3 ? 1 : 0));
		}

		// all other controls go over as normal floats
		else {
			sendFloatToController(keyName, value);
		}
	}
}

// Send a key:value pair to the controller with a single float value.
void sendFloatToController(String messageName, float value) {
	OscMessage message = new OscMessage("/"+messageName);
	message.add(value);
	sendMessageToController(message);
}

// Send a key:value:value tuple to the controller with a TWO float values (eg: x/y pad).
void sendFloatsToController(String messageName, float x, float y) {
	OscMessage message = new OscMessage("/"+messageName);
	message.add(x);
	message.add(y);
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