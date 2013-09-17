/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2013 Jason Stephens & VideoAlchemy Collective
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
//	Configurations are stored in ".tsv" files
//		we have a header row as 		field<tab>value
//		and then each row of data is 	<field><tab><value>
//										<field><tab><value>
//
//	We can auto-parse these config files using reflection.
//
////////////////////////////////////////////////////////////

//import java.lang.reflect.Field;
import java.lang.reflect.*;


// Internal "logical data types" we understand.
int _UNKNOWN_TYPE	= 0;
int _INT_TYPE 		= 1;
int _FLOAT_TYPE 	= 2;
int _BOOLEAN_TYPE 	= 3;
int _COLOR_TYPE 	= 4;
int _STRING_TYPE 	= 5;


/****
	OWEN TODO
		- simple unit test project
		- FIELDS vs CONSTANTS
		- separate table construction from filling, so we can do FIELDS, or CONTANTS or FIELDS+CONSTANTS
		- only write deltas to table
		- max/min semantics
		- list of controllers we'll notify about changes (passing table)
		- Controller class (save for later)

		- package as a library?

*****/



class Config {

	public Config() {}

	// Create an array with all of the fields we're managing.
	// Used, eg, to automatically save() all fields we care about.
	static String[] FIELDS = {"foo", "bar", "baz"};


////////////////////////////////////////////////////////////
//	Config file path.  Use  `getFilePath()` to get the full path.
//	as:  <filepath>/<filename>.tsv
////////////////////////////////////////////////////////////

	// Path to ALL config files for this type, local to sketch directory.
	// The path will be created if necessary.
	// DO NOT include the trailing slash.
	static String filepath = "config/";


	// Name of this individual config file.
	// This is generally set by `load()`ing or `save()`ing.
	// DO NOT include the path or extension!
	String filename;


	// Return the full path for a given config file instance.
	// If you pass `_filename`, we'll use that.
	// Otherwise we'll use our internal `filename` (but won't set it).
	// Returns `null` if no filename specified.
	String getFilePath(String _filename) {
		if (_filename == null) _filename = filename;
		if (_filename == null) {
			println("ERROR in config.getFilePath(): no filename specified;
			return null;
		}
		return filepath + "/" + _filename + ".tsv";
	}


////////////////////////////////////////////////////////////
//	Dealing with change.
////////////////////////////////////////////////////////////

	// One of our fields has changed.
	// Do something!  Tell somebody!
	void fieldChanged(String fieldName) {}


////////////////////////////////////////////////////////////
//	Loading from disk and parsing.
////////////////////////////////////////////////////////////

	// Load configuration from data stored on disk.
	// If you pass `_filename`, we'll load from that file and remember as our `filename` for later.
	// If you pass null, we'll use our stored `filename`.
	void load(String _filename) {
		// remember filename if
		if (_filename != null) this.filename = _filename;
		String path = getFilePath();
		if (path == null) {
			println("ERROR in config.loadFromConfigFile(): no filename specified");
			return;	// TOTHROW ???
		}

		println("Attempting to read config from file "+path);
		println("Current values:");
		this.echo();

		// load as a .tsv file with loadTable()
		Table inputTable = loadTable(path, "header,tsv");

		// make a table to hold changes found while setting values
		Table changeLog = makeFieldTable();

		// iterate through our inputTable, updating our fields
		for (TableRow row : inputTable.rows()) {
			String fieldName = row.getString("field");
			String value 	 = row.getString("value");
			String typeHint	 = row.getString("type");
			this.updateField(fieldName, value, typeHint, changeLog);
		}

	// TODO: send changeLog to our controllers (or possibly all values?)

		// print out the config
		println("Finished reading config!  New values:");
		this.echo();
	}

	// Parse a single field/value pair from our config file.
	// Eats all exceptions.
	void updateField(String fieldName, String stringValue) {
		this.updateField(fieldName, stringValue, null, null);
	}
	void updateField(String fieldName, String stringValue, String typeHint, Table changeLog) {
		try {
			Field field = this.getFieldDefinition(fieldName);
			int type = this.getFieldType(field, typeHint);
			switch (type) {
				case _INT_TYPE:		this.updateIntFieldWithString(field, stringValue, changeLog); return;
				case _FLOAT_TYPE:	this.updateFloatFieldWithString(field, stringValue, changeLog); return;
				case _BOOLEAN_TYPE:	this.updateBooleanFieldWithString(field, stringValue, changeLog); return;
				case _COLOR_TYPE:	this.updateColorFieldWithString(field, stringValue, changeLog); return;
				case _STRING_TYPE:	this.updateStringFieldWithString(field, stringValue, changeLog); return;
				default:			break;
		} catch (exception e) {
			println("parseConfigField("+fieldName+"): error while updating.  Skipping.");
		}
	}

	// Update an integer field on our object by coercing the specified `stringValue`.
	// Returns the parsed value.  Will throw if something goes wrong.
	int updateIntFieldWithString(String fieldName, String stringValue, String typeHint, Table changeLog) throws Exception {
		Field field Config.class.getDeclaredField(fieldName);
		return updateIntFieldWithString(field, stringValue, changeLog);
	}
	int updateIntFieldWithString(Field field, String stringValue, String typeHint, Table changeLog) throws Exception {
		// HACK: if stringValue starts with "rgba(", assume it's a color and process accordingly.
		if (stringValue.startsWith("rgba(")) return updateColorFieldWithString(field, stringValue);

		int oldValue = field.getInt(this);
		int newValue = int(stringValue);
		if (oldValue != newValue) {
			println("parsed int "+field.getName()+" value to "+newValue);
			field.setInt(this, newValue);
			if (changeLog) {
				TableRow row = changeLog.addRow();
				row.setString("field", field.getName());
				row.setString("type" , getTypeName(_INT_TYPE);
				row.setString("value", getStringValueForInt(field);
				row.setInt("native", newValue);
				row.setInt("old",    oldValue);
			}
		}
		return newValue;
	}

	// Update a boolean field on our object by coercing the specified `stringValue`.
	// Returns the parsed value.  Will throw if something goes wrong.
	boolean updateBooleanFieldWithString(String fieldName, String stringValue, Table changeLog) throws Exception {
		Field field Config.class.getDeclaredField(fieldName);
		return updateBooleanFieldWithString(field, stringValue, changeLog);
	}
	boolean updateBooleanFieldWithString(Field field, String stringValue, Table changeLog) throws Exception {
		boolean oldValue = field.getBoolean(this);
		boolean newValue = boolean(stringValue);
		if (oldValue != newValue) {
			println("parsed boolean "+field.getName()+" value to "+newValue);
			field.setBoolean(this, newValue);
			if (changeLog) {
				TableRow row = changeLog.addRow();
				row.setString("field", field.getName());
				row.setString("type" , getTypeName(_BOOLEAN_TYPE);
				row.setString("value", getStringValueForBoolean(field);
				row.setBoolean("native", newValue);
				row.setBoolean("old",    oldValue);
			}
		}
		return newValue;
	}

	// Update a float field on our object by coercing the specified `stringValue`.
	// Returns the parsed value.  Will throw if something goes wrong.
	float updateFloatFieldWithString(String fieldName, String stringValue, Table changeLog) throws Exception {
		Field field Config.class.getDeclaredField(fieldName);
		return updateFloatFieldWithString(field, stringValue, changeLog);
	}
	float updateFloatFieldWithString(Field field, String stringValue, Table changeLog) throws Exception {
		float oldValue = field.getFloat(this);
		float newValue = float(stringValue);
		if (oldValue != newValue) {
			println("parsed float "+field.getName()+" value to "+newValue);
			field.setFloat(this, newValue);
			if (changeLog) {
				TableRow row = changeLog.addRow();
				row.setString("field", field.getName());
				row.setString("type" , getTypeName(_FLOAT_TYPE);
				row.setString("value", getStringValueForFloat(field);
				row.setFloat("native", newValue);
				row.setFloat("old",    oldValue);
			}
		}
		return newValue;
	}

	// Update an color field on our object by coercing the specified `stringValue`.
	// Returns the parsed value.  Will throw if something goes wrong.
	color updateColorFieldWithString(String fieldName, String stringValue, Table changeLog) throws Exception {
		Field field Config.class.getDeclaredField(fieldName);
		return updateIntFieldWithString(field, stringValue, changeLog);
	}
	color updateColorFieldWithString(Field field, String stringValue, Table changeLog) throws Exception {
		int oldValue = field.getInt(this);
		int newValue = (int) getColorFieldValue(stringValue);
		if (oldValue != newValue) {
			println("parsed int "+field.getName()+" value to "+newValue);
			field.setInt(this, newValue);
			if (changeLog) {
				TableRow row = changeLog.addRow();
				row.setString("field", field.getName());
				row.setString("type" , getTypeName(_COLOR_TYPE);
				row.setString("value", getStringValueForColor(field);
				row.setInt("native", newValue);
				row.setInt("old",    oldValue);
			}
		}
		return (color) newValue;
	}

	// Update a string field on our object.
	// Returns the parsed value.  Will throw if something goes wrong.
	String updateStringFieldWithString(String fieldName, String stringValue, Table changeLog) throws Exception {
		Field field Config.class.getDeclaredField(fieldName);
		return updateStringFieldWithString(field, stringValue, null);
	}
	String updateStringFieldWithString(Field field, String stringValue) throws Exception {
		return updateStringFieldWithString(field, stringValue, null);
	}
	String updateStringFieldWithString(Field field, String newValue) throws Exception {
		String oldValue = field.get(this);
		if (oldValue == null || !oldValue.equals(newValue)) {
			println("upading string "+field.getName()+" value to "+newValue);
			field.set(this, newValue);
			this.fieldChanged(field.getName(), newValue, oldValue);
		}
		return newValue;
	}


////////////////////////////////////////////////////////////
//	Saving to disk.
////////////////////////////////////////////////////////////

	// Save the FIELDS in our current config to a file.
	// If you pass `_fileName`, we'll use that file (and remember it for later).
	// Otherwise we'll
	void save(String _fileName) {
		if (_filename != null) this.filename = _filename;
		String path = getFilePath();
		if (path == null) {
			println("ERROR in config.saveToFile(): no filename specified");
			return;	// TOTHROW ???
		}

		// Get the data as a table
		Table table = getFieldsAsTable(FIELDS, null);

// TODO: update our (controllers? observers?) with the new data
// 		 NOTE: we want to do this BEFORE writing to the file
//		 as saveTableAs() will munge the table...

		// Write to the file.
		saveTableAs(path, table);
	}

	// Given a table in our format, save it to a file.
	// NOTE: this will modify the table, removing the "native" and "old" columns!!!
	void saveTableAs(String path, Table table) {
		// remove the "native" and "old" column, as we don't write them out
		table.removeColumn("native");
		table.removeColumn("old");

		// Write to the file.
		saveTable(path, table);
	}

	// Create a new table for this config class which is set up to go.
	Table makeFieldTable() {
		Table table = new Table();
		table.addColumn("type");		// field type (eg: "int" or "string" or "color")
		table.addColumn("field");		// name of the field
		table.addColumn("value");		// string value for the field
		table.addColumn("native");		// CURRENT or FUTURE native value of the field (not saved, for internal manipulation)
		table.addColumn("old");			// OLD native value of the field (not saved, used when using as a change log)
		return table;
	}

	// Return output as a Table with columns:
	//		"type", "field", "value" and "native"
	//	where:
	//		- "value" is the stringified value (what we'll write to a file), and
	//		- "native" is the value expressed in table semantics
	//					so you can do `table.getRow(1).getInt("value")`
	// Eats exceptions.
	Table getFieldsAsTable(String[] fieldNames, Table table) {
		if (fieldNames == null) fieldNames = FIELDS;

		// if we weren't passed a table, create one now
		if (table == null) table = makeFieldTable();
		if (fieldNames == null) return table;

		for (String fieldName : fieldNames) {
			try {
				// add row up front, we'll remove it in the exception handler if something goes wrong
				TableRow row = table.addRow();

				// get the field definition
				Field field = getFieldDefinition(fieldName);
				row.setString("field", fieldName);

				// get the type of the field
				int type = getFieldType(field);
				if (type == _UNKNOWN_TYPE) new NoSuchFieldException();
				row.setString("type", getTypeName(type));

				switch (type) {
					case _INT_TYPE:		row.setString("value", 	this.getStringValueForInt(field));
										row.setInt("native", 	this.getValueForInt(field));
										break;

					case _FLOAT_TYPE:	row.setString("value", 	this.getStringValueForFloat(field));
										row.setFloat("native", 	this.getValueForFloat(field));
										break;

					case _BOOLEAN_TYPE:	row.setString("value", 	this.getStringValueForBoolean(field));
										row.setBoolean("native",this.getValueForBoolean(field));
										break;

					case _COLOR_TYPE:	row.setString("value",  this.getStringValueForColor(field));
										row.setInt("native", 	(int) this.getValueForColor(field));
										break;

					case _STRING_TYPE:	row.setString("value",	this.getStringValueForString(field));
										row.setString("native",	this.getStringValueForString(field));
										break;
					default:
						println("Don't know what to do with type of field "+fieldName);
				}
			} catch (Exception e) {
				println("getFieldsAsTable(): error processing field "+fieldName);
				// remove the incomplete row
				table.removeRow(table.getRowCount()-1);
			}
		}
		return table;
	}


////////////////////////////////////////////////////////////
//	Reflection methods
////////////////////////////////////////////////////////////

	////////////////////////////////////////////////////////////
	//	Working with field definitions and types.
	////////////////////////////////////////////////////////////

	// Return the Field definition for a named field.
	// Throws a `NoSuchFieldException` if field not found.
	Field getFieldDefinition(String fieldName) throws NoSuchFieldException {
		Field field Config.class.getDeclaredField(fieldName);
		if (field == null) throw new NoSuchFieldException();
		return field;
	}

	// Return the logical data type for a field, specified by `fieldName` or by `field`,
	//	eg: `_INT_TYPE` or `_FLOAT_TYPE`
	// Returns `_UNKNOWN_TYPE` if we can't find the field or it's not a type we understand.
	// Swallows all exceptions.
	int getFieldType(String fieldName) throws Exception {
		return getFieldType(getFieldDefinition(fieldName), null);
	}
	int getFieldType(Field field, String typeHint) {
		if (field == null) return _UNKNOWN_TYPE;
		if (typeHint != null && typeHint.equals("color")) return _COLOR_TYPE;

		Type type = field.getType();
		if (type == Integer.TYPE) {
			// Ugh.  Processing masquerades `color` variables as `int`s.
			// If the field name ends with "Color", assume it's a color.
			field.getName().endsWith("Color")) return _COLOR_TYPE;
			return _INT_TYPE;
		}
		else if (type == Float.TYPE) 	return _FLOAT_TYPE;
		else if (type == Boolean.TYPE) 	return _BOOLEAN_TYPE;
		else if (type == String.TYPE)	return _STRING_TYPE;
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
			default:			return "unknown";
		}
	}


	////////////////////////////////////////////////////////////
	//	Getting native data types from fields.
	////////////////////////////////////////////////////////////

	// Get string values for primitive types.
	int getValueForInt(Field field) {
		try {
			return field.getInt(this);
		} catch (Exception e) {
			println("ERROR in getValueForInt("+field.getName()+"): returning null");
			return null;
		}
	}
	float getValueForFloat(Field field) {
		try {
			return field.getFloat(this);
		} catch (Exception e) {
			println("ERROR in getValueForFloat("+field.getName()+"): returning null");
			return null;
		}
	}
	boolean getValueForBoolean(Field field) {
		try {
			return field.getBoolean(this);
		} catch (Exception e) {
			println("ERROR in getValueForBoolean("+field.getName()+"): returning null");
			return null;
		}
	}
	color getValueForColor(Field field) {
		try {
			return (color)field.getInt(this);
		} catch (Exception e) {
			println("ERROR in getValueForColor("+field.getName()+"): returning null");
			return null;
		}
	}
	String getValueForString(Field field) {
		try {
			return (String) field.get(this);
		} catch (Exception e) {
			println("ERROR in getValueForString("+field.getName()+"): returning null");
			return null;
		}
	}



	////////////////////////////////////////////////////////////
	//	Coercing native types to strings.
	////////////////////////////////////////////////////////////

	// Return the value for one of our fields, specified by `fieldName` or `field`.
	String getStringValueForField(String fieldName) {
		try {
			return getStringValueForField(getFieldDefinition(fieldName));
		} catch (Exception e) {
			return null;
		}
	}
	String getStringValueForField(Field field) {
		if (field == null) return null;
		try {
			int type = getFieldType(field);
			switch (type) {
				case _INT_TYPE:		return this.getStringValueForInt(field);
				case _FLOAT_TYPE:	return this.getStringValueForFloat(field);
				case _BOOLEAN_TYPE:	return this.getStringValueForBoolean(field);
				case _COLOR_TYPE:	return this.getStringValueForColor(field);
				case _STRING_TYPE:	return this.getStringValueForString(field);
			}
		} catch (Exception e);
		return null;
	}

	// Get string values for primitive types.
	String getStringValueForInt(Field field) {
		try {
			return ""+field.getInt(this);
		} catch (Exception e) {
			println("ERROR in getStringValueForInt("+field.getName()+"): returning null");
			return null;
		}
	}
	String getStringValueForFloat(Field field) {
		try {
			return ""+field.getFloat(this);
		} catch (Exception e) {
			println("ERROR in getStringValueForFloat("+field.getName()+"): returning null");
			return null;
		}
	}
	String getStringValueForBoolean(Field field) {
		try {
			boolean value = field.getBoolean(this);
			return (value ? "true" : "false");
		} catch (Exception e) {
			println("ERROR in getStringValueForBoolean("+field.getName()+"): returning null");
			return null;
		}
	}
	String getStringValueForColor(Field field) {
		try {
			color value = (color)field.getInt(this);
			return "rgba("+(int)red(value)+","+(int)green(value)+","+(int)blue(value)+","+(int)alpha(value)+")";
		} catch (Exception e) {
			println("ERROR in getStringValueForColor("+field.getName()+"): returning null");
			return null;
		}
	}
	String getStringValueForString(Field field) {
		try {
			return (String) field.get(this);
		} catch (Exception e) {
			println("ERROR in getStringValueForString("+field.getName()+"): returning null");
			return null;
		}
	}







////////////////////////////////////////////////////////////
//	Parsing different value types
////////////////////////////////////////////////////////////

	// Convert a color string to a color object (an int).
	// Currently only works for `rgba(r,g,b,a)` format.
	// TODO: type and/or error checking...
	color getColorFieldValue(String stringValue) {
		String[] rgbaMatch = match(stringValue, "rgba\\((\\d+?)\\s*,\\s*(\\d+?)\\s*,\\s*(\\d+?)\\s*,\\s*(\\d+?)\\)");
		if (rgbaMatch != null) {
			int r = int(rgbaMatch[1]);
			int g = int(rgbaMatch[2]);
			int b = int(rgbaMatch[3]);
			int a = int(rgbaMatch[4]);
			println("parsed color rgba("+r+","+g+","+b+","+a+")");
			return color(r,g,b,a);
		}
		println("getColorFieldValue(): color value `"+stringValue+"` not understood.  Returning black.");
		return color(0);
	}




}