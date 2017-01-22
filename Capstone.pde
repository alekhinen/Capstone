/*
Nick Alekhine
ARTG 4700 - Interaction Team Degree Project

Notes on KinectPV2:
- Color images always returned in 1920x1080.
- Everything else (depth, skeleton, IR) always returned in 512x424.
*/

// =======
// Imports
// =======

import generativedesign.*;

import KinectPV2.KJoint;
import KinectPV2.*;

import oscP5.*;
import netP5.*;

// ================
// Global Variables
// ================

KinectPV2 kinect;

OscP5 oscP5;
NetAddress myRemoteLocation;

int [] rawDepth;
PImage imgColor;

// static list of colors.
SonicColor [] sonicColors = {
  new SonicColor("red", color(255, 0, 0)), 
  new SonicColor("green", color(0, 255, 0)), 
  new SonicColor("blue", color(0, 0, 255)), 
  new SonicColor("white", color(255, 255, 255)), 
  new SonicColor("black", color(0, 0, 0))
};

// dynamic list of users.
ArrayList<User> users;

// ================
// Global Functions
// ================

// -----
// Setup 
// -----

void setup() {
  size(displayWidth, displayHeight, P3D);

  // initialize kinect stuff. 
  initKinect();
  // initialize users.
  users = new ArrayList<User>();
  // initialize OSC.
  initOsc();
  
  stroke(0, 50);
  background(255);
}

void initKinect() {
  kinect = new KinectPV2(this);

  kinect.enableDepthImg(true);
  kinect.enableColorImg(true);
  kinect.enableSkeletonColorMap(true);

  kinect.init();
}

void initOsc() {
  /* start oscP5, listening for incoming messages at port 8000 */
  oscP5 = new OscP5(this,12000);
  myRemoteLocation = new NetAddress("192.168.1.2", 8000);
}

// ----
// Draw
// ----

void draw() {
  // raw depth contains values [0 - 4500]in a one dimensional 512x424 array.
  rawDepth = kinect.getRawDepthData();
  // color image from the kinect.
  imgColor = kinect.getColorImage();
  // skeletons (aka users)
  ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonColorMap();

  // reset the screen.
  fill(255);
  noStroke();
  rect(0,0,width,height);
  
  // reset the users and send a closing message to OSC if users change.
  if (skeletonArray.size() != users.size()) {
    // TODO: should we be closing all the users out whenever one comes or leaves?
    closingMessage(users);
    users = new ArrayList<User>();
  }
  
  for (int i = 0; i < skeletonArray.size(); i++) {
    KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
    if (skeleton.isTracked()) {
      KJoint[] joints = skeleton.getJoints();
      
      boolean userExists = i < users.size();
      User currentUser;
      
      // if the user doesn't already exist, generate.
      if (!userExists) {
        currentUser = generateUser(joints[KinectPV2.JointType_SpineMid],
                                   joints[KinectPV2.JointType_HandLeft],
                                   joints[KinectPV2.JointType_HandRight]);
        // add to beginning of list
        users.add(currentUser);
        currentUser.draw();
      } else {
        userExists = true;
        currentUser = users.get(i);
        currentUser.update(joints[KinectPV2.JointType_SpineMid], 
                           joints[KinectPV2.JointType_HandLeft],
                           joints[KinectPV2.JointType_HandRight]);
        currentUser.draw();
      }

    }
  }
  
  // send OSC message about User.
  for (int i = 0; i < users.size(); i++) {
    User u = users.get(i);
    sendMessage(u, i);
  }

  fill(255, 0, 0);
  text(frameRate, 50, 50);
}

// draw hand state
void drawHandState(KJoint joint) {
  noStroke();
  handState(joint.getState());
  
  PVector mappedJoint = mapDepthToScreen(joint); 
  
  // draws the chest as a circle with the user's color.
  pushMatrix();
  translate(mappedJoint.x, mappedJoint.y, 0);
  //fill(u.cChest); perhaps this should be the color of the user.
  ellipse(0, 0, 30, 30);
  popMatrix();
  
}

// ----------
// Generators
// ----------

User generateUser(KJoint chest, KJoint lHand, KJoint rHand) {
  // TODO: should be a static function in User class. 
  color jointColor = getColorInRadius(Math.round(chest.getX()), Math.round(chest.getY()), 5);
  // increase exposure of color by 50. TODO: needs more work to be accurate.
  jointColor = color(red(jointColor) + 50, green(jointColor) + 50, blue(jointColor));
  String colorName = getClosestNameFromColor(jointColor);
  int z = getDepthFromJoint(chest);
  
  PVector mappedJoint = mapDepthToScreen(chest);
  PVector mappedLeft  = mapDepthToScreen(lHand);
  PVector mappedRight = mapDepthToScreen(rHand);
  
  return new User(jointColor, 
                  colorName, 
                  new PVector(mappedJoint.x, mappedJoint.y, z),
                  mappedLeft,
                  mappedRight);
}

// -------------
// Key Functions
// -------------

void keyReleased() {
  if (key == DELETE || key == BACKSPACE) background(255);


  // switch draw loop on/off
  // TODO: this should be for fullscreen toggling
  //if (key == 'f' || key == 'F') freeze = !freeze;
  //if (freeze == true) noLoop();
  //else loop();
}