

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
	float parseMessage(OscMessage message) throws Exception {
		float value = controller.getMessageValue(message);
		controller.updateConfigForField(fieldName, value);
		return value;
	}

	// A field from our config has changed -- update the controller.
	void onConfigFieldChanged(float controllerValue) {
		controller.send(fieldName, controllerValue);
	}
}


////////////////////////
//
//	OscButton class
// 	A button which has an affect on the controller, not necessarily on the config.
//
// 	Implement the action in your controller as "onButtonName", eg:
//				public YourController() {
//					...
//					new OscButton(this, "myButton");
//					...
//				}
//				...
//				void onMyButton(OscControl control, OscMessage message) {
//					... do your thing here! ...
//				}
//
// 	NOTE: TouchOSC will send an event with value "1" for finger down, and "0" for finger up.
//		  Normally we eat the "down" event and just send the "up" event (as you don't generally need to handle both).
//		  If you *DO* want to handle both, use the constructor:
//				new OscButton(controller, "myButton", false);
//
////////////////////////
class OscButton extends OscControl {
	boolean ignoreTouchDown = true;

	public OscButton(OscController _controller, String _fieldName) {
		super(_controller, _fieldName);
	}

	public OscButton(OscController _controller, String _fieldName, boolean _ignoreTouchDown) {
		super(_controller, _fieldName);
		this.ignoreTouchDown = _ignoreTouchDown;
	}

	// When receiving a message from a button, the value will be 1 if pressed, or 0 if released.
	float parseMessage(OscMessage message) throws Exception{
		float value = controller.getMessageValue(message);
		if (this.ignoreTouchDown && value == 1) {
			throw new Exception("OscButton('"+fieldName+"): ignoring touch down");
		}
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
		// can't return a sensical value, so return -1
		return -1;
	}

	void onConfigFieldChanged(float controllerValue) {
		try {
			float xValue = controller.getFieldValue(xField);
			float yValue = controller.getFieldValue(yField);
			controller.send(fieldName, xValue, yValue);
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
	float parseMessage(OscMessage message) throws Exception {
		String stringValue = controller.getMessageNameSuffix(message);
		if (stringValue == null) {
			String name = controller.getMessageName(message);
			println("Error in OscChoiceControl.parseMessage("+name+"): "
						+"value must start with '-'");
			throw new Exception("OscChoiceControl('"+name+"): can't parse value out of message name");
		}
		return (float) gConfig.setInt(fieldName, stringValue);
	}

	// Turn each button on or off as appropriate when the config value changes.
	void onConfigFieldChanged(float controllerValue) {
		int value = (int)controllerValue;
		for (int i = 0; i < choices.length; i++) {
			String name = fieldName + "-" + choices[i];
			controller.send(name, value == choices[i]);
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
//	NOTE: You MUST make the corresponding TouchOSC MultiToggle:
//				[ X ] Local feedback off
//				[ X ] Exclusive mode
//		  If you don't, you'll get endless loop behavior sometimes.  :-(
//
//	NOTE: for config property "foo", if you DO NOT create MIN_foo and MAX_foo config constants,
//			the value coming in to onConfigFieldChanged will be the actual value of "foo".
//			If you DO set MIN_xxx and/or MAX_xxx, the value will be foo normalized to 0..1.
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
	float parseMessage(OscMessage message) throws Exception{
		// ignore touch up events
		if (controller.getMessageValue(message) == 0) {
			throw new Exception("OscGridControl("+fieldName+"): Ignore grid touch up events");
		}

		// pull our zero-based index out of the message and make sure it's valid
		int index = this.index(message);
		if (index == -1 || index >= this.itemCount()) {
			throw new Exception("OscGridControl("+fieldName+"): can't parse valid index out of message");
		}
		gConfig.setField(fieldName, ""+index);
		return (float) index;
	}

	// Map the controller value to show the selected row/column.
	void onConfigFieldChanged(float controllerValue) {
		int value = (int)controllerValue;
		value = constrain(value, 0, this.itemCount());

		// convert to our 0-based, top-left rows
		int row = (int) value / colCount;
		int col = (int) value % colCount;

		// send to the controller w/1-based, bottom-left rows
		int controllerRow = rowCount - row;
		int controllerCol = col + 1;
//println("========> "+controllerRow + " " + controllerCol + " " + 1);
		controller.send(fieldName, controllerRow, controllerCol, 1);
	}


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
	public OscMultiGridControl(OscController _controller, String _fieldName, int _rowCount, int _colCount) {
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
		for (int row = rowCount-1; row >= 0; row--) {
			for (int col = 0; col < colCount; col++) {
				int index = (row*colCount) + col;
//				println(index+":"+(states[index]));
				message.add(states[index] ? 1 : 0);
			}
		}
		controller.send(message);
	}

}

*/