// -------------
// OSC Messaging
// -------------

/** 
 * @description: Handles all OSC communication to/from the MaxMSP app.
 */
class OSC {

  OscP5 oscP5;
  NetAddress myRemoteLocation;
  boolean hasOpened = false;
  
  // ------------
  // Constructors
  // ------------
  
  public OSC() {
    /* start oscP5, listening for incoming messages at port 8000 */
    oscP5 = new OscP5(this,12000);
    myRemoteLocation = new NetAddress("192.168.1.4", 8000);
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
    
    // send gathered node count
    OscMessage gatheredNodes = new OscMessage(oscId + "gatheredNodes");
    gatheredNodes.add(u.getGatheredNodesProportion());
    oscP5.send(gatheredNodes, myRemoteLocation);
    
    // send burst (if burst)
    if (u.hasBurst) {
      OscMessage hasBurst = new OscMessage(oscId + "hasBurst");
      hasBurst.add("burst!!!");
      oscP5.send(hasBurst, myRemoteLocation);
    }
    
  }
  
  /** 
   * @description sends an opening message exactly once.
   */
  void openingMessage() {
    if (!hasOpened) {
      OscMessage open = new OscMessage("/open");
      open.add(1);
      oscP5.send(open, myRemoteLocation);
      hasOpened = true;
    }
  }
  
  /** 
   * @description sends a closing message to OSC for all given users.
   * @arg Listof User users: the users to close out
   */
  void closingMessage(ArrayList<User> users) {
    for (int i = 0; i < users.size(); i++) {
      String oscId = "/" + str(i) + "/";
      OscMessage close = new OscMessage(oscId + "close");
      close.add(0);
      oscP5.send(close, myRemoteLocation);
    }
    // allow for opening message to be sent.
    hasOpened = false;
  }
  
}