

////////////////////////////////////////////////////////////
//	OscControl classes for working with TouchOSC
////////////////////////////////////////////////////////////


////////////////////////
//
//	OscControl class
// 	A basic 0..1 control, eg: a button or slider.
//
//	NOTE: You don't have to create "normal" OscControls manually,
//			they controller will automatically create them for you as needed.
//
////////////////////////
class OscControl {
	OscController controller;
	String fieldName;

	public OscControl() {}

	public OscControl(OscController _controller, String _fieldName) {
		controller = _controller;
		fieldName = _fieldName;
		controller.addControl(fieldName, this);
	}

	// Parse a message and update the config.
	float parseMessage(OscMessage message) {
		float value = controller.getMessageValue(message);
		controller.updateConfigForField(fieldName, value);
		return value;
	}

	// A field from our config has changed -- update the controller.
	void onConfigFieldChanged(float controllerValue) {
		controller.sendFloat(fieldName, controllerValue);
	}
}


////////////////////////
//
//	OscButton class
// 	A button which has an affect on the controller, not necessarily on the config.
//
// 	Implement the action via `yourController.handlespecialAction()`, eg:
//				void handleSpecialAction(OscControl control, String fieldName, float parsedValue, OscMessage message) {
//					if (fieldName.equals("myButton"))	doSomething();
//					else if (fieldName.equals("..."))	...
//					...
//				}
//
// 	NOTE: Osc buttons will send a "1" value when the control goes down, and a "0" value when the control goes up,
//			so you'll likely want to check the parsedValue() and only invoke your action
//			when the value is 1, eg:
//				void handleSpecialAction(OscControl control, String fieldName, float parsedValue, OscMessage message) {
//					if (fieldNameequals("myButton"))	if (parsedValue == 1) doSomething();
//					...
//				}
//
////////////////////////
class OscButton extends OscControl {
	public OscButton(OscController _controller, String _fieldName) {
		super(_controller, _fieldName);
	}

	// When receiving a message from a button, the value will be 1 if pressed, or 0 if released.
	float parseMessage(OscMessage message) {
		float value = controller.getMessageValue(message);
println("button "+fieldName+" pressed with value "+value);
		return value;
	}

	void onConfigFieldChanged(float controllerValue) {
		// NOTE: this should never be called for a button!
	}
}


////////////////////////
//
//	OscFlagControl	class
// 	A flag is a button which toggles a "flag" on the CONTROLLER to be on or off.
//	Access the current state of the flag as    `gController.flagIsSet(fieldName)`
//
////////////////////////
class OscFlagControl extends OscControl {
	public OscFlagControl(OscController _controller, String _fieldName) {
		super(_controller, _fieldName);
	}

	// Map the name of the actual button pressed to the right config parameter.
	float parseMessage(OscMessage message) {
		boolean isOn = (controller.getMessageValue(message) != 0);
		controller.setFlag(fieldName, isOn);
		return (isOn ? 1 : 0);
	}

	// Turn each button on or off as appropriate when the config value changes.
	void onConfigFieldChanged(float controllerValue) {
		// NOTE: this should never be called!
	}
}


////////////////////////
//
//	OscXYControl class
// 	OSC X-Y control, mapping two config values to one control.
//
////////////////////////
class OscXYControl extends OscControl {
	String xField;
	String yField;

	public OscXYControl(OscController _controller, String _fieldName, String _xField, String _yField) {
		super(_controller, _fieldName);

		// remember x and y field names
		this.xField 	 = _xField;
		this.yField		 = _yField;

		// add to controller under x/y fields as well
		this.controller.addControl(xField, this);
		this.controller.addControl(yField, this);
	}

	float parseMessage(OscMessage message) {
		float xValue = controller.getMessageValue(message, 0);
		float yValue = controller.getMessageValue(message, 1);
		controller.updateConfigForField(xField, xValue);
		controller.updateConfigForField(yField, yValue);
		// can't return a sensical value, so forget it
		return -1;
	}

	void onConfigFieldChanged(float controllerValue) {
		try {
			float xValue = controller.getFieldValue(xField);
			float yValue = controller.getFieldValue(yField);
			controller.sendFloats(fieldName, xValue, yValue);
		} catch (Exception e) {
			println("Error in OscXYControl.onConfigFieldChanged("+fieldName+"): "+e);
		}
	}
}


////////////////////////
//
//	OscChoiceControl class
// 	A bunch of buttons which act as radio buttons for a set of choices.
//
////////////////////////
class OscChoiceControl extends OscControl {
	int[] choices;


	// Construct with just the number of choices.
	public OscChoiceControl(OscController _controller, String _fieldName, int choiceCount) {
		super(_controller, _fieldName);
		this.choices = new int[choiceCount];
		for (int i = 0; i < choiceCount; i++) {
			choices[i] = i;
		}
		this.addControlsForChoices();
	}


	// Construct with an explicit set of choices.
	public OscChoiceControl(OscController _controller, String _fieldName, int[] _choices) {
		super(_controller, _fieldName);
		this.choices = _choices;
		this.addControlsForChoices();
	}
	void addControlsForChoices() {
		// add to controller under all choice indexes
		for (int i = 0; i < choices.length; i++) {
			String name = fieldName + "-" + choices[i];
			this.controller.addControl(name, this);
		}
	}

	// Map the name of the actual button pressed to the right config value.
	float parseMessage(OscMessage message) {
		String stringValue = controller.getMessageNameSuffix(message);
		if (stringValue == null) {
			println("Error in OscChoiceControl.parseMessage("+controller.getMessageName(message)+")"
						+"): value must start with '-'");
			return -1;
		}
		return (float) gConfig.setInt(fieldName, stringValue);
	}

	// Turn each button on or off as appropriate when the config value changes.
	void onConfigFieldChanged(float controllerValue) {
		int value = (int)controllerValue;
		for (int i = 0; i < choices.length; i++) {
			String name = fieldName + "-" + choices[i];
			controller.sendBoolean(name, value == choices[i]);
		}
	}
}


////////////////////////
//
//	OscGridControl class
// 	Multi-toggle control, MAPPED SO TOP-LEFT ITEM IS 0,0!!!
//
// 	NOTE: this is an EXCLUSIVE control, meaning that only one value will be selected at a time.
//			See OscMultiGridControl for a grid which shows multiple values at once.
//
////////////////////////
class OscGridControl extends OscControl {
	int rowCount;
	int colCount;

	// Construct with explicit rowCount and colCount.
	public OscGridControl(OscController _controller, String _fieldName, int _rowCount, int _colCount) {
		super(_controller, _fieldName);

		this.rowCount = _rowCount;
		this.colCount = _colCount;
	}

	// Map the value of the message to the button that was pressed.
	float parseMessage(OscMessage message) {
		int value = this.index(message);
		gConfig.setField(fieldName, ""+value);
		return (float) value;
	}

	// TODO ???
	void onConfigFieldChanged(float controllerValue) {}


	// Max number of items we're expecting.
	int itemCount() {
		return (rowCount+1) * colCount;
	}

	// Given a message, return the (top-left-based) row it corresponds to.
	// Returns -1 if message doesn't conform to expected format.
	int row(OscMessage message) {
		try {
			String[] msgName = message.addrPattern().split("/");
			// get the row from bit 2 of the message
			//	and then invert it's row number
			//	(since TouchOsc is bottom-based and we're top-based)
			return rowCount - int(msgName[2]);
		} catch (Exception e) {
			return -1;
		}
	}

	// Given a message, return the (top-left-based) row it corresponds to.
	// Returns -1 if message doesn't conform to expected format.
	int col(OscMessage message) {
		try {
			String[] msgName = message.addrPattern().split("/");
			// get the row from bit 2 of the message
			//	and then invert it's row number
			//	(since TouchOsc is bottom-based and we're top-based)
			return int(msgName[3]) - 1;
		} catch (Exception e) {
			return -1;
		}
	}


	// Given a message, return the index which it corresponds to.
	// Returns -1 if message doesn't conform to expected format.
	int index(OscMessage message) {
		int row = this.row(message);
		int col = this.col(message);
		if (row == -1 || col == -1) return -1;
		return (row * colCount) + col;
	}
}
/*

////////////////////////
//
//	OscMultiGridControl class
//	Multi-toggle control which deals with a large set of non-exclusive values.
//
////////////////////////
class OscMultiGridControl extends OscControl {
	int rowCount;
	int colCount;

	// Construct with explicit rowCount and colCount.
	public OscMultiGridControl(OscController _controller, String _fieldName, int _rowCount, int _colCount)
	{
		super(_controller, _fieldName);
	}

	// Map the value of the message to the button that was pressed.
	float parseMessage(OscMessage message) {
		int value = this.index(message);
		return (float) value;
	}

	// TODO ???
	void onConfigFieldChanged(float controllerValue) {}

	// Send a message which will update a non-exclusive Grid which a list of boolean states.
	void updateStates(boolean[] states) {
		if (this.exlusive) {
			println(fieldName+".updateStates(): called on an exclusive control");
			return;
		}
		if (states.length != this.itemCount()) {
			println(fieldName+".updateStates(): state array count is "+states.length+"; expecting "+this.itemCount());
			return;
		}
		OscMessage message = new OscMessage("/"+fieldName);
		for (int col = 0; col < colCount; col++) {
			for (int row = rowCount; row >= 0; row--) {
				int cell = (row*colCount) + col;
				boolean exists = states[cell];
				if (exists) {
					message.add(1);
				} else {
					message.add(0);
				}
			}
		}
		controller.sendMessage(message);
	}

}

*/