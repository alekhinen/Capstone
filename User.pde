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
  
  // node + attractor parameters
  
  OriginNode[] nodes;
  
  Attractor leftAttractor;
  Attractor rightAttractor;
  Attractor chestAttractor;
  
  int xCount;
  int yCount;
  
  PVector gridSize;
  float attractorStrength = 3;
  int nodeSize = 5;
  
  // -----------
  // Constructor
  // -----------
  
  User(color cChest, 
       String cChestName, 
       PVector chestPosn, 
       PVector lHandPosn, 
       PVector rHandPosn) {
    this.cChest = color(Math.round(random(100, 255)), 
                        Math.round(random(100, 255)), 
                        Math.round(random(100, 255)), 100);
    this.cChestName = cChestName;
    this.chestPosn = chestPosn;
    this.lHandPosn = lHandPosn;
    this.rHandPosn = rHandPosn;
    
    // grid size is a vector where x -> width, y -> height
    this.gridSize = new PVector(Math.round(random(1400, displayWidth)), 
                                Math.round(random(300, displayHeight)));
    this.gridSize.x = this.gridSize.y;
    
    xCount = Math.round(random(100, 201));
    yCount = Math.round(random(20, 31));
    
    // diamond generator (specifically to count the number of nodes needed).
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
    leftAttractor  = new Attractor(0, 0);
    rightAttractor = new Attractor(0, 0);
    chestAttractor = new Attractor(0, 0);
  }
  
  void initNodeGrid() {
    // use a variable height and width to position the nodes randomly within the size of the screen.
    int seedWidth  = Math.round(random(gridSize.x, width));
    int seedHeight = Math.round(random(gridSize.y, height));
    
    // diamond generator (same as in the constructor).
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
        this.nodes[i].setDamping(0.01);  //// 0.0 - 1.0
        i++;
      }
    }
  }
  
  // --------
  // Mutators
  // --------
  
  void update(KJoint chest, KJoint lHand, KJoint rHand) {
    
    // map and update user skeleton.

    int z = getDepthFromJoint(chest);
    
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
    
    leftAttractor.x = this.lHandPosn.x;
    leftAttractor.y = this.lHandPosn.y;
    
    rightAttractor.x = this.rHandPosn.x;
    rightAttractor.y = this.rHandPosn.y;
    
    chestAttractor.x = this.chestPosn.x;
    chestAttractor.y = this.chestPosn.y;
    
    // update user node positions.
    
    for (int j = 0; j < this.nodes.length; j++) {
      if (lHand.getState() == KinectPV2.HandState_Closed) {
        // spiral repulsor
        leftAttractor.strength = attractorStrength;
        leftAttractor.setMode(2);
      } else {
        // attractor
        leftAttractor.strength = attractorStrength; 
        leftAttractor.setMode(1);
      }
      
      if (rHand.getState() == KinectPV2.HandState_Closed) {
        // super-strong attractor
        rightAttractor.strength = attractorStrength * 4; 
      } else {
        // attractor
        rightAttractor.strength = attractorStrength; 
      }
      
      leftAttractor.attract(this.nodes[j]);
      rightAttractor.attract(this.nodes[j]);
      chestAttractor.attract(this.nodes[j]);
  
      this.nodes[j].update();
    }
    
  }
  
  // -------------
  // ??? Functions
  // -------------
  
  void draw() {
    
    // draw each node
    
    for (int j = 0; j < this.nodes.length; j++) {
      fill(this.cChest);
      rect(this.nodes[j].x, this.nodes[j].y, nodeSize, nodeSize);
    }
    
    fill(255,0,0);
    text(Math.round(this.getAverageNodeVelocity() * 1000), 50, 70);
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
}