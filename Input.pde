// any User Interface/ Input elements are here

// what we're drawing
enum DrawMode {
  Body,
    Satellite
}

// Helper for all of our User Interface stuff
class UI {
  DrawMode drawMode;
  // when making a new body
  boolean makingBody;
  PVector bodyCenter;
  color latestColor;
  // remember the last satellite we launched
  Satellite lastLaunched;

  // constructors
  public UI() {
    drawMode = DrawMode.Body;
    makingBody = false;
    bodyCenter = null;
    latestColor = color(255);
    lastLaunched = null;
  }

  // when we register a click on the screen
  public void click() {
    switch(drawMode) {
    case Body:
      if (makingBody) { // if we were previously drawing a planet, place it and stop placing
        makingBody = false;
        addBody();
        latestColor = color(random(0, 255), random(0, 255), random(0, 255));
      } else { // if we weren't previously drawing a planet, start doing so
        makingBody = true;
        bodyCenter = new PVector(mouseX, mouseY);
      }
      break;
    case Satellite:
      if (makingBody) { // if we were previously placing a satellite, launch it
        makingBody = false;
        addSatellite();
      } else { // start launching a satellite
        makingBody = true;
        bodyCenter = new PVector(mouseX, mouseY);
      }
      break;
    }
  }

  // draw either the planet we're drawing or a mouse placeholder
  public void show() {
    switch(drawMode) {
    case Body:
      noStroke();
      fill(latestColor);
      if (makingBody) { // the body we're drawing
        float len = dist(bodyCenter.x, bodyCenter.y, mouseX, mouseY);
        ellipse(bodyCenter.x, bodyCenter.y, len*2, len*2);
      } else { // a mouse placeholder
        ellipse(mouseX, mouseY, 10, 10);
      }
      break;
    case Satellite:
      stroke(255);
      strokeWeight(1);
      // the direction it'll go
      if (makingBody) {
        drawSatellitePath();
        rect(bodyCenter.x - 3, bodyCenter.y - 3, 6, 6);
      } else {
        rect(mouseX - 3, mouseY - 3, 6, 6);
      }
      break;
    }
  }

  // helper function to add a new body to the simulation
  public void addBody() {
    float radius = dist(bodyCenter.x, bodyCenter.y, mouseX, mouseY);
    Body body = new Body(bodyCenter, radius, latestColor);
    g_bodies.add(body);
    g_forceMap.addBody(body);
  }

  // helper function to add a new satellite to the simulation
  public void addSatellite() {
    PVector velocity = new PVector(mouseX - bodyCenter.x, mouseY - bodyCenter.y);
    Satellite body = new Satellite(bodyCenter, velocity, color(220));
    lastLaunched = new Satellite(body);
    g_satellites.add(body);
  }

  // reset the simulation
  public void reset() {
    g_bodies = new ArrayList<Body>();
    g_satellites = new ArrayList<Satellite>();
    g_forceMap.clear();
    makingBody = false;
  }

  // clears the satellites
  public void clear() {
    g_satellites = new ArrayList<Satellite>();
  }

  // clears all satellites, re-launches the last launched satellite, and records until it dies
  public void startRecording() {
    clear();
    Satellite movieStar = pasteLast();
    g_recorder.startRecording(movieStar);
  }

  // stops the recording
  public void stopRecording() {
    g_recorder.stopRecording();
  }

  // change whether we're placing a planet or a satellite
  public void swapModes() {
    makingBody = false;
    switch(drawMode) {
    case Body:
      drawMode = DrawMode.Satellite;
      break;
    case Satellite:
      drawMode = DrawMode.Body;
      break;
    default:
      drawMode = DrawMode.Body;
      break;
    }
  }

  // trace out the expected path the satellite will take
  public void drawSatellitePath() {
    noStroke();
    fill(255);
    // start from where we clicked
    PVector currPos = PVector.div(bodyCenter, SCALING);
    // with the velocity pointing towards the mouse
    PVector currVel = new PVector(mouseX - bodyCenter.x, mouseY - bodyCenter.y);
    currVel.div(SCALING);
    // and a vector to store the unscaled position of the dot we'll draw on the screen
    PVector dotPos = bodyCenter.copy();
    // do 15 iterations
    for (int t = 0; t < 30; t++) {
      // running the same gravity calculations as in the Satellite
      for (int i = 0; i < 3; i++) {
        PVector gravity = g_forceMap.getForce(currPos.x, currPos.y);
        currVel.add( PVector.mult(gravity, dt)  );
        currPos.add( PVector.mult(currVel, dt) );
        // figure out where we are on the screen
        dotPos = PVector.mult(currPos, SCALING);
        if (dotPos.x < 0 || dotPos.x > width || dotPos.y < 0 || dotPos.y > height) {
          return; // stopping if we go off screen
        }
      }
      // drawing our dots along the way
      ellipse(dotPos.x, dotPos.y, 5, 5);
    }
  }

  public Satellite pasteLast() {
    Satellite copyOfLast = null;
    if (lastLaunched != null) {
      copyOfLast = new Satellite(lastLaunched);
      g_satellites.add(copyOfLast);
    }
    return copyOfLast;
  }
}

// built-in function called when the mouse is clicked
void mouseClicked() {
  if (!g_recorder.isRecording){
    g_ui.click();
  }
}

// built-in function called when a key is pressed
void keyPressed() {
  if (key == 'k') {
    g_ui.startRecording();
  } else if (key == 'l') {
    g_ui.stopRecording();
  } else if (!g_recorder.isRecording){
    if (key == 'r') {
      g_ui.reset();
    } else if (key == ' ') {
      g_ui.swapModes();
    } else if (key == 'c') {
      g_ui.clear();
    } else if (key == 'v') {
      g_ui.pasteLast();
    }
  } 
}
