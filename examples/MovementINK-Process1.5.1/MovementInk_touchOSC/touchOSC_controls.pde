/*keep track of the changes I made::

color changes happended in this function:  public void updateAndRenderGL() {
  
and here:
public void updateAndRenderGL() {
    
//----------------------------------------------------------------bring in the TOUCH OSC variables
    viscosity = viscosityOSC;
    
  
*/


// create function to recv and parse oscP5 messages
void oscEvent (OscMessage theOscMessage) {

  //------------------------------------debug Print upon receive OSC Message
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());
  
  
  
  String addr = theOscMessage.addrPattern();  //never did fully understand string syntaxxx
  float val = theOscMessage.get(0).floatValue(); // this is returning the get float from bellow

  if (addr.equals("/color/faderRed")) {  //remove the if statement and put it in draw
    faderRed = val; //assign received value.  then call function in draw to pass parameter
    //print(faderRed);
  }
  else if (addr.equals("/color/faderGreen")) {
    faderGreen = val;// assigned receive val. prepare to pass parameter in called function: end of draw
  }
  else if (addr.equals("/color/faderBlue")) {
    faderBlue = val;// assigned received val from tilt and prepare to pass in function
  }
  else if (addr.equals("/color/faderAlpha")) {
    faderAlpha = val;
  }
  else if (addr.equals("/P_Manager/viscosity")) {
    viscosityOSC = val;
  }
  
  
  else if (addr.equals("/P_Manager/forceMulti")) {
    forceMultiOSC= val;
  }
  else if (addr.equals("/P_Manager/accFriction")) {
    accFrictionOSC = val;
  }
  else if (addr.equals("/P_Manager/accLimiter")) {
    accLimiterOSC = val;
  }
  
  
  else if (addr.equals("/P_Manager/noiseStrength")) {
    noiseStrengthOSC = val;
  }
  else if (addr.equals("/P_Manager/noiseScale")) {
    noiseScaleOSC =val; //check out this vector, bro IF Val = 1, then isHit returns positive
  }
  else if (addr.equals("/P_Manager/zNoise")) {
   zNoiseVelocityOSC = val ; //check out this vector, bro IF Val = 1, then isHit returns positive
  }
  else if (addr.equals("/P_Manager/genSpread")) {
    generateSpreadOSC = val ; //check out this vector, bro IF Val = 1, then isHit returns positive
  }
  
  
  /*
  else if (addr.equals("/1/hotspotFL")) {
    hotspotFL.checkOSC(val) ; //check out this vector, bro IF Val = 1, then isHit returns positive
  }
  else if (addr.equals("/1/hotspotF")) {
    hotspotF.checkOSC(val) ; //check out this vector, bro IF Val = 1, then isHit returns positive
  }
  else if (addr.equals("/1/hotspotFR")) {
    hotspotFR.checkOSC(val) ; //check out this vector, bro IF Val = 1, then isHit returns positive
  }
  else if (addr.equals("/1/hotspotMR")) {
    hotspotMR.checkOSC(val) ; //check out this vector, bro IF Val = 1, then isHit returns positive
  }
  else if (addr.equals("/1/hotspotBR")) {
    hotspotBR.checkOSC(val) ; //check out this vector, bro IF Val = 1, then isHit returns positive
  }
  */
}



