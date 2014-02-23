/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2014 Jason Stephens, Owen Williams & VideoAlchemy Collective
 *
 *	See `credits.txt` for base work and shouts out.
 *	Published under CC Attrbution-ShareAlike 3.0 (CC BY-SA 3.0)
 *		            http://creativecommons.org/licenses/by-sa/3.0/
 *******************************************************************/

////////////////////////////////////////////////////////////
//  Simple Controller class, to go with Config.
////////////////////////////////////////////////////////////

import oscP5.*;	// TouchOSC
import netP5.*;

class Controller {
	// minimum and maximum values for all of our controls.
	float minValue = 0.0f;
	float maxValue = 1.0f;

	// A config field has changed to a new float.
	// Update the controller.
	void onConfigFieldChanged(String fieldName, float controllerValue, String typeName, String valueLabel) {}

	// A config field has changed to a new color.
	// Update the controller.
	void onConfigColorChanged(String fieldName, color _color, String valueLabel) {}

	// Return the current SCALED value of our config object from just a field name.
	float getFieldValue(String fieldName) throws Exception {
		return gConfig.valueForController(fieldName, this.minValue, this.maxValue);
	};

}

class OscController extends Controller {
	OscP5 oscMessenger;

	ArrayList<NetAddress> outboundAddresses;

	// minimum and maximum values for all of our controls.
	float minValue = 0.0f;
	float maxValue = 1.0f;

	// Map of controls we support.
	HashMap<String, OscControl> controls;

	// Map of flags which are turned on/off by FlagControls.
	HashMap<String, Boolean> flags;

////////////////////////////////////////////////////////////
//	Initial setup.
////////////////////////////////////////////////////////////

	public OscController() {
		this.controls = new HashMap<String, OscControl>();
		this.flags = new HashMap<String, Boolean>();
		outboundAddresses = 	new ArrayList<NetAddress>();
	}

	// create function to recv and parse oscP5 messages
	void oscEvent(OscMessage message) {
		// Add this message as a controller we'll talk to
		//	by remembering its outbound address.
		this.rememberOutboundAddress(message.netAddress());

		try {
			// update the configuration
			this.parseMessage(message);
		} catch (Exception e) {}
	}


	// Add an outbound address to the list of addresses that we talk to.
	// OK to call this more than once with the same address.
	void rememberOutboundAddress(NetAddress inboundAddress) {
		for (NetAddress address : this.outboundAddresses) {
			if (address.address().equals(inboundAddress.address())) return;
		}
		println("******* ADDING ADDRESS "+inboundAddress);
		// convert to the OUTBOUND address
		NetAddress outboundAddress = new NetAddress(inboundAddress.address(), gConfig.setupOscOutboundPort);
		this.outboundAddresses.add(outboundAddress);
		// tell the config to update all controllers (including us) with the current values
		gConfig.syncControllers();
	}



	// Add a named OscControl.
	void addControl(String fieldName, OscControl control) {
		this.controls.put(fieldName, control);
	}

	// Return a named control.
	// Returns null if no control with this name defined.
	OscControl getControl(String fieldName) {
		return this.controls.get(fieldName);
	}

	// Return a named control, or create a simple "OscControl" instance if none found.
	OscControl getOrCreateControl(String fieldName) {
		OscControl control = this.getControl(fieldName);
		if (control == null) {
			control = this.makeBasicControl(fieldName);
		}
		return control;
	}

	// Do we have an existing control for the given field name?
	boolean controlExists(String fieldName) {
		OscControl control = this.controls.get(fieldName);
		return (control != null);
	}

	// Make a generic control for the specified field.
	OscControl makeBasicControl(String fieldName) {
		if (fieldName.endsWith("Color")) {
			return new OscColorControl(this, fieldName);
		} else {
			return new OscControl(this, fieldName);
		}
	}




////////////////////////////////////////////////////////////
//	Deal with changes to the current configuration.
//	We delegate down to OscControl objects to do the actual work.
////////////////////////////////////////////////////////////

	// A configuration field has changed.  Tell the controller by sending the value through the appropriate control.
	void onConfigFieldChanged(String fieldName, float controllerValue, String typeName, String valueLabel) {
		// update the label
		this.sendLabel(fieldName, valueLabel);

		OscControl control = this.getOrCreateControl(fieldName);
		control.onConfigFieldChanged(controllerValue);
	}

	void onConfigColorChanged(String fieldName, color _color, String valueLabel) {
		// update the label
		this.sendLabel(fieldName, valueLabel);

		OscControl control = this.getOrCreateControl(fieldName);
		control.onConfigColorChanged(_color);
	}




////////////////////////////////////////////////////////////
//	Parse messages from the controller, which generally update our config.
//	We delegate down to OscControl objects to do the actual work.
////////////////////////////////////////////////////////////

	// A configuration field has changed.  Tell the controller.
	void parseMessage(OscMessage message) {
		// get the name of the field being affected, minus the initial slash
		String fieldName = this.getMessageNamePrefix(message);

		OscControl control = this.getOrCreateControl(fieldName);

		// have the control attempt to parse the value
		// if it's not valid, or it's not something we want to deal with,
		//	the control can throw an exception and we'll stop processing.
		float parsedValue;
		try {
			parsedValue = control.parseMessage(message);
		} catch (Exception e) {
//println(e);
			return;
		}

		// Use reflection to call an "onXxx" method if defined
		Class myClass = this.getClass();
		Class[] args  = new Class[] { OscControl.class, OscMessage.class };
		String handlerName = "on" + fieldName.substring(0,1).toUpperCase()
								  + fieldName.substring(1);
		try {
			Method method = myClass.getMethod(handlerName, args);
			method.invoke(this, control, message);
		} catch (NoSuchMethodException e) {
			// if we can't find a method, forget it
		} catch (Exception e) {
			println("--------------------------------------------------------");
			println("parseMessage("+fieldName+"): Error invoking controller."+handlerName+"()");
			println(e);
			println("--------------------------------------------------------");
		}

/*
		// handle any special actions not covered by our normal controls
		this.handleSpecialAction(control, control.fieldName, parsedValue, message);
*/
		// if we're dealing with a setup field, save the setup automatically
		if (gConfig.isSetupField(fieldName)) {
			gConfig.saveSetup();
		}
	}


	// Update the configuration for a particular field.
	// Value is the float value we got from OSC.
	void updateConfigForField(String fieldName, float value) {
		gConfig.setFromController(fieldName, value, this.minValue, this.maxValue);
	}


	// Return the name of a message without the leading "/"
	String getMessageName(OscMessage message) {
		return message.addrPattern().substring(1);
	}

	// Return the name of a message BEFORE the "-"
	String getMessageNamePrefix(OscMessage message) {
		// field name minus initial slash
		String fieldName = this.getMessageName(message);

		// for "multi-toggle" controls, lop off everything after "/"
		int index = fieldName.indexOf("/");
		if (index > -1) fieldName = fieldName.substring(0, index);

		// for "composite" controls, lop off everything after "-"
		index = fieldName.indexOf("-");
		if (index > -1) fieldName = fieldName.substring(0, index);

		// lop off
		return fieldName;
	}

	// Return the name of the message AFTER the "-".
	// Returns null if no "-" in the name.
	String getMessageNameSuffix(OscMessage message) {
		// field name minus initial slash
		String fieldName = this.getMessageName(message);
		// is there a "-" ?
		int index = fieldName.indexOf("-");
		// if no, return null
		if (index == -1) return null;
		// return the bit after the "-"
		return fieldName.substring(index+1);
	}


	// Return the first "value" of a message as a float.
	float getMessageValue(OscMessage message) {
		return this.getMessageValue(message, 0);
	}

	// Return an arbitrarily-indexed "value" of a message as a float.
	float getMessageValue(OscMessage message, int valueIndex) {
		return message.get(valueIndex).floatValue();
	}

/*
	// Return the first "value" of a message as an int.
	int getMessageValue(OscMessage message) {
		return this.getMessageValue(message, 0);
	}

	// Return an arbitrarily-indexed "value" of a message as an int.
	int getMessageValue(OscMessage message, int valueIndex) {
		return (int) message.get(valueIndex).floatValue();
	}

	// Return the first "value" of a message as a boolean.
	boolean getMessageValue(OscMessage message) {
		return this.getMessageValue(message, 0);
	}

	// Return an arbitrarily-indexed "value" of a message as a boolean.
	boolean getMessageValue(OscMessage message, int valueIndex) {
		return (message.get(valueIndex).floatValue() != 0);
	}
*/


////////////////////////////////////////////////////////////
//	Flags (eg: buttons which are held down temporarily)
////////////////////////////////////////////////////////////
	void setFlag(String fieldName, boolean isOn) {
		if (isOn) 	this.flags.put(fieldName, true);
		else		this.flags.remove(fieldName);
	}

	boolean flagIsSet(String fieldName) {
		return (this.flags.get(fieldName) == true);
	}



////////////////////////////////////////////////////////////
//	Send messages to all known controllers.
////////////////////////////////////////////////////////////

	// Send a prepared `message` to the OSCTouch controller.
	// NOTE: if `gOscMasterAddress` hasn't been set up, we'll show a warning and bail.
	// TODO: support many controllers?
	void send(OscMessage message) {
		if (this.outboundAddresses.size() == 0) {
			println("osc.sendMessageToController("+message.addrPattern()+"): controller.outboundAddress not set up!  Skipping message.");
		} else {
			for (NetAddress outboundAddress : this.outboundAddresses) {
				try {
					gOscMaster.send(message, outboundAddress);
				} catch (Exception e) {
					println("Exception sending message "+message.addrPattern()+": "+e);
				}
			}
		}
	}

	void send(String fieldName, boolean value) {
		println("  sending boolean "+fieldName+"="+value);
		OscMessage message = new OscMessage("/"+fieldName);
		message.add(value);
		this.send(message);
	}

	void send(String fieldName, int value) {
		println("  sending int "+fieldName+"="+value);
		OscMessage message = new OscMessage("/"+fieldName);
		message.add(value);
		this.send(message);
	}

	void send(String fieldName, int value1, int value2) {
		println("  sending ints "+fieldName+"="+value1+" "+value2);
		OscMessage message = new OscMessage("/"+fieldName);
		message.add(value1);
		message.add(value2);
		this.send(message);
	}

	void send(String fieldName, int value1, int value2, int value3) {
		println("  sending ints "+fieldName+"="+value1+" "+value2+" "+value3);
		OscMessage message = new OscMessage("/"+fieldName);
		message.add(value1);
		message.add(value2);
		message.add(value3);
		this.send(message);
	}

	void send(String fieldName, float value) {
		println("  sending float "+fieldName+"="+value);
		OscMessage message = new OscMessage("/"+fieldName);
		message.add(value);
		this.send(message);
	}

	void send(String fieldName, float value1, float value2) {
		println("  sending floats "+fieldName+"="+value1+" "+value2);
		OscMessage message = new OscMessage("/"+fieldName);
		message.add(value1);
		message.add(value2);
		this.send(message);
	}

	void send(String fieldName, float value1, float value2, float value3) {
		println("  sending floats "+fieldName+"="+value1+" "+value2+" "+value3);
		OscMessage message = new OscMessage("/"+fieldName);
		message.add(value1);
		message.add(value2);
		message.add(value3);
		this.send(message);
	}


	void togglePresetButton(String presetName, boolean turnOn) {
		this.send("/"+presetName, turnOn ? 1 : 0);
//		this.send("/Load/"+presetName, turnOn ? 1 : 0);
//		this.send("/Save/"+presetName, turnOn ? 1 : 0);
	}

	void sendLabel(String fieldName, String value) {
		println("  sending label "+fieldName+"="+value);
		OscMessage message = new OscMessage("/"+fieldName+"Label");
		message.add(fieldName+"="+value);
		this.send(message);
	}

	// Set color of a control.
	// Valid colors are:
	//		"red", "green", "blue", "yellow", "purple",
	//		"gray", "orange", "brown", "pink"
	void setColor(String fieldName, String value) {
		OscMessage message = new OscMessage("/"+fieldName+"/color");
		message.add(value);
		this.send(message);
	}

	// Show a named control.
	void showControl(String fieldName) {
		OscMessage message = new OscMessage("/"+fieldName+"/visible");
		message.add(1);
		this.send(message);
	}

	// Hide a named control.
	void hideControl(String fieldName) {
		OscMessage message = new OscMessage("/"+fieldName+"/visible");
		message.add(0);
		this.send(message);
	}



////////////////////////////////////////////////////////////
//	Talk-back to the user
////////////////////////////////////////////////////////////
	void say(String msgText) {
		println("  saying "+msgText);
		OscMessage message = new OscMessage("/message");
		message.add(msgText);
		this.send(message);
	}


////////////////////////////////////////////////////////////
//	Exotic controller types
////////////////////////////////////////////////////////////

	// Return the row associated with an Osc Multi-Toggle control.
	// Throws an exception if the message doesn't conform to your expectations.
	// NOTE: Osc Multi-toggles have the BOTTOM row at 0, and rows start with 1.
	//		 So if you want to convert to TOP-based, starting at 0, do:
	//			`int row = ROWCOUNT - (controller.getMultiToggleRow(message) - 1);`
	//		 or use:
	//			`int row = controller.getZeroBasedRow(message, ROWCOUNT);`
//UNTESTED
	int getMultiToggleRow(OscMessage message) throws Exception {
		String[] msgName = message.addrPattern().split("/");
		return int(msgName[2]);
	}

	// Return the column associated with an Osc Multi-Toggle control.
	// Throws an exception if the message doesn't conform to your expectations.
	// NOTE: Osc Multi-toggles have the LEFT-MOST row at 1.
	//		 So if you want to convert to LEFT-based, starting at 0, do:
	//			`int row = COLCOUNT - (controller.getMultiToggleColumn(message) - 1);`
	//		 or use:
	//			`int row = controller.getZeroBasedColumn(message, COLCOUNT);`
//UNTESTED
	int getMultiToggleColumn(OscMessage message) throws Exception {
		String[] msgName = message.addrPattern().split("/");
		return int(msgName[3]);
	}


	// Return the index which corresponds to the row+column in a Multi-Toggle control.
	// NOTE: this is Top-Left biased, As God Intended™.
	int getMultiToggleIndex(OscMessage message, int maxRows, int maxCols) {
		int col = this.getZeroBasedColumn(message, maxCols);
		int row = this.getZeroBasedRow(message, maxRows);
		return (row * maxCols) + col;
	}

	// Return the zero-based, top-left-counting row associated with an Osc Multi-Toggle control.
	// Returns `-1` on exception.
	int getZeroBasedRow(OscMessage message, int rowCount) {
		try {
			int bottomBasedRow = this.getMultiToggleRow(message);
			return rowCount - bottomBasedRow;
		} catch (Exception e) {
			return -1;
		}
	}

	// Return the zero-based, top-left-counting column associated with an Osc Multi-Toggle control.
	// Returns `-1` on exception.
	int getZeroBasedColumn(OscMessage message, int ColCount) {
		try {
			int bottomBasedCol = this.getMultiToggleColumn(message);
			return (bottomBasedCol - 1);
		} catch (Exception e) {
			return -1;
		}
	}


}
