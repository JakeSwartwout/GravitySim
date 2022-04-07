// any body in the simulation
class Body {
  // where it is on the screen
  PVector position;
  // where it is in terms of (column, row)
  PVector scaledPos;
  float radius;
  float mass;
  color bodyColor;

  // a copy of the forcemap for this body
  ForceMap forceMap;

  // Various constructor functions
  public Body() {
    this(new PVector(0, 0), 5);
  }

  public Body(float posX, float posY, float rad) {
    this(new PVector(posX, posY), rad);
  }

  public Body(PVector pos, float rad) {
    this(pos, rad, color(255));
  }

  public Body(PVector pos, float rad, color bodColor) {
    position = pos.copy();
    scaledPos = PVector.div(position, SCALING);
    radius = rad;
    mass = rad * rad * rad;
    bodyColor = bodColor;
    forceMap = null;
  }

  // draw the body
  void show() {
    fill(bodyColor);
    stroke(0);
    strokeWeight(2);
    ellipse(position.x, position.y, radius * 2, radius * 2);
  }

  void saveForceMap(ForceMap map) {
    forceMap = map;
  }
}
