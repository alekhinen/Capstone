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

import KinectPV2.KJoint;
import KinectPV2.*;

import oscP5.*;
import netP5.*;

// =======
// Classes
// =======

class SonicColor {
  
  String name;
  color colorValue;
  
  SonicColor(String name, color colorValue) {
    this.name = name;
    this.colorValue = colorValue;
  }
  
  /** 
   * @description: calculates the euclidean distance between this color and a given color.
   */
  double euclideanDistance(color c) {
    float deltaR = red(colorValue) - red(c);
    float deltaG = green(colorValue) - green(c);
    float deltaB = blue(colorValue) - blue(c);
    return Math.sqrt(Math.pow(deltaR, 2) + Math.pow(deltaG, 2) + Math.pow(deltaB, 2));
  }

}

// ================
// Global Variables
// ================

KinectPV2 kinect;

OscP5 oscP5;
NetAddress myRemoteLocation;

int [] rawDepth;
PImage imgColor;

// screen properties
int WIDTH = 1680;
int HEIGHT = 1050;

SonicColor [] colors = {
  new SonicColor("red", color(255, 0, 0)), 
  new SonicColor("green", color(0, 255, 0)), 
  new SonicColor("blue", color(0, 0, 255)), 
  new SonicColor("white", color(255, 255, 255)), 
  new SonicColor("black", color(0, 0, 0))
};

// ================
// Global Functions
// ================

void setup() {
  size(1680, 1050, P3D);

  kinect = new KinectPV2(this);

  kinect.enableDepthImg(true);
  kinect.enableColorImg(true);
  kinect.enableSkeletonColorMap(true);

  kinect.init();
  
  /* start oscP5, listening for incoming messages at port 8000 */
  oscP5 = new OscP5(this,12000);
  
  myRemoteLocation = new NetAddress("192.168.1.5", 8000);
}

void draw() {
  background(0);
  
  image(kinect.getDepthImage(), 0, 0);
  imgColor = kinect.getColorImage();

  //values for [0 - 4500] strip in a 512x424 array.
  rawDepth = kinect.getRawDepthData();
  imgColor = kinect.getColorImage();

  ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonColorMap();

  //individual JOINTS
  for (int i = 0; i < skeletonArray.size(); i++) {
    KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
    if (skeleton.isTracked()) {
      KJoint[] joints = skeleton.getJoints();

      color col  = skeleton.getIndexColor();
      fill(col);
      stroke(col);

      drawDepthFromJoint(joints[KinectPV2.JointType_SpineMid]);
      //draw different color for each hand state
      drawHandState(joints[KinectPV2.JointType_HandRight]);
      drawHandState(joints[KinectPV2.JointType_HandLeft]);
    }
  }

  fill(255, 0, 0);
  text(frameRate, 50, 50);
}

void sendMessage(int depth, int x, int y) {
  /* in the following different ways of creating osc messages are shown by example */
  OscMessage depthMsg = new OscMessage("/1/depth");
  depthMsg.add(depth);
  oscP5.send(depthMsg, myRemoteLocation);
  
  OscMessage coordMsg = new OscMessage("/1/coord");
  coordMsg.add(new int [] {x, y});
  oscP5.send(coordMsg, myRemoteLocation);
}

void drawDepthFromJoint(KJoint joint) {
  color jointColor = getColorInRadius(Math.round(joint.getX()), Math.round(joint.getY()), 15);
  fill(255, 0, 0);
  // map coordinate to get depth
  int x = Math.min(Math.max(Math.round(map(joint.getX(), 0, 1920, 0, 512)), 0), 512); 
  int y = Math.min(Math.max(Math.round(map(joint.getY(), 0, 1080, 0, 424)), 0), 424);
  // x, y coordinates can go negative. workaround is to 
  // use the max of either 0 or the coordinate value.
  // joint.getZ() always returns 0 which is why we need the depth value.
  int z = rawDepth[x+(512*y)];
  
  // map depth value down to [0 - 255]
  background(map(z, 0, 4500, 0, 255));
  
  noStroke();
  fill(jointColor);
  pushMatrix();
  
  // draws the circle at the joint position with the joint color.
  PVector mappedJoint = mapDepthToScreen(joint); 
  translate(mappedJoint.x, mappedJoint.y, mappedJoint.z);
  ellipse(0, 0, 70, 70);
  popMatrix();
  
  // TODO: this sends OSC messages to MaxMSP app.
  sendMessage(Math.round(map(z, 0, 4500, 0, 255)), Math.round(mappedJoint.x), Math.round(mappedJoint.y));
}

/** 
 * @description: Gets the average color in a radius for a point from the HD color image.
 * @returns color
 */
color getColorInRadius(int x, int y, int radius) {
  // Ensure these coordinates don't go outside their bounds (e.g. 0-1920, 0-1080).
  int lowerX = Math.max((x - radius), 0);
  int upperX = Math.min((x + radius), 1920);
  
  int lowerY = Math.max((y - radius), 0);
  int upperY = Math.min((y + radius), 1080);
  
  int increment = 0;
  int r = 0;
  int g = 0;
  int b = 0;
  
  // sum the color values.
  while (lowerX < upperX) {
    int newLowerY = lowerY;
    while (newLowerY < upperY) {
      color c = imgColor.get(lowerX, newLowerY);
      r += Math.round(red(c));
      g += Math.round(green(c));
      b += Math.round(blue(c));
      System.out.println(r + " " + g + " " + b);
      increment += 1;
      newLowerY += 1;
    }
    lowerX += 1;
  }
  
  // divide the sum by the increment to get the average values.
  r = Math.round(r / increment);
  g = Math.round(g / increment);
  b = Math.round(b / increment);
  
  return color(r, g, b);
}

//draw hand state
void drawHandState(KJoint joint) {
  noStroke();
  handState(joint.getState());
  pushMatrix();
  PVector mappedJoint = mapDepthToScreen(joint); 
  translate(mappedJoint.x, mappedJoint.y, mappedJoint.z);
  ellipse(0, 0, 70, 70);
  popMatrix();
}

PVector mapDepthToScreen(KJoint joint) {
  int x = Math.round(map(joint.getX(), 0, 1920, 0, WIDTH));
  int y = Math.round(map(joint.getY(), 0, 1080, 0, HEIGHT));
  int z = Math.round(joint.getZ());
  return new PVector(x, y, z);
}

/*
Different hand state
 KinectPV2.HandState_Open
 KinectPV2.HandState_Closed
 KinectPV2.HandState_Lasso
 KinectPV2.HandState_NotTracked
 */
void handState(int handState) {
  switch(handState) {
  case KinectPV2.HandState_Open:
    fill(0, 255, 0);
    break;
  case KinectPV2.HandState_Closed:
    fill(255, 0, 0);
    break;
  case KinectPV2.HandState_Lasso:
    fill(0, 0, 255);
    break;
  case KinectPV2.HandState_NotTracked:
    fill(255, 255, 255);
    break;
  }
}