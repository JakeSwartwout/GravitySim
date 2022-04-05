/*
Jake Swartwout
 Gravity simulation program
 Click once to choose a body center
 Click again to set the radius
 */

// Constants
final float dt = .04;
final float G = 8000;
final float SCALING = 4;

// Top-level Variables (global)
ArrayList<Body> g_bodies;
ArrayList<Satellite> g_satellites;
ForceMap g_forceMap;
UI g_ui;
Recording g_recorder;

// run once -> initialize all of our variables
void setup() {
  // set the display size and clear the background
  size(700, 700);
  background(0);
  // scale down the resolution as desired
  int RESOLUTION = int(min(width, height) / SCALING);

  // initialize our global variables
  g_bodies = new ArrayList<Body>();
  g_satellites = new ArrayList<Satellite>();
  g_forceMap = new ForceMap(RESOLUTION);
  g_ui = new UI();
  g_recorder = new Recording();
}

// run repeatedly -> used for re-drawing our screen
void draw() {
  // draw our gravity field in the background
  g_forceMap.show();

  // draw each of our planet shapes
  for (Body body : g_bodies) {
    body.show();
  }

  // draw and update our satellites, removing the dead satellites
  for ( int i = g_satellites.size()-1; i >= 0; i --) {
    g_satellites.get(i).update();
    if (g_satellites.get(i).toBeDeleted) {
      g_satellites.remove(i);
    }
  }
  
  // record the frame before drawing our UI elements
  g_recorder.tryRecord();

  // draw any necessary UI elements
  g_ui.show();
}
