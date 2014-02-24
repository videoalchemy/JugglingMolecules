/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2014 Jason Stephens, Owen Williams & VideoAlchemy Collective
 *
 *	See `credits.txt` for base work and shouts out.
 *	Published under CC Attrbution-ShareAlike 3.0 (CC BY-SA 3.0)
 *		            http://creativecommons.org/licenses/by-sa/3.0/
 *******************************************************************/

////////////////////////////////////////////////////////////
//  Configuration base class.
//
//  We can load and save these to disk to restore "interesting" states to play with.
//
//	Configurations are stored in ".tsv" files in Tab-Separated-Value format.
//		We have a header row as 		type<TAB>field<TAB>value
//		and then each row of data is 	<type><TAB><field><TAB><value>
//										<type><TAB><field><TAB><value>
//
//	We can auto-parse these config files using reflection.
//		TODOC... more details
//
////////////////////////////////////////////////////////////

//import java.lang.reflect.Field;
import java.lang.reflect.*;


// Internal "logical data types" we understand.
static final int _UNKNOWN_TYPE	= 0;
static final int _INT_TYPE 		= 1;
static final int _FLOAT_TYPE 	= 2;
static final int _BOOLEAN_TYPE 	= 3;
static final int _COLOR_TYPE 	= 4;
static final int _STRING_TYPE 	= 5;



class Config {
	// Set to true to print debugging information if something goes wrong
	//	which would normally be swallowed silently.
	boolean debugging = true;

	String restartConfigFile = "RESTART";

	// Default config file to load if "RESTART" config not found.
	String defaultConfigFile = "PS01";

	// Name of the last config file we loaded.
	String lastConfigFileSaved;

	// constructor
	public Config() {
println("CONFIG INIT");
		this.controllers = new ArrayList<OscController>();

		// Set up our file existance map.
		this.initConfigExistsMap();
	}

////////////////////////////////////////////////////////////
//	Controllers that we're aware of.
////////////////////////////////////////////////////////////
	ArrayList<OscController> controllers;

////////////////////////////////////////////////////////////
//	Sets of fields that we manage
////////////////////////////////////////////////////////////

	// List of "setup" fields.
	// These will be loaded/saved in "config/setup.config" and will be loaded
	//	BEFORE initialization begins (so you can have dynamic screen size, etc).
	String[] SETUP_FIELDS;

	// Names of all of our "normal" configuration fields.
	// These are what are actually saved per each configuration.
	String[] FIELDS;


////////////////////////////////////////////////////////////
//	Config file path.  Use  `getFilePath()` to get the full path.
//	as:  <filepath>/<filename>.tsv
////////////////////////////////////////////////////////////

	// Path to ALL config files for this type, local to sketch directory.
	// The path will be created if necessary.
	// YOU MUST include the trailing slash.
	String filepath = "config/";


	// Prefix for "normal" config files.
	String normalFilePrefix = "PS";

	// Extension (including period) for all files of this type.
	String configExtension = ".tsv";

	// Number of "normal" configs we support in this config.
	int maxNormalConfigCount = 100;

	// Return the full path for a given config file instance.
	// If you pass `_fileName`, we'll use that.
	// Returns `null` if no filename specified.
	String getFilePath() {
		return this.getFilePath(null);
	}
	String getFilePath(String _fileName) {
		if (_fileName == null) _fileName = this.defaultConfigFile;
		if (_fileName == null) {
			logError("ERROR in gConfig.getFilePath(): no filename specified.");
			return null;
		}
		return filepath + _fileName + configExtension;
	}

	// Return the full path to a "normal" file given an integer index.
	String getFilePath(int configFileIndex) {
		String fileName = this.getFileName(configFileIndex);
		return this.getFilePath(fileName);
	}

	// Return the FILE NAME to a "normal" file given an integer index
	//	WITHOUT THE EXTENSION!!!
	// NOTE: the base implementation assumes we have 2-digit file indexing.
	//			override this in your subclass if that's not the case!
	String getFileName(int configFileIndex) {
		return normalFilePrefix + String.format("%02d", configFileIndex);
	}

	// Return the index associated with a "normal" config file name.
	// Returns -1 if it doesn't match our normal config naming pattern.
	int getFileIndex(String fileName) {
		if (fileName == null || !fileName.startsWith(normalFilePrefix)) return -1;
		// reduce down to just numbers
		String stringValue = fileName.replaceAll( "[^\\d]", "" );
		return Integer.parseInt(stringValue, 10);
	}

////////////////////////////////////////////////////////////
//	Dealing with change.
////////////////////////////////////////////////////////////

	// Tell the controller(s) about the state of all of our FIELDs.
	void syncControllers() {
		println("-------------------------------------------");
		println("    S  Y  N  C");
		println("-------------------------------------------");
		// get normal fields
		Table table = this.getFieldsAsTable(FIELDS);
		// add setup fields as well
		this.getFieldsAsTable(SETUP_FIELDS, table);
		// now signal that all of those fields have changed
		this.fieldsChanged(table);
		// Notify that we're synchronized.
		if (gController != null) {
			gController.sync();
		}
	}

	// One of our fields has changed.
	// Tell all of our controllers.
	void fieldChanged(String fieldName, String typeName, String currentValueString) {
		Field field = this.getField(fieldName, "fieldChanged("+fieldName+"): field not found");
		this.fieldChanged(field, typeName, currentValueString);
	}
	void fieldChanged(Field field, String typeName, String currentValueString) {
		if (field == null) return;
		for (OscController controller : this.controllers) {
			String fieldName = field.getName();
			int type = this.getType(field);
			try {
				// handle colors specially
				if (type == _COLOR_TYPE) {
					color controllerValue = this.getColor(field);
					controller.onConfigColorChanged(fieldName, controllerValue, currentValueString);
				}
				// treat everything else as a float
				else {
					float controllerValue = this.valueForController(field, controller.minValue, controller.maxValue);
					controller.onConfigFieldChanged(fieldName, controllerValue, typeName, currentValueString);
				}
			} catch (Exception e) {
				logWarning("fieldChanged("+fieldName+") exception setting controller value", e);
			}
		}
	}

	// A bunch of fields have changed.
	// Tell all of our controllers.
	void fieldsChanged(Table changeLog) {
		for (TableRow row : changeLog.rows()) {
			this.fieldChanged(row.getString("field"), row.getString("type"), row.getString("value"));
		}
	}

	// Record a change to a field in our changeLog.
	// If no changeLog found, we'll call `fieldChanged()` immediately.
	void recordChange(Field field, String typeName, String currentValueString, Table changeLog) {
		if (changeLog != null) {
			TableRow row = changeLog.addRow();
			row.setString("field", field.getName());
			row.setString("type" , typeName);
			row.setString("value", currentValueString);
		} else {
			this.fieldChanged(field, typeName, currentValueString);
		}
	}

	// Echo the current state of our FIELDS to the output.
	void echo() {
		this.echo(this.getFieldsAsTable(this.FIELDS, null));
	}
	void echo(Table table) {
//TODO...
	}


////////////////////////////////////////////////////////////
//	Dealing with controllers and messages from controllers.
////////////////////////////////////////////////////////////
	void addController(OscController controller) {
		this.controllers.add(controller);
	}
	void removeController(OscController controller) {
		this.controllers.remove(controller);
	}


////////////////////////////////////////////////////////////
//	Setting values as they come from the controller.
////////////////////////////////////////////////////////////

	void setFromController(String fieldName, float controllerValue, float controllerMin, float controllerMax) {
		Field field = this.getField(fieldName, "setFromController({{fieldName}}): field not found");
		if (field != null) this.setFromController(field, controllerValue, controllerMin, controllerMax);
	}

	void setFromController(Field field, float controllerValue, float controllerMin, float controllerMax) {
		if (field == null) return;
		try {
			int type = this.getType(field);
			switch (type) {
				case _INT_TYPE:		this.setIntFromController(field, controllerValue, controllerMin, controllerMax); return;
				case _FLOAT_TYPE:	this.setFloatFromController(field, controllerValue, controllerMin, controllerMax); return;
				case _BOOLEAN_TYPE:	this.setBooleanFromController(field, controllerValue, controllerMin, controllerMax); return;
				case _COLOR_TYPE:	this.setColorFromController(field, controllerValue, controllerMin, controllerMax); return;
				default:			break;
			}
		} catch (Exception e) {
			logWarning("setFromController("+field.getName()+"): exception setting field value", e);
		}
	}

	// Set internal integer value from controller value.
	void setIntFromController(Field field, float controllerValue, float controllerMin, float controllerMax) {
		if (field == null) return;
		int configMin, configMax, newValue;
		// try to get min/max from variables and use that to scale the value.
		try {
			configMin = this.getInt("MIN_"+field.getName());
			configMax = this.getInt("MAX_"+field.getName());
			newValue = (int) map(controllerValue, controllerMin, controllerMax, configMin, configMax);
		}
		// if that didn't work, just coerce to an int
		catch (Exception e) {
			newValue = (int) controllerValue;
		}
		logDebug("setIntFromController("+field.getName()+"): setting to "+newValue);
		this.setInt(field, newValue, null);
	}


	// Set internal float value from controller value.
	void setFloatFromController(Field field, float controllerValue, float controllerMin, float controllerMax) {
		if (field == null) return;
		float configMin, configMax, newValue;
		// try to get min/max from variables and use that to scale the value.
		try {
			configMin = this.getFloat("MIN_"+field.getName());
			configMax = this.getFloat("MAX_"+field.getName());
			newValue = map(controllerValue, controllerMin, controllerMax, configMin, configMax);
		}
		// if that didn't work, just use the value as a raw float
		catch (Exception e) {
			newValue = controllerValue;
		}
		logDebug("setFloatFromController("+field.getName()+"): setting to "+newValue);
		this.setFloat(field, newValue, null);
	}

	// Set internal boolean value from controller value.
	void setBooleanFromController(Field field, float controllerValue, float controllerMin, float controllerMax) {
		if (field == null) return;
		boolean newValue = controllerValue != 0;
		logDebug("setBooleanFromController("+field.getName()+"): setting to "+newValue);
		this.setBoolean(field, newValue, null);
	}

	// Set internal color value from controller value.
	// NOTE: we assume that they're passing in the HUE!
//TODO: split into r,g,b etc
	void setColorFromController(Field field, float controllerValue, float controllerMin, float controllerMax) {
		if (field == null) return;
println("==============> Config.setColorFromController("+field.getName()+")");
		float theHue = map(controllerValue, controllerMin, controllerMax, 0, 1);
		color newValue = colorFromHue(theHue);
		logDebug("setColorFromController("+field.getName()+"): setting to "+colorToString(newValue));
		this.setColor(field, newValue, null);
	}


////////////////////////////////////////////////////////////
//	Getting values to send to the controller as floats. (???)
////////////////////////////////////////////////////////////


	float valueForController(String fieldName, float controllerMin, float controllerMax) throws Exception {
		Field field = this.getField(fieldName, "valueForController({{fieldName}}): field not found");
		return this.valueForController(field, controllerMin, controllerMax);
	}
	float valueForController(Field field, float controllerMin, float controllerMax) throws Exception {
		if (field == null) throw new NoSuchFieldException();
		int type = this.getType(field);
		switch (type) {
			case _INT_TYPE:		return this.intForController(field, controllerMin, controllerMax);
			case _FLOAT_TYPE:	return this.floatForController(field, controllerMin, controllerMax);
			case _BOOLEAN_TYPE:	return this.booleanForController(field, controllerMin, controllerMax);
			case _COLOR_TYPE:	return this.colorForController(field, controllerMin, controllerMax);
			default:			logWarning("valueForController("+field.getName()+"): type not understood");
		}
		throw new NoSuchFieldException();
	}

	// Return internal integer field value as a float, scaled for our controller.
	float intForController(Field field, float controllerMin, float controllerMax) throws Exception {
		float currentValue = (float) this.getInt(field);
		// attempt to map to MIN_ and MAX_ for control
		try {
			int configMin, configMax;
			configMin = this.getInt("MIN_"+field.getName());
			configMax = this.getInt("MAX_"+field.getName());
			// if we can find them, coerce the value
			currentValue = map((float)currentValue, configMin, configMax, controllerMin, controllerMax);
		} catch (Exception e) {/* eat this error */}

		return currentValue;
	}

	// Return internal float field value as a float, scaled for our controller.
	float floatForController(Field field, float controllerMin, float controllerMax) throws Exception {
		float currentValue = this.getFloat(field);
		// attempt to get min and max
		try {
			float configMin, configMax;
			configMin = this.getFloat("MIN_"+field.getName());
			configMax = this.getFloat("MAX_"+field.getName());
			// if we can find them, coerce the value
			currentValue = map(currentValue, configMin, configMax, controllerMin, controllerMax);
		} catch (Exception e) {	/* eat this error */}
		return currentValue;
	}

	// Return internal boolean field value as a float, scaled for our controller.
	float booleanForController(Field field, float controllerMin, float controllerMax) throws Exception {
		boolean isTrue = this.getBoolean(field);
		return (isTrue ? controllerMax : controllerMin);
	}

	// Set internal color value from controller value.
	// NOTE: we assume that they're passing in the HUE!
//TODO: split into r,g,b etc
	// Return internal color field value as a float, scaled for our controller.
	float colorForController(Field field, float controllerMin, float controllerMax) throws Exception {
		color clr = this.getColor(field);
		return hueFromColor(clr);
	}



////////////////////////////////////////////////////////////
//	Loading from disk and parsing.
////////////////////////////////////////////////////////////

	Table loadAll() {
		// load our setup fields
		this.loadSetup();


		// attempt to load our "RESTART" file if it exists
		if (this.configFileExists(this.restartConfigFile)) {
			this.load(this.restartConfigFile);
		} else {
			this.load(this.defaultConfigFile);
		}

		return null;
	}

	// Load our "main" configuration from data stored on disk.
	// If you pass `_fileName`, we'll load from that file and remember as our `filename` for later.
	// If you pass null, we'll use our stored `filename`.
	// Returns `changeLog` Table of actual changed values.
	Table load() {
		return this.load(null);
	}

	// Load a numbered config.
	Table load(int fileIndex) {
		String _fileName = this.getFileName(fileIndex);
		return this.load(_fileName);
	}

	// Load a file by name (within our <sketch>/config/ folder).
	Table load(String _fileName) {
		// remember filename if passed in
		if (_fileName != null) {
			// save current setup config
			this.saveSetup();
		}
		return this.loadFromFile(_fileName);
	}

	// Load our defaults from disk.
	Table loadSetup() {
		return this.loadFromFile("setup");
	}


	// Load ANY configuration file from data stored on disk.
	// Returns `changeLog` Table of actual changed values.
	Table loadFromFile(String _fileName) {
		String path = this.getFilePath(_fileName);
		if (path == null) {
			logError("ERROR in gConfig.loadFromConfigFile(): no filename specified");
			return null;
		}

		logDebug("Loading from '"+path+"'");
		// load as a .tsv file with loadTable()
		Table inputTable;
		try {
			inputTable = loadTable(path, "header,tsv");
		} catch (Exception e) {
			logWarning("loadFromFile('"+path+"'): couldn't load table file.  Does it exist?", e);
			return null;
		}

//		logDebug("Values before load:");
//		if (this.debugging) this.echo();

		// make a table to hold changes found while setting values
		Table changeLog = makeFieldTable();

		// iterate through our inputTable, updating our fields
		for (TableRow row : inputTable.rows()) {
			String fieldName = row.getString("field");
			String value 	 = row.getString("value");
			String typeHint	 = row.getString("type");
			this.setField(fieldName, value, typeHint, changeLog);
		}

		// update all controllers with the current value for all FIELDS
		this.syncControllers();

		return changeLog;
	}



	// Parse a single field/value pair from our config file and update the corresponding value.
	// Eats all exceptions.
	void setField(String fieldName, String stringValue) { this.setField(fieldName, stringValue, null, null); }
	void setField(String fieldName, String stringValue, String typeHint) { this.setField(fieldName, stringValue, typeHint, null); }
	void setField(String fieldName, String stringValue, String typeHint, Table changeLog) {
		Field field = this.getField(fieldName, "gConfig.setField("+fieldName+"): field not found.");
		if (field == null) return;
		this.setField(field, stringValue, typeHint, changeLog);
	}

	void setField(Field field, String stringValue) { this.setField(field, stringValue, null, null);	}
	void setField(Field field, String stringValue, String typeHint) { this.setField(field, stringValue, null, null);	}
	void setField(Field field, String stringValue, String typeHint, Table changeLog) {
		if (field == null) {
			logWarning("gConfig.setField() called with null field");
			return;
		}

		String messagePrefix = "gConfig.setField("+field.getName()+", '"+stringValue+"', "+typeHint+"): ";
		int type = this.getType(field, typeHint);
		switch (type) {
			case _INT_TYPE:
				try {
					int newValue = stringToInt(stringValue);
					this.setInt(field, newValue, changeLog);
				} catch (Exception e)	{
					logWarning(messagePrefix+" couldn't convert string value to int");
				}
				break;

			case _FLOAT_TYPE:
				try {
					float newValue = stringToFloat(stringValue);
					this.setFloat(field, newValue, changeLog);
				} catch (Exception e)	{
					logWarning(messagePrefix+" couldn't convert string value to float");
				}
				break;

			case _BOOLEAN_TYPE:
				try {
					boolean newValue = stringToBoolean(stringValue);
					this.setBoolean(field, newValue, changeLog);
				} catch (Exception e)	{
					logWarning(messagePrefix+" couldn't convert string value to boolean");
				}
				break;

			case _COLOR_TYPE:
				try {
					color newValue = stringToColor(stringValue);
					this.setColor(field, newValue, changeLog);
				} catch (Exception e)	{
					logWarning(messagePrefix+" couldn't convert string value to color");
				}
				break;


			case _STRING_TYPE:
				this.setString(field, stringValue, changeLog);
				break;

			default:
				break;
		}
	}


	// Set an integer field to a string value or an integer value.
	// Returns the value actually set to, or -1 if couldn't do it for some reason.
	// If you pass a changeLog, we'll write the results to that.
	// Otherwise we'll call `fieldChanged()`.
	int setInt(String fieldName, int newValue) {
		Field field = this.getField(fieldName, "gConfig.setInt("+fieldName+"): field not found.  Returning -1.");
		if (field == null) return -1;
		return this.setInt(field, newValue, null);
	}
	int setInt(Field field, int newValue, Table changeLog) {
		if (field == null) {
			logWarning("setInt(null): field is null!.  Returning -1");
			return -1;	// ????
		}

		// attempt to pin to min value but ignore it if we can't find a MIN_XXX field
		try {
			int configMin = this.getInt("MIN_"+field.getName());
			if (newValue < configMin) newValue = configMin;
		} catch (Exception e){}

		// attempt to pin to max value but ignore it if we can't find a MAX_XXX field
		try {
			int configMax = this.getInt("MAX_"+field.getName());
			if (newValue > configMax) newValue = configMax;
		} catch (Exception e){}

		// actually set it and record the change
		try {
			field.setInt(this, newValue);
			this.recordChange(field, this.getTypeName(_INT_TYPE), this.intFieldToString(field), changeLog);
			return newValue;
		} catch (Exception e){
			logWarning("setInt("+field.getName()+", "+newValue+"): something went wrong! "+e+"  Returning -1");
			return -1;
		}
	}


	// Set an float field to a string value or an float value.
	// Returns the new value we changed to, or -1 if couldn't do it for some reason.
	// If you pass a changeLog, we'll write the results to that.
	// Otherwise we'll call `fieldChanged()`.
	float setFloat(String fieldName, float newValue) {
		Field field = this.getField(fieldName, "gConfig.setFloat("+fieldName+"): field not found.  Returning -1.");
		if (field == null) return -1;
		return this.setFloat(field, newValue, null);
	}

	float setFloat(Field field, float newValue, Table changeLog) {
		if (field == null) {
			logWarning("setFloat(null): field is null!.  Returning -1.");
			return -1;
		}

		// attempt to pin to min value but ignore it if we can't find a MIN_XXX field
		try {
			float configMin = this.getFloat("MIN_"+field.getName());
			if (newValue < configMin) newValue = configMin;
		} catch (Exception e){}
		// attempt to pin to max value but ignore it if we can't find a MAX_XXX field
		try {
			float configMax = this.getFloat("MAX_"+field.getName());
			if (newValue > configMax) newValue = configMax;
		} catch (Exception e){}

		// actually set it and record the change
		try {
			field.setFloat(this, newValue);
			this.recordChange(field,  this.getTypeName(_FLOAT_TYPE), this.floatFieldToString(field), changeLog);
			return newValue;
		} catch (Exception e){
			logWarning("setFloat("+field.getName()+", "+newValue+"): something went wrong! "+e+"  Returning -1.");
			return -1;
		}
	}



	// Set a boolean field to a string value or a boolean value.
	// Returns value actually set to, or false if something goes wrong.
	// If you pass a changeLog, we'll write the results to that.
	// Otherwise we'll call `fieldChanged()`.
	boolean setBoolean(String fieldName, boolean newValue) {
		Field field = this.getField(fieldName, "gConfig.setBoolean("+fieldName+"): field not found.  Returning false.");
		if (field == null) return false;
		return this.setBoolean(field, newValue, null);
	}
	boolean setBoolean(Field field, boolean newValue, Table changeLog) {
		if (field == null) {
			logWarning("setBoolean(null): field is null!.  Returning False");
			return false;
		}
		try {
			field.setBoolean(this, newValue);
			this.recordChange(field,  this.getTypeName(_BOOLEAN_TYPE), this.booleanFieldToString(field), changeLog);
			return newValue;
		} catch (Exception e){
			logWarning("setBoolean("+field.getName()+", "+newValue+"): something went wrong! "+e+"  Returning false.");
			return false;
		}
	}


	// Set a color field to a string value or an color value.
	// Returns the color actually set to, or black if something goes wrong.
	// If you pass a changeLog, we'll write the results to that.
	// Otherwise we'll call `fieldChanged()`.
	color setColor(String fieldName, color newValue) {
		Field field = this.getField(fieldName, "setColor({{fieldName}}): field not found.  Returning black.");
		if (field == null) return color(0);
		return this.setColor(field, newValue, null);
	}
	color setColor(Field field, color newValue, Table changeLog) {
		println("setting "+field.getName()+" to "+colorToString(newValue)+")");
		color black = color(0);
		if (field == null) {
			logWarning("setColor(null): field is null!.  Returning black.");
			return black;
		}
		try {
			field.setInt(this, (int)newValue);
			this.recordChange(field,  this.getTypeName(_COLOR_TYPE), this.colorFieldToString(field), changeLog);
			return newValue;
		} catch (Exception e){
			logWarning("setColor("+field.getName()+", "+newValue+"): something went wrong! "+e+"  Returning black.");
			return black;
		}
	}



	// Set a String field to a string value or an String value.
	// Returns string actually set to, or null if something goes wrong.
	// If you pass a changeLog, we'll write the results to that.
	// Otherwise we'll call `fieldChanged()`.
	String setString(String fieldName, String stringValue, Table changeLog) {
		Field field = this.getField(fieldName, "setString({{fieldName}}): field not found.");
		if (field == null) return null;
		return this.setString(field, stringValue, changeLog);
	}
	String setString(Field field, String newValue, Table changeLog) {
		if (field == null) {
			logWarning("setString(null): field is null!.  Returning null.");
			return null;
		}
		try {
			field.set(this, newValue);
			this.recordChange(field,  this.getTypeName(_BOOLEAN_TYPE), this.stringFieldToString(field), changeLog);
			return newValue;
		} catch (Exception e){
			logWarning("setString("+field.getName()+", '"+newValue+"'): something went wrong! "+e+"  Returning null.");
			return null;
		}
	}



////////////////////////////////////////////////////////////
//	Saving to disk.
////////////////////////////////////////////////////////////

	// Save the FIELDS in our current config to a file.
	// If you pass `_fileName`, we'll use that file (and remember it for later).
	// Otherwise we'll save to the current filename.
	// Returns a Table with the data as it was saved.
	Table save() {
		return this.save(null);
	}

	// Load a numbered config.
	Table save(int fileIndex) {
		String _fileName = this.getFileName(fileIndex);
		return this.load(_fileName);
	}

	Table save(String _fileName) {
		if (_fileName != null) this.lastConfigFileSaved = _fileName;
//println("SAVING "+_fileName);
		return this.saveToFile(this.lastConfigFileSaved, this.FIELDS);
	}

	// Save our current state so we'll restart in the same place.
	Table saveRestartState() {
//println("SAVING RESTART STATE");
		return this.saveToFile(this.restartConfigFile, this.FIELDS);
	}

	// Load our defaults from disk.
	Table saveSetup() {
		return this.saveToFile("setup", this.SETUP_FIELDS);
	}

	// Save an arbitrary set of fields in our current config to a file.
	// You must pass `_fileName`.
	Table saveToFile(String _fileName, String[] fields) {
		String path = getFilePath(_fileName);
		if (path == null) {
			logError("ERROR in gConfig.saveToFile(): no filename specified");
			return null;
		}
		logDebug("Saving to '"+path+"'");

		// update our configExistsMap for this file if it maps to a "normal" file
		int fileIndex = this.getFileIndex(_fileName);
		if (fileIndex > -1) {
			if (fileIndex >= maxNormalConfigCount) {
				println("Warning: saving '"+_fileName+"' which returned index of "+fileIndex);
			} else {
				configExistsMap[fileIndex] = true;
			}
		}

		// Get the data as a table
		Table table = getFieldsAsTable(fields);

		// Write to the file.
		saveTable(table, path);

		// save current setup config
		if (_fileName != null && !_fileName.equals("setup")) this.saveSetup();

		return table;
	}


	// Create a new table for this config class which is set up to go.
	Table makeFieldTable() {
		Table table = new Table();
		table.addColumn("type");		// field type (eg: "int" or "string" or "color")
		table.addColumn("field");		// name of the field
		table.addColumn("value");		// string value for the field
		return table;
	}

	// Return output for a set of fieldNames as a Table with columns:
	//		"type", "field", "value" (stringified)
	// If you pass a Table, we'll add to that, otherwise we'll create a new one.
	// Eats exceptions.
	Table getFieldsAsTable(String[] fieldNames) {
		return this.getFieldsAsTable(fieldNames, null);
	}
	Table getFieldsAsTable(String[] fieldNames, Table table) {
		if (fieldNames == null) fieldNames = this.FIELDS;

		// if we weren't passed a table, create one now
		if (table == null) table = makeFieldTable();
		if (fieldNames == null) return table;

		for (String fieldName : fieldNames) {
			Field field;
			int type;
			String value;
			try {
				// get the field definition
				field = this.getField(fieldName, "getFieldsAsTable(): field {{fieldName}} not found.");

				// get the type of the field
				type = this.getType(field);
				if (type == _UNKNOWN_TYPE) continue;

				value = this.typedFieldToString(field, type);

			} catch (Exception e) {
				logWarning("getFieldsAsTable(): error processing field "+fieldName, e);
				continue;
			}

			// add row up front, we'll remove it in the exception handler if something goes wrong
			TableRow row = table.addRow();
			row.setString("field", fieldName);
			row.setString("type", getTypeName(type));
			row.setString("value", value);
		}
		return table;
	}


////////////////////////////////////////////////////////////
//	Reflection methods
////////////////////////////////////////////////////////////

	////////////////////////////////////////////////////////////
	//	Getting field definitions.
	////////////////////////////////////////////////////////////

	// Return the Field definition for a named field.
	// Returns null if no field can be found.
	// Swallows all exceptions.
	Field getField(String fieldName) {
		try {
//TODO: how to genericise this to current class?
			return this.getClass().getDeclaredField(fieldName);
		} catch (Exception e){
			return null;
		}
	}

	// Return the field definition for a named field, printing a debug message if not found.
	//
	// If field cannot be found, we'll:
	//	- print debug message (with "{{fieldName}}" replaced with the name of the field), and
	//	- return null.
	Field getField(String fieldName, String message) {
		Field field = this.getField(fieldName);
		if (field == null && message != null) {
			logDebug(message.replace("{{fieldName}}", fieldName));
		}
		return field;
	}

	////////////////////////////////////////////////////////////
	//	Getting lists of fields
	////////////////////////////////////////////////////////////
	String[] expandFieldList(String[] fields) {
		ArrayList<String> output = new ArrayList<String>(100);
		for (String fieldName : fields) {
			if (!fieldName.contains("*")) {
				output.add(fieldName);
			} else {
				String prefix = fieldName.substring(0, fieldName.length()-1);
				this.addFieldNamesStartingWith(prefix, output);
			}
		}
		String[] allFields = output.toArray(new String[output.size()]);
		return allFields;
	}

	// Add field nams declared on us (NOT on supers) which start with a prefix.
	void addFieldNamesStartingWith(String prefix, ArrayList<String>output) {
		Field[] allFields = this.getClass().getDeclaredFields();
		for (Field field : allFields) {
			String name = field.getName();
			if (name.startsWith(prefix)) output.add(name);
		}
	}


	// Return true if a particular field is in our SETUP_FIELDS list.
	boolean isSetupField(String fieldName) {
		for (String setupFieldName : this.SETUP_FIELDS) {
			if (fieldName.equals(setupFieldName)) return true;
		}
		return false;
	}

	////////////////////////////////////////////////////////////
	//	Getting "logical" field types.
	////////////////////////////////////////////////////////////

	// Return the "logical" data type for a field, specified by `fieldName` or by `field`,
	//	eg: `_INT_TYPE` or `_FLOAT_TYPE`
	// If you have a `typeHint` (eg: from a tsv file), pass that, it might help.
	// Returns `_UNKNOWN_TYPE` if we can't find the field or it's not a type we understand.
	// Swallows all exceptions.
	int getType(String fieldName) { return this.getType(getField(fieldName), null); }
	int getType(String fieldName, String typeHint) { return this.getType(getField(fieldName), typeHint); }
	int getType(Field field) { return this.getType(field, null); }
	int getType(Field field, String typeHint) {
		if (field == null) return _UNKNOWN_TYPE;
//TODO: how best to genericise this???  some type of MAP ???
		if (typeHint != null && typeHint.equals("color")) return _COLOR_TYPE;

		Type type = field.getType();
		if (type == Integer.TYPE) {
			// Ugh.  Processing masquerades `color` variables as `int`s.
			// If the field name ends with "Color", assume it's a color.
//TODO: how best to genericise this???
			if (field.getName().endsWith("Color")) return _COLOR_TYPE;
			return _INT_TYPE;
		}
		if (type == Float.TYPE) 	return _FLOAT_TYPE;
		if (type == Boolean.TYPE) 	return _BOOLEAN_TYPE;
//try {
//	static final Class<?> _STRING_CLASS = Class.forName("String");
//} catch (Exception e) {
//	println("ERROR: can't get string class!");
//}

		if (type == "".getClass())	return _STRING_TYPE;
		return _UNKNOWN_TYPE;
	}

	// Return our logical 'name' for each `type`.
	String getTypeName(int type) {
		switch(type) {
			case _INT_TYPE:		return "int";
			case _FLOAT_TYPE:	return "float";
			case _BOOLEAN_TYPE:	return "boolean";
			case _COLOR_TYPE:	return "color";
			case _STRING_TYPE:	return "string";
			default:			return "UNKNOWN";
		}
	}


////////////////////////////////////////////////////////////
//	Return internal value for a given field, specified by field name or Field.
// 	They will throw:
//		- `NoSuchFieldException` if no field found with that name, or
//		- `IllegalArgumentException` if we can't parse the value.
////////////////////////////////////////////////////////////

	int getInt(String fieldName) throws Exception {return this.getInt(getField(fieldName));}
	int getInt(Field field) throws Exception {
		if (field == null) throw new NoSuchFieldException();
		return field.getInt(this);
	}
	float getFloat(String fieldName) throws Exception {return this.getFloat(getField(fieldName));}
	float getFloat(Field field) throws Exception {
		if (field == null) throw new NoSuchFieldException();
		return field.getFloat(this);
	}
	boolean getBoolean(String fieldName) throws Exception {return this.getBoolean(getField(fieldName));}
	boolean getBoolean(Field field) throws Exception {
		if (field == null) throw new NoSuchFieldException();
		return field.getBoolean(this);
	}
	color getColor(String fieldName) throws Exception {return this.getColor(getField(fieldName));}
	color getColor(Field field) throws Exception {
		if (field == null) throw new NoSuchFieldException();
		return (color)field.getInt(this);
	}
	String getString(String fieldName) throws Exception {return this.getString(getField(fieldName));}
	String getString(Field field) throws Exception {
		if (field == null) throw new NoSuchFieldException();
		return (String) field.get(this);
	}


////////////////////////////////////////////////////////////
//	Return internal values for a given field, returning `defaultValue` on exception.
//	Swallows all exceptions.
////////////////////////////////////////////////////////////

	// Get internal int value.
	int getInt(String fieldName, int defaultValue) {
		Field field = this.getField(fieldName, "getInt({{fieldName}}): field not found.  Returning default: "+defaultValue);
		return getInt(field, defaultValue);
	}
	int getInt(Field field, int defaultValue) {
		if (field == null) return defaultValue;
		try {
			return field.getInt(this);
		} catch (Exception e) {
			logWarning("getInt("+field.getName()+"): error getting int value.  Returning default "+defaultValue, e);
			return defaultValue;
		}
	}

	// Get internal float value.
	float getFloat(String fieldName, float defaultValue) {
		Field field = this.getField(fieldName, "getFloat({{fieldName}}): field not found.  Returning default: "+defaultValue);
		return getFloat(field, defaultValue);
	}
	float getFloat(Field field, float defaultValue){
		if (field == null) return defaultValue;
		try {
			return field.getFloat(this);
		} catch (Exception e) {
			logWarning("getFloat("+field.getName()+"): error getting float value.  Returning default "+defaultValue, e);
			return defaultValue;
		}
	}

	// Get internal boolean value.
	boolean getBoolean(String fieldName, boolean defaultValue) {
		Field field = this.getField(fieldName, "getBoolean({{fieldName}}): field not found.  Returning default: "+defaultValue);
		return getBoolean(field, defaultValue);
	}
	boolean getBoolean(Field field, boolean defaultValue){
		if (field == null) return defaultValue;
		try {
			return field.getBoolean(this);
		} catch (Exception e) {
			logWarning("getBoolean("+field.getName()+"): error getting boolean value.  Returning default "+defaultValue, e);
			return defaultValue;
		}
	}

	// Get internal color value.
	color getColor(String fieldName, color defaultValue) {
		Field field = this.getField(fieldName, "getColor({{fieldName}}): field not found.  Returning default: "+defaultValue);
		return getColor(field, defaultValue);
	}
	color getColor(Field field, color defaultValue){
		if (field == null) return defaultValue;
		try {
			return (color) field.getInt(this);
		} catch (Exception e) {
			logWarning("getColor("+field.getName()+"): error getting color value.  Returning default "+defaultValue, e);
			return defaultValue;
		}
	}

	// Get internal string value.
	String getString(String fieldName, String defaultValue) {
		Field field = this.getField(fieldName, "getString({{fieldName}}): field not found.  Returning default: "+defaultValue);
		return getString(field, defaultValue);
	}
	String getString(Field field, String defaultValue){
		if (field == null) return defaultValue;
		try {
			return (String) field.get(this);
		} catch (Exception e) {
			logWarning("getString("+field.getName()+"): error getting String value.  Returning default "+defaultValue, e);
			return defaultValue;
		}
	}



////////////////////////////////////////////////////////////
//	Coercing native field value to our string equivalent.
//	Returns `null` on exception.
////////////////////////////////////////////////////////////

	// Return the value for one of our fields, specified by `fieldName` or `field`.
	String fieldToString(String fieldName) {
		Field field = this.getField(fieldName, "fieldToString({{fieldName}}): field not found.");
		return this.fieldToString(field);
	}
	String fieldToString(String fieldName, int type) {
		Field field = this.getField(fieldName, "fieldToString({{fieldName}}): field not found.");
		return this.typedFieldToString(field, type);
	}
	String fieldToString(Field field) {
		int type = this.getType(field);
		return this.typedFieldToString(field, type);
	}

	// Given a Field record and a corresponding "logical" `type"
	//	return the current value of that field as a String.
	String typedFieldToString(Field field, int type) {
		if (field == null) return null;
		switch (type) {
			case _INT_TYPE:		return this.intFieldToString(field);
			case _FLOAT_TYPE:	return this.floatFieldToString(field);
			case _BOOLEAN_TYPE:	return this.booleanFieldToString(field);
			case _COLOR_TYPE:	return this.colorFieldToString(field);
			case _STRING_TYPE:	return this.stringFieldToString(field);
			default:
				logWarning("typedFieldToString(field "+field.getName()+" field type '"+type+"' not understood");
		}
		return null;
	}

////////////////////////////////////////////////////////////
//	Coercing native field value to our string equivalent.
//	Returns `null` on exception.
////////////////////////////////////////////////////////////

	// Return string value for integer field.
	String intFieldToString(String fieldName) {
		Field field = this.getField(fieldName, "intFieldToString({{fieldName}}): field not found.");
		return this.intFieldToString(field);
	}
	String intFieldToString(Field field) {
		try {
			return intToString(this.getInt(field));
		} catch (Exception e) {
			logWarning("intFieldToString(field "+field.getName()+"): returning null", e);
			return null;
		}
	}

	// Return string value for float field.
	String floatFieldToString(String fieldName) {
		Field field = this.getField(fieldName, "floatFieldToString({{fieldName}}): field not found.");
		return this.floatFieldToString(field);
	}
	String floatFieldToString(Field field) {
		try {
			return floatToString(this.getFloat(field));
		} catch (Exception e) {
			logWarning("floatFieldToString(field "+field.getName()+"): returning null", e);
			return null;
		}
	}

	// Return string value for boolean field.
	String booleanFieldToString(String fieldName) {
		Field field = this.getField(fieldName, "booleanFieldToString({{fieldName}}): field not found.");
		return this.booleanFieldToString(field);
	}
	String booleanFieldToString(Field field) {
		try {
			return booleanToString(this.getBoolean(field));
		} catch (Exception e) {
			logWarning("booleanFieldToString(field "+field.getName()+"): returning null", e);
			return null;
		}
	}

	// Return string value for color field.
	String colorFieldToString(String fieldName) {
		Field field = this.getField(fieldName, "colorFieldToString({{fieldName}}): field not found.");
		return this.colorFieldToString(field);
	}
	String colorFieldToString(Field field) {
		try {
			return colorToString(this.getColor(field));
		} catch (Exception e) {
			logWarning("colorFieldToString(field "+field.getName()+"): returning null");
			return null;
		}
	}

	// Return string value for string field.  :-)
	String stringFieldToString(String fieldName) {
		Field field = this.getField(fieldName, "stringFieldToString({{fieldName}}): field not found.");
		return this.stringFieldToString(field);
	}
	String stringFieldToString(Field field) {
		try {
			return this.getString(field);
		} catch (Exception e) {
			logWarning("stringFieldToString("+field.getName()+"): returning null");
			return null;
		}
	}



////////////////////////////////////////////////////////////
//	Reflection for our config files on disk.
////////////////////////////////////////////////////////////
	// Array of boolean values for whether config files actually exist on disk.
	boolean[] configExistsMap;

	// Initialize our configExistsMap map.
	void initConfigExistsMap() {
		configExistsMap = new boolean[maxNormalConfigCount];
		for (int i = 0; i < this.maxNormalConfigCount; i++) {
			configExistsMap[i] = this.configFileExists(i);
		}
	}

	boolean configFileExists(int index) {
		// get local path (relative to sketch)
		String localPath = this.getFilePath(index);
		return this.configPathExists(localPath);
	}

	boolean configFileExists(String name) {
		String localPath = this.getFilePath(name);
		return this.configPathExists(localPath);
	}

	boolean configPathExists(String localPath) {
		// use sketchPath to convert to full path
		String path = sketchPath(localPath);
		return new File(path).exists();
	}


////////////////////////////////////////////////////////////
//	Dealing with window size.
//	Save window size as, eg: "640x480"
////////////////////////////////////////////////////////////
	void initWindowSize(String wdSize) {
		if (wdSize == null) {
			logWarning("gConfig.initWindowSize(): size is null!");
			return;
		}
		String[] sizes = wdSize.split("x");
		try {
			int wdWidth = Integer.parseInt(sizes[0], 10);
			int wdHeight = Integer.parseInt(sizes[1], 10);
			size(wdWidth, wdHeight);
		} catch (Exception e) {
			logWarning("gConfig.initWindowSize("+wdSize+"): exception parsing size "+e);
		}
	}

}