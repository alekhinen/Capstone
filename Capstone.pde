/*
Nick Alekhine
ARTG 4700 - Interaction Team Degree Project

Notes on KinectPV2:
- Color images always returned in 1920x1080.
- Everything else (depth, skeleton, IR) always returned in 512x424.
*/

import KinectPV2.KJoint;
import KinectPV2.*;

KinectPV2 kinect;

int [] rawDepth;

// screen properties
int WIDTH = 1680;
int HEIGHT = 1050;

void setup() {
  size(1680, 1050, P3D);

  kinect = new KinectPV2(this);

  kinect.enableDepthImg(true);
  kinect.enableSkeletonDepthMap(true);

  kinect.init();
}

void draw() {
  background(0);
  
  image(kinect.getDepthImage(), 0, 0);

  //values for [0 - 4500] strip in a 512x424 array.
  rawDepth = kinect.getRawDepthData();
  System.out.println(rawDepth.length);

  ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonDepthMap();

  //individual JOINTS
  for (int i = 0; i < skeletonArray.size(); i++) {
    KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
    if (skeleton.isTracked()) {
      KJoint[] joints = skeleton.getJoints();

      color col  = skeleton.getIndexColor();
      fill(col);
      stroke(col);

      drawDepthFromJoint(joints[KinectPV2.JointType_Head]);
      //draw different color for each hand state
      drawHandState(joints[KinectPV2.JointType_HandRight]);
      drawHandState(joints[KinectPV2.JointType_HandLeft]);
    }
  }

  fill(255, 0, 0);
  text(frameRate, 50, 50);
}

void drawDepthFromJoint(KJoint joint) {
  fill(255, 0, 0);
  int x = Math.round(joint.getX());
  int y = Math.round(joint.getY());
  int z = rawDepth[x+(512*y)];
  // joint.getZ() always returns 0.
  String msg = "(x, y, z): " +x + ", " +y + ", " + z;
  textSize(20);
  text(msg, 50, 100);
  background(z % 255);
  
  noStroke();
  fill(100, 100, 100);
  pushMatrix();
  PVector mappedJoint = mapDepthToScreen(joint); 
  translate(mappedJoint.x, mappedJoint.y, mappedJoint.z);
  ellipse(0, 0, 70, 70);
  popMatrix();
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
  int x = Math.round(map(joint.getX(), 0, 512, 0, WIDTH));
  int y = Math.round(map(joint.getY(), 0, 512, 0, HEIGHT));
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