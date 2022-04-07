// define the way we add two elements
MathLambda<PVector> PVectorMath = new MathLambda<PVector>() {
  public PVector plus(PVector one, PVector two) {
    return PVector.add(one, two);
  }
  public PVector clone(PVector original) {
    return original.copy();
  }
};

// define the way we calculate gravity
class Gravity implements EquationLambda<PVector> {
  int rowB, colB;
  float mass;

  public Gravity(int x, int y, float mass) {
    rowB = y;
    colB = x;
    this.mass = mass;
  }

  public PVector calc(int rowA, int colA) {
    // grab the distance between the point and this object
    float distance = dist(rowA, colA, rowB, colB);
    // gravity = G * m1 * m2 / (distance ^ 2)
    float gravity = G * mass / (distance * SCALING * distance * SCALING);
    // find the direction the force is pointing
    int rise = rowB - rowA;
    int run = colB - colA;
    float angle = atan((float) rise / (float) run );
    if (run < 0) { // artifact of atan not being perfect
      angle += PI;
    }
    // store the result as a vector pointing with the right force in the right direction
    return new PVector(gravity * cos(angle), gravity * sin(angle));
  }
};


// The class to store the gravitational force data
class ForceMap {
  // can save processing power by not working at full resolution
  int resolution;
  // the actual array of our gravitational vectors
  JArray<PVector> array;
  // an image representation of the data
  PImage image;

  // constructors
  public ForceMap() {
    this(min(width, height));
  }

  public ForceMap(int res) {
    resolution = res;
    array = new JArray<PVector>(res, res, new PVector(), PVectorMath);
    image = createImage(res, res, RGB);
  }

  public ForceMap(Body body, int res) {
    resolution = res;
    Gravity bodyGravity = new Gravity(int(body.scaledPos.x), int(body.scaledPos.y), body.radius);
    array = new JArray<PVector>(res, res, bodyGravity, PVectorMath);
  }

  // add a new body to our simulation
  public void addBody(Body body) {
    // create a forcemap for just the body
    ForceMap bodiesMap = new ForceMap(body, resolution);
    // give a copy to the body itself
    body.saveForceMap(bodiesMap);
    // merge that map onto the existing map
    addMap(bodiesMap);
  }

  // merge the given map onto this one
  public void addMap(ForceMap two) {
    // just add the values
    array.plus(two.array, true);
    // update our image with our new data
    updateImage();
  }

  // get the force at a certain location
  public PVector getForce(float posX, float posY) {
    return array.get(int(posY), int(posX));
  }

  // helper function for drawing our image
  public color getGravityColor(PVector gravity) {
    // heading is from -PI to PI, want it to be from 0 to 100
    float direction = (gravity.heading() / TWO_PI + .5) * 100;
    float strength = constrain( 10 * sqrt(gravity.mag()), 0, 100);
    return color(direction, strength, strength );
  }

  // convert our latest gravity data into an image representation
  public void updateImage() {
    // prep work
    colorMode(HSB, 100);
    image.loadPixels();
    // loop through each pixel
    for (int r = 0; r < resolution; r++) {
      for (int c = 0; c < resolution; c++) {
        // calculate the desired gravity color for that spot
        image.pixels[r * image.width + c] = getGravityColor(array.get(r, c));
      }
    }
    // finishing work
    image.updatePixels();
    colorMode(RGB, 255);
  }

  // draw our image over the whole screen
  public void show() {
    image(image, 0, 0, width, height);
  }

  // reset everything
  public void clear() {
    array = new JArray<PVector>(resolution, resolution, new PVector(), PVectorMath);
    updateImage();
  }
}
