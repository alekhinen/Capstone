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