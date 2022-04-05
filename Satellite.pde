// Any moving body in the simulation
class Satellite extends Body {

  PVector scaledVel;

  boolean toBeDeleted;

  // constructors
  public Satellite(float posX, float posY, color bodyColor) {
    this(new PVector(posX, posY), new PVector(), bodyColor);
  }

  public Satellite(PVector realPosition, color bodyColor) {
    this(realPosition, new PVector(), bodyColor);
  }

  public Satellite(PVector realPosition, PVector realVelocity, color bodyColor) {
    super(realPosition, 10, bodyColor);
    scaledVel = PVector.div(realVelocity, SCALING);
    toBeDeleted = false;
  }

  public Satellite(Satellite toCopy) {
    this(toCopy.position, PVector.mult(toCopy.scaledVel, SCALING), toCopy.bodyColor);
  }

  // update everything we need to about the satellite
  public void update() {
    if (!toBeDeleted) {
      move();
      show();
    }
  }

  // move it according to the gravity map
  public void move() {
    PVector gravity = g_forceMap.getForce(scaledPos.x, scaledPos.y);
    scaledVel.add( PVector.mult(gravity, dt)  );
    scaledPos.add( PVector.mult(scaledVel, dt) );
    position = PVector.mult(scaledPos, SCALING);
    checkBounds();
  }

  // overwrite the regular constructor to draw a satellite instead
  public void show() {
    // rotate it
    pushMatrix();
    translate(position.x, position.y);
    rotate(scaledVel.heading() - HALF_PI);
    // draw the shape
    stroke(111);
    strokeWeight(10);
    line( -7, 0, 7, 0);
    stroke(0);
    strokeWeight(1);
    fill(bodyColor);
    rect(-radius / 2, -radius / 2, radius, radius);
    stroke(255);
    line(0, 0, 0, 10);
    // un-rotate it
    popMatrix();
  }

  // checks if the satellite is still in bounds
  public void checkBounds() {
    boolean outBounds = position.x < 0 || position.x > width || position.y < 0 || position.y > height;
    if (outBounds) {
      position = new PVector();
      scaledPos = new PVector();
      scaledVel = new PVector();
      toBeDeleted = true;
    }

    boolean collision = false;
    for (Body body : g_bodies) {
      float distance = dist(body.position.x, body.position.y, position.x, position.y);
      if (distance < body.radius + 2) {
        collision = true;
      }
      if (collision) {
        toBeDeleted = true;
      }
    }
  }
}
