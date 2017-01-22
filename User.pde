class User {
  
  // ----------
  // Parameters
  // ----------
  
  color cChest;
  String cChestName;
  PVector chestPosn;
  PVector lHandPosn;
  PVector rHandPosn;
  
  OriginNode[] nodes;
  
  Attractor leftAttractor;
  Attractor rightAttractor;
  
  int xCount;
  int yCount;
  
  float gridSize = 300;
  float attractorStrength = 3;
  
  // -----------
  // Constructor
  // -----------
  
  User(color cChest, 
       String cChestName, 
       PVector chestPosn, 
       PVector lHandPosn, 
       PVector rHandPosn) {
    this.cChest = cChest;
    this.cChestName = cChestName;
    this.chestPosn = chestPosn;
    this.lHandPosn = lHandPosn;
    this.rHandPosn = rHandPosn;
    
    xCount = Math.round(random(50, 251));
    yCount = Math.round(random(50, 251));
    
    // note: xCount * yCount
    nodes = new OriginNode[xCount*yCount];
    
    // setup node grid
    initNodeGrid();
    
    // setup attractors
    leftAttractor = new Attractor(0, 0);
    rightAttractor = new Attractor(0, 0);
  }
  
  void initNodeGrid() {
    int i = 0; 
    for (int y = 0; y < this.yCount; y++) {
      for (int x = 0; x < this.xCount; x++) {
        float xPos = x*(gridSize/(this.xCount-1))+(width-gridSize)/2;
        float yPos = y*(gridSize/(this.yCount-1))+(height-gridSize)/2;
        this.nodes[i] = new OriginNode(xPos, yPos);
        this.nodes[i].setBoundary(0, 0, width, height);
        this.nodes[i].setDamping(0.02);  //// 0.0 - 1.0
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
    
    PVector mappedJoint = mapDepthToScreen(chest);
    PVector mappedLeft  = mapDepthToScreen(lHand);
    PVector mappedRight = mapDepthToScreen(rHand);
    
    this.chestPosn = new PVector(mappedJoint.x, mappedJoint.y, z);
    this.lHandPosn = mappedLeft;
    this.rHandPosn = mappedRight;
    
    // update attractor positions.
    
    leftAttractor.x = this.lHandPosn.x;
    leftAttractor.y = this.lHandPosn.y;
    
    rightAttractor.x = this.rHandPosn.x;
    rightAttractor.y = this.rHandPosn.y;
    
    // update user node positions.
    
    for (int j = 0; j < this.nodes.length; j++) {
      if (lHand.getState() == KinectPV2.HandState_Closed) {
        // repulsion
        leftAttractor.strength = attractorStrength; 
      } else {
        // attraction
        leftAttractor.strength = -attractorStrength; 
      }
      
      if (rHand.getState() == KinectPV2.HandState_Closed) {
        // repulsion
        rightAttractor.strength = attractorStrength; 
      } else {
        // attraction
        rightAttractor.strength = -attractorStrength; 
      }
      
      leftAttractor.attract(this.nodes[j]);
      rightAttractor.attract(this.nodes[j]);
  
      this.nodes[j].update();
    }
    
  }
  
  // -------------
  // ??? Functions
  // -------------
  
  void draw() {
    // TODO: could be interesting to increase strength as hands get closer. 
    float handDist = (float) euclideanDistance(this.lHandPosn, this.rHandPosn);
    
    for (int j = 0; j < this.nodes.length; j++) {
      // draw nodes
      fill(0);
      rect(this.nodes[j].x, this.nodes[j].y, 1, 1);
    }
    
    fill(255, 0, 0);
    text(this.cChestName, 50, 70);
  }
  
}