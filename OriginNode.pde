public class OriginNode extends Node {
  
  float originX;
  float originY;
  float originZ;
  
  boolean isReturning;
  PVector returnVelocity = new PVector();
  
  boolean hasPriorNode = false;
  OriginNode priorNode;
  
  boolean trackAttractor = false;
  Attractor trackedAttractor;
  
  final int baseOpacity = 128;
  int toOpacity = 128;
  int opacity = 128;
  boolean triggered = false;
  
  // ------ constructors ------
  
  public OriginNode() {
  }

  public OriginNode(float theX, float theY) {
    x = theX;
    y = theY;
    
    originX = theX;
    originY = theY;
  }
  
  public OriginNode(float theX, float theY, OriginNode priorNode) {
    x = theX;
    y = theY;
    
    originX = theX;
    originY = theY;
    
    this.priorNode = priorNode;
    this.hasPriorNode = true;
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
    updateOpacity();
    
    boolean velocityStopped = (velocity.x <= 0.09 && velocity.x >= -0.09) 
      && (velocity.y <= 0.09 && velocity.y >= -0.09);
    
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
      
      if (this.trackAttractor) {
        // TODO: this came out like shit.
        //float deltaX = this.trackedAttractor.x - this.x;
        //float deltaY = this.trackedAttractor.y - this.y;
        
        //this.velocity.x += Math.sqrt(deltaX);
        //this.velocity.y += Math.sqrt(deltaY);
      }
      
      if (this.hasPriorNode && this.trackAttractor) {
        float deltaX = this.x - this.priorNode.x; // TODO: can also use velocity.
        float deltaY = this.y - this.priorNode.y;
        
        this.priorNode.x += deltaX / 2;
        this.priorNode.y += deltaY / 2;
      }
    }
  }
  
  void updateOpacity() {
    // since we are updating the toOpacity on every frame most likely, 
    // we know that whenver the opacity is above the base, the toOpacity
    // needs to stay bottomed out regardless of who is updating the value.
    if (this.opacity > this.baseOpacity || this.triggered) {
      this.toOpacity = this.baseOpacity;
    }
    
    if (this.toOpacity > this.opacity) {
      // shoot the value all the way up.
      this.opacity = this.toOpacity;
      this.triggered = true;
    } else if (this.opacity > this.toOpacity) {
      // slowly transition back down.
      this.opacity -= 25;
    } else {
      // if we've gone too far, return back to the base.
      this.opacity = this.baseOpacity;
    }
  }
  
  void resetOpacity() {
    this.toOpacity = this.baseOpacity;
    this.opacity   = this.baseOpacity;
    this.triggered = false;
  }
  
}