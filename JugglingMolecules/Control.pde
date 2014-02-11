

////////////////////////////////////////////////////////////
//	OscControl classes for working with TouchOSC
////////////////////////////////////////////////////////////

// A basic 0..1 control, eg: a button or slider.
class OscControl {
	Controller controller;

	public OscControl(Controller _controller, String fieldName) {
		this.controller = _controller;
		this.controller.addControl(fieldName, this);
	}

	// Parse a message and update the config.
	float parseMessage(OscMessage message) {
		float value = controller.getMessageValue(message);
		controller.updateConfigForField(fieldName, value);
		return value;
	}

	// A field from our config has changed -- update the controller.
	void onConfigFieldChanged(float controllerValue) {
		controller.updateConfigForField(fieldName, controllerValue);
	}
}



// OSC X-Y control, mapping two config values to one control.
class OscXYControl extends OscControl {
	String xField;
	String yField;

	public OscXYControl(Controller _controller, String _fieldName, String _xField, String _yField) {
		this.fieldName = _fieldName;
		this.xField 	 = _xField;
		this.yField		 = _yField;

		this.controller = _controller;
		// add to controller under all three fields
		this.controller.addControl(fieldName, this);
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
			float xValue = controller.getFieldValue(firstFieldName);
			float yValue = controller.getFieldValue(secondFieldName);
			controller.sendFloats(fieldName, xValue, yValue);
		} catch (Exception e) {
			println("Error in OscXYControl.onConfigFieldChanged("+fieldName+"): "+e);
		}
	}
}


// A bunch of buttons which act as radio buttons for a set of choices.
class OscChoiceControl extends OscControl {
	int[] choices;

	// Construct with just the number of choices.
	public OscChoiceControl(Controller _controller, String _fieldName, int choiceCount) {
		int[] _choices = int[choiceCount];
		for (int i = 0; i < choiceCount; i++) {
			_choices[i] = i;
		}
		super(_controller, _fieldName, _choices);
	}

	// Construct with an explicit set of choices.
	public OscChoiceControl(Controller _controller, String _fieldName, int[] _choices) {
		this.fieldName = _fieldName;
		this.choices = _choices;

		this.controller = _controller;
		this.controller.addControl(fieldName, this);
		// add to controller under all choice indexes
		for (int i = 0; i < choices.length; i++) {
			name = fieldName + "-" + choices[i];
			this.controller.addControl(name, this);
		}
	}

	// Map the name of the actual button pressed to the right config parameter.
	float parseMessage(OscMessage message) {
		String stringValue = controller.getMessageNameSuffix(message);
		if (stringValue == null) {
			println("Error in OscChoiceControl.parseMessage("+controller.getMessageName(message)"): value must start with '-'");
			return;
		}
		float value = (float) int(stringValue);
		if (value >= choices.length) {
			println("Error in OscChoiceControl.parseMessage("+controller.getMessageName(message)"): returned index of "+value+" which is greater than the number of choices!");
			return;
		}
		controller.updateConfigForField(fieldName, value);
		return value;
	}

	// Turn each button on or off as appropriate when the config value changes.
	void onConfigFieldChanged(float controllerValue) {
		int value = (int)value;
		for (int i = 0; i < choices.length; i++) {
			name = fieldName + "-" + i;
			controller.sendFloat(name, value == i);
		}
	}
}


// A flag is a button which is currently either on or off.
class OscFlagControl extends OscControl {

	// Map the name of the actual button pressed to the right config parameter.
	float parseMessage(OscMessage message) {
		boolean isOn = controller.getMessageValue(message);
		controller.setFlag(fieldName, isOn);
	}

	// Turn each button on or off as appropriate when the config value changes.
	void onConfigFieldChanged(float controllerValue) {
		// NOTE: this should never be called!
	}
}



// Multi-toggle control, MAPPED SO TOP-LEFT ITEM IS 0,0!!!
// NOTE: the default is an NON-EXCLUSIVE control,
//		 meaning that only one value will be selected at a time.
class OscGridControl extends OscControl {
	int rowCount;
	int colCount;

	// Construct with explicit rowCount and colCount.
	public OscGridControl(Controller _controller, String _fieldName, int _rowCount, int _colCount)
	{
		this.rowCount = _rowCount;
		this.colCount = _colCount;

		super(_controller, _fieldName);
	}

	// Map the value of the message to the button that was pressed.
	float parseMessage(OscMessage message) {
		int value = this.index(message);
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
			return = rowCount - int(msgName[2]);
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



// Multi-toggle control, MAPPED SO TOP-LEFT ITEM IS 0,0!!!
// NOTE: the default is an NON-EXCLUSIVE control,
//		 meaning that only one value will be selected at a time.
class OscNonExclusiveGridControl extends OscControl {
	int rowCount;
	int colCount;

	// Construct with explicit rowCount and colCount.
	public OscNonExclusiveGridControl(Controller _controller, String _fieldName, int _rowCount, int _colCount)
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

