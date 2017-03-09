class User {
  
  // ----------
  // Parameters
  // ----------
  
  // skeleton parameters (from kinect)
  
  color cChest;
  String cChestName;
  PVector chestPosn;
  PVector lHandPosn;
  PVector rHandPosn;
  
  // attractor parameters
  
  boolean hasBurst = false;
  
  Attractor leftAttractor;
  Attractor rightAttractor;
  Attractor chestAttractor;
  
  boolean leftMoved  = false;
  boolean rightMoved = false;
  boolean chestMoved = false;
  
  boolean leftJerked  = false;
  boolean rightJerked = false;
  boolean chestJerked = false;
  
  // debug (potentially not...)
  // TODO: need to figure out a better way to do a high pass filter
  double leftDelta = 0;
  double rightDelta = 0;
  double chestDelta = 0;
  
  // node parameters
  
  OriginNode[] nodes;
  ArrayList<Integer> gatheredNodes = new ArrayList<Integer>();
  
  int xCount;
  int yCount;
  
  PVector gridSize;
  float attractorStrength = 3;
  int nodeSize = 5;
  
  // death transitioners
  
  // note: 60 frames is 2 seconds (since we're running at 30fps).
  final float transitionFrame = 60.0;
  float currentFrame = 0.0;
  boolean isDying = false;
  
  // peace transitioners
  
  float peaceColor = 0;
  
  // -----------
  // Constructor
  // -----------
  
  User(PVector chestPosn, 
       PVector lHandPosn, 
       PVector rHandPosn) {
    this.cChest = color(Math.round(random(100, 255)), 
                        Math.round(random(100, 255)), 
                        Math.round(random(100, 255)), 
                        128);
    this.cChestName = getClosestNameFromColor(this.cChest);
    this.chestPosn  = chestPosn;
    this.lHandPosn  = lHandPosn;
    this.rHandPosn  = rHandPosn;
    
    // grid size is a vector where x -> width, y -> height
    this.gridSize = new PVector(Math.round(random(1400, displayWidth)), 
                                Math.round(random(300, Math.max(displayHeight - 200, 300))));
    this.gridSize.x = this.gridSize.y;
    
    xCount = Math.round(random(100, 201));
    yCount = Math.round(random(20, 31));
    
    // diamond generator (specifically to count the number of nodes needed).
    // todo: this should be refactored
    int totalCount = 0;
    int nodeMidHeight = yCount / 2;
    for (int y = 0; y < yCount; y++) {
      int newY = y;
      if (y > nodeMidHeight) {
        newY = this.yCount - y;
      }
      float ratio = (newY * 1.0) / (nodeMidHeight * 1.0);
      int xCountRow = Math.round(ratio * this.xCount);
      totalCount += xCountRow;
    }
    
    
    // note: xCount * yCount
    nodes = new OriginNode[totalCount];
    
    // setup node grid
    initNodeGrid();
    
    // setup attractors
    leftAttractor  = new Attractor(lHandPosn.x, lHandPosn.y);
    rightAttractor = new Attractor(rHandPosn.x, rHandPosn.y);
    chestAttractor = new Attractor(chestPosn.x, chestPosn.y);
  }
  
  void initNodeGrid() {
    // use the chest position as the basis for the position of the user's nodes.
    int seedWidth  = Math.round(this.chestPosn.x + gridSize.x + (gridSize.x / 2));
    int seedHeight = Math.round(this.chestPosn.y + gridSize.y);
    
    // diamond generator (same as in the constructor).
    // todo: this should be refactored.
    int i = 0; 
    int nodeMidHeight = this.yCount / 2;
    for (int y = 0; y < this.yCount; y++) {
      
      int newY = y;
      if (y > nodeMidHeight) {
        newY = this.yCount - y;
      }
      float ratio = (newY * 1.0) / (nodeMidHeight * 1.0);
      int xCountRow = Math.round(ratio * this.xCount);
      System.out.println("xCountRow: " + str(xCountRow));

      for (int x = 0; x < xCountRow; x++) {
        float xPos = x*((gridSize.x * ratio)/(xCountRow-1))+(seedWidth-(gridSize.x * ratio))/2;
        float yPos = y*(gridSize.y/(this.yCount-1))+(seedHeight-gridSize.y)/2;
        this.nodes[i] = new OriginNode(xPos, yPos);
        this.nodes[i].setBoundary(0, 0, width, height);
        this.nodes[i].setDamping(0.019);  //// 0.0 - 1.0
        i++;
      }
    }
  }
  
  // --------
  // Mutators
  // --------
  
  /*
   * @description: the update function when the user is marked as dying.
   */
  void deathUpdate() {
    
    // update transitioners
    
    if (this.currentFrame > 0 && this.isDying) {
      this.currentFrame -= 1;
    }
    
    this.leftAttractor.strength = 0;
    this.rightAttractor.strength = 0;
    this.chestAttractor.strength = 0;
    
    for (int j = 0; j < this.nodes.length; j++) {
      OriginNode currentNode = this.nodes[j];
      currentNode.update();  
    }
    
  }
  
  /*
   * @description: the main update function. (updates User state)
   */
  void update(KJoint chest, KJoint lHand, KJoint rHand) {
    
    // update transitioners
    
    if (this.currentFrame > 0 && this.isDying) {
      this.currentFrame -= 1;
    } else if (this.currentFrame < this.transitionFrame && !this.isDying) {
      this.currentFrame += 1;
    }
    
    // map and update user skeleton.

    int z = getDepthFromJoint(chest);
    // have depth map to the size of the nodes.
    this.nodeSize = Math.round(map(z, 0, 4500, 2, 20));
    
    PVector mappedChest = mapDepthToScreen(chest);
    PVector mappedLeft  = mapDepthToScreen(lHand);
    PVector mappedRight = mapDepthToScreen(rHand);
    
    this.chestPosn = new PVector(mappedChest.x, mappedChest.y, z);
    this.lHandPosn = mappedLeft;
    this.rHandPosn = mappedRight;
    
    // note: could be interesting to increase strength as hands get closer. 
    float handDist = (float) euclideanDistance(this.lHandPosn, this.rHandPosn);
    this.attractorStrength = 2.5 - map(handDist, 0, 1080, 0.1, 2.4);
    
    // update attractor positions.
    
    this.updateAttractors(lHand, rHand);
    
    // reset gathered nodes + burst
    
    // clear out all nodes past the 30th element.
    int gatheredLength = this.gatheredNodes.size();
    if (gatheredLength > 30) {
      this.gatheredNodes = new ArrayList<Integer>(this.gatheredNodes.subList(0, 30));
      gatheredLength = 30;
    }
    
    // get the last element.
    int previouslyGathered = 0;
    if (gatheredLength > 0) {
      previouslyGathered = this.gatheredNodes.get(gatheredLength - 1);
    }
    int currentlyGatheredNodes = 0;
    
    // update the user's node positions.
    
    for (int j = 0; j < this.nodes.length; j++) {
      OriginNode currentNode = this.nodes[j];
      currentNode.trackAttractor = false;
      
      leftAttractor.attract(currentNode);
      rightAttractor.attract(currentNode);
      chestAttractor.attract(currentNode);
      
      // todo: the toOpacity should be refactored somehow...
      
      if (leftAttractor.dist(currentNode) < leftAttractor.radius / 2) {
        currentNode.trackAttractor = true;
        currentNode.trackedAttractor = leftAttractor;
        currentlyGatheredNodes += 1;
        if (leftMoved) {
          currentNode.resetOpacity();
        }
        currentNode.toOpacity = 255;
      } else if (rightAttractor.dist(currentNode) < rightAttractor.radius / 2) {
        currentNode.trackAttractor = true;
        currentNode.trackedAttractor = rightAttractor;
        currentlyGatheredNodes += 1;
        if (rightMoved) {
          currentNode.resetOpacity();
        }
        currentNode.toOpacity = 255;
      } else if (chestAttractor.dist(currentNode) < chestAttractor.radius / 2) {
        currentNode.trackAttractor = true;
        currentNode.trackedAttractor = chestAttractor;
        currentlyGatheredNodes += 1;
        if (chestMoved) {
          currentNode.resetOpacity();
        }
        currentNode.toOpacity = 255;
      } else {
        currentNode.resetOpacity();
      }
  
      this.nodes[j].update();
    }
    
    // add the current amount to the beginning of the list
    this.gatheredNodes.add(0, currentlyGatheredNodes);
    this.hasBurst = previouslyGathered - currentlyGatheredNodes > 300;
    
  }
  
  void updateAttractors(KJoint lHand, KJoint rHand) {
    
    // determine if attractors moved
    
    double currentLeftDelta  = this.leftDelta;
    double currentRightDelta = this.rightDelta;
    double currentChestDelta = this.chestDelta;
    
    this.leftDelta  = euclideanDistance(this.lHandPosn, new PVector(leftAttractor.x, leftAttractor.y));
    this.rightDelta = euclideanDistance(this.rHandPosn, new PVector(rightAttractor.x, rightAttractor.y));
    this.chestDelta = euclideanDistance(this.chestPosn, new PVector(chestAttractor.x, chestAttractor.y));
    
    leftMoved  = leftDelta  > 10;
    rightMoved = rightDelta > 10;
    chestMoved = chestDelta > 10;
    
    // note: there's been a lot of intermittent spikes in value. so to make sure
    //       that we aren't registering a spike we are keeping a top level value to
    //       do a sort of high pass filter on the signal.
    leftJerked  = leftDelta > 100 && Math.abs(currentLeftDelta - this.leftDelta) < 50;
    rightJerked = rightDelta > 100 && Math.abs(currentRightDelta - this.rightDelta) < 50;
    chestJerked = chestDelta > 100; // currently not used
    
    // update positions
    
    leftAttractor.x = this.lHandPosn.x;
    leftAttractor.y = this.lHandPosn.y;
    
    rightAttractor.x = this.rHandPosn.x;
    rightAttractor.y = this.rHandPosn.y;
    
    chestAttractor.x = this.chestPosn.x;
    chestAttractor.y = this.chestPosn.y;
    
    // update state and strength
    
    if (leftJerked) {
      // shoot the particles out if left hand jerked.
      leftAttractor.strength = -5000;
      leftAttractor.setMode(1);
    } else {
      if (lHand.getState() == KinectPV2.HandState_Closed) {
        // spiral repulsor is mode 2
        leftAttractor.strength = attractorStrength;
        leftAttractor.setMode(2);
      } else {
        // attractor
        leftAttractor.strength = attractorStrength; 
        leftAttractor.setMode(1);
      }
    }
    
    if (rightJerked) {
      // shoot the particles out if right hand jerked.
      // TODO: maybe instead of shooting the particles out, we tell the particles
      //       that are linked to stay linked (otherwise de-link.
      rightAttractor.strength = -5000;
      rightAttractor.setMode(1);
    } else {
      rightAttractor.setMode(1);
      if (rHand.getState() == KinectPV2.HandState_Closed) {
        // super-strong attractor
        rightAttractor.strength = attractorStrength * 4; 
      } else {
        // attractor
        rightAttractor.strength = attractorStrength; 
      }
    }
  }
  
  // --------------
  // Draw Functions
  // --------------
  
  void draw() {
    
    // draw each node
    for (OriginNode currentNode : this.nodes) {
      float colorMapping = map(currentNode.opacity, 128, 255, 0, 20);
      // opacity is based off the proportion of currentFrame to transitionFrame.
      fill(red(this.cChest) + colorMapping, 
           green(this.cChest) + colorMapping, 
           blue(this.cChest) + colorMapping,
           currentNode.opacity * (this.currentFrame / this.transitionFrame));
      rect(currentNode.x, currentNode.y, nodeSize, nodeSize);
    }
    
    //drawDebug();
  }
  
  /*
   * @description draws text related to debugging the program. 
   */
  void drawDebug() {
    fill(255,0,0);
    text(Math.round(this.getAverageNodeVelocity() * 1000), 50, 70);
    
    if (this.gatheredNodes.size() > 0) {
      text(Math.round(this.gatheredNodes.get(0)), 50, 90);
    }
    if (this.gatheredNodes.size() >= 30) {
      text(Math.round(this.gatheredNodes.get(29)), 50, 105);
    }
    text(str(this.hasBurst), 50, 120);
    text(str(this.getGatheredNodesProportion()), 50, 140);
  }
  
  // ----------------
  // Helper Functions
  // ----------------
  
  /*
   * @description returns the average velocity for this user's nodes.
   * @note seems to always be in the range of [0 - 4].
   */
  public double getAverageNodeVelocity() {    
    double result = 0;
    for (int j = 0; j < nodes.length; j++) {
      double velocity = Math.sqrt( Math.pow(nodes[j].velocity.x, 2) + Math.pow(nodes[j].velocity.y, 2) );
      result += velocity;
    }
    result = result / nodes.length;
    return result;
  }
  
  /*
   * @description returns the proportion of currently gathered nodes.
   * @note returns anywhere from 0 to 100.
   */
  public int getGatheredNodesProportion() {
    int amountNodes = this.nodes.length;
    int amountGathered = 0;
    
    if (this.gatheredNodes.size() > 0) {
      amountGathered = this.gatheredNodes.get(0);
    }
    
    return Math.round(((float) amountGathered / amountNodes) * 100);
  }
  
  public int getColorFromNodeCollection() {
    int gatheredProportion = this.getGatheredNodesProportion();
    int baseColor = Math.round(map(gatheredProportion, 0, 100, 0, 33));
    
    if (gatheredProportion == 100 && this.peaceColor < (255 - 33)) {
      this.peaceColor += 0.25;
    }  else if (this.peaceColor > 0) {
      this.peaceColor -= 1;
    }
    int finalColor = baseColor + Math.round(this.peaceColor);
    if (finalColor == 255 && this.nodeSize < 30) {
      this.nodeSize += 1;
    }
    return finalColor;
  }
  
  // -------
  // Closing
  // -------
  
  void fadeOut() {
    isDying = true;
  }
  
}