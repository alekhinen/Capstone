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
  
  int xCount;
  int yCount;
  
  int gridSize;
  float attractorStrength = 3;
  int nodeSize = 2;
  
  // music parameters
  
  float beatCount = 0.0;
  
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
    
    this.gridSize = Math.round(random(200, 901));
    
    xCount = Math.round(random(50, 151));
    yCount = Math.round(random(50, 151));
    
    // note: xCount * yCount
    nodes = new OriginNode[xCount*yCount];
    
    // setup node grid
    initNodeGrid();
    
    // setup attractors
    leftAttractor = new Attractor(0, 0);
    rightAttractor = new Attractor(0, 0);
  }
  
  void initNodeGrid() {
    // use a variable height and width to position the nodes randomly within the size of the screen.
    int seedHeight = Math.round(random(gridSize, height*2));
    int seedWidth  = Math.round(random(gridSize, width*2));
    
    int i = 0; 
    for (int y = 0; y < this.yCount; y++) {
      for (int x = 0; x < this.xCount; x++) {
        float xPos = x*(gridSize/(this.xCount-1))+(seedWidth-gridSize)/2;
        float yPos = y*(gridSize/(this.yCount-1))+(seedHeight-gridSize)/2;
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
    
    PVector mappedJoint = mapDepthToScreen(chest);
    PVector mappedLeft  = mapDepthToScreen(lHand);
    PVector mappedRight = mapDepthToScreen(rHand);
    
    this.chestPosn = new PVector(mappedJoint.x, mappedJoint.y, z);
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
    
    // update user node positions.
    
    for (int j = 0; j < this.nodes.length; j++) {
      if (lHand.getState() == KinectPV2.HandState_Closed) {
        // attraction
        leftAttractor.strength = -attractorStrength; 
      } else {
        // repulsion
        leftAttractor.strength = attractorStrength; 
      }
      
      if (rHand.getState() == KinectPV2.HandState_Closed) {
        // attraction
        rightAttractor.strength = -attractorStrength; 
      } else {
        // repulsion
        rightAttractor.strength = attractorStrength; 
      }
      
      leftAttractor.attract(this.nodes[j]);
      rightAttractor.attract(this.nodes[j]);
  
      this.nodes[j].update();
    }
    
    // update beat.
    
    //this.beatCount = sin( map( (this.beatCount + BPF) % 1, 0, 1, 0, (float) Math.PI ) ); 
    //this.beatCount += 1; // increment since we are in a new frame;
    //this.beatCount = sin(  );
    
    //this.nodeSize = Math.round(map(this.beatCount, 0, 1, 1, 5));
    
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
    
    // TODO: debug stuff.
    
    fill(255, 0, 0);
    text(this.beatCount, 50, 70);
  }
  
}