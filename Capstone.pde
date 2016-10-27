import KinectPV2.*;

/*
Nick Alekhine
ARTG 4700 - Interaction Team Degree Project
*/

import KinectPV2.KJoint;
import KinectPV2.*;

KinectPV2 kinect;

int [] rawDepth;

void setup() {
  // native is 1920x1080. Resizing causes joint coordinate mismatch (need to manually rescale)
  size(1680, 1050, P3D);

  kinect = new KinectPV2(this);

  kinect.enableDepthImg(true);
  kinect.enableSkeletonDepthMap(true);

  kinect.init();
}

void draw() {
  background(0);

  //values for [0 - 256] strip
  rawDepth = kinect.getRawDepthData();

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
  int z = rawDepth[x*y];
  // joint.getZ() always returns 0.
  String msg = "(x, y, z): " + joint.getX() + ", " + joint.getY() + ", " + z;
  textSize(20);
  text(msg, 50, 100);
  //background(head.getZ() % 255);
}

//draw hand state
void drawHandState(KJoint joint) {
  noStroke();
  handState(joint.getState());
  pushMatrix();
  translate(joint.getX(), joint.getY(), joint.getZ());
  ellipse(0, 0, 70, 70);
  popMatrix();
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