/*******************************************************************
 *	VideoAlchemy "Juggling Molecules" Interactive Light Sculpture
 *	(c) 2011-2013 Jason Stephens & VideoAlchemy Collective
 *
 *	See `credits.txt` for base work and shouts out.
 *	Published under CC Attrbution-ShareAlike 3.0 (CC BY-SA 3.0)
 *		            http://creativecommons.org/licenses/by-sa/3.0/
 *******************************************************************/

////////////////////////////////////////////////////////////
//
//  OmiCron Mapping Setup
//
////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////
//	Interaction between particles and flow field.
////////////////////////////////////////////////////////////
int gBlueButtonIndex = 7;
int gBlueLeftIndex = 1;
int gBlueRightIndex = 2;

int gGreenButtonIndex = 8;
int gGreenLeftIndex = 3;
int gGreenRightIndex = 4;

int gRedButtonIndex = 9;
int gRedLeftIndex = 5;
int gRedRightIndex = 0;

int gOhmIndex = 6;

int gSnapperIndex = 10;


// Process a packet of OmiCron data from the Serial port.
void processOmiCronPacket(int[] omiCronData) {
	float unitValue;

	// if Blue Left control affects particleMaxCount:
	// get blue left knob current value as "unit" measurement
	unitValue = omiCronToUnit(  omiCronData[gBlueLeftIndex]  );
	// set config property with unit value
	gConfig.particleMaxCount = gConfig.particleMaxCountFromUnit(unitValue);


	// if Blue Right control affects particleColor:
	// get blue right nob current value as "unit" measurement
	unitValue = omiCronToUnit(  omiCronData[gBlueRightIndex]  );
	// set config property with unit value
	gConfig.particleColor = gConfig.particleColorFromUnit(unitValue);

	//....repeat for all controls....

	// tell TouchOSC about the new state
	outputStateToOSCController();
}




// Convert an OmiCron variable (0..1023) to a "unit" vector (0..1).
float omiCronToUnit(int omiCronValue) {
	return map((float) omiCronValue, 0 , 1023, 0, 1);
}
