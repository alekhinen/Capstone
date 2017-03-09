// -----------------
// Utility Functions
// -----------------

void drawLine(PVector[] points, boolean curves) {
  // this funktion draws a line from an array of PVectors
  // curves : if true, points will be connected with curves (a bit like curveVertex, 
  //          not as accurate, but faster) 

  PVector d1 = new PVector();
  PVector d2 = new PVector();
  float l1, l2, q0, q1, q2;

  // first and last index to be drawn
  //int i1 = (points.length-1) / 2 - len;
  //int i2 = (points.length-1) / 2 + len;
  
  int i1 = 0;
  int i2 = points.length - 1;

  // draw first point
  beginShape();
  vertex(points[i1].x, points[i1].y);
  q0 = 0.5;

  for (int i = i1+1; i <= i2; i++) {
    if (curves) {
      if (i < i2) {
        // distance to previous and next point
        l1 = PVector.dist(points[i], points[i-1]);
        l2 = PVector.dist(points[i], points[i+1]);
        // vector form previous to next point
        d2 = PVector.sub(points[i+1], points[i-1]);
        // shortening of this vector
        d2.mult(0.333);
        // how to distribute d2 to the anchors
        q1 = l1 / (l1+l2);
        q2 = l2 / (l1+l2);
      } 
      else {
        // special handling for the last index
        l1 = PVector.dist(points[i], points[i-1]);
        l2 = 0;
        d2.set(0, 0, 0);
        q1 = l1 / (l1+l2);
        q2 = 0;
      }
      // draw bezierVertex
      bezierVertex(points[i-1].x+d1.x*q0, points[i-1].y+d1.y*q0, 
      points[i].x-d2.x*q1, points[i].y-d2.y*q1,
      points[i].x, points[i].y);
      // remember d2 and q2 for the next iteration
      d1.set(d2);
      q0 = q2;
    } 
    else {
      vertex(points[i].x, points[i].y);
    }  
  }

  endShape();
}

/**
 * @description: 
 * @returns integer value between [0 - 4500]
 */
int getDepthFromJoint(KJoint joint) {
  // map the (x, y) from depth joint to find Z from depth image.
  // note 1: (x, y) can go negative or beyond the upper limit. 
  //                workaround is to use the max of either 0 or the coordinate value
  //                and the min of the bound or coordinate value.
  // note 2: joint.getZ() always returns 0 which is why we need the depth value.
  int x = Math.min(Math.max(Math.round(joint.getX()), 0), 512);
  int y = Math.min(Math.max(Math.round(joint.getY()), 0), 423);
  int z = rawDepth[x+(512*y)]; // todo: this keeps on breaking (going out of bounds??)
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