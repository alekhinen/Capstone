// -------------
// OSC Messaging
// -------------

/** 
 * @description: Handles all OSC communication to/from the MaxMSP app.
 */
class OSC {

  OscP5 oscP5;
  NetAddress myRemoteLocation;
  
  // ------------
  // Constructors
  // ------------
  
  public OSC() {
    /* start oscP5, listening for incoming messages at port 8000 */
    oscP5 = new OscP5(this,12000);
    myRemoteLocation = new NetAddress("192.168.1.2", 8000);
  }
  
  // ---------
  // Functions
  // ---------
  
  /** 
   * @description sends the given user's information over OSC.
   * @arg User u: the user
   * @arg int id: the unique id of the user to use when sending the OSC message.
   */
  void sendMessage(User u, int id) {
    String oscId = "/" + str(id) + "/";
    
    // send name of the user's chest color.
    OscMessage colorName = new OscMessage(oscId + "colorName");
    colorName.add(u.cChestName);
    oscP5.send(colorName, myRemoteLocation);
    
    // send rgb value of the user's chest color
    OscMessage rgbColor = new OscMessage(oscId + "rgbColor");
    rgbColor.add(new float [] {red(u.cChest), green(u.cChest), blue(u.cChest)});
    oscP5.send(rgbColor, myRemoteLocation);
        
    // send leftAttractor strength
    OscMessage lAttractor = new OscMessage(oscId + "leftAttractor");
    lAttractor.add(u.leftAttractor.strength);
    oscP5.send(lAttractor, myRemoteLocation);
    
    // send rightAttractor strength
    OscMessage rAttractor = new OscMessage(oscId + "rightAttractor");
    rAttractor.add(u.rightAttractor.strength);
    oscP5.send(rAttractor, myRemoteLocation);
    
    // send average node velocity
    OscMessage nodeVelocity = new OscMessage(oscId + "nodeVelocity");
    nodeVelocity.add(Math.round(u.getAverageNodeVelocity() * 1000));
    oscP5.send(nodeVelocity, myRemoteLocation);
  }
  
  /** 
   * @description sends a closing message to OSC for all given users.
   * @arg Listof User users: the users to close out
   */
  void closingMessage(ArrayList<User> users) {
    for (int i = 0; i < users.size(); i++) {
      String oscId = "/" + str(i) + "/";
      OscMessage close = new OscMessage(oscId + "close");
      oscP5.send(close, myRemoteLocation);
    }
  }
  
}