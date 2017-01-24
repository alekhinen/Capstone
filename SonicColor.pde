class SonicColor {
  String name;
  color colorValue;
  
  SonicColor(String name, color colorValue) {
    this.name = name;
    this.colorValue = colorValue;
  }
  
  /** 
   * @description: calculates the euclidean distance between this color and a given color.
   */
  double euclideanDistance(color c) {
    float deltaR = red(colorValue) - red(c);
    float deltaG = green(colorValue) - green(c);
    float deltaB = blue(colorValue) - blue(c);
    return Math.sqrt(Math.pow(deltaR, 2) + Math.pow(deltaG, 2) + Math.pow(deltaB, 2));
  }

}