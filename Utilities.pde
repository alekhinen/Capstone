// -----------------
// Utility Functions
// -----------------

/**
 * @description: 
 * @returns integer value between [0 - 4500]
 */
int getDepthFromJoint(KJoint joint) {
  // map the (x, y) from depth joint to find Z from depth image.
  // note 1: (x, y) can go negative. workaround is to use the max of either 0 or the coordinate value.
  //                (but really we're just using the absolute value..)
  // note 2: joint.getZ() always returns 0 which is why we need the depth value.
  int x = Math.abs(Math.round(joint.getX()));
  int y = Math.abs(Math.round(joint.getY()));
  int z = rawDepth[x+(512*y)];
  return z;
}

/**
 * @description: returns the name of the sonic color which is closest to the given color.
 */
String getClosestNameFromColor(color c) {
  String bestName = "";
  double closestDist = -1;
  for (SonicColor sColor : sonicColors) {
    double dist = sColor.euclideanDistance(c);
    if (closestDist == -1 || dist < closestDist) {
      closestDist = dist;
      bestName = sColor.name;
    }
  }
  return bestName;
};

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
  
  int increment = 1;
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

PVector mapDepthToScreen(KJoint joint) {
  int x = Math.round(map(joint.getX(), 0, 512, 0, displayWidth));
  int y = Math.round(map(joint.getY(), 0, 424, 0, displayHeight));
  int z = Math.round(joint.getZ());
  return new PVector(x, y, z);
}

double euclideanDistance(PVector a, PVector b) {
  return Math.sqrt(Math.pow((a.x - b.x), 2) + Math.pow((a.y - b.y), 2));
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