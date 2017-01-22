class User {
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
    
    xCount = Math.round(random(50, 401));
    yCount = Math.round(random(50, 401));
    
    // note: xCount * yCount
    nodes = new OriginNode[xCount*yCount];
    
    // setup node grid
    initNodeGrid();
    
    // setup attractors
    leftAttractor = new Attractor(0, 0);
    rightAttractor = new Attractor(0, 0);
  }
  
  void initGrid() {
    int i = 0; 
    for (int y = 0; y < yCount; y++) {
      for (int x = 0; x < xCount; x++) {
        float xPos = x*(gridSize/(xCount-1))+(width-gridSize)/2;
        float yPos = y*(gridSize/(yCount-1))+(height-gridSize)/2;
        myNodes[i] = new OriginNode(xPos, yPos);
        myNodes[i].setBoundary(0, 0, width, height);
        myNodes[i].setDamping(0.02);  //// 0.0 - 1.0
        i++;
      }
    }
  }
  
}