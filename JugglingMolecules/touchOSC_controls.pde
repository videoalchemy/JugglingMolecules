/*keep track of the changes I made::

color changes happended in this function:  public void updateAndRenderGL() {

and here:
public void updateAndRenderGL() {

//----------------------------------------------------------------bring in the TOUCH OSC variables
    viscosity = particleViscocityOSC;


*/


// create function to recv and parse oscP5 messages
void oscEvent (OscMessage theOscMessage) {

  //------------------------------------debug Print upon receive OSC Message
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());



  String addr = theOscMessage.addrPattern();  //never did fully understand string syntaxxx
  float val = theOscMessage.get(0).floatValue(); // this is returning the get float from bellow

  if      (addr == "/color/faderRed")          gConfig.particleRed = val;
  else if (addr == "/color/faderGreen")        gConfig.particleGreen = val;
  else if (addr == "/color/faderBlue")         gConfig.particleBlue = val;
  else if (addr == "/color/faderAlpha")        gConfig.particleAlpha = val;
  else if (addr == "/P_Manager/viscosity")     gConfig.particleViscocity = val;

  else if (addr == "/P_Manager/forceMulti")    gConfig.particleForceMultiplier = val;
  else if (addr == "/P_Manager/accFriction")   gConfig.particleAccelerationFriction = val;
  else if (addr == "/P_Manager/accLimiter")    gConfig.particleAccelerationLimiter = val;

  else if (addr == "/P_Manager/noiseStrength") gConfig.noiseStrength = val;
  else if (addr == "/P_Manager/noiseScale")    gConfig.noiseScale = val;
  else if (addr == "/P_Manager/zNoise")        gConfig.particleNoiseVelocity = val;
  else if (addr == "/P_Manager/genSpread")     gConfig.particleGenerateSpread = val;

}



