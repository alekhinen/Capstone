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
OSC osc;

int FRAME_RATE = 30;
int [] rawDepth;

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
// users that walked off the screen, transitioning to their passing.
ArrayList<User> dyingUsers;

// ================
// Global Functions
// ================

// -----
// Setup 
// -----

void setup() {
  
  fullScreen();
  frameRate(FRAME_RATE);
  stroke(0, 50);
  background(0);

  // initialize kinect stuff. 
  
  initKinect();
  
  // initialize users.
  
  users = new ArrayList<User>();
  dyingUsers = new ArrayList<User>();
  
  // initialize OSC.
  
  osc = new OSC();
  
}

void initKinect() {
  kinect = new KinectPV2(this);

  kinect.enableDepthImg(true);
  kinect.enableSkeletonDepthMap(true);

  kinect.init();
}

// ----
// Draw
// ----

void draw() {
  
  resetScreen();
  clearTheDead();
  
  // get kinect data.
  // note: raw depth contains values [0 - 4500] in a one dimensional 512x424 array.
  rawDepth = kinect.getRawDepthData();
  ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonDepthMap();
  
  // send opening message if we have users.
  if (skeletonArray.size() > 0) {
    osc.openingMessage();
  }
  
  // reset the users and send a closing message to OSC if users change.
  if (skeletonArray.size() != users.size()) {
    // TODO: should we be closing all the users out whenever one comes or leaves?
    osc.closingMessage(users);
    for (User u : users) {
      u.fadeOut();
      u.draw();
      dyingUsers.add(u);
    }
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
    osc.sendMessage(u, i);
  }

  fill(255, 0, 0);
  text(frameRate, 50, 50);
}

// ---------------------
// Draw Helper Functions
// ---------------------

void resetScreen() {
  float colorValue = 0;
  for (User u : users) {
      colorValue += u.getColorFromNodeCollection();
  }
  colorValue /= users.size();
  
  fill(colorValue, 55);
  noStroke();
  rect(0,0,width,height);
}

/*
 * @description: for any user in dyingUsers that's currentFrame is 0,
 *               remove them from the list.
 */
void clearTheDead() {
  int dyingIncrement = 0;
  while (dyingIncrement < dyingUsers.size()) {
    User u = dyingUsers.get(dyingIncrement);
    if (u.currentFrame == 0.0) {
      dyingUsers.remove(dyingIncrement);
    } else {
      u.deathUpdate();
      u.draw();
      dyingIncrement += 1;
    }
  }
}

// ----------
// Generators
// ----------

User generateUser(KJoint chest, KJoint lHand, KJoint rHand) {
  
  int z = getDepthFromJoint(chest);
  PVector mappedJoint = mapDepthToScreen(chest);
  PVector mappedLeft  = mapDepthToScreen(lHand);
  PVector mappedRight = mapDepthToScreen(rHand);
  
  return new User(new PVector(mappedJoint.x, mappedJoint.y, z),
                  mappedLeft,
                  mappedRight);
}

// -------------
// Key Functions
// -------------

void keyReleased() {
  if (key == DELETE || key == BACKSPACE) background(255);
}