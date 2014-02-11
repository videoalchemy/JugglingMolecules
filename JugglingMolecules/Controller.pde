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

	// A config field has changed.
	// Update the controller.
	void onConfigFieldChanged(String fieldName, float controllerValue, String typeName, String valueLabel) {}

	// Return the current SCALED value of our config object from just a field name.
	float getFieldValue(String fieldName) throws Exception {
		return gConfig.valueForController(fieldName, this.minValue, this.maxValue);
	};

}

class TouchOscController extends Controller {
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

	public TouchOscController() {
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
		if (!control) {
			control = this.makeBasicControl(this, fieldName);
		}
		return control
	}

	// Do we have an existing control for the given field name?
	void controlExists(String fieldName) {
		OscControl control = this.controls.get(fieldName);
		return (control != null);
	}

	// Make a generic control for the specified field.
	OscControl makeBasicControl(String fieldName) {
		return new OscControl(this, fieldName);
	}




////////////////////////////////////////////////////////////
//	Deal with changes to the current configuration.
//	We delegate down to OscControl objects to do the actual work.
////////////////////////////////////////////////////////////

	// A configuration field has changed.  Tell the controller.
	void onConfigFieldChanged(String fieldName, float controllerValue, String typeName, String valueLabel) {
		// update the label
		this.sendLabel(fieldName, valueLabel);

		OscControl control = this.getOrCreateControl(fieldName);
		control.onConfigFieldChanged(controllerValue);
	}



////////////////////////////////////////////////////////////
//	Parse messages from the controller, which generally update our config.
//	We delegate down to OscControl objects to do the actual work.
////////////////////////////////////////////////////////////

	// A configuration field has changed.  Tell the controller.
	void parseMessage(OscMessage message) {
		// get the name of the field being affected, minus the initial slash
		String fieldName = this.getMessageNamePrefix(message);

		// lop off anything after a "-"
		int index = fieldName.indexOf("-");
		if (index > -1) fieldName = fieldName.substr(0, index);

		OscControl control = this.getOrCreateControl(fieldName);
		float parsedValue = control.parseMessage(message);

		// handle any special actions not covered by our normal controls
		this.handleSpecialAction(control, parsedValue, message);
	}

	// Handle a special action from some field being pressed.
	// Override this to do special things when, eg, specific buttons are pressed.
	void handleSpecialAction(Control control, OscMessage message) {
		return;
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
		// lop off everything after "-"
		int index = fieldName.indexOf("-");
		if (index > -1) fieldName = fieldName.substr(0, index);
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
		return fieldName.substr(index+1);
	}


	// Return the first "value" of a message as a float.
	float getMessageValue(OscMessage message) {
		return this.getMessageValue(message, 0);
	}

	// Return an arbitrarily-indexed "value" of a message as a float.
	float getMessageValue(OscMessage message, int valueIndex) {
		return message.get(valueIndex).floatValue();
	}


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



////////////////////////////////////////////////////////////
//	Flags (eg: buttons which are held down temporarily)
////////////////////////////////////////////////////////////
	void setFlag(String fieldName, boolean isOn) {
		if (isOn) 	this.flags.set(fieldName, true);
		else		this.flags.remove(fieldName);
	}

	void flagIsSet(String fieldName) {
		return (this.flags.get(fieldName) == true);
	}



////////////////////////////////////////////////////////////
//	Send messages to all known controllers.
////////////////////////////////////////////////////////////

	// Send a prepared `message` to the OSCTouch controller.
	// NOTE: if `gOscMasterAddress` hasn't been set up, we'll show a warning and bail.
	// TODO: support many controllers?
	void sendMessage(OscMessage message) {
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

	void sendBoolean(String fieldName, boolean value) {
		println("  setting controller "+fieldName+" to "+value);
		OscMessage message = new OscMessage("/"+fieldName);
		message.add(value);
		this.sendMessage(message);
	}

	void sendInt(String fieldName, int value) {
		println("  setting controller "+fieldName+" to "+value);
		OscMessage message = new OscMessage("/"+fieldName);
		message.add(value);
		this.sendMessage(message);
	}

	void sendFloat(String fieldName, float value) {
		println("  setting controller "+fieldName+" to "+value);
		OscMessage message = new OscMessage("/"+fieldName);
		message.add(value);
		this.sendMessage(message);
	}

	void sendFloat(String fieldName, boolean value) {
		float floatValue = (boolean ? 1 : 0)
		println("  setting controller "+fieldName+" to "+floatValue);
		OscMessage message = new OscMessage("/"+fieldName);
		message.add(floatValue);
		this.sendMessage(message);
	}


	void sendFloats(String fieldName, float value1, float value2) {
		println("  setting controller "+fieldName+" to "+value1+" "+value2);
		OscMessage message = new OscMessage("/"+fieldName);
		message.add(value1);
		message.add(value2);
		this.sendMessage(message);
	}

	// Send a series of messages for different choice values, from 0 - maxValue.
	void sendChoice(String fieldName, float value, int maxValue) {
		for (int i = 0; i <= maxValue; i++) {
			this.sendFloat(fieldName+"-"+i, ((int)value == i ? 1 : 0));
		}
		this.sendFloat(fieldName, value);
	}

	// Send a series of messages for different choice values,
	//	with choices as an array of ints.
	void sendChoice(String fieldName, float value, int[] choices) {
		for (int i : choices) {
			this.sendFloat(fieldName+"-"+i, ((int)value == i ? 1 : 0));
		}
		this.sendFloat(fieldName, value);
	}

	void togglePresetButton(String presetName, boolean turnOn) {
		this.sendInt("/"+presetName, turnOn ? 1 : 0);
//		this.sendInt("/Load/"+presetName, turnOn ? 1 : 0);
//		this.sendInt("/Save/"+presetName, turnOn ? 1 : 0);
	}

	void sendLabel(String fieldName, String value) {
		println("  sending label "+fieldName+"="+value);
		OscMessage message = new OscMessage("/"+fieldName+"Label");
		message.add(fieldName+"="+value);
		this.sendMessage(message);
	}

	// Set color of a control.
	// Valid colors are:
	//		"red", "green", "blue", "yellow", "purple",
	//		"gray", "orange", "brown", "pink"
	void setColor(String fieldName, String value) {
		OscMessage message = new OscMessage("/"+fieldName+"/color");
		message.add(value);
		this.sendMessage(message);
	}

	// Show a named control.
	void showControl(String fieldName) {
		OscMessage message = new OscMessage("/"+fieldName+"/visible");
		message.add(1);
		this.sendMessage(message);
	}

	// Hide a named control.
	void hideControl(String fieldName) {
		OscMessage message = new OscMessage("/"+fieldName+"/visible");
		message.add(0);
		this.sendMessage(message);
	}

	boolean controlIsOn

////////////////////////////////////////////////////////////
//	Talk-back to the user
////////////////////////////////////////////////////////////
	void say(String msgText) {
		println("  saying "+msgText);
		OscMessage message = new OscMessage("/message");
		message.add(msgText);
		this.sendMessage(message);
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
	},


}
