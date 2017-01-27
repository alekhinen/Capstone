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
    myRemoteLocation = new NetAddress("192.168.1.3", 8000);
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
    
    // send the (x, y, z) coord of the user's chest.
    OscMessage coordMsg = new OscMessage(oscId + "coord");
    coordMsg.add(new float [] {u.chestPosn.x, u.chestPosn.y, u.chestPosn.z});
    oscP5.send(coordMsg, myRemoteLocation);
    
    OscMessage lHandMsg = new OscMessage(oscId + "lHandCoord");
    lHandMsg.add(new float [] {u.lHandPosn.x, u.lHandPosn.y});
    oscP5.send(lHandMsg, myRemoteLocation);
    
    OscMessage rHandMsg = new OscMessage(oscId + "rHandCoord");
    rHandMsg.add(new float [] {u.rHandPosn.x, u.rHandPosn.y});
    oscP5.send(rHandMsg, myRemoteLocation);
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