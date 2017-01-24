public class OriginNode extends Node {
  
  float originX;
  float originY;
  float originZ;
  
  boolean isReturning;
  PVector returnVelocity = new PVector();
  
  // ------ constructors ------
  
  public OriginNode() {
  }

  public OriginNode(float theX, float theY) {
    x = theX;
    y = theY;
    
    originX = theX;
    originY = theY;
  }

  public OriginNode(float theX, float theY, float theZ) {
    x = theX;
    y = theY;
    z = theZ;
    
    originX = theX;
    originY = theY;
    originZ = theZ;
  }

  public OriginNode(PVector theVector) {
    x = theVector.x;
    y = theVector.y;
    z = theVector.z;
    
    originX = theVector.x;
    originY = theVector.y;
    originZ = theVector.z;
  }
  
  // functions
  
  public void update() {
    boolean velocityStopped = (velocity.x <= 0.001 && velocity.x >= -0.001) 
      && (velocity.y <= 0.001 && velocity.y >= -0.001);
    
    if (isReturning) {
      x += returnVelocity.x;
      y += returnVelocity.y;
      
      returnVelocity.x *= (1-damping);
      returnVelocity.y *= (1-damping);
      
      isReturning = velocityStopped;
    } else {
      super.update();
      if (velocityStopped) {
        isReturning = true;
        
        float deltaX = originX - x;
        float deltaY = originY - y;
        
        returnVelocity.x = deltaX * damping;
        returnVelocity.y = deltaY * damping;
      }
    }
  }
}